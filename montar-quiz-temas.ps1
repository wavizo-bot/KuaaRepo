# Monta Quiz/ a partir de "Quiz com tematica.json" (Downloads) em 9 temas.
# Uso: .\montar-quiz-temas.ps1  (raiz do KuaaRepo)
# - Apaga o Quiz/ atual (git rm) e grava 1 arquivo por tema, com `tematica`.
# - Mantém da versão atual o quiz ausente na fonte ("bateria social").
# Depois: .\gerar-manifest.ps1, conferir, commit + push.
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
Set-Location $Root

$temas = @{
  "Relacionamentos e Amor" = @{ Arquivo = "relacionamentos-e-amor.json"; Titulos = @(
    "Como você se comporta em relacionamentos afetivos?",
    "Qual é a sua postura real diante da vulnerabilidade afetiva?",
    "Qual é a sua verdadeira moeda de troca nas relações?",
    "Qual ferida da infância você trouxe para o amor?",
    "Qual seu papel numa briga de casal?",
    "Qual seu tipo de amor tóxico preferido?",
    "Qual sua linguagem de evitação do amor?",
    "Qual tipo de namorado(a) você é?",
    "Qual tipo de pessoa você atrai (e por quê)?",
    "Que tipo de filme de terror é seu relacionamento atual?",
    "Você sabe reconhecer bandeiras (verdes, amarelas e vermelhas) na vida real?"
  )}
  "Sobrevivência e Resiliência" = @{ Arquivo = "sobrevivencia-e-resiliencia.json"; Titulos = @(
    "Como está o seu nível invisível de esgotamento (burnout)?",
    "Qual é a sua tolerância real ao desconforto e ao tédio?",
    "Qual é o seu mecanismo de defesa predominante diante da frustração?",
    "Qual tipo de apocalipse você estaria mais preparado(a) para enfrentar?"
  )}
  "Identidade e Estilo Pessoal" = @{ Arquivo = "identidade-e-estilo-pessoal.json"; Titulos = @(
    "Qual das Meninas Superpoderosas você seria?",
    "Qual doce traduz sua forma de lidar com a vida?",
    "Qual docinho de festa você é?",
    "Qual mulher icônica das telas você seria?",
    "Se você fosse algo esquecido em casa, o que seria?"
  )}
  "Ambição, Sucesso e Tempo" = @{ Arquivo = "ambicao-sucesso-e-tempo.json"; Titulos = @(
    "O que a sua relação com o tempo diz sobre a sua urgência de vida?",
    "Qual ambição oculta está guiando suas escolhas atuais?",
    "Qual é a sua relação invisível com o sucesso?",
    "Qual é o seu modelo mental de tomada de decisão sob pressão?",
    "Qual é o seu sabotador profissional secreto?"
  )}
  "Energia, Ritmo e Arquétipos Animais" = @{ Arquivo = "energia-ritmo-arquetipos-animais.json"; Titulos = @(
    "Qual animal reflete seu nível de energia e ritmo de vida?",
    "Como é a sua bateria social segundo o reino animal?"
  )}
  "Família e Heranças Emocionais" = @{ Arquivo = "familia-e-herancas-emocionais.json"; Titulos = @(
    "Qual herança emocional dos seus pais mais guia suas escolhas atuais?"
  )}
  "Amizades e Vínculos Sociais" = @{ Arquivo = "amizades-e-vinculos-sociais.json"; Titulos = @(
    "Qual é a sua linguagem oculta para lidar com conflitos?",
    "Qual é o seu método para lidar com encrencas e conflitos?",
    "Que tipo de âncora você representa nas suas amizades?"
  )}
  "Autoconhecimento e Comportamento" = @{ Arquivo = "autoconhecimento-e-comportamento.json"; Titulos = @(
    "O que a sua irritação com os outros revela sobre a sua Sombra?",
    "O que você está projetando nos outros?",
    "Quais padrões tóxicos você repete sem perceber?",
    "Qual fase de vida sua mente está vivendo no momento?",
    "Qual é a sua relação com o controle e a incerteza?",
    "Qual é o seu medo primário oculto?"
  )}
  "Adaptabilidade e Rotina" = @{ Arquivo = "adaptabilidade-e-rotina.json"; Titulos = @(
    "Qual é o seu perfil de adaptabilidade alimentar e de rotina?"
  )}
}

$fonte = "C:\Users\Maycon\Downloads\Quiz com tematica.json"
$quizzes = Get-Content $fonte -Raw -Encoding UTF8 | ConvertFrom-Json
$porTitulo = @{}
foreach ($e in $quizzes.exams) { $porTitulo[$e.title] = $e }
# Quiz ausente na fonte: reaproveita da versão atual do repo
$ausente = "Como é a sua bateria social segundo o reino animal?"
$quizDir = Join-Path $Root "Quiz"
if (-not $porTitulo.ContainsKey($ausente)) {
  git checkout -q HEAD -- "Quiz/Bem-estar/bem-estar.json"
  if (Test-Path -LiteralPath $quizDir) {
  Get-ChildItem -LiteralPath $quizDir -Recurse -File -Filter *.json | ForEach-Object {
    $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($e in $j.exams) { if ($e.title -eq $ausente) { $porTitulo[$ausente] = $e } }
  }
  }
}

# Apaga o Quiz/ atual do git (lista primeiro, remove depois)
$quizAntigos = @()
if (Test-Path -LiteralPath $quizDir) { $quizAntigos = @(Get-ChildItem -LiteralPath $quizDir -Recurse -File -Filter *.json) }
foreach ($f in $quizAntigos) { git rm -q $f.FullName }
$quizSubdirs = @()
if (Test-Path -LiteralPath $quizDir) { $quizSubdirs = @(Get-ChildItem -LiteralPath $quizDir -Directory) }
foreach ($d in $quizSubdirs) { Remove-Item $d.FullName -Recurse -Force -ErrorAction SilentlyContinue }

function chaveTitulo([string]$s) { return (([string]$s -replace '"', '' -replace '\s+', ' ').Trim().ToLower()) }
$temaPorChave = @{}
foreach ($tema in $temas.Keys) { foreach ($t in $temas[$tema].Titulos) { $temaPorChave[(chaveTitulo $t)] = $tema } }
$porTema = @{}
foreach ($tema in $temas.Keys) { $porTema[$tema] = @() }

$semTema = @()
foreach ($t in $porTitulo.Keys) {
  $ch = chaveTitulo $t
  if ($temaPorChave.ContainsKey($ch)) { $porTema[$temaPorChave[$ch]] += $porTitulo[$t] }
  else { $semTema += $t }
}
if ($semTema.Count) { Write-Warning "sem tema: $($semTema -join ' | ')"; }

foreach ($tema in $temas.Keys) {
  $dest = Join-Path $quizDir $tema
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  $exames = @()
  foreach ($e in $porTema[$tema]) {
    $e | Add-Member -NotePropertyName tematica -NotePropertyValue $tema -Force
    $exames += $e
  }
  $pacote = @{ format = "kuaa/estudante"; createdAt = (Get-Date).ToUniversalTime().ToString("o"); exams = @($exames) }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText((Join-Path $dest $temas[$tema].Arquivo), ($pacote | ConvertTo-Json -Depth 20), $enc)
  git add (Join-Path $dest $temas[$tema].Arquivo)
  Write-Output "$tema : $($exames.Count) quizzes"
}
Write-Output "Quiz remontado. Rode .\gerar-manifest.ps1 em seguida."
