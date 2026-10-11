# KuaaRepo — acervo de provas do Kuaa

Pacotes de provas/quiz/formulários em JSON, organizados por pasta, para o app
[Kuaa](https://github.com/wavizo-bot/Kuaa-app-MSIX) importar.

- **`manifest.json`** é o índice oficial: lista todos os pacotes com pasta,
  nº de provas, nº de questões e data de atualização. O app lê esse arquivo
  para mostrar o acervo online e baixar só o que mudou.
- **`gerar-manifest.ps1`** regenera o índice. Rode após adicionar, remover ou
  atualizar qualquer JSON: `.\gerar-manifest.ps1`

## Pastas

| Pasta | Conteúdo |
|---|---|
| `Ensino Superior/` | Provas de cursos superiores e saúde |
| `Fundamental e Médio/` | EF/EM, vestibulares e ENEM por tópico |
| `Quiz/` | Quizzes de personalidade (sem gabarito) |
| `Tecnico/` | Cursos técnicos |

## Formato dos arquivos

Cada JSON segue o envelope `caderno-estudante/v1` (`format`, `createdAt`,
`exams[]`). Não edite a estrutura à mão — use o fluxo do Kuaa-admin para
gerar, e rode o script acima depois.

## Regras de guarda

Leia **`COMO-GUARDAR-PROVAS.md`** antes de adicionar ou alterar qualquer
prova: pastas oficiais, envelope obrigatório, campos exigidos pelo
importador do app, caso especial dos quizzes e fluxo de publicação.
