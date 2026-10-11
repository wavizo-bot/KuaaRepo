# Como guardar provas no KuaaRepo

Este repositório é o **acervo oficial** que o app kuaa Estudante baixa
(painel **Importar → Repositório**). O app nunca vê o site do GitHub:
ele lê o `manifest.json` e baixa os JSONs crus. Por isso as regras abaixo
precisam ser seguidas à risca — qualquer desvio quebra a importação no
celular do usuário.

## 1. Pastas (nomes exatos, com acento)

| Pasta | Conteúdo |
|---|---|
| `Ensino Superior/` | Provas de cursos superiores e saúde |
| `Fundamental e Médio/` | EF/EM, vestibulares e ENEM por tópico |
| `Quiz/` | Quizzes de personalidade (sem gabarito) |
| `Técnico/` | Cursos técnicos |

Não crie pastas novas nem renomeie as existentes sem atualizar o app
(a ordem de exibição — Superior, Fundamental e Médio, Técnico, Quiz —
está no código). Nome de **arquivo**: minúsculas, `_` no lugar de espaço
(ex.: `fisica_mru.json`), um assunto por arquivo.

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

1. Copie os JSONs de `C:\APPS\Kuaa\quaestions\` para as pastas
   correspondentes aqui (converta o nome da pasta para a forma com
   acento: `Fundamental e Medio` → `Fundamental e Médio`,
   `Tecnico` → `Técnico`).
2. Rode `.\gerar-manifest.ps1` na raiz — ele **regenera** o
   `manifest.json` (nunca edite esse arquivo à mão).
3. Confira os totais impressos pelo script e faça `commit` + `push`.

## 4. O que NÃO fazer

- Não commitar JSON inválido (o script avisa `ignorado (JSON invalido)`).
- Não reutilizar `id` de prova de outro arquivo.
- Não subir arquivos com espaço no nome (use `_`).
- Não apagar um pacote sem avisar: quem já baixou mantém a cópia local,
  mas o pacote some para usuários novos.
