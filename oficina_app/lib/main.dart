import 'package:flutter/material.dart';

import 'api.dart';
import 'perguntas.dart';

// Paleta inspirada no site da Rocketseat: fundo escuro e destaque laranja.
const Color laranja = Color(0xFFFF7A00);
const Color fundo = Color(0xFF0A0A0C);
const Color cartao = Color(0xFF141417);
const Color borda = Color(0xFF2A2A30);
const Color laranjaSuave = Color(0x1AFF7A00);
const Color vermelho = Color(0xFFFF4D4D);
const Color vermelhoSuave = Color(0x14FF4D4D);

void main() {
  runApp(const DesafioTiApp());
}

class DesafioTiApp extends StatelessWidget {
  const DesafioTiApp({super.key, this.api});

  /// Permite injetar um cliente falso nos testes.
  final Api? api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio TI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fundo,
        colorScheme: const ColorScheme.dark(
          primary: laranja,
          onPrimary: fundo,
          secondary: laranja,
          onSecondary: fundo,
          surface: cartao,
          onSurface: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.bold,
            height: 1.05,
            letterSpacing: -1.5,
          ),
          headlineMedium: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          titleLarge: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
          labelLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: fundo,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
          iconTheme: IconThemeData(color: laranja),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: laranja,
            foregroundColor: fundo,
            disabledBackgroundColor: Color(0xFF3A2A1C),
            disabledForegroundColor: Colors.white54,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF101013),
          labelStyle: const TextStyle(color: Colors.white70),
          floatingLabelStyle: const TextStyle(color: laranja),
          prefixIconColor: laranja,
          border: _bordaInput(borda),
          enabledBorder: _bordaInput(borda),
          focusedBorder: _bordaInput(laranja),
        ),
      ),
      home: JogoPage(api: api ?? Api()),
    );
  }
}

OutlineInputBorder _bordaInput(Color cor) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: cor),
  );
}

class JogoPage extends StatefulWidget {
  const JogoPage({super.key, required this.api});

  final Api api;

  @override
  State<JogoPage> createState() => _JogoPageState();
}

class _JogoPageState extends State<JogoPage> {
  final TextEditingController _apelidoController = TextEditingController();

  Api get _api => widget.api;

  // 0 = início, 1 = pergunta, 2 = resultado.
  int _etapa = 0;
  int _indice = 0;
  int _pontuacao = 0;
  int _acertos = 0;
  List<Pergunta> _perguntas = const [];

  bool _carregando = true;
  bool _enviando = false;
  bool _respostaDada = false;
  bool _respostaJaRegistrada = false;

  String? _alternativaEscolhida;
  String? _erroCarregamento;
  String? _erroEnvio;
  ResultadoResposta? _resultado;
  String _apelido = '';

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerguntas() async {
    setState(() {
      _carregando = true;
      _erroCarregamento = null;
    });

    try {
      final perguntas = await _api.buscarPerguntas();
      if (!mounted) return;
      setState(() {
        _perguntas = perguntas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erroCarregamento = e is ApiException
            ? e.mensagem
            : 'Não foi possível carregar as perguntas. Verifique sua conexão.';
      });
    }
  }

  void _comecar() {
    final apelido = _apelidoController.text.trim();
    if (apelido.isEmpty || _perguntas.isEmpty) {
      return;
    }

    setState(() {
      _apelido = apelido;
      _indice = 0;
      _pontuacao = 0;
      _acertos = 0;
      _enviando = false;
      _respostaDada = false;
      _respostaJaRegistrada = false;
      _alternativaEscolhida = null;
      _erroEnvio = null;
      _resultado = null;
      _etapa = 1;
    });
  }

  Future<void> _responder(Alternativa alternativa) async {
    if (_respostaDada || _enviando) {
      return;
    }

    setState(() {
      _enviando = true;
      _erroEnvio = null;
      _alternativaEscolhida = alternativa.id;
    });

    final pergunta = _perguntas[_indice];
    try {
      final resultado = await _api.enviarResposta(
        jogador: _apelido,
        perguntaId: pergunta.id,
        alternativaId: alternativa.id,
      );
      if (!mounted) return;
      setState(() {
        _resultado = resultado;
        _pontuacao = resultado.pontuacaoTotal;
        if (resultado.correta) {
          _acertos += 1;
        }
        _respostaDada = true;
        _respostaJaRegistrada = false;
        _enviando = false;
      });
    } on RespostaJaRegistrada catch (_) {
      if (!mounted) return;
      setState(() {
        _respostaJaRegistrada = true;
        _respostaDada = true;
        _enviando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _erroEnvio = e is ApiException
            ? e.mensagem
            : 'Não foi possível enviar sua resposta. Tente novamente.';
      });
    }
  }

  void _avancar() {
    setState(() {
      if (_indice < _perguntas.length - 1) {
        _indice += 1;
        _resultado = null;
        _respostaDada = false;
        _respostaJaRegistrada = false;
        _alternativaEscolhida = null;
        _erroEnvio = null;
      } else {
        _etapa = 2;
      }
    });
  }

  void _jogarNovamente() {
    _apelidoController.clear();
    setState(() {
      _etapa = 0;
      _indice = 0;
      _pontuacao = 0;
      _acertos = 0;
      _enviando = false;
      _respostaDada = false;
      _respostaJaRegistrada = false;
      _alternativaEscolhida = null;
      _erroEnvio = null;
      _resultado = null;
      _apelido = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          alignment: Alignment.center,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: laranjaSuave,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: laranja),
          ),
          child: const Icon(Icons.rocket_launch, color: laranja, size: 20),
        ),
        title: const Text('Desafio TI'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [laranja, Color(0x00FF7A00)],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.4,
            colors: [laranjaSuave, fundo],
            stops: [0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _conteudo(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_etapa == 0) {
      return _buildInicio();
    }
    if (_etapa == 1) {
      return _buildPergunta();
    }
    return _buildResultado();
  }

  Widget _cabecalho(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 3, color: laranja),
            const SizedBox(width: 10),
            const Text(
              'DESAFIO TI',
              style: TextStyle(
                color: laranja,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(titulo, style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 4,
          decoration: BoxDecoration(
            color: laranja,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  Widget _rodape() {
    return const Padding(
      padding: EdgeInsets.only(top: 32),
      child: Center(
        child: Text(
          'DESAFIO TI',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _painel({required Widget child, Color? destaque}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (destaque != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: destaque,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cartao,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borda),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FF7A00),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildCarregamento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cabecalho('Desafio TI'),
        const SizedBox(height: 32),
        _painel(
          destaque: laranja,
          child: Column(
            children: [
              const CircularProgressIndicator(color: laranja),
              const SizedBox(height: 20),
              Text(
                'Carregando perguntas...',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        _rodape(),
      ],
    );
  }

  Widget _buildErroCarregamento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cabecalho('Desafio TI'),
        const SizedBox(height: 32),
        _painel(
          destaque: vermelho,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.cloud_off_outlined, color: vermelho, size: 36),
              const SizedBox(height: 16),
              Text(
                _erroCarregamento ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _carregarPerguntas,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        _rodape(),
      ],
    );
  }

  Widget _buildInicio() {
    if (_carregando) {
      return _buildCarregamento();
    }
    if (_erroCarregamento != null) {
      return _buildErroCarregamento();
    }

    final podeComecar =
        _apelidoController.text.trim().isNotEmpty && _perguntas.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cabecalho('Desafio TI'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _Chip(texto: '3 perguntas', icone: Icons.quiz_outlined),
            _Chip(texto: '4 alternativas', icone: Icons.radio_button_checked),
            _Chip(texto: '100 pontos por acerto', icone: Icons.stars_outlined),
          ],
        ),
        const SizedBox(height: 32),
        _painel(
          destaque: laranja,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _apelidoController,
                maxLength: 20,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Apelido',
                  counterText: '',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: podeComecar ? _comecar : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Começar'),
              ),
            ],
          ),
        ),
        _rodape(),
      ],
    );
  }

  Widget _indicadores() {
    return Row(
      children: [
        for (var i = 0; i < _perguntas.length; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i == _perguntas.length - 1 ? 0 : 8,
              ),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _indice ? laranja : borda,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPergunta() {
    if (_perguntas.isEmpty) {
      return _buildCarregamento();
    }

    final pergunta = _perguntas[_indice];
    final eUltima = _indice == _perguntas.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pergunta ${_indice + 1} de ${_perguntas.length}',
              style: const TextStyle(
                color: laranja,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cartao,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(color: borda),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_outlined, color: laranja, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Pontuação: $_pontuacao',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _indicadores(),
        const SizedBox(height: 28),
        _painel(
          child: Text(
            pergunta.enunciado,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        for (final alternativa in pergunta.alternativas)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              style: _estiloAlternativa(alternativa),
              onPressed: _respostaDada || _enviando
                  ? null
                  : () => _responder(alternativa),
              child: Row(
                children: [
                  _badgeAlternativa(alternativa),
                  const SizedBox(width: 16),
                  Expanded(child: Text(alternativa.texto)),
                ],
              ),
            ),
          ),
        if (_enviando) ...[
          const SizedBox(height: 8),
          _painel(
            destaque: laranja,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: laranja,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Enviando resposta...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
        if (_erroEnvio != null) ...[
          const SizedBox(height: 8),
          _painel(
            destaque: vermelho,
            child: Text(
              _erroEnvio!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
        if (_respostaJaRegistrada) ...[
          const SizedBox(height: 8),
          _painel(
            destaque: laranja,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resposta já registrada.',
                  style: TextStyle(
                    color: laranja,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _avancar,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(eUltima ? 'Ver resultado' : 'Próxima pergunta'),
                ),
              ],
            ),
          ),
        ],
        if (_respostaDada && _resultado != null) ...[
          const SizedBox(height: 8),
          _painel(
            destaque: _resultado!.correta ? laranja : vermelho,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _resultado!.correta ? laranjaSuave : vermelhoSuave,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _resultado!.correta
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    color: _resultado!.correta ? laranja : vermelho,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resultado!.correta ? 'Acertou!' : 'Errou!',
                        style: TextStyle(
                          color: _resultado!.correta ? laranja : vermelho,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${_resultado!.pontosGanhos} pontos',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explicação: ${_resultado!.explicacao}',
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _avancar,
            icon: Icon(
              eUltima ? Icons.flag_rounded : Icons.arrow_forward_rounded,
            ),
            label: Text(eUltima ? 'Ver resultado' : 'Próxima pergunta'),
          ),
        ],
        _rodape(),
      ],
    );
  }

  Widget _badgeAlternativa(Alternativa alternativa) {
    var corFundo = borda;
    var corTexto = laranja;

    if (_respostaDada && _resultado != null) {
      if (alternativa.id == _alternativaEscolhida) {
        if (_resultado!.correta) {
          corFundo = laranja;
          corTexto = fundo;
        } else {
          corFundo = vermelho;
          corTexto = Colors.white;
        }
      }
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        alternativa.id.toUpperCase(),
        style: TextStyle(color: corTexto, fontWeight: FontWeight.bold),
      ),
    );
  }

  ButtonStyle _estiloAlternativa(Alternativa alternativa) {
    var corFundo = cartao;
    var corBorda = borda;
    var larguraBorda = 1.0;

    if (_respostaDada && _resultado != null) {
      if (alternativa.id == _alternativaEscolhida) {
        corFundo = _resultado!.correta ? laranjaSuave : vermelhoSuave;
        corBorda = _resultado!.correta ? laranja : vermelho;
        larguraBorda = 2.0;
      }
    }

    return ElevatedButton.styleFrom(
      backgroundColor: corFundo,
      disabledBackgroundColor: corFundo,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white,
      elevation: 0,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      side: BorderSide(color: corBorda, width: larguraBorda),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildResultado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cabecalho('Resultado'),
        const SizedBox(height: 28),
        _painel(
          destaque: laranja,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: laranjaSuave,
                    radius: 22,
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      color: laranja,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Apelido: $_apelido',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(width: 48, height: 3, color: laranja),
              const SizedBox(height: 20),
              Text(
                'Pontuação: $_pontuacao',
                style: const TextStyle(
                  color: laranja,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acertos: $_acertos de $_totalPerguntas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _jogarNovamente,
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Jogar novamente'),
        ),
        _rodape(),
      ],
    );
  }

  int get _totalPerguntas => _perguntas.length;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.icone});

  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cartao,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        border: Border.all(color: borda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: laranja, size: 16),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
