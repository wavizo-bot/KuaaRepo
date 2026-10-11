# Reorganiza o KuaaRepo: EF/EM por ANO (não por matéria) + Quiz por TEMA.
# Uso: .\reorganizar-anos.ps1  (a partir da raiz do KuaaRepo, uma vez por publicação)
# - Move "Fundamental e Médio/*.json" para "5º ano".."3º ano EM" pelo role da prova.
# - Extrai do initial-student-package.json (msix-app) só os exames NOVOS
#   (os que ainda não estão neste repo) para o ano correspondente.
# - Move "Quiz/*.json" para "Quiz/<Tema>" pela tabela abaixo.
# Depois rode .\gerar-manifest.ps1, confira, commit + push.
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
Set-Location $Root

function Ano-DoRole([string]$role) {
  if ($role -match "5º EF") { return "5º ano" }
  if ($role -match "6º EF") { return "6º ano" }
  if ($role -match "7º EF") { return "7º ano" }
  if ($role -match "8º EF") { return "8º ano" }
  if ($role -match "9º EF") { return "9º ano" }
  if ($role -match "1º EM") { return "1º ano EM" }
  if ($role -match "2º EM") { return "2º ano EM" }
  if ($role -match "3º EM") { return "3º ano EM" }
  return $null
}

# 1) EF/EM por ano (via git mv, preserva histórico)
$origemFM = Join-Path $Root "Fundamental e Médio"
if (Test-Path -LiteralPath $origemFM) {
  Get-ChildItem -LiteralPath $origemFM -File -Filter *.json | ForEach-Object {
    $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $anos = @($j.exams | ForEach-Object { Ano-DoRole $_.role } | Where-Object { $_ } | Sort-Object -Unique)
    if ($anos.Count -eq 0) {
      # Sem ano no role (ex.: portugues_banco_sintetico, role "Estudante"):
      # gramática normativa nível EM/vestibular -> 3º ano EM (presunção documentada).
      $anos = @("3º ano EM")
    }
    if ($anos.Count -eq 1) {
      $dest = Join-Path $Root $anos[0]
      if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
      git mv $_.FullName (Join-Path $dest $_.Name)
    } else {
      # Arquivo com provas de anos distintos: divide um arquivo por ano.
      foreach ($ano in $anos) {
        $parte = @{ format = $j.format; createdAt = $j.createdAt; exams = @($j.exams | Where-Object { (Ano-DoRole $_.role) -eq $ano }) }
        $dest = Join-Path $Root $ano
        if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
        $nome = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + "-" + ($ano -replace "º ano ?", "" -replace " ", "") + ".json"
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText((Join-Path $dest $nome), ($parte | ConvertTo-Json -Depth 20), $enc)
        git add (Join-Path $dest $nome)
      }
      git rm -q $_.FullName
    }
  }
  $restam = @(Get-ChildItem -LiteralPath $origemFM -File -ErrorAction SilentlyContinue)
  if ($restam.Count -eq 0) { Remove-Item -LiteralPath $origemFM -Force }
}

# 2) Novidades do pacote inicial (só exames que ainda NÃO estão no repo)
$initPath = "C:\APPS\Kuaa\msix-app\initial-student-package.json"
if (Test-Path -LiteralPath $initPath) {
  $existentes = @{}
  Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.json |
    Where-Object { $_.Name -ne "manifest.json" } | ForEach-Object {
      $jj = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
      foreach ($e in $jj.exams) { $existentes[$e.id] = $true }
    }
  $init = Get-Content $initPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $novos = @($init.exams | Where-Object { -not $existentes.ContainsKey($_.id) -and (Ano-DoRole $_.role) })
  $grupos = $novos | Group-Object { Ano-DoRole $_.role }
  $mapaNome = @{ "8º ano" = "pacote-inicial-8ano.json"; "9º ano" = "pacote-inicial-9ano.json"; "1º ano EM" = "pacote-inicial-1em.json" }
  foreach ($g in $grupos) {
    $nome = $mapaNome[$g.Name]
    if (-not $nome) { $nome = "pacote-inicial.json" }
    $dest = Join-Path (Join-Path $Root $g.Name) $nome
    if (Test-Path -LiteralPath $dest) { Write-Output "já existe, mantido: $($g.Name)/$nome"; continue }
    $pacote = @{ format = "kuaa/estudante"; createdAt = (Get-Date).ToUniversalTime().ToString("o"); exams = @($g.Group) }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($dest, ($pacote | ConvertTo-Json -Depth 20), $enc)
    git add $dest
    Write-Output "novo: $($g.Name)/$nome ($($g.Count) provas)"
  }
}

# 3) Quiz por tema
$temas = @{
  "Relacionamentos" = @(
    "Como você se comporta em relacionamentos afetivos.json",
    "Qual é a sua linguagem oculta para lidar com conflitos.json",
    "Qual é a sua postura real diante da vulnerabilidade afetiva.json",
    "Qual é a sua verdadeira moeda de troca nas relações.json",
    "Qual é o seu método para lidar com encrencas e conflitos.json",
    "Qual ferida da infância você trouxe para o amor.json",
    "Qual seu papel numa briga de casal.json",
    "Qual seu tipo de amor tóxico preferido.json",
    "Qual sua linguagem de evitação do amor.json",
    "Qual tipo de namorado-a você é.json",
    "Qual tipo de pessoa você atrai e por quê.json",
    "Que tipo de âncora você representa nas suas amizades.json",
    "Que tipo de filme de terror é seu relacionamento atual.json",
    "Você sabe reconhecer bandeiras na vida real.json"
  )
  "Autoconhecimento" = @(
    "O que a sua irritação com os outros revela sobre a sua Sombra.json",
    "O que a sua relação com o tempo diz sobre a sua urgência de vida.json",
    "O que você está projetando nos outros.json",
    "Quais padrões tóxicos você repete sem perceber.json",
    "Qual ambição oculta está guiando suas escolhas atuais.json",
    "Qual é a sua relação com o controle e a incerteza.json",
    "Qual é a sua relação invisível com o sucesso.json",
    "Qual é o seu mecanismo de defesa predominante diante da frustração.json",
    "Qual é o seu medo primário oculto.json",
    "Qual é o seu modelo mental de tomada de decisão sob pressão.json",
    "Qual é o seu sabotador profissional secreto.json",
    "Qual fase de vida sua mente está vivendo no momento.json",
    "Qual herança emocional dos seus pais mais guia suas escolhas atuais.json"
  )
  "Bem-estar" = @(
    "Como é a sua bateria social segundo o reino animal.json",
    "Como está o seu nível invisível de esgotamento burnout.json",
    "Qual animal reflete seu nível de energia e ritmo de vida.json",
    "Qual é a sua tolerância real ao desconforto e ao tédio.json",
    "Qual é o seu perfil de adaptabilidade alimentar e de rotina.json"
  )
  "Diversão" = @(
    "Qual das Meninas Superpoderosas você seria.json",
    "Qual doce traduz sua forma de lidar com a vida.json",
    "Qual docinho de festa você é.json",
    "Qual mulher icônica das telas você seria.json",
    "Qual tipo de apocalipse você estaria mais preparado(a) para enfrentar.json",
    "Se você fosse algo esquecido em casa, o que seria.json"
  )
}
$quizDir = Join-Path $Root "Quiz"
foreach ($tema in $temas.Keys) {
  $dest = Join-Path $quizDir $tema
  if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
  foreach ($arq in $temas[$tema]) {
    $orig = Join-Path $quizDir $arq
    if (Test-Path -LiteralPath $orig) { git mv $orig (Join-Path $dest $arq) }
  }
}

Write-Output "Reorganização concluída. Rode .\gerar-manifest.ps1 em seguida."
