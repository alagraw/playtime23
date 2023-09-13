import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';

void main() {
  runApp(MyApp());
}

var pubnub = PubNub(
    defaultKeyset: Keyset(
        subscribeKey: "sub-c-7ac88e2a-0405-4f10-a4fe-023f32da9fe5",
        publishKey: "pub-c-db4ef0b4-3c82-49b8-a771-64a993a592be",
        userId: UserId('myUniqueUserId')));

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 42, 10, 226)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final subscription = pubnub.subscribe(channels: {'playtime'});
  var status = '';

  void updateStatus(newStatus) {
    status = newStatus;
    print('status updated to $status');
    notifyListeners();
  }

  String selectedOfficeBuilding = 'Luxor'; // Initialize with an empty string
  String selectedPlayArea = 'TT Table'; // Initialize with an empty string

  // List of office buildings and play areas (replace with your data)
  List<String> officeBuildings = ['Luxor', 'Ferns', 'Vigyan'];
  List<String> playAreas = ['TT Table', 'Pool Table', 'Foosball Table'];

  // Method to update the selected office building
  void updateSelectedOfficeBuilding(String newValue) {
    selectedOfficeBuilding = newValue;
    notifyListeners(); // Notify listeners to update the UI
  }

  // Method to update the selected play area
  void updateSelectedPlayArea(String newValue) {
    selectedPlayArea = newValue;
    notifyListeners(); // Notify listeners to update the UI
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var subscription = appState.subscription;

    return Stack(
      children: [
        // Logo text at the top of the screen
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              'PlayTime',
              style: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        // Dropdowns for selecting "Office Building" and "Play Area"
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Label for selecting office building
              Text(
                'Select your office building',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Dropdown for selecting "Office Building"
              Container(
                padding: EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: appState.selectedOfficeBuilding,
                  items: appState.officeBuildings.map((officeBuilding) {
                    return DropdownMenuItem<String>(
                      value: officeBuilding,
                      child: Text(
                        officeBuilding,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    // Update the selected office building here
                    appState.updateSelectedOfficeBuilding(newValue!);
                  },
                ),
              ),
              SizedBox(height: 20),
              // Label for selecting play area
              Text(
                'Select your play area',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Dropdown for selecting "Play Area"
              Container(
                padding: EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: appState.selectedPlayArea,
                  onChanged: (newValue) {
                    // Update the selected play area here
                    appState.updateSelectedPlayArea(newValue!);
                  },
                  items: appState.playAreas.map((playArea) {
                    return DropdownMenuItem<String>(
                      value: playArea,
                      child: Text(
                        playArea,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  subscription.messages.listen((envelope) {
                    switch (envelope.messageType) {
                      case MessageType.normal:
                        {
                          appState.updateStatus(envelope.content);
                          print("content is ${envelope.content}");
                          break;
                        }
                      default:
                        print(
                            'User with id ${envelope.uuid} sent a message: ${envelope.content}');
                    }
                  });
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(20.0),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: Text(
                  'Check',
                  style: TextStyle(fontSize: 24.0,
                  color: Colors.white),
                ),
              ),
              Visibility(
                visible: appState.status
                    .isNotEmpty, // Only show BigCard if status is not empty
                child: Column(
                  children: [
                    SizedBox(height: 18),
                    BigCard(
                      content: appState.status,
                      textStyle: TextStyle(fontSize: 18.0),
                      color: getStatusColor(appState.status),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
                  
              //   },
              //   style: ButtonStyle(
              //     padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              //       EdgeInsets.all(20.0),
              //     ),
              //     backgroundColor:
              //         MaterialStateProperty.all<Color>(Colors.blueGrey),
              //   ),
              //   child: Text(
              //     'Notify when available',
              //     style: TextStyle(
              //       fontSize: 24.0,
              //       color: Colors.white),
              //   ),
              // ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Adjust padding as needed
            child: NotifButton(),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Adjust padding as needed
            child: CalendarButton(),
          ),
        ),
      ],
    );
  }
}

Color getStatusColor(String status) {
  if (status == 'Fetching') {
    return Colors.yellow;
  } else if (status == 'Unoccupied') {
    return Colors.green;
  } else if (status == 'Occupied') {
    return Colors.red;
  } else {
    return Colors.blue;
  }
}

class NotifButton extends StatelessWidget {
  const NotifButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            onPressed: () {
              print('button pressed');
            },
            child: Icon(Icons.add_alert, size: 40),
          ),
        )
    );
  }
}

class CalendarButton extends StatelessWidget {
  const CalendarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            onPressed: () {
              print('button pressed');
            },
            child: Icon(Icons.calendar_month, size: 40),
          ),
        )
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard(
      {super.key,
      required this.content,
      required TextStyle textStyle,
      required this.color});

  final content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: style,
        ),
      ),
    );
  }
}
