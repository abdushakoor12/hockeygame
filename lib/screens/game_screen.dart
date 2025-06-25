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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: won 
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.red[400]!, Colors.red[600]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with large emoji
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      won ? '🏆' : '💀',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      won ? 'VICTORY!' : 'GAME OVER',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        children: [
                          Text(
                            'The word was:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentWord.toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(widget.level.gradientColors[1]),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            won 
                              ? 'Amazing! You cracked the code!'
                              : 'Don\'t give up! Try again!',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Column(
                      children: [
                        _buildGameButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _startNewGame();
                          },
                          text: 'PLAY AGAIN',
                          icon: Icons.refresh,
                          isPrimary: true,
                          color: won ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 12),
                        _buildGameButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); // Return to menu
                          },
                          text: 'MENU',
                          icon: Icons.home,
                          isPrimary: false,
                          color: won ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
    required MaterialColor color,
  }) {
    return Material(
      color: isPrimary ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: Colors.white, width: 2),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? color[600] : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? color[600] : Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(widget.level.gradientColors[0]).withOpacity(0.8),
              Color(widget.level.gradientColors[1]).withOpacity(0.6),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game Header with HUD-style design
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(widget.level.gradientColors[0]).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(widget.level.gradientColors[0]).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Back button with game styling
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(widget.level.gradientColors[0]).withOpacity(0.8),
                            Color(widget.level.gradientColors[1]).withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Level info with game styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.level.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.level.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'LEVEL ${widget.level.name.split(' ').last}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(widget.level.gradientColors[0]),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // New game button with game styling
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange[400]!,
                            Colors.orange[600]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _startNewGame,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lives indicator - Hockey Game Style
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red[900]!.withOpacity(0.8),
                      Colors.red[700]!.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[400]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '⚡ ENERGY LEVEL ⚡',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[200],
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: _livesText.split('').asMap().entries.map((entry) {
                          int index = entry.key;
                          String letter = entry.value;
                          bool isStruck = index < _wrongGuesses;
                          
                          return TextSpan(
                            text: letter == ' ' ? '  ' : letter,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isStruck ? Colors.grey : Colors.white,
                              decoration: isStruck ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.red[300],
                              decorationThickness: 4,
                              shadows: isStruck ? null : [
                                Shadow(
                                  color: Colors.red[400]!,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Word display - Game style
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(widget.level.gradientColors[0]).withOpacity(0.6),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(widget.level.gradientColors[0]).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
                                gradient: LinearGradient(
                                  colors: isRevealed 
                                    ? [
                                        Color(widget.level.gradientColors[0]).withOpacity(0.3),
                                        Color(widget.level.gradientColors[1]).withOpacity(0.2),
                                      ]
                                    : [
                                        Colors.grey[800]!.withOpacity(0.5),
                                        Colors.grey[900]!.withOpacity(0.3),
                                      ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isRevealed 
                                    ? Color(widget.level.gradientColors[0])
                                    : Colors.grey[600]!,
                                  width: 2,
                                ),
                                boxShadow: isRevealed ? [
                                  BoxShadow(
                                    color: Color(widget.level.gradientColors[0]).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isRevealed ? letter : '',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: isRevealed 
                                        ? Colors.white
                                        : Colors.transparent,
                                      shadows: isRevealed ? [
                                        Shadow(
                                          color: Color(widget.level.gradientColors[1]),
                                          blurRadius: 4,
                                        ),
                                      ] : null,
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
              
              // Wrong letters display - Game style
              if (_wrongLetters.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red[900]!.withOpacity(0.7),
                        Colors.red[800]!.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[400]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red[200],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MISSED SHOTS: ${_wrongLetters.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[200],
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.warning,
                            color: Colors.red[200],
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _wrongLetters.map((letter) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              // Game Keyboard
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  border: Border.all(
                    color: Color(widget.level.gradientColors[0]).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(widget.level.gradientColors[0]).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, -5),
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
    
    List<Color> gradientColors;
    Color textColor;
    Color borderColor;
    List<BoxShadow> shadows;
    
    if (isCorrect) {
      gradientColors = [Colors.green[400]!, Colors.green[600]!];
      textColor = Colors.white;
      borderColor = Colors.green[300]!;
      shadows = [
        BoxShadow(
          color: Colors.green.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (hasWrongGuesses) {
      gradientColors = [Colors.red[400]!, Colors.red[600]!];
      textColor = Colors.white;
      borderColor = Colors.red[300]!;
      shadows = [
        BoxShadow(
          color: Colors.red.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else {
      gradientColors = [
        Color(widget.level.gradientColors[0]).withOpacity(0.8),
        Color(widget.level.gradientColors[1]).withOpacity(0.6),
      ];
      textColor = Colors.white;
      borderColor = Color(widget.level.gradientColors[0]).withOpacity(0.6);
      shadows = [
        BoxShadow(
          color: Color(widget.level.gradientColors[0]).withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
    }
    
    // Calculate responsive font size based on key width
    double fontSize = (keyWidth * 0.4).clamp(12.0, 18.0);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _onKeyPressed(key),
          child: Container(
            width: keyWidth,
            height: keyHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              boxShadow: shadows,
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
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