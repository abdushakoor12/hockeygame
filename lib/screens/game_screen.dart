import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_level.dart';

class GameScreen extends StatefulWidget {
  final GameLevel level;
  
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // QWERTY keyboard layout - letters only
  final List<List<String>> _keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  String _currentWord = '';
  final Set<int> _revealedPositions = {}; // Track which letter positions are revealed
  final Set<String> _wrongLetters = {}; // Track unique wrong guesses
  final Set<String> _guessedLetters = {}; // All letters that have been guessed
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
      _currentWord = widget.level.words[random.nextInt(widget.level.words.length)];
      _revealedPositions.clear();
      _wrongLetters.clear();
      _guessedLetters.clear();
      _wrongGuesses = 0;
    });
  }

  void _onKeyPressed(String key) {
    if (_wrongGuesses >= _livesText.length || _guessedLetters.contains(key)) {
      return;
    }

    setState(() {
      _guessedLetters.add(key);
      
      if (_currentWord.contains(key)) {
        // Reveal all occurrences of this letter
        for (int i = 0; i < _currentWord.length; i++) {
          if (_currentWord[i] == key) {
            _revealedPositions.add(i);
          }
        }
        
        // Check if word is complete
        if (_isWordComplete()) {
          _showGameOverDialog(true);
        }
      } else {
        // Wrong guess - unique letters only
        _wrongLetters.add(key);
        _wrongGuesses++;
        
        if (_wrongGuesses >= _livesText.length) {
          _showGameOverDialog(false);
        }
      }
    });
  }

  bool _isWordComplete() {
    return _revealedPositions.length == _currentWord.length;
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to menu
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(widget.level.gradientColors[0]).withOpacity(0.3),
              Color(widget.level.gradientColors[1]).withOpacity(0.1),
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with level info
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.level.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.level.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            widget.level.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _startNewGame,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
              
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
                          bool isRevealed = _revealedPositions.contains(index);
                          
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
                                    color: Color(widget.level.gradientColors[1]),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isRevealed ? letter : '',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Color(widget.level.gradientColors[1]),
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
                        'Wrong Guesses (${_wrongLetters.length}):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _wrongLetters.toList().join(', '),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive key dimensions
                    double availableWidth = constraints.maxWidth - 32; // Account for padding
                    double keySpacing = 2;
                    
                    // Calculate key width based on the longest row (first row with 10 keys)
                    double totalSpacing = (10 - 1) * keySpacing;
                    double keyWidth = (availableWidth - totalSpacing) / 10;
                    
                    // Ensure minimum and maximum key size
                    keyWidth = keyWidth.clamp(25.0, 45.0);
                    double keyHeight = keyWidth * 1.2;
                    
                    // Calculate stagger offsets proportionally
                    double staggerOffset = keyWidth * 0.5;
                    
                    return Column(
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
                                // Add proportional offset for second and third rows to create QWERTY stagger
                                if (rowIndex == 1) SizedBox(width: staggerOffset),
                                if (rowIndex == 2) SizedBox(width: staggerOffset * 2),
                                
                                ...row.map((key) => _buildKey(key, keyWidth, keyHeight)),
                                
                                if (rowIndex == 1) SizedBox(width: staggerOffset),
                                if (rowIndex == 2) SizedBox(width: staggerOffset * 2),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String key, double keyWidth, double keyHeight) {
    bool isGuessed = _guessedLetters.contains(key);
    bool hasWrongGuesses = _wrongLetters.contains(key);
    bool isCorrect = isGuessed && _currentWord.contains(key);
    
    Color keyColor;
    Color textColor;
    Color borderColor;
    
    if (isCorrect) {
      keyColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      borderColor = Colors.green[300]!;
    } else if (hasWrongGuesses) {
      keyColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      borderColor = Colors.red[300]!;
    } else {
      keyColor = Color(widget.level.gradientColors[0]).withOpacity(0.1);
      textColor = Color(widget.level.gradientColors[1]);
      borderColor = Color(widget.level.gradientColors[0]).withOpacity(0.3);
    }
    
    // Calculate responsive font size based on key width
    double fontSize = (keyWidth * 0.4).clamp(12.0, 18.0);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: keyColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onKeyPressed(key),
          child: Container(
            width: keyWidth,
            height: keyHeight,
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
                  fontSize: fontSize,
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