$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host "=== Lab01 DFX / ZCU102 ===" -ForegroundColor Cyan

$vivado = Get-Command vivado.bat -ErrorAction SilentlyContinue
if (-not $vivado) { $vivado = Get-Command vivado -ErrorAction SilentlyContinue }
if (-not $vivado) {
    Write-Host "Vivado is not on PATH. Open 'Vivado 2023.2 Tcl Shell' and run:" -ForegroundColor Yellow
    Write-Host "  cd `"$Root`""
    Write-Host "  vivado -mode batch -source tcl/run_behavioral_sim.tcl"
    Write-Host "  vivado -mode batch -source tcl/create_project_skeleton.tcl"
    exit 1
}

Write-Host "[1/2] Running behavioral simulation..." -ForegroundColor Green
& $vivado.Source -mode batch -source "$Root\tcl\run_behavioral_sim.tcl"
if ($LASTEXITCODE -ne 0) { throw "Behavioral simulation failed." }

Write-Host "[2/2] Creating Vivado project skeleton..." -ForegroundColor Green
& $vivado.Source -mode batch -source "$Root\tcl\create_project_skeleton.tcl"
if ($LASTEXITCODE -ne 0) { throw "Project creation failed." }

Write-Host "Done. Open: $Root\vivado\lab01_dfx\lab01_dfx.xpr" -ForegroundColor Cyan
Write-Host "Complete the Block Design + DFX Wizard steps printed by the Tcl script." -ForegroundColor Cyan
