# Unifica cada pasta de ano E cada tema de Quiz em UM único arquivo.
# Uso: .\unificar-anos.ps1  (raiz do KuaaRepo)
# - Junta todos os *.json da pasta em um único arquivo (dedupe por id).
# - Elimina questões exatamente duplicadas (mesmo enunciado+gabarito).
# - Remove os antigos via git rm. Depois: .\gerar-manifest.ps1.
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
Set-Location $Root

$anos = @(
  @{ Pasta = "5º ano";    Arquivo = "5ano.json" },
  @{ Pasta = "6º ano";    Arquivo = "6ano.json" },
  @{ Pasta = "7º ano";    Arquivo = "7ano.json" },
  @{ Pasta = "8º ano";    Arquivo = "8ano.json" },
  @{ Pasta = "9º ano";    Arquivo = "9ano.json" },
  @{ Pasta = "1º ano EM"; Arquivo = "1ano-em.json" },
  @{ Pasta = "2º ano EM"; Arquivo = "2ano-em.json" },
  @{ Pasta = "3º ano EM"; Arquivo = "3ano-em.json" },
  @{ Pasta = "Quiz\Autoconhecimento"; Arquivo = "autoconhecimento.json" },
  @{ Pasta = "Quiz\Bem-estar"; Arquivo = "bem-estar.json" },
  @{ Pasta = "Quiz\Diversão"; Arquivo = "diversao.json" },
  @{ Pasta = "Quiz\Relacionamentos"; Arquivo = "relacionamentos.json" }
)

foreach ($a in $anos) {
  $dir = Join-Path $Root $a.Pasta
  if (-not (Test-Path -LiteralPath $dir)) { continue }
  $fontes = @(Get-ChildItem -LiteralPath $dir -File -Filter *.json)
  if ($fontes.Count -le 1) { Write-Output "$($a.Pasta): já unificado"; continue }

  $exames = @()
  $idsVistos = @{}
  $idsDup = 0
  $format = "kuaa/estudante"
  foreach ($f in ($fontes | Sort-Object Name)) {
    $j = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($j.format) { $format = $j.format }
    foreach ($e in $j.exams) {
      if ($idsVistos.ContainsKey($e.id)) { $idsDup++; continue }
      $idsVistos[$e.id] = $true
      $exames += $e
    }
  }

  # Dedupe de questões idênticas dentro do ano (normaliza enunciado+gabarito)
  $qsVistas = @{}
  $qsDup = 0
  foreach ($e in $exames) {
    $unicas = @()
    foreach ($q in @($e.questions)) {
      $txt = ""
      if ($q.text) { $txt = ([string]$q.text -replace "\s+", " ").Trim().ToLower() }
      $gab = ""
      if ($q.correct) { $gab = [string]$q.correct }
      $alts = @(@($q.alternatives) | ForEach-Object { ([string]$_.text -replace "\s+", " ").Trim().ToLower() }) -join " ## "
      $pts = ""
      try { $pts = (@($q.alternatives) | ForEach-Object { ($_ | ConvertTo-Json -Compress) }) -join " ## " } catch { $pts = "" }
      $chave = "$txt|$gab|$alts|$pts"
      if ($qsVistas.ContainsKey($chave)) { $qsDup++; continue }
      $qsVistas[$chave] = $true
      $unicas += $q
    }
    $e.questions = @($unicas)
  }
  $exames = @($exames | Where-Object { @($_.questions).Count -gt 0 })
  $totQ = 0
  foreach ($e in $exames) { $totQ += @($e.questions).Count }

  $dest = Join-Path $dir $a.Arquivo
  $pacote = @{ format = $format; createdAt = (Get-Date).ToUniversalTime().ToString("o"); exams = @($exames) }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($dest, ($pacote | ConvertTo-Json -Depth 20), $enc)

  foreach ($f in $fontes) { git rm -q $f.FullName }
  git add $dest
  Write-Output "$($a.Pasta): $($fontes.Count) arqs -> $($a.Arquivo) | provas=$($exames.Count) questoes=$totQ ids-dup=$idsDup questoes-dup=$qsDup"
}

Write-Output "Unificação concluída. Rode .\gerar-manifest.ps1 em seguida."
