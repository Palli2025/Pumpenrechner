import 'package:flutter/material.dart';

void main() {
  runApp(const PalliCalcApp());
}

class PalliCalcApp extends StatelessWidget {
  const PalliCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.green,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PalliCalc',
      theme: base.copyWith(
        cardTheme: const CardThemeData(color: Colors.white),
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 140, height: 140),
                const SizedBox(height: 14),
                const Text(
                  'Palliativteam Hochtaunus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Daimlerstraße 12\n61352 Bad Homburg',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Willkommen zu PalliCalc – dem Pumpenrechner für die palliative Versorgung.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CalculatorPage()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Pumpenrechner starten'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _aMg = TextEditingController(text: '0');
  final _aMl = TextEditingController(text: '0');
  final _bMg = TextEditingController(text: '0');
  final _bMl = TextEditingController(text: '0');
  final _cMg = TextEditingController(text: '0');
  final _cMl = TextEditingController(text: '0');

  final _fillMl = TextEditingController(text: '50'); // manual fallback
  final _reserveMl = TextEditingController(text: '2');

  final _doseMgPerDay = TextEditingController(text: '0');

  bool _autoFillFromMeds = true;

  double _num(TextEditingController c) {
    final raw = c.text.replaceAll(',', '.').trim();
    if (raw.isEmpty) return 0;
    return double.tryParse(raw) ?? 0;
  }

  @override
  void dispose() {
    _aMg.dispose();
    _aMl.dispose();
    _bMg.dispose();
    _bMl.dispose();
    _cMg.dispose();
    _cMl.dispose();
    _fillMl.dispose();
    _reserveMl.dispose();
    _doseMgPerDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aMg = _num(_aMg);
    final aMl = _num(_aMl);
    final bMg = _num(_bMg);
    final bMl = _num(_bMl);
    final cMg = _num(_cMg);
    final cMl = _num(_cMl);

    final totalMg = aMg + bMg + cMg;
    final totalDrugVolMl = aMl + bMl + cMl;

    final manualFillMl = _num(_fillMl).clamp(0, 100);
    final fillMl = (_autoFillFromMeds ? totalDrugVolMl : manualFillMl).clamp(0, 100);

    final reserveMl = _num(_reserveMl).clamp(0, fillMl);
    final effectiveMl = (fillMl - reserveMl).clamp(0, 100);

    final dosePerDayMg = _num(_doseMgPerDay);

    final bagConc = fillMl > 0 ? (totalMg / fillMl) : 0.0; // mg/ml
    final pumpConcSet = effectiveMl > 0 ? (totalMg / effectiveMl) : 0.0; // mg/ml

    // If user entered a daily dose, compute rate.
    final mgPerHour = dosePerDayMg / 24.0;
    final rateMlPerHour = pumpConcSet > 0 ? (mgPerHour / pumpConcSet) : 0.0;

    // Diluent needed (if bag should reach fillMl)
    final diluentNeeded = (fillMl - totalDrugVolMl).clamp(0, 1000);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('PalliCalc'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medikamente im Beutel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _drugRow('A', _aMg, _aMl),
                  const SizedBox(height: 10),
                  _drugRow('B', _bMg, _bMl),
                  const SizedBox(height: 10),
                  _drugRow('C', _cMg, _cMl),
                  const SizedBox(height: 12),
                  Text(
                    'Gesamt: ${totalMg.toStringAsFixed(2)} mg • Medikamentenvolumen: ${totalDrugVolMl.toStringAsFixed(1)} ml',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beutel / Pumpe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Füllvolumen automatisch aus A+B+C'),
                    subtitle: const Text('Beutel-Füllvolumen wird aus den eingetragenen Medikamentenvolumina berechnet'),
                    value: _autoFillFromMeds,
                    onChanged: (v) => setState(() => _autoFillFromMeds = v),
                  ),

                  const SizedBox(height: 6),

                  if (_autoFillFromMeds)
                    _readonlyValue(
                      label: 'Beutel-Füllvolumen (ml)',
                      value: fillMl.toStringAsFixed(1),
                      helper: diluentNeeded > 0
                          ? 'Auffüllen bis ${fillMl.toStringAsFixed(1)} ml: ${diluentNeeded.toStringAsFixed(1)} ml'
                          : 'Kein Auffüllen notwendig',
                    )
                  else
                    _numField(_fillMl, 'Beutel-Füllvolumen (ml)', helper: 'max. 100 ml'),

                  const SizedBox(height: 12),
                  _numField(_reserveMl, 'Reserve (ml)', helper: 'Volumen, das nicht mitläuft'),
                  const SizedBox(height: 12),
                  _numField(_doseMgPerDay, 'Tagesdosis (mg/24h)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ergebnisse',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _resultLine('Konzentration im Beutel', '${bagConc.toStringAsFixed(2)} mg/ml'),
                  _resultLine('Pumpe einstellen (ohne Reserve)', '${pumpConcSet.toStringAsFixed(2)} mg/ml'),
                  _resultLine('Tagesdosis', '${dosePerDayMg.toStringAsFixed(2)} mg/24h'),
                  _resultLine('Förderrate', '${rateMlPerHour.toStringAsFixed(2)} ml/h'),
                  const SizedBox(height: 10),
                  const Text(
                    'Hinweis: Ergebnisse sind Hilfswerte. Plausibilität und ärztliche Anordnung prüfen.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drugRow(String label, TextEditingController mgCtrl, TextEditingController mlCtrl) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(child: _numField(mgCtrl, 'mg', denseLabel: true)),
        const SizedBox(width: 10),
        Expanded(child: _numField(mlCtrl, 'ml', denseLabel: true)),
      ],
    );
  }

  Widget _numField(TextEditingController c, String label, {String? helper, bool denseLabel = false}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        isDense: denseLabel,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _readonlyValue({required String label, required String value, String? helper}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
      child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _resultLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
