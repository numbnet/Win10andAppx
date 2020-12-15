# =============Install OpenSSH Windows 10===============

####====================================================
# Create folder location
New-Item -Path $env:Temp -Name "OpenSSH" -ItemType Directory -force;

####====================================================
### Download OpenSSH
#### ---------------------------------------------------
#### ---------------------------------------------------
#### OpenSSH    --v7.9.0.0p1-Beta    --x64
#(New-Object System.Net.WebClient).DownloadFile('https://github.com/numbnet/Win10andAppx/blob/numbnet/WinModules/OpenSSH/releases/download/v7.9.0.0p1-Beta/OpenSSH-Win32.zip','$env:Temp\OpenSSH\OpenSSH-Win64.zip');
#### ---------------------------------------------------
#### OpenSSH    --v7.9.0.0p1-Beta    --x32
#(New-Object System.Net.WebClient).DownloadFile('https://github.com/numbnet/Win10andAppx/blob/numbnet/WinModules/OpenSSH/releases/download/v7.9.0.0p1-Beta/OpenSSH-Win64.zip','$env:Temp\OpenSSH\OpenSSH-Win64.zip');
#### ---------------------------------------------------
#### ---------------------------------------------------
#### OpenSSH    --v8.1.0.0p1-Beta    --x64
(New-Object System.Net.WebClient).DownloadFile('https://github.com/numbnet/Win10andAppx/blob/numbnet/WinModules/OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip','$env:Temp\OpenSSH\OpenSSH-Win64.zip');
#### ---------------------------------------------------
#### OpenSSH    --v8.1.0.0p1-Beta    --x32
#(New-Object System.Net.WebClient).DownloadFile('https://github.com/numbnet/Win10andAppx/blob/numbnet/WinModules/OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win32.zip','$env:Temp\OpenSSH\OpenSSH-Win32.zip');

####====================================================
#### Unzip the files
Expand-Archive -Path "$env:temp\OpenSSH\OpenSSH-Win64.Zip" -DestinationPath "$env:ProgramFiles\OpenSSH\";

####====================================================
#### Move \OpenSSH\OpenSSH-Win64\  \OpenSSH
copy '$env:ProgramFiles\OpenSSH\OpenSSH-Win64\*' '$env:ProgramFiles\OpenSSH';

####====================================================
####  Install service
. "$env:ProgramFiles\OpenSSH\install-sshd.ps1";

####====================================================
#### Set firewall permissions
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22;

####====================================================
#### Set service startup END
Set-Service sshd -StartupType Automatic;
Start-Service sshd;

####====================================================
#### Set Authentication to public key
((Get-Content -path $env:ProgramData\ssh\sshd_config -Raw) ` -replace '#PubkeyAuthentication yes','PubkeyAuthentication yes' ` -replace '#PasswordAuthentication yes','PasswordAuthentication yes' ` -replace 'Match Group administrators','#Match Group administrators' ` -replace 'AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys','#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content -Path $env:ProgramData\ssh\sshd_config;

####====================================================
#### Restart after changes
Restart-Service sshd;

####====================================================
#### force file creation
New-item -Path $env:USERPROFILE -Name .ssh -ItemType Directory -force;

####====================================================
#### Copy key V1:
cat $env:USERPROFILE\.ssh\nn.ed25519.key.pub | Out-File $env:USERPROFILE\.ssh\authorized_keys -Encoding ascii;
#### Copy key V1:
# echo "" | Out-File $env:USERPROFILE\.ssh\authorized_keys -Encoding ascii;
<<<<<<< HEAD

=======
>>>>>>> c1cec89f7a1ae7be36937c45f67b3d56dcf97ac6

####====================================================
#### Cleaning Dir
Remove-Item -Path $env:ProgramFiles\OpenSSH\OpenSSH-Win64 -Recurse;
Remove-Item -Path $env:Temp\OpenSSH -Recurse

####====================================================
#### Quit
exit
