# Gera manifest.json: indice de todos os pacotes de prova deste repositorio.
# Uso: .\gerar-manifest.ps1  (a partir da raiz do KuaaRepo)
# Rode de novo sempre que adicionar, remover ou atualizar arquivos.
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.json |
  Where-Object { $_.Name -ne "manifest.json" }

$pacotes = @()
$totalProvas = 0
$totalQuestoes = 0
foreach ($f in ($files | Sort-Object FullName)) {
  $rel = $f.FullName.Substring($Root.Length + 1).Replace("\", "/")
  try {
    $j = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
  } catch {
    Write-Warning "ignorado (JSON invalido): $rel"
    continue
  }
  $exams = @($j.exams)
  $nq = 0
  $upd = $null
  foreach ($e in $exams) {
    $nq += @($e.questions).Count
    if ($e.updatedAt -and ($null -eq $upd -or $e.updatedAt -gt $upd)) { $upd = $e.updatedAt }
  }
  if ($null -eq $upd) { $upd = $f.LastWriteTimeUtc.ToString("o") }
  $totalProvas += $exams.Count
  $totalQuestoes += $nq
  $pacotes += [pscustomobject]@{
    caminho      = $rel
    pasta        = (Split-Path $rel -Parent)
    arquivo      = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    provas       = $exams.Count
    questoes     = $nq
    atualizadoEm = $upd
  }
}

$manifest = [pscustomobject]@{
  versao      = 1
  repositorio = "wavizo-bot/KuaaRepo"
  branch      = "main"
  geradoEm    = (Get-Date).ToUniversalTime().ToString("o")
  totais      = [pscustomobject]@{ arquivos = $pacotes.Count; provas = $totalProvas; questoes = $totalQuestoes }
  pacotes     = $pacotes
}
$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("$Root\manifest.json", ($manifest | ConvertTo-Json -Depth 6), $enc)
Write-Output "manifest.json: $($pacotes.Count) pacotes, $totalProvas provas, $totalQuestoes questoes"
