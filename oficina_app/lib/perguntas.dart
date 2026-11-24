/// Modelos públicos vindos de GET /api/perguntas.
/// Não existe gabarito nem explicação aqui: quem decide o acerto é o backend.
class Alternativa {
  const Alternativa({required this.id, required this.texto});

  final String id;
  final String texto;

  factory Alternativa.fromJson(Map<String, dynamic> json) {
    return Alternativa(
      id: json['id'] as String,
      texto: json['texto'] as String,
    );
  }
}

class Pergunta {
  const Pergunta({
    required this.id,
    required this.enunciado,
    required this.alternativas,
  });

  final String id;
  final String enunciado;
  final List<Alternativa> alternativas;

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'] as String,
      enunciado: json['enunciado'] as String,
      alternativas: (json['alternativas'] as List<dynamic>)
          .map((item) => Alternativa.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
