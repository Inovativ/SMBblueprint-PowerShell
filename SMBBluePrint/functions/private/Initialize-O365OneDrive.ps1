function Initialize-O365OneDrive
{
    [cmdletbinding()]
    param(
     [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Users,
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Credential,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $SPOAdminUrl
        )
        begin {
            $arch = ""
            if($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){
                $arch = 64
            } else {
                $arch = 32
            }
            $null = add-type -path "$global:root\assemblies\$arch\Microsoft.SharePoint.Client.Runtime.dll"
            $null = add-type -path "$global:root\assemblies\$arch\Microsoft.SharePoint.Client.dll"
            $null = add-type -path "$global:root\assemblies\$arch\Microsoft.SharePoint.Client.UserProfiles.dll"
            $null = add-type -path "$global:root\assemblies\$arch\Microsoft.Online.SharePoint.Client.Tenant.dll"
           

            $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SPOAdminUrl)
            $web = $ctx.Web
            $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName,$Credential.Password)
            $ctx.Load($web)
            $ctx.ExecuteQuery()
            $loader = [Microsoft.SharePoint.Client.UserProfiles.ProfileLoader]::GetProfileLoader($ctx)
            $ctx.ExecuteQuery()




               
        }
        process {

            Try
            {
                write-log -message "Provisioning Onedrive for $($Users.count) users"
                $loader.CreatePersonalSiteEnqueueBulk($Users)
                $loader.Context.ExecuteQuery()

                #throw "Test Exception"
                #Connect-SPOService -Url $SPOAdminUrl -Credential $Credential
                #Request-SPOPersonalSite -UserEmails $Users -NoWait


            }

            Catch

            {
            throw "Cannot provision one drive for users: $_"

            }
        }




}