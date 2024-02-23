# NSGexport

This PowerShell script is used to retrieve information about Network Security Groups (NSGs) and their rules in Azure, and then export that information to a CSV file.

Here's a step-by-step explanation:

$azNsgs = Get-AzNetworkSecurityGroup: This line retrieves all the NSGs in your Azure subscription and stores them in the $azNsgs variable.

foreach ($azNsg in $azNsgs): This line starts a loop that iterates over each NSG stored in $azNsgs.

Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg: This line retrieves the security rules for the current NSG in the loop.

Select-Object ...: This line selects specific properties from each security rule and creates a custom object with those properties.

Export-Csv -Path "$($home)\tf\nsg-rules.csv" -NoTypeInformation -Append -force: This line exports the custom objects to a CSV file. The -Append flag is used to add the data to the existing file instead of overwriting it.

The script does this twice for each NSG: once for the custom rules and once for the default rules. The only difference between the two blocks of code is the -Defaultrules flag in the second Get-AzNetworkSecurityRuleConfig command, which indicates that the default rules should be retrieved instead of the custom rules.
