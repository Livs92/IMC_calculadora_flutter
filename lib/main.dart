import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const BMIApp());

class BMIApp extends StatelessWidget {
  const BMIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F9FC),
        colorSchemeSeed: const Color(0xFF1E6C86),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/* ===================== SPLASH ===================== */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctl,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: .9,
    end: 1.0,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const BMIPage(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _goNext,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        size: 44,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your body',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'BMI Calculator',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to continue',
                      style: TextStyle(
                        color: Colors.black.withOpacity(.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== BMI PAGES ===================== */

enum Gender { male, female }

class BMIPage extends StatefulWidget {
  const BMIPage({super.key});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  final _formKey = GlobalKey<FormState>();
  // CAMPO VAZIO AO INICIAR
  final _w = TextEditingController();
  final _h = TextEditingController();
  Gender _gender = Gender.male;

  // controla quem está com o keypad aberto
  TextEditingController? _activeCtrl;
  String _activeLabel = '';

  double? _bmi;

  @override
  void dispose() {
    _w.dispose();
    _h.dispose();
    super.dispose();
  }

  double _toNumber(String s) =>
      double.tryParse(s.replaceAll(',', '.')) ?? double.nan;

  void _calc() {
    if (!_formKey.currentState!.validate()) return;
    final weight = _toNumber(_w.text);
    final heightM = _toNumber(_h.text) / 100.0;
    final bmi = weight / (heightM * heightM);
    setState(() => _bmi = double.parse(bmi.toStringAsFixed(1)));
  }

  void _reset() {
    // LIMPA CAMPOS AO VOLTAR PARA NOVO CÁLCULO
    _w.clear();
    _h.clear();
    FocusScope.of(context).unfocus();
    setState(() => _bmi = null);
  }

  String _category(double x) {
    if (x < 18.5) return 'Underweight';
    if (x < 25) return 'Normal';
    if (x < 30) return 'Overweight';
    return 'Obesity';
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _InfoLine(bold: 'BMI categories'),
            SizedBox(height: 16),
            _InfoLine(bold: 'Less than 18.5', text: "you're underweight."),
            _InfoLine(bold: '18.5 to 24.9', text: "you're normal."),
            _InfoLine(bold: '25 to 29.9', text: "you're overweight."),
            _InfoLine(bold: '30 or more', text: 'obesity.'),
          ],
        ),
      ),
    );
  }

  // ---------- NUMERIC KEYPAD ----------
  void _openKeypad({
    required String label,
    required TextEditingController controller,
  }) {
    setState(() {
      _activeCtrl = controller;
      _activeLabel = label;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return _NumericKeypad(
          label: _activeLabel,
          controller: _activeCtrl!,
          onDone: () {
            Navigator.pop(ctx);
            setState(() {}); // atualiza UI com o novo valor
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _activeCtrl = null;
        _activeLabel = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _bmi == null
              ? _InputView()
              : _ResultView(value: _bmi!, again: _reset),
        ),
      ),
    );
  }

  /* ---------- INPUT VIEW ---------- */
  Widget _InputView() {
    final pad = MediaQuery.of(context).size.width > 520 ? 40.0 : 20.0;
    return Padding(
      key: const ValueKey('input'),
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Text(
                'Your body',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: _showInfo,
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('BMI Calculator', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),

          // Gênero
          Row(
            children: [
              _GenderCard(
                label: 'Male',
                asset: 'assets/images/homem.png',
                selected: _gender == Gender.male,
                onTap: () => setState(() => _gender = Gender.male),
              ),
              const SizedBox(width: 12),
              _GenderCard(
                label: 'Female',
                asset: 'assets/images/mulher.png',
                selected: _gender == Gender.female,
                onTap: () => setState(() => _gender = Gender.female),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Campos com números grandes + teclado custom
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: _BigNumberField(
                    controller: _w,
                    label: 'Your weight (kg)',
                    readOnly: true,
                    onTap: () =>
                        _openKeypad(label: 'Your weight (kg)', controller: _w),
                    validator: (v) {
                      final n = _toNumber(v ?? '');
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (n.isNaN || n <= 0 || n > 500) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _BigNumberField(
                    controller: _h,
                    label: 'Your height (cm)',
                    readOnly: true,
                    onTap: () =>
                        _openKeypad(label: 'Your height (cm)', controller: _h),
                    validator: (v) {
                      final n = _toNumber(v ?? '');
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (n.isNaN || n < 30 || n > 260) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
              onPressed: _calc,
              child: const Text('Calculate your BMI'),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------- RESULT VIEW ---------- */
  Widget _ResultView({required double value, required VoidCallback again}) {
    final pad = MediaQuery.of(context).size.width > 520 ? 40.0 : 20.0;
    final cat = _category(value);
    final catColor = switch (cat) {
      'Underweight' => Colors.amber,
      'Normal' => Colors.green,
      'Overweight' => Colors.orange,
      _ => Colors.red,
    };
    return Padding(
      key: const ValueKey('result'),
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: again, icon: const Icon(Icons.arrow_back)),
              const Text(
                'Your body',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: _showInfo,
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('BMI Calculator', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your BMI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: catColor[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: again,
                    child: const Text('Calculate BMI again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : const Color(0xFF607587);
    final bg = selected ? const Color(0xFF1E6C86) : Colors.white;
    final border = selected ? Colors.transparent : const Color(0xFFE2E8F0);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              CircleAvatar(radius: 30, backgroundImage: AssetImage(asset)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const _BigNumberField({
    required this.controller,
    required this.label,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: Colors.black.withOpacity(.55),
      fontSize: 13,
    );

    // InkWell POR FORA do card garante que o toque abre o keypad mesmo no Web/Desktop
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
          decoration: const InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: [
            // mantém consistente caso o usuário cole algo
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\s]')),
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        // Se for readOnly, o toque no card inteiro abre o keypad.
        if (readOnly)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: card,
          )
        else
          card,
      ],
    );
  }
}

class _NumericKeypad extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onDone;

  const _NumericKeypad({
    required this.label,
    required this.controller,
    required this.onDone,
  });

  @override
  State<_NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<_NumericKeypad> {
  static const int _maxLen = 6;

  String get _text => widget.controller.text;

  void _setText(String v) {
    widget.controller.text = v;
    widget.controller.selection = TextSelection.collapsed(offset: v.length);
    setState(() {});
  }

  bool get _hasDecimal => _text.contains(RegExp(r'[.,]'));

  void _append(String ch) {
    if (_text.length >= _maxLen) return;
    if ((ch == ',' || ch == '.') && _hasDecimal) return;
    _setText(_text + ch);
  }

  void _backspace() {
    if (_text.isEmpty) return;
    _setText(_text.substring(0, _text.length - 1));
  }

  void _clear() => _setText('');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: _clear, child: const Text('Clear')),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: widget.onDone,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // visor
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _text.isEmpty ? ' ' : _text,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // grade de botões
            _row(['7', '8', '9']),
            _row(['4', '5', '6']),
            _row(['1', '2', '3']),
            Row(
              children: [
                _key('.', flex: 1, onTap: () => _append(',')), // usa vírgula
                _key('0', flex: 1, onTap: () => _append('0')),
                _iconKey(Icons.backspace_outlined, onTap: _backspace),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: items
            .map((t) => _key(t, onTap: () => _append(t)))
            .toList(growable: false),
      ),
    );
  }

  Widget _key(String label, {required VoidCallback onTap, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconKey(IconData icon, {required VoidCallback onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(icon),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String bold;
  final String? text;
  const _InfoLine({required this.bold, this.text});

  @override
  Widget build(BuildContext context) {
    final b = TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: text == null ? 20 : 18,
    );
    final n = const TextStyle(fontSize: 16);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(bold, style: b),
        if (text != null) ...[
          const SizedBox(width: 10),
          Expanded(child: Text(text!, style: n)),
        ],
      ],
    );
  }
}
