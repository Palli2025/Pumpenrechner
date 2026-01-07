import 'package:flutter/material.dart';

void main() => runApp(const PumpCalcApp());

class PumpCalcApp extends StatelessWidget {
  const PumpCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6B8F7A); // muted green
    const surface = Color(0xFFF7F7F7);
    const textDark = Color(0xFF2F2F2F);

    return MaterialApp(
      title: 'PalliCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, surface: surface),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textDark,
          elevation: 0,
        ),
        // Flutter 3.38+ expects CardThemeData here (CardTheme is a widget).
        cardTheme: const CardThemeData(color: Colors.white),
      ),
      home: const LandingPage(),
    );
  }
}


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const String _welcomeText =
      'Willkommen beim Pumpenrechner des Palliativteams Hochtaunus.\n'
      'Mit diesem Rechner können Sie schnell und zuverlässig Pumpeneinstellungen berechnen.\n\n'
      'Bitte starten Sie den Rechner über den Button unten.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 120, height: 120),
                const SizedBox(height: 16),
                const Text(
                  'Palliativteam Hochtaunus\nDaimlerstraße 12\n61352 Bad Homburg',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text(
                  LandingPage._welcomeText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const OhneBolusPage()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Start'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OhneBolusPage extends StatefulWidget {
  const OhneBolusPage({super.key});

  @override
  State<OhneBolusPage> createState() => _OhneBolusPageState();
}

class _OhneBolusPageState extends State<OhneBolusPage> {
  final _fillMl = TextEditingController();
  final _runtimeH = TextEditingController();

  final _aMgMl = TextEditingController();
  final _aVolMl = TextEditingController();
  final _bMgMl = TextEditingController();
  final _bVolMl = TextEditingController();
  final _cMgMl = TextEditingController();
  final _cVolMl = TextEditingController();

  @override
  void dispose() {
    _fillMl.dispose();
    _runtimeH.dispose();
    _aMgMl.dispose();
    _aVolMl.dispose();
    _bMgMl.dispose();
    _bVolMl.dispose();
    _cMgMl.dispose();
    _cVolMl.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    if (t.isEmpty) return 0.0;
    return double.tryParse(t) ?? 0.0;
  }

  double get fillMl => _num(_fillMl).clamp(0.0, 100.0);
  double get runtimeH => _num(_runtimeH) > 0 ? _num(_runtimeH) : 0.0;

  double get aMgMl => _num(_aMgMl);
  double get aVolMl => _num(_aVolMl);
  double get bMgMl => _num(_bMgMl);
  double get bVolMl => _num(_bVolMl);
  double get cMgMl => _num(_cMgMl);
  double get cVolMl => _num(_cVolMl);

  double get rateMlPerH => runtimeH > 0 ? (fillMl / runtimeH) : 0.0;
  double get reserveMl => 100.0 - fillMl;

  double get totalDrugVolMl => aVolMl + bVolMl + cVolMl;
  double get diluentVolNeededMl => (fillMl - totalDrugVolMl);

  double mg(double mgMl, double volMl) => mgMl * volMl;
  double concInBag(double mgTotal) => fillMl > 0 ? (mgTotal / fillMl) : 0.0;

  double get aMg => mg(aMgMl, aVolMl);
  double get bMg => mg(bMgMl, bVolMl);
  double get cMg => mg(cMgMl, cVolMl);

  double get aConcBag => concInBag(aMg);
  double get bConcBag => concInBag(bMg);
  double get cConcBag => concInBag(cMg);

  double get targetA_mgPer24h => runtimeH > 0 ? (aMg / runtimeH) * 24.0 : 0.0;
  double get pumpConcSet_A => fillMl > 0 ? (targetA_mgPer24h / fillMl) : 0.0;
  double get checkDeliveredA_mgPer24h => rateMlPerH * aConcBag * 24.0;

  InputDecoration _dec(String label, {String? suffix}) => InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      );

  Widget _numField({required TextEditingController c, required String label, String? suffix}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _dec(label, suffix: suffix),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _drugCard({
    required String title,
    required TextEditingController mgMlC,
    required TextEditingController volMlC,
    required double mgTotal,
    required double bagConc,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _numField(c: mgMlC, label: 'Wirkstoff', suffix: 'mg/ml')),
                const SizedBox(width: 10),
                Expanded(child: _numField(c: volMlC, label: 'Volumen', suffix: 'ml')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('Wirkstoffmenge: ${mgTotal.toStringAsFixed(2)} mg')),
                Expanded(child: Text('Konz. im Beutel: ${bagConc.toStringAsFixed(3)} mg/ml')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearAll() {
    _fillMl.clear();
    _runtimeH.clear();
    _aMgMl.clear();
    _aVolMl.clear();
    _bMgMl.clear();
    _bVolMl.clear();
    _cMgMl.clear();
    _cVolMl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final reserveColor = reserveMl < 0 ? Colors.red : Colors.black;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        toolbarHeight: 72,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 56, fit: BoxFit.contain),
            const SizedBox(width: 10),
            const Expanded(child: Text('PalliCalc', overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Alle Felder leeren', onPressed: _clearAll, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Parameter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _numField(c: _fillMl, label: 'Beutel-Füllvolumen', suffix: 'ml')),
              const SizedBox(width: 10),
              Expanded(child: _numField(c: _runtimeH, label: 'Laufzeit', suffix: 'h')),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: Text('Laufrate: ${rateMlPerH.toStringAsFixed(2)} ml/h'),
              subtitle: Text('Reserve: ${reserveMl.toStringAsFixed(2)} ml', style: TextStyle(color: reserveColor)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Medikamente im Beutel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _drugCard(title: 'A – Morphin (Hauptmedikament)', mgMlC: _aMgMl, volMlC: _aVolMl, mgTotal: aMg, bagConc: aConcBag),
          _drugCard(title: 'B – Midazolam', mgMlC: _bMgMl, volMlC: _bVolMl, mgTotal: bMg, bagConc: bConcBag),
          _drugCard(title: 'C – optional', mgMlC: _cMgMl, volMlC: _cVolMl, mgTotal: cMg, bagConc: cConcBag),
          const SizedBox(height: 16),
          const Text('Vorgabe Hauptmedikament A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text('Zieldosis Morphin (automatisch)'),
              subtitle: Text('${targetA_mgPer24h.toStringAsFixed(2)} mg/24h'),
              trailing: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.red.shade800,
            child: ListTile(
              title: const Text('Konzentration einstellen (mg/ml)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(pumpConcSet_A.toStringAsFixed(3), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              trailing: const Text('A', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Kontrolle (optional): tatsächliche Abgabe A (mg/24h)'),
              subtitle: Text(checkDeliveredA_mgPer24h.toStringAsFixed(2)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _clearAll, icon: const Icon(Icons.delete_outline), label: const Text('Alle Felder leeren')),
        ],
      ),
    );
  }
}
