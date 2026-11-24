# Prompt 02 — API Spring Boot dos alunos

Leia e siga integralmente `contratos/contrato-api.md`, fornecido pelo instrutor. O contrato é obrigatório: não invente rotas, campos JSON, regras ou nomes.

O projeto Spring Boot já foi criado manualmente pela turma no Spring Initializr, com Maven, Java 17 e Spring Web. **Não crie outro projeto, não execute scaffolding e não substitua arquivos de configuração.** Trabalhe dentro do projeto aberto.

Implemente somente `GET /api/perguntas` e `POST /api/respostas`.

Perguntas, alternativas, gabarito e explicações ficam hardcoded em Java. Não utilize banco, arquivos externos, autenticação, página web, ranking ou WebSocket.

Requisitos:
- retornar somente campos públicos das perguntas;
- nunca expor o gabarito no endpoint de perguntas;
- validar respostas exclusivamente no backend;
- aplicar 100 pontos por acerto;
- impedir que o mesmo participante responda à mesma pergunta mais de uma vez;
- respeitar status HTTP e JSON do contrato;
- habilitar CORS para o app Flutter durante a oficina.

Mantenha solução pequena e compreensível, sem abstrações desnecessárias. Ao terminar, informe como executar e testar os dois endpoints. Não implemente nada além do contrato.
