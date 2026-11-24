import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oficina_app/api.dart';
import 'package:oficina_app/main.dart';

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Dados públicos devolvidos pelo servidor falso (espelham o contrato).
List<Map<String, dynamic>> _perguntasJson() {
  return [
    {
      'id': 'q1',
      'enunciado': 'O que significa a sigla HTTP?',
      'alternativas': [
        {'id': 'a', 'texto': 'HyperText Transfer Protocol'},
        {'id': 'b', 'texto': 'High Transfer Text Program'},
        {'id': 'c', 'texto': 'Hyper Transfer Terminal Process'},
        {'id': 'd', 'texto': 'Home Tool Transfer Protocol'},
      ],
    },
    {
      'id': 'q2',
      'enunciado': 'Qual formato de instruções a JVM executa?',
      'alternativas': [
        {'id': 'a', 'texto': 'HTML'},
        {'id': 'b', 'texto': 'Java bytecode'},
        {'id': 'c', 'texto': 'CSS'},
        {'id': 'd', 'texto': 'SQL'},
      ],
    },
    {
      'id': 'q3',
      'enunciado': 'Qual é a principal finalidade de uma API REST?',
      'alternativas': [
        {'id': 'a', 'texto': 'Criar imagens'},
        {'id': 'b', 'texto': 'Gerenciar a memória do celular'},
        {
          'id': 'c',
          'texto': 'Permitir comunicação entre sistemas por HTTP',
        },
        {'id': 'd', 'texto': 'Substituir o sistema operacional'},
      ],
    },
  ];
}

http.Response _respostaPerguntas() {
  return http.Response(
    jsonEncode({'perguntas': _perguntasJson()}),
    200,
    headers: {'content-type': 'application/json; charset=UTF-8'},
  );
}

/// Servidor falso com o gabarito do contrato (somente nos testes).
MockClient clienteApiFalso() {
  final respondidas = <String>{};
  var total = 0;
  const gabarito = {'q1': 'a', 'q2': 'b', 'q3': 'c'};
  const explicacoes = {
    'q1': 'HTTP significa HyperText Transfer Protocol.',
    'q2': 'a JVM executa bytecode Java.',
    'q3':
        'APIs REST permitem comunicação entre sistemas usando recursos e métodos HTTP.',
  };

  return MockClient((request) async {
    if (request.url.path == '/api/perguntas') {
      return _respostaPerguntas();
    }

    if (request.url.path == '/api/respostas') {
      final corpo = jsonDecode(request.body) as Map<String, dynamic>;
      final chaves = (corpo.keys.toList()..sort()).join(',');
      if (chaves != 'alternativaId,jogador,perguntaId') {
        return http.Response(jsonEncode({'erro': 'Campos inválidos'}), 400);
      }

      final jogador = corpo['jogador'] as String;
      final perguntaId = corpo['perguntaId'] as String;
      final alternativaId = corpo['alternativaId'] as String;
      if (jogador != 'Ana' ||
          !gabarito.containsKey(perguntaId) ||
          !['a', 'b', 'c', 'd'].contains(alternativaId)) {
        return http.Response(jsonEncode({'erro': 'Requisição inválida'}), 400);
      }

      final chave = '$jogador|$perguntaId';
      if (respondidas.contains(chave)) {
        return http.Response(
          jsonEncode({
            'erro': 'Este participante já respondeu a esta pergunta.',
          }),
          409,
        );
      }
      respondidas.add(chave);

      final correta = gabarito[perguntaId] == alternativaId;
      final ganhos = correta ? 100 : 0;
      total += ganhos;

      return http.Response(
        jsonEncode({
          'jogador': jogador,
          'perguntaId': perguntaId,
          'correta': correta,
          'pontosGanhos': ganhos,
          'pontuacaoTotal': total,
          'explicacao': explicacoes[perguntaId],
        }),
        200,
        headers: {'content-type': 'application/json; charset=UTF-8'},
      );
    }

    return http.Response('', 404);
  });
}

void main() {
  testWidgets('integração: carrega, envia respostas e mostra o resultado',
      (WidgetTester tester) async {
    await tester.pumpWidget(DesafioTiApp(api: Api(client: clienteApiFalso())));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pump();
    await tocar(tester, find.text('Começar'));

    expect(find.text('Pergunta 1 de 3'), findsOneWidget);
    expect(find.text('O que significa a sigla HTTP?'), findsOneWidget);

    await tocar(tester, find.text('HyperText Transfer Protocol'));
    await tester.pumpAndSettle();

    expect(find.text('Acertou!'), findsOneWidget);
    expect(find.text('+100 pontos'), findsOneWidget);
    expect(find.text('Pontuação: 100'), findsOneWidget);
    expect(
      find.text('Explicação: HTTP significa HyperText Transfer Protocol.'),
      findsOneWidget,
    );

    // Depois de responder, a outra alternativa não pode mudar a pontuação.
    await tocar(tester, find.text('High Transfer Text Program'));
    expect(find.text('Acertou!'), findsOneWidget);
    expect(find.text('Pontuação: 100'), findsOneWidget);

    await tocar(tester, find.text('Próxima pergunta'));
    expect(find.text('Pergunta 2 de 3'), findsOneWidget);

    await tocar(tester, find.text('HTML'));
    await tester.pumpAndSettle();
    expect(find.text('Errou!'), findsOneWidget);
    expect(find.text('+0 pontos'), findsOneWidget);
    expect(find.text('Pontuação: 100'), findsOneWidget);
    expect(
      find.text('Explicação: a JVM executa bytecode Java.'),
      findsOneWidget,
    );

    await tocar(tester, find.text('Próxima pergunta'));
    expect(find.text('Pergunta 3 de 3'), findsOneWidget);

    await tocar(tester, find.text('Permitir comunicação entre sistemas por HTTP'));
    await tester.pumpAndSettle();
    expect(find.text('Pontuação: 200'), findsOneWidget);

    await tocar(tester, find.text('Ver resultado'));
    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Apelido: Ana'), findsOneWidget);
    expect(find.text('Pontuação: 200'), findsOneWidget);
    expect(find.text('Acertos: 2 de 3'), findsOneWidget);

    await tocar(tester, find.text('Jogar novamente'));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('API indisponível: mostra mensagem e permite tentar novamente',
      (WidgetTester tester) async {
    var tentativas = 0;
    final cliente = MockClient((request) async {
      if (request.url.path == '/api/perguntas') {
        tentativas += 1;
        if (tentativas == 1) {
          return http.Response('{"erro":"indisponível"}', 503);
        }
        return _respostaPerguntas();
      }
      return http.Response('', 404);
    });

    await tester.pumpWidget(DesafioTiApp(api: Api(client: cliente)));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar as perguntas. Tente novamente.'),
      findsOneWidget,
    );

    await tocar(tester, find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(tentativas, 2);
  });

  testWidgets('falha no POST não avança; 409 é tratado como já registrado',
      (WidgetTester tester) async {
    var tentativasPost = 0;
    final cliente = MockClient((request) async {
      if (request.url.path == '/api/perguntas') {
        return _respostaPerguntas();
      }
      if (request.url.path == '/api/respostas') {
        tentativasPost += 1;
        if (tentativasPost == 1) {
          return http.Response('{"erro":"indisponível"}', 503);
        }
        return http.Response(
          jsonEncode({
            'erro': 'Este participante já respondeu a esta pergunta.',
          }),
          409,
        );
      }
      return http.Response('', 404);
    });

    await tester.pumpWidget(DesafioTiApp(api: Api(client: cliente)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pump();
    await tocar(tester, find.text('Começar'));

    await tocar(tester, find.text('HyperText Transfer Protocol'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível enviar sua resposta. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.text('Pergunta 1 de 3'), findsOneWidget);
    expect(find.text('Próxima pergunta'), findsNothing);

    // Nova tentativa: o servidor responde 409 (resposta já aceita antes).
    await tocar(tester, find.text('HyperText Transfer Protocol'));
    await tester.pumpAndSettle();

    expect(find.text('Resposta já registrada.'), findsOneWidget);
    expect(find.text('Pergunta 1 de 3'), findsOneWidget);

    await tocar(tester, find.text('Próxima pergunta'));
    expect(find.text('Pergunta 2 de 3'), findsOneWidget);
    expect(tentativasPost, 2);
  });
}
