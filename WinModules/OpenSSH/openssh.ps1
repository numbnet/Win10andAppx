## ====== Install OpenSSH Win10 ======

## =============== ≠≠≠ ===============
##  Variable
$SSHkeyPUBSSHKEPUB = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp3bxeApwQec9N6DaIP1Iq3o7Ks4jcL66wHi1YdqkFC root'




## =============== ≠≠≠ ===============
##  Start as Administrator
param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
	if ($elevated) 
	{
# tried to elevate, did not work, aborting
	}
	else {
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
	}
exit
}


#########  INSTALL OPENSSH  #########
## =============== ≠≠≠ ===============
##      Add New Directory
New-Item -Path "$env:SYSTEMDRIVE\" -Name "PS\OpenSSH" -ItemType Directory -force;

## =============== ≠≠≠ ===============
## Определяем Архитектуру x64 x86
If([IntPtr]::Size -eq 4)
{
Write-Host "Windows x86";   # OpenSSH x32
echo "##------ v8.1.0.0p1-Beta ------"
Invoke-WebRequest -Uri "https://github.com/numbnet/Win10andAppx/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win32.zip" -OutFile "$env:SYSTEMDRIVE\PS\OpenSSH\OpenSSH-Win32.zip"

## =============== ≠≠≠ ===============
echo "======= Unzip the files ========="
Expand-Archive -Path $env:SYSTEMDRIVE\PS\OpenSSH\OpenSSH-Win32.Zip -DestinationPath $env:ProgramFiles\OpenSSH\;

copy $env:ProgramFiles\OpenSSH\OpenSSH-Win32\* $env:ProgramFiles\OpenSSH;

}
    Else
{
    Write-Host "Windows x64";
## =============== ≠≠≠ ===============
## ВЫПОЛНЯЕМ ДЛЯ Windows x64

##---------v8.1.0.0p1-Beta-----------
Invoke-WebRequest -Uri "https://github.com/numbnet/Win10andAppx/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip" -OutFile "$env:SYSTEMDRIVE\PS\OpenSSH\OpenSSH-Win64.zip"


## =============== ≠≠≠ ===============
echo "======== Unzip the files ========"
Expand-Archive -Path "$env:SYSTEMDRIVE\PS\OpenSSH\OpenSSH-Win64.Zip" -DestinationPath "$env:ProgramFiles\OpenSSH\";

## =============== ≠≠≠ ===============
echo "===== Copy \OpenSSH\OpenSSH-Win64\  \OpenSSH ======"
copy $env:ProgramFiles\OpenSSH\OpenSSH-Win64\* $env:ProgramFiles\OpenSSH;

}


##================= ≠≠≠ =================
echo "========= Install service ========="
. "$env:ProgramFiles\OpenSSH\install-sshd.ps1"

##================= ≠≠≠ =================
echo "========= Set firewall permissions= ====="
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22;

##================= ≠≠≠ =================
echo "======= Set service startup END"
Set-Service sshd -StartupType Automatic | Start-Service sshd;

##================= ≠≠≠ =================
echo "====== Set Authentication to public key"
((Get-Content -path $env:ProgramData\ssh\sshd_config -Raw) ` -replace '#PubkeyAuthentication yes','PubkeyAuthentication yes' ` -replace '#PasswordAuthentication yes','PasswordAuthentication yes' ` -replace 'Match Group administrators','#Match Group administrators' ` -replace 'AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys','#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content -Path $env:ProgramData\ssh\sshd_config;

##================= ≠≠≠ =================
echo "====== Restart after changes"
Restart-Service sshd;

##================= ≠≠≠ =================
echo "=============== force file creation"
New-item -Path $env:USERPROFILE -Name .ssh -ItemType Directory -force;


##########################################
## Для начала посмотрим имя ПК
$env:COMPUTERNAME

## смена имени с перезагрузкой
# Rename-Computer -NewName "NNL" -Restart

## Перейменование без перезагпузки
Rename-Computer -NewName "NNL"

## А можно и позже командой 
## - Restart-Computer

## После перезагрузки проверьте имя ПК:
$env:COMPUTERNAMERename-Computer -NewName "NNL" -Restart



##================= ≠≠≠ =================
##=== Generation NEW SSH-KEY Var1
ssh-keygen -t ed25519 -C "$env:USERNAME" -f "$env:USERPROFILE\.ssh\$env:COMPUTERNAME.$env:USERNAME.ed25519.key";
##=== Generation NEW SSH-KEY Var2 Random
# ssh-keygen -t ed25519 -C "$env:USERNAME" -f $env:USERPROFILE\.ssh\$env:COMPUTERNAME.$(Get-Random).ed25519.key


## =============== ≠≠≠ ===============
##=== If Have SSH-KEY var1
echo "$SSHkeyPUB" | Out-File $env:USERPROFILE\.ssh\authorized_keys -Encoding ascii;

##===== Copy SSH-KEY var2
#cat $env:USERPROFILE\.ssh\*$env:COMPUTERNAME.$env:USERNAME.ed25519.key.pub | Out-File $env:USERPROFILE\.ssh\authorized_keys -Encoding ascii;



##================= ≠≠≠ =================
##===== Cleaning 
Remove-Item -Path $env:SYSTEMDRIVE\PS\OpenSSH -Recurse;
If([IntPtr]::Size -eq 4)
{
Write-Host "If Windows x86 ... ";
Remove-Item -Path $env:ProgramFiles\OpenSSH\OpenSSH-Win32 -Recurse;
}
    Else
{
Write-Host "If Windows x64 ... ";
Remove-Item -Path $env:ProgramFiles\OpenSSH\OpenSSH-Win64 -Recurse;
}

echo "OpenSSH is installed........."

##================= ≠≠≠ =================
exit







##================= ≠≠≠ =================
##================= INFO =================
##  Variant 1
# if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "64*")
# {Write "Windows x64";}
# else
# {Write "Windows x86";}

##================= ≠≠≠ =================
##  Variant 2
# If([IntPtr]::Size -eq 4)
# { Write-Host "32 bit"; }
# Else
# { Write-Host "64 bit"; }
