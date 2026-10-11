# Como guardar provas no KuaaRepo

Este repositório é o **acervo oficial** que o app kuaa Estudante baixa
(painel **Importar → Repositório**). O app nunca vê o site do GitHub:
ele lê o `manifest.json` e baixa os JSONs crus. Por isso as regras abaixo
precisam ser seguidas à risca — qualquer desvio quebra a importação no
celular do usuário.

## 1. Pastas (nomes exatos, com acento)

| Pasta | Conteúdo |
|---|---|
| `Ensino Superior/` | Provas de cursos superiores e saúde, por profissão |
| `5º ano/` … `9º ano/` | Ensino Fundamental, por ano do estudante |
| `1º ano EM/` … `3º ano EM/` | Ensino Médio, ENEM e vestibular, por ano |
| `Técnico/` | Cursos técnicos |
| `Quiz/Autoconhecimento/`, `Quiz/Bem-estar/`, `Quiz/Diversão/`, `Quiz/Relacionamentos/` | Quizzes por temática (sem gabarito) |

Não crie pastas novas nem renomeie as existentes sem atualizar o app
(a ordem de exibição está no código). Cada pasta de **ano tem UM único
arquivo** (`5ano.json`, …, `1ano-em.json`, …) — o app mostra uma linha por
ano, sem nome de arquivo. Nome de **arquivo** nas demais pastas:
minúsculas, `_` no lugar de espaço (ex.: `nutricionista.json`).
Exceção: cada tema de Quiz tem UM único arquivo (`autoconhecimento.json`,
`bem-estar.json`, `diversao.json`, `relacionamentos.json`).

## 2. Formato de cada JSON (obrigatório)

Envelope fixo — um array solto de questões **não** é importável:

```json
{
  "format": "kuaa/estudante",
  "createdAt": "2026-10-11T00:00:00.000Z",
  "exams": [ { "id": "...", "title": "...", ... } ]
}
```

Por prova (`exams[]`):

- `id` — **único no acervo inteiro**. Duplicado = descartado em silêncio.
- `title`, `board` (banca), `role` (cargo) — obrigatórios.
- `role` precisa ter **3+ letras** e **não** pode conter
  `prova/caderno/folha/gabarito`, nem ser só número/código —
  senão a prova é **bloqueada** na importação.
- `city/state/year/booklet/status` — preencher sempre que souber
  (`status`: `Pronto para importacao` ou `Revisao pendente`).

Por questão (`questions[]`):

- `id`, `originalNumber`, `label`, `text` (enunciado, nunca vazio).
- `alternatives`: **2+ itens** com `id` e `text` não vazio.
  Convenção de ids: `A01`…`A05` (acervo novo). Não misture com `A`…`E`
  no mesmo arquivo.
- `correct`: id de alternativa existente (ou `ANULADA`). Vazio = questão
  sem gabarito (entra, mas não pontua).
- `subject`: matéria hierárquica com ` > `
  (ex.: `Fisica > Termodinamica`). Nunca vazio — é o que popula o
  carrossel de matérias do app.
- `difficulty`: só `facil`, `media` ou `dificil`.
- `type`: `unica`. `visualStatus`: `not_needed` (ou `needed` se a questão
  exigir imagem).

Caso especial **Quiz**: sem `correct`, cada alternativa tem `pontos`
(`{final1…final5}`) e a prova tem `quizFinais[5]` + `quizDesempate`.
Não trate quiz como prova de concurso (daria 0 acertos sempre).

## 3. Publicando (fluxo manual)

A pasta local de entrega é `C:\APPS\Kuaa\KuaaRepo`. Para publicar:

1. Atualize as fontes (`C:\APPS\Kuaa\quaestions\` e, se houver mudança, o
   pacote inicial do msix-app).
2. Rode `.\reorganizar-anos.ps1` na raiz — ele move os arquivos para as
   pastas de ano/tema (pelo `role` da prova), extrai do pacote inicial só
   os exames que ainda não estão no repo e preserva o histórico com
   `git mv`. Depois rode `.\unificar-anos.ps1` (junta cada ano em um único
   arquivo e elimina questões exatamente duplicadas) e por fim
   `.\gerar-manifest.ps1` (ele **regenera** o `manifest.json`; nunca edite
   esse arquivo à mão).
3. Confira os totais impressos pelos scripts e faça `commit` + `push`.

Regras da divisão por ano: o ano vem do `role` (`5º EF`→`5º ano`, …,
`3º EM`→`3º ano EM`). Arquivo sem ano no `role` (ex.: banco sintético de
português, gramática normativa) vai para `3º ano EM`. Quiz segue a tabela
de temas em `reorganizar-anos.ps1`.

## 4. O que NÃO fazer

- Não commitar JSON inválido (o script avisa `ignorado (JSON invalido)`).
- Não reutilizar `id` de prova de outro arquivo.
- Não subir arquivos com espaço no nome (use `_`).
- Não apagar um pacote sem avisar: quem já baixou mantém a cópia local,
  mas o pacote some para usuários novos.
