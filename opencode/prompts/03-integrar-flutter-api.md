# Prompt 03 — Integrar Flutter à API

Leia e siga integralmente `contratos/contrato-app.md` e `contratos/contrato-api.md`. Os contratos são obrigatórios. Não invente rotas, campos ou regras.

O projeto Flutter já existe e possui o quiz funcionando com perguntas hardcoded. **Não recrie o projeto nem refaça o visual sem necessidade.** Preserve telas e experiência.

Substitua a fonte local pela API:
- buscar perguntas em `GET /api/perguntas`;
- enviar respostas em `POST /api/respostas`;
- enviar `jogador`, `perguntaId` e `alternativaId` exatamente como no contrato;
- usar `correta`, `pontosGanhos`, `pontuacaoTotal` e `explicacao` da resposta do backend;
- remover o gabarito local: Flutter não decide se a resposta está correta.

Adicione `http` se ainda não existir (o instrutor pode executar `flutter pub add http` com a turma). Centralize a URL base em um único local fácil de alterar.

Trate carregamento, indisponibilidade e erros HTTP. Não avance se a resposta não tiver sido confirmada. Evite envios duplicados; trate HTTP 409 como resposta já registrada.

Não implemente ranking, banco, autenticação ou telas fora do contrato. Ao terminar, explique onde alterar a URL e como testar no emulador e em celular físico.
