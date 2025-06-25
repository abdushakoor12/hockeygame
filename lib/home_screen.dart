import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Word list with big words
  final List<String> _wordList = [
    'CHAMPIONSHIP',
    'EXTRAORDINARY',
    'MAGNIFICENT',
    'REVOLUTIONARY',
    'SPECTACULAR',
    'TRANSPORTATION',
    'INTERNATIONAL',
    'UNPRECEDENTED',
    'SOPHISTICATED',
    'ENVIRONMENTAL',
    'CONSTRUCTION',
    'INDEPENDENT',
    'INVESTIGATION',
    'ENTERTAINMENT',
    'ACCELERATION',
    'DEVELOPMENT',
    'PROGRAMMING',
    'TEMPERATURE',
    'INFORMATION',
    'TECHNOLOGY',
    'PERSONALITY',
    'PHOTOGRAPHY',
    'IMAGINATION',
    'APPRECIATION',
    'COMBINATION'
  ];

  // QWERTY keyboard layout - letters only
  final List<List<String>> _keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  String _currentWord = '';
  final Set<String> _guessedLetters = {};
  final Set<String> _wrongLetters = {};
  int _wrongGuesses = 0;
  final String _livesText = 'HOCKEY GAME';

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final random = Random();
    setState(() {
      _currentWord = _wordList[random.nextInt(_wordList.length)];
      _guessedLetters.clear();
      _wrongLetters.clear();
      _wrongGuesses = 0;
    });
  }

  void _onKeyPressed(String key) {
    if (_guessedLetters.contains(key) || _wrongGuesses >= _livesText.length) {
      return;
    }

    setState(() {
      _guessedLetters.add(key);
      
      if (_currentWord.contains(key)) {
        // Correct guess - check if word is complete
        if (_isWordComplete()) {
          _showGameOverDialog(true);
        }
      } else {
        // Wrong guess
        _wrongLetters.add(key);
        _wrongGuesses++;
        
        if (_wrongGuesses >= _livesText.length) {
          _showGameOverDialog(false);
        }
      }
    });
  }

  bool _isWordComplete() {
    return _currentWord.split('').every((letter) => _guessedLetters.contains(letter));
  }

  void _showGameOverDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '🎉 You Won!' : '💀 Game Over'),
        content: Text(won 
          ? 'Congratulations! You guessed "$_currentWord"!'
          : 'The word was "$_currentWord". Better luck next time!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Word Guessing Game'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Lives indicator - HOCKEY GAME
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!, width: 2),
            ),
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: _livesText.split('').asMap().entries.map((entry) {
                    int index = entry.key;
                    String letter = entry.value;
                    bool isStruck = index < _wrongGuesses;
                    
                    return TextSpan(
                      text: letter,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isStruck ? Colors.red[300] : Colors.red[700],
                        decoration: isStruck ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.red[700],
                        decorationThickness: 3,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // Word display
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal letter box width based on available space
                double availableWidth = constraints.maxWidth - 40; // Account for padding
                double spacing = 4;
                double totalSpacing = (_currentWord.length - 1) * spacing;
                double letterWidth = (availableWidth - totalSpacing) / _currentWord.length;
                
                // Ensure minimum and maximum width constraints
                letterWidth = letterWidth.clamp(25.0, 50.0);
                
                // Calculate font size based on letter width
                double fontSize = (letterWidth * 0.6).clamp(16.0, 28.0);
                
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _currentWord.split('').asMap().entries.map((entry) {
                      int index = entry.key;
                      String letter = entry.value;
                      bool isGuessed = _guessedLetters.contains(letter);
                      
                      return Container(
                        margin: EdgeInsets.only(
                          right: index < _currentWord.length - 1 ? spacing : 0,
                        ),
                        child: Container(
                          width: letterWidth,
                          height: letterWidth * 1.2, // Maintain aspect ratio
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.indigo[300]!,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isGuessed ? letter : '',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Wrong letters display
          if (_wrongLetters.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Wrong Letters:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _wrongLetters.join(', '),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          
          const Spacer(),
          
          // Keyboard
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Keyboard rows
                ..._keyboardLayout.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  List<String> row = entry.value;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Add offset for second and third rows to create QWERTY stagger
                        if (rowIndex == 1) const SizedBox(width: 20),
                        if (rowIndex == 2) const SizedBox(width: 40),
                        
                        ...row.map((key) => _buildKey(key)),
                        
                        if (rowIndex == 1) const SizedBox(width: 20),
                        if (rowIndex == 2) const SizedBox(width: 40),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    bool isGuessed = _guessedLetters.contains(key);
    bool isWrong = _wrongLetters.contains(key);
    bool isCorrect = isGuessed && !isWrong;
    
    Color keyColor;
    Color textColor;
    Color borderColor;
    
    if (isCorrect) {
      keyColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      borderColor = Colors.green[300]!;
    } else if (isWrong) {
      keyColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      borderColor = Colors.red[300]!;
    } else {
      keyColor = Colors.indigo[50]!;
      textColor = Colors.indigo[700]!;
      borderColor = Colors.indigo[200]!;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: keyColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isGuessed ? null : () => _onKeyPressed(key),
          child: Container(
            width: 35,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  keyColor,
                ],
              ),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}