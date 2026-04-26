import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Цитатник дня',
      theme:
          ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue),
      darkTheme:
          ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

//КОНСТАНТЫ
const List<String> kQuotes = [
  "Самый лучший способ предсказать будущее — создать его.",
  "Успех — это сумма маленьких усилий, повторяемых изо дня в день.",
  "Неудача — это просто возможность начать сначала, но уже более мудро.",
  "Единственный способ делать великие дела — любить то, что ты делаешь.",
  "Начните с того, что необходимо, затем сделайте то, что возможно.",
  "Терпение и настойчивость — главные ключи к успеху.",
  "Верьте в себя и все, что вы есть.",
  "Жизнь на 10% из того, что происходит, и на 90% из того, как вы реагируете.",
  "Не позволяйте вчерашнему дню отнимать слишком много сегодняшнего.",
  "Чтобы дойти до цели, надо прежде всего идти.",
];

//ГЛАВНЫЙ ЭКРАН
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentQuote = kQuotes[0];
  List<String> _favorites = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentQuote = prefs.getString('last_quote') ?? kQuotes[0];
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  void _generateQuote() async {
    setState(() {
      _currentQuote = kQuotes[_random.nextInt(kQuotes.length)];
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_quote', _currentQuote);
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(_currentQuote)) {
        _favorites.remove(_currentQuote);
      } else {
        _favorites.add(_currentQuote);
      }
    });
    await prefs.setStringList('favorites', _favorites);
  }

  @override
  Widget build(BuildContext context) {
    bool isFav = _favorites.contains(_currentQuote);
    return Scaffold(
      appBar: AppBar(title: const Text('Цитатник дня'), actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoritesScreen()))
              .then((_) => _loadData()),
        )
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_currentQuote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.amber : null),
                  onPressed: _toggleFavorite,
                ),
                ElevatedButton(
                    onPressed: _generateQuote,
                    child: const Text('Другая цитата')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//ЭКРАН ИЗБРАННОГО
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavs();
  }

  void _loadFavs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];
          return Dismissible(
            key: Key(item),
            onDismissed: (dir) async {
              _favorites.removeAt(index);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('favorites', _favorites);
            },
            background: Container(color: Colors.red),
            child: ListTile(title: Text(item)),
          );
        },
      ),
    );
  }
}
