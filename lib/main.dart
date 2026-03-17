import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lab 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InteractiveCounter(),
    );
  }
}

class InteractiveCounter extends StatefulWidget {
  const InteractiveCounter({super.key});

  @override
  State<InteractiveCounter> createState() => _InteractiveCounterState();
}

class _InteractiveCounterState extends State<InteractiveCounter> {
  int _counter = 0;
  final TextEditingController _textController = TextEditingController();
  String _message = '';
  Color _counterColor = Colors.black;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _message = 'Інкремент збільшено!';
      _updateCounterColor();
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _message = 'Інкремент зменшено!';
      _updateCounterColor();
    });
  }

  void _updateCounterColor() {
    if (_counter > 0) {
      _counterColor = Colors.green;
    } else if (_counter < 0) {
      _counterColor = Colors.red;
    } else {
      _counterColor = Colors.black;
    }
  }

  void _processInput(String input) {
    setState(() {
      final trimmedInput = input.trim().toLowerCase();

      if (trimmedInput == 'avada kedavra') {
        _counter = 0;
        _message = '⚡ Avada Kedavra! Інкремент скинуто до 0!';
        _counterColor = Colors.purple;
      } else if (trimmedInput == 'fikus pikus') {
        _counter += 100;
        _message = '✨ Fikus Pikus! Додано +100 до інкременту!';
        _updateCounterColor();
      } else {
        final number = int.tryParse(input.trim());
        if (number != null) {
          _counter += number;
          _message = number >= 0
              ? 'Додано $number до інкременту'
              : 'Віднято ${number.abs()} від інкременту';
          _updateCounterColor();
        } else if (trimmedInput.isNotEmpty) {
          _message = 'Введено не число: "$input"';
        } else {
          _message = '';
        }
      }
      _textController.clear();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Інтерактивний інкремент'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Поточний інкремент:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: _counterColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Введіть число або заклинання',
                  hintText:
                      'Спробуйте: число, "Avada Kedavra" або "Fikus Pikus"',
                  prefixIcon: Icon(Icons.edit),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: _processInput,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _processInput(_textController.text),
                icon: const Icon(Icons.send),
                label: const Text('Відправити'),
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _message,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _decrementCounter,
                    icon: const Icon(Icons.remove),
                    label: const Text('-1'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add),
                    label: const Text('+1'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
