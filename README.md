# KuaaRepo — acervo de provas do Kuaa

Pacotes de provas e testes em JSON, organizados por pasta. O app
[kuaa Estudante](https://github.com/wavizo-bot/kuaa-estudante) lê o
**`manifest.json`** e baixa direto daqui — o usuário nunca precisa abrir
este site.

- **`manifest.json`** é o índice oficial: lista todos os pacotes com pasta,
  nº de provas, nº de questões e data de atualização.

## Pastas oficiais

| Pasta | Conteúdo |
|---|---|
| `Ensino Superior/` | Provas de cursos superiores e saúde, por profissão |
| `5º ano/` … `9º ano/` | Ensino Fundamental, por ano do estudante |
| `1º ano EM/` … `3º ano EM/` | Ensino Médio/ENEM/vestibular, por ano |
| `Técnico/` | Cursos técnicos |
| `Quiz/Relacionamentos e Amor/` | ❤️ Testes afetivos e amorosos |
| `Quiz/Sobrevivência e Resiliência/` | 🌪️ Testes de superação e resistência |
| `Quiz/Identidade e Estilo Pessoal/` | 🍬 Testes de entretenimento |
| `Quiz/Ambição, Sucesso e Tempo/` | 🎯 Testes de ambição e tempo |
| `Quiz/Energia, Ritmo e Arquétipos Animais/` | 🐾 Testes de energia e ritmo |
| `Quiz/Família e Heranças Emocionais/` | 👨‍👩‍👧 Testes de família |
| `Quiz/Amizades e Vínculos Sociais/` | 🤝 Testes de amizade |
| `Quiz/Autoconhecimento e Comportamento/` | 🧠 Testes de autoconhecimento |
| `Quiz/Adaptabilidade e Rotina/` | 🧩 Testes de rotina |

## Ambiente (personalização oficial futura)

| Pasta | Acesso no app |
|---|---|
| `Ambiente/Temas/` | Botão de importar da configuração de temas |
| `Ambiente/Sons/` | Botão de importar da configuração de sons |

O índice é o **`manifest-ambiente.json`**. Medalhas acompanham a versão
do programa (sem repositório).

## Formato dos arquivos

Cada JSON segue o envelope `kuaa/estudante` (`format`, `createdAt`,
`exams[]`), com 1 prova por quiz e campos exigidos pelo importador do app
(`id` único, `role` com cargo válido, `subject` preenchido).
