# escape=`

# use the lastest Windows Server Core image with Powershell support
FROM mcr.microsoft.com/windows/servercore:20H2

# Restore the default Windows shell for correct batch processing
SHELL ["cmd", "/S", "/C"]

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Install Build Tools with the Microsoft.VisualStudio.Workload.VCTools workload, including the recommend components.
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended `
    --add Microsoft.VisualStudio.Component.Git `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Install package manager
#RUN powershell.exe -ExecutionPolicy RemoteSigned `
#  iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
RUN powershell.exe iwr get.scoop.sh -outfile 'C:\TEMP\install.ps1' && `
    powershell.exe -ExecutionPolicy RemoteSigned C:\TEMP\install.ps1 -RunAsAdmin

# Install task
RUN scoop install task

# Define the entry point for the docker container.  
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
