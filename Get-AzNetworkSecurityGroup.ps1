# Short script to export all NSGs rules from subscriptions with the ability to select a specific subscription.
# This PowerShell script is designed to export all Network Security Group (NSG) rules from Azure subscriptions. It provides the ability to select a specific subscription if needed.
# The script starts by getting all Azure subscriptions. The Get-AzSubscription cmdlet is used to fetch all subscriptions, and the Out-GridView cmdlet is used to display these subscriptions in a grid view, allowing the user to select a specific subscription if desired.
# The script then iterates over each subscription using a foreach loop. For each subscription, it sets the current context to that subscription using the Set-AzContext cmdlet. The subscription name is also stored in the $azSubName variable.
# Next, the script fetches all NSGs within the current subscription context using the Get-AzNetworkSecurityGroup cmdlet. It filters out any NSGs that do not have an ID (i.e., where Id is null).
# The script then iterates over each NSG using another foreach loop. For each NSG, it exports both custom and default rules. The Get-AzNetworkSecurityRuleConfig cmdlet is used to fetch the rules, and the Select-Object cmdlet is used to select specific properties of each rule. These properties are then exported to a CSV file using the Export-Csv cmdlet.
# The properties exported for each rule include the NSG name, location, rule name, source address prefix, source application security group, source port range, access, priority, direction, protocol, destination address prefix, destination application security group, destination port range, resource group name, NIC assignment name, and subnet assignment name.
# The script uses the -Append and -Force parameters with the Export-Csv cmdlet to append to the existing CSV file and overwrite it if it already exists, respectively. The -NoTypeInformation parameter is used to prevent the output of type information to the CSV file.
# In summary, this script provides a handy way to export all NSG rules from Azure subscriptions to a CSV file for further analysis or documentation purposes.


#! Get all Azure Subscriptions
# $azSubs = Get-AzSubscription

#! Use the following if you want to select a specific Azure Subscription
$azSubs = Get-AzSubscription | Out-Gridview -PassThru -Title 'Select Azure Subscription'

foreach ( $azSub in $azSubs ) 
Set-AzContext -Subscription $azSub | Out-Null
$azSubName = $azSub.Name

$azNsgs = Get-AzNetworkSecurityGroup | Where-Object {$_.Id -ne $NULL}

foreach ( $azNsg in $azNsgs ) {
    # Export custom rules
    Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
    @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
    @{label = 'Rule Name'; expression = { $_.Name } }, `
    @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
    @{label = 'Source Application Security Group'; expression = { foreach ($Asg in $_.SourceApplicationSecurityGroups) {$Asg.id.Split('/')[-1]} } }, `
    @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, Protocol, `
    @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
    @{label = 'Destination Application Security Group'; expression = { foreach ($Asg in $_.DestinationApplicationSecurityGroups) {$Asg.id.Split('/')[-1]} } }, `
    @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
    @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } }, `
    @{label = 'NIC Assignment Name'; expression = { $azNsg.NetworkInterfaces.Id.split('/')[-1] } }, `
    @{label = 'Subnet Assignment Name'; expression = { $azNsg.Subnets.Id.split('/')[-1] } } | `
    Export-Csv -Path ".\Azure-nsg-rules.csv" -NoTypeInformation -Append -force
    
    # Export default rules
    Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg -Defaultrules | `
    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
    @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
    @{label = 'Rule Name'; expression = { $_.Name } }, `
    @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
    @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, Protocol, `
    @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
    @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
    @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } }, `
    @{label = 'NIC Assignment Name'; expression = { $azNsg.NetworkInterfaces.Id.split('/')[-1] } }, `
    @{label = 'Subnet Assignment Name'; expression = { $azNsg.Subnets.Id.split('/')[-1] } } | `
    Export-Csv -Path ".\Azure-nsg-rules.csv" -NoTypeInformation -Append -force
    
    }