#!/bin/bash
# Windows 安装脚本 for Claude Code Source
# 使用方法: 在 PowerShell 中运行 .\install.ps1

# 检测是否是 Windows
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    Write-Host "检测到 Windows 系统" -ForegroundColor Green
} else {
    Write-Host "请在 Windows 系统上运行此脚本" -ForegroundColor Red
    exit 1
}

# 检查 PowerShell 版本
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "建议使用 PowerShell 7+ (https://aka.ms/powershell)" -ForegroundColor Yellow
}

Write-Host "`n=== Claude Code Source - Windows 安装 ===" -ForegroundColor Cyan

# 1. 检查并安装 Bun
Write-Host "`n[1/4] 检查 Bun..." -ForegroundColor Yellow
$bunPath = Get-Command bun -ErrorAction SilentlyContinue
if (-not $bunPath) {
    Write-Host "未找到 Bun，正在安装..." -ForegroundColor Yellow
    # 使用 PowerShell 安装 Bun
    irm get.bun.sh | iex
    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
} else {
    Write-Host "Bun 已安装: $($bunPath.Source)" -ForegroundColor Green
}

# 验证 Bun 安装
$bunVersion = bun --version 2>$null
if (-not $bunVersion) {
    Write-Host "Bun 安装失败，请手动安装: https://bun.sh" -ForegroundColor Red
    exit 1
}
Write-Host "Bun 版本: $bunVersion" -ForegroundColor Green

# 2. 安装项目依赖
Write-Host "`n[2/4] 安装项目依赖..." -ForegroundColor Yellow
bun install

if ($LASTEXITCODE -ne 0) {
    Write-Host "依赖安装失败" -ForegroundColor Red
    exit 1
}
Write-Host "依赖安装完成" -ForegroundColor Green

# 3. 构建项目
Write-Host "`n[3/4] 构建项目..." -ForegroundColor Yellow
bun run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "构建失败" -ForegroundColor Red
    exit 1
}
Write-Host "构建完成" -ForegroundColor Green

# 4. 创建快捷启动方式
Write-Host "`n[4/4] 配置启动方式..." -ForegroundColor Yellow

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 添加到 PATH（可选）
$addToPath = Read-Host "是否将此项目添加到用户 PATH? (y/N)"
if ($addToPath -eq "y" -or $addToPath -eq "Y") {
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $newPath = "$currentPath;$ScriptDir"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "已添加到 PATH" -ForegroundColor Green
}

Write-Host "`n=== 安装完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用方法:" -ForegroundColor White
Write-Host "  开发模式: bun run dev" -ForegroundColor Gray
Write-Host "  构建生产: bun run build" -ForegroundColor Gray
Write-Host "  运行 CLI: .\cli" -ForegroundColor Gray
Write-Host ""
Write-Host "注意: Windows 环境下建议使用 PowerShell 7" -ForegroundColor Yellow