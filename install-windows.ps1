# Claude Code Source - Windows 安装脚本 (优化版)
# 使用方法: PowerShell 中运行 .\install-windows.ps1

# 检测 Windows
if (-not ($IsWindows -or $env:OS -eq "Windows_NT")) {
    Write-Host "请在 Windows 系统上运行此脚本" -ForegroundColor Red
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Claude Code Source - Windows 安装" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. 检查并安装/升级 Bun
# ============================================
Write-Host "[1/5] 检查 Bun..." -ForegroundColor Yellow

$bunVersion = $null
try {
    $bunVersion = bun --version 2>$null
} catch {
    $null = $null
}

if (-not $bunVersion) {
    Write-Host "未找到 Bun，正在安装..." -ForegroundColor Yellow
    powershell -Command "irm get.bun.sh | iex"
    # 刷新环境变量后重试
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    Start-Sleep -Seconds 2
    $bunVersion = bun --version 2>$null
}

if (-not $bunVersion) {
    Write-Host "Bun 安装失败，请手动安装: https://bun.sh" -ForegroundColor Red
    Write-Host "安装完成后重新运行此脚本" -ForegroundColor Yellow
    Read-Host "按回车退出"
    exit 1
}

Write-Host "当前 Bun 版本: $bunVersion" -ForegroundColor White

# 检查版本是否需要升级
$versionParts = $bunVersion -split '\.'
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2]

if ($major -lt 1 -or ($major -eq 1 -and $minor -lt 3) -or ($major -eq 1 -and $minor -eq 3 -and $patch -lt 11)) {
    Write-Host "版本过旧 (需要 >= 1.3.11)，正在升级..." -ForegroundColor Yellow
    powershell -Command "irm get.bun.sh | iex"
    Start-Sleep -Seconds 2
    $bunVersion = bun --version 2>$null
    Write-Host "升级后版本: $bunVersion" -ForegroundColor Green
}

# ============================================
# 2. 安装依赖
# ============================================
Write-Host ""
Write-Host "[2/5] 安装项目依赖..." -ForegroundColor Yellow

bun install
if ($LASTEXITCODE -ne 0) {
    Write-Host "依赖安装失败" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}
Write-Host "依赖安装完成" -ForegroundColor Green

# ============================================
# 3. 尝试构建 (带错误处理)
# ============================================
Write-Host ""
Write-Host "[3/5] 尝试构建项目..." -ForegroundColor Yellow

$buildSuccess = $false
try {
    bun run build 2>&1 | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -eq 0) {
        $buildSuccess = $true
        Write-Host "构建成功!" -ForegroundColor Green
    }
} catch {
    Write-Host "构建过程出现异常: $_" -ForegroundColor Red
}

# 如果构建失败，尝试 dev 模式
if (-not $buildSuccess) {
    Write-Host ""
    Write-Host "构建失败，尝试使用开发模式..." -ForegroundColor Yellow

    # 检查是否有 cli-dev
    if (Test-Path "$ScriptDir\cli-dev") {
        Write-Host "找到预编译的 cli-dev，可以直接运行" -ForegroundColor Green
    } else {
        Write-Host "注意: 开发模式需要保持终端连接" -ForegroundColor Yellow
    }
}

# ============================================
# 4. 配置环境
# ============================================
Write-Host ""
Write-Host "[4/5] 配置环境..." -ForegroundColor Yellow

# 检查是否有 .env 文件
if (-not (Test-Path "$ScriptDir\.env")) {
    Write-Host "提示: 可以创建 .env 文件设置 ANTHROPIC_API_KEY" -ForegroundColor Cyan
}

Write-Host "环境配置完成" -ForegroundColor Green

# ============================================
# 5. 显示使用方法
# ============================================
Write-Host ""
Write-Host "[5/5] 安装完成!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "使用方法:" -ForegroundColor White
Write-Host ""
Write-Host "  方式1 - 开发模式 (推荐):" -ForegroundColor Gray
Write-Host "    bun run dev" -ForegroundColor White
Write-Host ""
Write-Host "  方式2 - 直接运行 cli-dev:" -ForegroundColor Gray
Write-Host "    .\cli-dev" -ForegroundColor White
Write-Host ""
Write-Host "  方式3 - 构建后运行:" -ForegroundColor Gray
Write-Host "    bun run build" -ForegroundColor White
Write-Host "    .\cli" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# 询问是否立即运行
Write-Host ""
$runNow = Read-Host "是否立即运行? (y/N)"
if ($runNow -eq "y" -or $runNow -eq "Y") {
    Write-Host ""
    Write-Host "启动开发模式... (按 Ctrl+C 退出)" -ForegroundColor Yellow
    Write-Host ""
    bun run dev
}