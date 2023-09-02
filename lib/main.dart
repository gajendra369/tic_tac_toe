import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
        ),
        body: const TicTacToe(),
      ),
    );
  }
}

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> with TickerProviderStateMixin {
  List<String> board = List.filled(9, '');//create list of length 9 all elements initialized to ''
  bool isPlayer1Turn = true;
  String winner = '';
  late ImageProvider xImage;
  late ImageProvider oImage;
  final Map<int, AnimationController> _animationControllers = {};


  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for each cell
    for (int i = 0; i < 9; i++) {
      _animationControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),//animation duration
      );
      const interval = Interval(0.0, 0.5, curve: Curves.easeOut);

      _animationControllers[i]?.drive(
        Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: interval),
        ),
      );
    } // Adjust the duration as needed
  }


  void _onTileTap(int index) { //callback for tap detection
    if (board[index] == '' && winner == '') {
      setState(() {
        board[index] = isPlayer1Turn ? 'X' : 'O';
        isPlayer1Turn = !isPlayer1Turn;
        winner=_checkWinner();
      });
    }
    final controller = _animationControllers[index];
    if (controller != null) {
      _startPopAnimation(index);
    }
  }
  void _startPopAnimation(int index) {
    final controller = _animationControllers[index];
    controller?.reset();
    controller?.forward();
  }


  @override
  void dispose() {
    // Dispose of animation controllers to prevent memory leaks
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void show(String msg){ //function for showing dailogbox
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(msg, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _restartGame();
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Restart Game'),
          ),
          ],
        ),
        );
      },
    );
  }
  String _checkWinner() { //to determine the winner
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var condition in winConditions) {
      if (board[condition[0]] != '' &&
          board[condition[0]] == board[condition[1]] &&
          board[condition[0]] == board[condition[2]]) {
        show("${board[condition[0]]} is the winner");
        return board[condition[0]];
      }
    }


    if (!board.contains('')) {
      show("draw match");
      return 'draw';
    }

    return '';
  }

  void _restartGame() { //to reinitialize the conditions on game restart
    setState(() {
      board = List.filled(9, '');
      isPlayer1Turn = true;
      winner = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return
        Stack(
          children:[
            Image.asset(
              'assets/bg.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            SingleChildScrollView(
            child: Center(
              child: Column(
                children: [

                      Padding(
                        padding: const EdgeInsets.only(left: 500.0),
                        child: Row(
                          children: [
                            const Text("Turn :",style:TextStyle(fontSize: 40,color: Colors.white),),
                            Image(
                              image: AssetImage(isPlayer1Turn ? "assets/x_image.png" : "assets/o_image.png"),
                              height: 30,
                              width: 30,
                            )

                          ],
                        ),
                      ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: 600,
                    height: 600,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( //defines size and layout of the grids
                        crossAxisCount: 3,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onTileTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 5),
                            ),
                            child: Center(
                              child: board[index] == 'X'
                                  ? AnimatedBuilder(
                                animation: _animationControllers[index] ?? const AlwaysStoppedAnimation(0.0),
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: (_animationControllers[index]?.value) ?? 0.0,
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  'assets/x_image.png',
                                  width: 100,
                                  height: 100,
                                ),
                              )
                                  : board[index] == 'O'
                                  ? AnimatedBuilder(
                                animation: _animationControllers[index] ?? const AlwaysStoppedAnimation(0.0),
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: (_animationControllers[index]?.value) ?? 0.0,
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  'assets/o_image.png',
                                  width: 100,
                                  height: 100,
                                ),
                              )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),],
        );
  }

}
