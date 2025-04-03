$repoPath = "C:\Users\kccistc\Documents\GitHub\Verilog-HDL"  # 깃허브 레포지토리 클론 폴더 경로를를 지정하면 됩니당.
$gitExe = "C:\Program Files\Git\bin\git.exe"   # Git 실행 파일 경로를 지정하면 됩니당.
$vivadoPath = "C:\Xilinx\Vivado\2020.2\bin\vivado.bat"  # Vivado 실행 경로를 지정하면 됩니당.
$vivadoWorkspace = "D:\Working\FPGA_Harman_25_1" # Vivado 프로젝트 경로를 지정하면 됩니당.
$gitWorkspace = "$repoPath\code"  # 깃허브 레포지토리에 어떤 폴더에 저장할 지 적으면 됩니당.
# 위는 $repoPath에 workspace 폴더에 넣는 것. 없으면 만들어서 저장합니당.

# 아래는 건드리지 않아도 됨!!!!!


# 오늘 날짜 가져오기 (yyyy-MM-dd 형식)
$today = Get-Date -Format "yyyy-MM-dd"

# Vivado 실행
Write-Host "Vivado 2020.2 Start!!"
Start-Process -FilePath $vivadoPath -NoNewWindow -Wait

Write-Host "Vivado Closed. Checking for modified projects..."

# 수정된 날짜가 오늘인 폴더 찾기
$modifiedProjects = Get-ChildItem -Path $vivadoWorkspace -Directory #| Where-Object {
#     $_.LastWriteTime.Date -eq (Get-Date $today).Date
# }

foreach ($project in $modifiedProjects) {
    $projectName = $project.Name
    $srcPath = "$vivadoWorkspace\$project\$project.srcs"
    $destPath = "$gitWorkspace\$project.srcs"

    if (Test-Path $srcPath) {
        Write-Host "Detected Changed Project: $projectName"
        Copy-Item -Path $srcPath -Destination $gitWorkspace -Recurse -Force
    }
}

# 만약 수정된 프로젝트가 없으면 메시지 출력
if ($modifiedProjects.Count -eq 0) {
    Write-Host "Nothing has changed"
}

Write-Host "Git Auto Commit & Push Start!!"

# Git 커밋 및 푸시 수행
Set-Location -Path $repoPath

# 현재 시간 포맷 (예: 2025-03-06 15:30)
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMessage = "Auto commit for modified projects on $currentTime"

& $gitExe add .
& $gitExe commit -m $commitMessage
& $gitExe push origin main

Write-Host "Git Auto Commit & Push done."

# 3초 대기 후 PowerShell 창 종료
Start-Sleep -Seconds 3
Exit
