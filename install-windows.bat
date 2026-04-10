@echo off
REM Windows 安装脚本 for Claude Code Source (简化版)
REM 使用方法: 将此脚本放在项目根目录，双击运行

echo ====================================
echo Claude Code Source - Windows 安装
echo ====================================
echo.

REM 检查 Bun
where bun >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 未找到 Bun，正在安装...
    powershell -Command "irm get.bun.sh | iex"
) else (
    echo Bun 已安装
)

REM 安装依赖
echo.
echo [1/2] 安装依赖...
call bun install
if %ERRORLEVEL% NEQ 0 (
    echo 依赖安装失败
    pause
    exit /b 1
)

REM 构建
echo.
echo [2/2] 构建项目...
call bun run build
if %ERRORLEVEL% NEQ 0 (
    echo 构建失败
    pause
    exit /b 1
)

echo.
echo ====================================
echo 安装完成！
echo.
echo 使用方法:
echo   bun run dev   - 开发模式
echo   bun run build - 构建
echo   .\cli         - 运行 CLI
echo ====================================
pause