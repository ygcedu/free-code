@echo off
REM Claude Code Source - Windows 安装脚本 (简化版)
REM 使用方法: 双击运行 或 在 CMD 中运行 install-windows.bat

echo ====================================
echo Claude Code Source - Windows 安装
echo ====================================
echo.

REM 检查 Bun
where bun >/dev/null 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 未找到 Bun，正在安装...
    powershell -Command "irm get.bun.sh | iex"
    echo 请重新运行此脚本
    pause
    exit /b 1
)

echo Bun 已安装

REM 安装依赖
echo.
echo [1/3] 安装依赖...
call bun install
if %ERRORLEVEL% NEQ 0 (
    echo 依赖安装失败
    pause
    exit /b 1
)

REM 尝试构建（可能失败）
echo.
echo [2/3] 尝试构建...
call bun run build 2>/dev/null
if %ERRORLEVEL% EQU 0 (
    echo 构建成功!
    goto :run_cli
)

echo 构建失败，将使用开发模式

:run_cli
echo.
echo [3/3] 安装完成
echo.
echo ====================================
echo 使用方法:
echo.
echo   开发模式: bun run dev
echo   直接运行: .\cli-dev
echo   构建版本: bun run build ^&^& .\cli
echo ====================================
echo.
set /p choice="是否立即运行开发模式? (y/n): "
if /i "%choice%"=="y" (
    echo.
    echo 启动开发模式...
    bun run dev
)
