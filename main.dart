
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Animada',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(buttonColor: Colors.blueAccent),
      ),
      home: CalculadoraHome(),
    );
  }
}

class CalculadoraHome extends StatefulWidget {
  @override
  _CalculadoraHomeState createState() => _CalculadoraHomeState();
}

class _CalculadoraHomeState extends State<CalculadoraHome> with SingleTickerProviderStateMixin {
  String _display = '';
  final AudioCache _player = AudioCache(prefix: 'assets/sounds/');
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _playSound() {
    _player.play('click.mp3');
  }

  void _onButtonPressed(String value) {
    _playSound();
    _animationController?.forward().then((value) => _animationController?.reverse());
    setState(() {
      if (value == 'C') {
        _display = '';
      } else if (value == '=') {
        try {
          final result = _evaluateExpression(_display);
          _display = result.toString();
        } catch (e) {
          _display = 'Erro';
        }
      } else {
        _display += value;
      }
    });
  }

  double _evaluateExpression(String expression) {
    expression = expression.replaceAll(' ', '');
    if (expression.isEmpty) return 0;

    double total = 0;
    String currentNumber = '';
    String lastOp = '+';

    for (int i = 0; i < expression.length; i++) {
      String c = expression[i];
      if ('0123456789.'.contains(c)) {
        currentNumber += c;
      } else if ('+-'.contains(c)) {
        double num = double.tryParse(currentNumber) ?? 0;
        if (lastOp == '+') total += num;
        else if (lastOp == '-') total -= num;
        lastOp = c;
        currentNumber = '';
      }
    }
    double num = double.tryParse(currentNumber) ?? 0;
    if (lastOp == '+') total += num;
    else if (lastOp == '-') total -= num;

    return total;
  }

  Widget _buildButton(String emoji, String text, String value) {
    return ScaleTransition(
      scale: _scaleAnimation!,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.blueAccent,
        ),
        onPressed: () => _onButtonPressed(value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(text, style: TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['7️⃣', '7', '7'],
      ['8️⃣', '8', '8'],
      ['9️⃣', '9', '9'],
      ['➕', '+', '+'],
      ['4️⃣', '4', '4'],
      ['5️⃣', '5', '5'],
      ['6️⃣', '6', '6'],
      ['➖', '-', '-'],
      ['1️⃣', '1', '1'],
      ['2️⃣', '2', '2'],
      ['3️⃣', '3', '3'],
      ['=', '=', '='],
      ['C', 'C', 'C'],
      ['0️⃣', '0', '0'],
      ['.', '.', '.'],
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Calculadora Animada')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(20),
                child: Text(
                  _display,
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: buttons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final btn = buttons[index];
                return _buildButton(btn[0], btn[1], btn[2]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
