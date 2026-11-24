import 'dart:convert';

import 'package:http/http.dart' as http;

import 'perguntas.dart';

/// Único local da URL base.
/// Emulador Android: http://10.0.2.2:8080
/// Celular físico: troque 10.0.2.2 pelo IP do computador na rede.
/// Competição: use a URL informada pelo instrutor.
const String baseUrl = 'http://10.0.2.2:8080';

class ApiException implements Exception {
  const ApiException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// HTTP 409: o participante já respondeu a esta pergunta.
class RespostaJaRegistrada implements Exception {
  const RespostaJaRegistrada();
}

class ResultadoResposta {
  const ResultadoResposta({
    required this.correta,
    required this.pontosGanhos,
    required this.pontuacaoTotal,
    required this.explicacao,
  });

  final bool correta;
  final int pontosGanhos;
  final int pontuacaoTotal;
  final String explicacao;

  factory ResultadoResposta.fromJson(Map<String, dynamic> json) {
    return ResultadoResposta(
      correta: json['correta'] as bool,
      pontosGanhos: json['pontosGanhos'] as int,
      pontuacaoTotal: json['pontuacaoTotal'] as int,
      explicacao: json['explicacao'] as String,
    );
  }
}

class Api {
  Api({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String caminho) => Uri.parse('$baseUrl$caminho');

  Future<List<Pergunta>> buscarPerguntas() async {
    late final http.Response resposta;
    try {
      resposta = await _client.get(_uri('/api/perguntas'));
    } catch (_) {
      throw const ApiException(
        'Não foi possível carregar as perguntas. Verifique sua conexão.',
      );
    }

    if (resposta.statusCode != 200) {
      throw const ApiException(
        'Não foi possível carregar as perguntas. Tente novamente.',
      );
    }

    try {
      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final lista = dados['perguntas'] as List<dynamic>;
      return lista
          .map((item) => Pergunta.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ApiException('A API respondeu com um formato inesperado.');
    }
  }

  Future<ResultadoResposta> enviarResposta({
    required String jogador,
    required String perguntaId,
    required String alternativaId,
  }) async {
    late final http.Response resposta;
    try {
      resposta = await _client.post(
        _uri('/api/respostas'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'jogador': jogador,
          'perguntaId': perguntaId,
          'alternativaId': alternativaId,
        }),
      );
    } catch (_) {
      throw const ApiException(
        'Não foi possível enviar sua resposta. Verifique sua conexão.',
      );
    }

    if (resposta.statusCode == 409) {
      throw const RespostaJaRegistrada();
    }

    if (resposta.statusCode != 200) {
      throw const ApiException(
        'Não foi possível enviar sua resposta. Tente novamente.',
      );
    }

    try {
      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      return ResultadoResposta.fromJson(dados);
    } catch (_) {
      throw const ApiException('A API respondeu com um formato inesperado.');
    }
  }
}
