# Prompt 04 — Evoluir a API do instrutor para a competição

Leia integralmente `contratos/contrato-api.md`. Esta tarefa é feita previamente pelo instrutor em uma cópia do projeto Spring Boot. O projeto já implementa `GET /api/perguntas` e `POST /api/respostas`.

**Não crie outro projeto, não execute scaffolding e não altere o contrato dos endpoints existentes.** Os apps dos alunos devem funcionar apenas trocando a URL base.

Preserve exatamente métodos, caminhos, JSON, IDs, textos, alternativas, gabarito e regras dos endpoints de perguntas e respostas.

Acrescente somente:
1. `GET /api/ranking`, conforme JSON e ordenação do contrato.
2. Página web `/ranking`, servida pela própria aplicação Spring Boot.

Ranking:
- participantes e respostas em memória;
- apelido identifica participante, normalizado sem diferenciar maiúsculas/minúsculas;
- cada participante responde cada pergunta uma única vez;
- pontuação calculada no servidor;
- tempo de conclusão medido no servidor, entre a primeira e a terceira resposta recebida;
- ordenação exatamente conforme o contrato.

Página `/ranking`:
- título “Desafio TI — Ranking Geral”;
- mostrar posição, apelido, pontuação, acertos e conclusão;
- destacar os três primeiros;
- consultar `GET /api/ranking` automaticamente a cada 3 segundos;
- estado vazio antes dos primeiros participantes;
- HTML, CSS e JavaScript simples, sem framework;
- visual legível em tela projetada.

Não usar banco, WebSocket, autenticação ou dependências desnecessárias. Não adicionar funcionalidades além das descritas. Teste os endpoints e confirme que o app dos alunos permanece compatível.
