$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host "=== Lab01 DFX / ZCU102 ===" -ForegroundColor Cyan

$vivado = Get-Command vivado.bat -ErrorAction SilentlyContinue
if (-not $vivado) { $vivado = Get-Command vivado -ErrorAction SilentlyContinue }
if (-not $vivado) {
    Write-Host "Vivado is not on PATH. Open your Vivado 2026.x Tcl Shell and run:" -ForegroundColor Yellow
    Write-Host "  cd `"$Root`""
    Write-Host "  vivado -mode batch -source tcl/vivado_2026_preflight.tcl"
    Write-Host "  vivado -mode batch -source tcl/run_behavioral_sim.tcl"
    Write-Host "  vivado -mode batch -source tcl/create_project_skeleton.tcl"
    exit 1
}

Write-Host "Detected Vivado:" -ForegroundColor Cyan
& $vivado.Source -version | Select-Object -First 1

Write-Host "[1/3] Checking Vivado/ZCU102/DFX installation..." -ForegroundColor Green
& $vivado.Source -mode batch -source "$Root\tcl\vivado_2026_preflight.tcl"
if ($LASTEXITCODE -ne 0) { throw "Vivado DFX preflight failed." }

Write-Host "[2/3] Running behavioral simulation..." -ForegroundColor Green
& $vivado.Source -mode batch -source "$Root\tcl\run_behavioral_sim.tcl"
if ($LASTEXITCODE -ne 0) { throw "Behavioral simulation failed." }

Write-Host "[3/3] Creating Vivado project skeleton..." -ForegroundColor Green
& $vivado.Source -mode batch -source "$Root\tcl\create_project_skeleton.tcl"
if ($LASTEXITCODE -ne 0) { throw "Project creation failed." }

Write-Host "Done. Open: $Root\vivado\lab01_dfx\lab01_dfx.xpr" -ForegroundColor Cyan
Write-Host "Complete the Block Design + DFX definition steps printed by the Tcl script." -ForegroundColor Cyan
