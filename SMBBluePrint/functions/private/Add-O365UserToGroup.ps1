function Add-O365UserToGroup
{
	param(
	[Parameter(Mandatory=$true,
	ValueFromPipelineByPropertyName=$true)]
	[ValidateNotNullOrEmpty()]

	[string]$Username,

	[Parameter(Mandatory=$true,
	ValueFromPipelineByPropertyName=$true)]
	
	[string]$groupname,
	[ValidateSet('office','security')]
	[string] $Type = 'security'



	)
	Try
	{
		if($Type -eq 'security'){
			$group = Get-MsolGroup -searchstring $groupname
			$members = Get-MsolGroupMember -GroupObjectId $group.objectid
			$exists = 0
			foreach ($member in $members)
			{
				if ($member.displayname -eq $username){
					write-log -message "User $username is already member of the group $groupname" -Type Information
					$exists = 1
				}

			}

			if ($exists -eq 0)
			{
				$user = Get-MsolUser -SearchString $username
				$null = Add-MsolGroupMember -GroupObjectId $group.objectid -GroupMemberObjectId $user.objectid -GroupMemberType User
				write-log -Message "Added user $username to group $($groupname)"
			}
		} elseif($type -eq 'office'){
			$username = $Username.split('@')[0]
			$members = get-unifiedgrouplinks -identity $groupname -linktype members
			$found = $false
			foreach($member in $members){
				if($member.name -eq $Username){
					$found = $true
					break
				}
			}
			if($found -eq $true){
				write-log "User '$UserName' is already member of the Office Group '$GroupName'"
			} else {
				$OK = $false
				while($OK -eq $false){
					try{
						write-log -type verbose -message "Attempting to add '$UserName' to group '$groupname'"
						while((get-user -ErrorAction Ignore -Identity $UserName) -eq $null){

						}
						$null = Add-UnifiedGroupLinks -LinkType members -Identity $groupname -Links $Username
						
						$OK = $true
					} catch {
						if($_.Exception.Message -like "*Couldn't find object*"){} else {throw $_}
					}

				}
				write-log "User '$UserName' is now member of the Office Group '$GroupName'"
				
			}
			
		}




	}

	Catch
	{
		throw "Cannot add User $username to group $($groupname): $_"

	}




}