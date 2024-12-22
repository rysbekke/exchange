import 'dart:async';
import 'dart:convert';
//import 'dart:js_util';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:flutter/src/widgets/focus_scope.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:localstorage/localstorage.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MaterialApp(
    home: MainScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    //checkForUpdates();
    return _MainScreen();
  }
}

final LocalStorage storage = new LocalStorage('localstorage_app');
Future<List<Rate>>? _futureAlbum840;
Future<List<Rate>>? _futureAlbum978;
Future<List<Rate>>? _futureAlbum643;
Future<List<Rate>>? _futureAlbum398;

Future<String>? _futureVideoTxt;

////////////////*Основная страница
class _MainScreen extends State<MainScreen> {
  //String st='111This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. ';
  //String st= fetchAlbum();
  String _message = "Checking for updates...";
  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

/////////////////////////////

  Future<void> checkForUpdates() async {
    try {
      final response =
          await http.get(Uri.parse('http://report.capital.kg:3000/version'));
      if (response.statusCode == 200) {
        final serverVersion = json.decode(response.body)['version'];
        final localVersion = '1.0.0'; // Current app version

        if (serverVersion != localVersion) {
          setState(() {
            _message = "New version available. Downloading...";
          });
          await requestPermissions();
          await downloadAndInstallUpdate();
        } else {
          setState(() {
            _message = "App is up to date.";
          });
        }
      } else {
        setState(() {
          _message = "Failed to check for updates.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  Future<void> requestPermissions() async {
    await [
      Permission.storage,
      Permission.requestInstallPackages,
    ].request();
  }

  Future<void> downloadAndInstallUpdate() async {
    try {
      final response = await http.get(
          Uri.parse('http://report.capital.kg:3000/updates/app-release.apk'));
      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/app-release.apk';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _message = "Update downloaded. Installing...";
        });

        final result = await OpenFile.open(filePath);

        if (result.type == ResultType.done) {
          setState(() {
            _message = "Update installed successfully.";
          });
        } else {
          setState(() {
            _message = "Could not open APK file.";
          });
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Update Downloaded"),
            content: Text(
                "The application has been updated. Please follow the instructions to install the new version."),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text("Exit"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _message = "Failed to download update.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  int _selectedButtonIndex = 0;

  FocusNode _focusNode = FocusNode();

  // void _onKey(RawKeyEvent event) {
  //   if (event is RawKeyDownEvent) {
  //     setState(() {
  //       // if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
  //       //   _selectedButtonIndex =
  //       //       (_selectedButtonIndex - 1 + _icons.length) % _icons.length;
  //       // } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
  //       //   _selectedButtonIndex = (_selectedButtonIndex + 1) % _icons.length;
  //       // } else

  //       if (event.logicalKey == LogicalKeyboardKey.select) {
  //         _handleButtonPress(_selectedButtonIndex);
  //       }
  //     });
  //   }
  // }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      print('Key pressed: ${event.logicalKey}');

      // Попробуем несколько возможных значений для кнопки Enter
      if (
          //event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select
          //event.logicalKey == LogicalKeyboardKey.gameButtonStart ||
          //event.logicalKey == LogicalKeyboardKey.gameButtonA
          ) {
        _handleButtonPress(_selectedButtonIndex);
      }
    }
  }

  void _handleButtonPress(int index) {
    // Handle button press logic here
    _settingsButtonPress(0);
  }

  Future<void> _settingsButtonPress(int index) async {
    int id = 0;
    await storage.ready;
    var stid = await storage.getItem('id');
    String idstr = (stid != null) ? stid : "0";

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(
            myParam: idstr,
          ),
        ));

    // Handle button press logic here
  }
/////////////////////////////

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Create Data Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Scaffold(
            //appBar: AppBar(title: Text('Главное меню')),
            body: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _onKey,
          autofocus: true,
          child: Column(children: <Widget>[
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.6145, //615, 605, 600
                  height: MediaQuery.of(context).size.height * 0.1296, //70,
                  color: Colors.white70,
                  //padding: EdgeInsets.all(30),
                  child: Image.asset('assets/images/logo.png'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.3854, //345, 355, 360
                  height: MediaQuery.of(context).size.height * 0.1296, //70,
                  color: Colors.blueGrey,
                  //padding: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,

                  child: IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      _settingsButtonPress(0);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.6145, //615, 605, 600
                    height: MediaQuery.of(context).size.height * 0.7862, //430,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 15.0),
                    child: //VideoPlayerApp()
                        Padding(
                            padding: EdgeInsets.all(0.0),
                            child: VideoPlayerApp()),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width *
                        0.3854, //345, 355, 360
                    height: MediaQuery.of(context).size.height * 0.7862, //430,
                    color: Colors.blue,
                    //padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.3854, //345,
                          height:
                              MediaQuery.of(context).size.height * 0.0918, //55,
                          color: Colors.blue,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: Text("АКЧА АЛМАШТЫРУУ",
                                  style: new TextStyle(
                                      fontSize: 28.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.3854, //345,
                          height:
                              MediaQuery.of(context).size.height * 0.0648, //35,
                          color: Colors.blue,
                          child: Center(
                              child: Text("ОБМЕН ВАЛЮТ",
                                  style: new TextStyle(
                                      fontSize: 28.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600))),
                        ),
                        // Container(
                        //   width:
                        //       MediaQuery.of(context).size.width * 0.3854, //345,
                        //   height:
                        //       MediaQuery.of(context).size.height * 0.0648, //35,
                        //   color: Colors.blue,
                        //   child: Center(
                        //       child: Text("Акча  Сатып алуу  Сатуу",
                        //           style: new TextStyle(
                        //               fontSize: 24.0,
                        //               color: Colors.white,
                        //               fontWeight: FontWeight.bold))),
                        // ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.3854, //345,
                          height: MediaQuery.of(context).size.height *
                              0.6296, //340,
                          color: Colors.blue,
                          child: RateTableWidget(),
                        )
                      ],
                    )
                    //MyStatelessWidget(),
                    ),
                //Text(_message)
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                      width: MediaQuery.of(context).size.width, //960,
                      height: MediaQuery.of(context).size.height * 0.0648, //35,
                      color: Colors.white,
                      //padding: EdgeInsets.only(left:20.0),
                      child: const MyScrollText()
                      //  Container(
                      //     color: Colors.green,
                      //     child: SingleChildScrollView(child: Text(
                      //         'This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. '
                      //     )
                      // ))
                      //   TextScroll( st,
                      //      'This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. This is the sample text for Flutter TextScroll widget. ',
                      //      style: new TextStyle(fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.w600),

                      ),
                ),
              ],
            ),
          ]),
        )));
  }
}

////////////////////////////////////////////////////////////// Бегущая строка
Future<String> getScrollText() async {
  final response = await http.get(
      //Uri.parse('https://tunduk.capital.kg:88/api/Arithemetic/getTextUrl'));
      Uri.parse('https://report.capital.kg:4051/api/Arithemetic/getTextUrl'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response.body.toString();
    //Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class MyScrollText extends StatefulWidget {
  const MyScrollText({super.key});

  @override
  State<MyScrollText> createState() => _MyScrollTextState();
}

class _MyScrollTextState extends State<MyScrollText> {
  late Future<String> futureScrollText;

  @override
  void initState() {
    super.initState();
    futureScrollText = getScrollText();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        //appBar: AppBar(title: const Text('Fetch Data Example'),),
        body: Center(
          child: FutureBuilder<String>(
            future: futureScrollText,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TextScroll(
                  snapshot.data!,
                  style: TextStyle(fontSize: 30),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////// Видео url

String getVideoText() {
//  final response = http.get(Uri.parse('https://tunduk.capital.kg:88/api/Arithemetic/getVideoUrl'));

//  if (response.statusCode == 200) {
  // If the server did return a 200 OK response,
  // then parse the JSON.
  //   return response.body.toString();
  //Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//  } else {
  // If the server did not return a 200 OK response,
  // then throw an exception.
  //   throw Exception('Failed to load album');
  // }

  String str = '';
  String str2 = '';
  http
      .get(
          //Uri.parse('https://tunduk.capital.kg:88/api/Arithemetic/getVideoUrl'))
          Uri.parse(
              'https://report.capital.kg:4051/api/Arithemetic/getVideoUrl'))
      .then((response) {
    //print("response status ${response.statusCode}");
    //print("response body ${response.body}");
    //final user = jsonDecode(response.body) as Map<String, dynamic>;

    //str = user.toString();
    str2 = response.body.toString();
    //print('${user['title']}');
    //print(str);
  });
  return str2;
}

class MyVideoText extends StatefulWidget {
  const MyVideoText({super.key});

  @override
  State<MyVideoText> createState() => _MyVideoTextState();
}

class _MyVideoTextState extends State<MyVideoText> {
  late Future<String> futureVideoText;

  @override
  void initState() {
    super.initState();
    futureVideoText = getScrollText();
  }

  Future<String> someFutureStringFunction() async {
    return Future.delayed(const Duration(seconds: 1), () => "someText");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: someFutureStringFunction(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!);
        } else {
          return Text('Loading...');
        }
      },
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //appBar: AppBar(title: const Text('Fetch Data Example'),),
        body: Center(
          child: FutureBuilder<String>(
            future: futureVideoText,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TextScroll(snapshot.data!);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  } */
}

///////////////////////////////////////////////////////////// Курсы валют

Text buildColumn() {
  return Text("ОБМЕН ВАЛЮТ");
}

FutureBuilder<String> buildFutureVideoText() {
  return FutureBuilder<String>(
    future: _futureVideoTxt,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
          //Random().nextInt(10).toString(),
          snapshot.data!,
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

FutureBuilder<List<Rate>> buildFutureBuilder840Sell() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum840,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            //Random().nextInt(10).toString(),
            snapshot.data!.first.sellRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

FutureBuilder<List<Rate>> buildFutureBuilder840Buy() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum840,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.buyRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }
      return const CircularProgressIndicator();
    },
  );
}

//////////////
FutureBuilder<List<Rate>> buildFutureBuilder978Sell() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum978,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.sellRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

FutureBuilder<List<Rate>> buildFutureBuilder978Buy() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum978,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.buyRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

//////////////
FutureBuilder<List<Rate>> buildFutureBuilder643Sell() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum643,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.sellRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

FutureBuilder<List<Rate>> buildFutureBuilder643Buy() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum643,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.buyRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

//////////////
FutureBuilder<List<Rate>> buildFutureBuilder398Sell() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum398,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.sellRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

FutureBuilder<List<Rate>> buildFutureBuilder398Buy() {
  return FutureBuilder<List<Rate>>(
    future: _futureAlbum398,
    builder: (context, snapshot) {
      final responseData = snapshot.data;
      if (snapshot.hasData) {
        return Text(
            snapshot.data!.first.buyRate.substring(0, 5).replaceAll(",", "."),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40));
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }

      return const CircularProgressIndicator();
    },
  );
}

///////////////////////////////////////////////////

class RateTableWidget extends StatefulWidget {
  const RateTableWidget({super.key});

  @override
  State<RateTableWidget> createState() {
    return _RateTableWidget();
  }
}

class _RateTableWidget extends State<RateTableWidget> {
  List<List<dynamic>> _userTransactionList = [
    ["USD", 89.30, 89.72],
    ["EUR", 94.30, 95.30],
    ["RUB", 0.960, 0.980],
    ["KZT", 0.733, 0.200]
  ];

  @override
  Widget build(BuildContext context) {
    //setState(() { _futureAlbum = getRate("", "");     });

    //var v = buildFutureBuilder();

    void handleTimeout() {
      // callback function
      //final storage = new FlutterSecureStorage();
      //String st="19";
      //storage.setItem("id", "19");
      //var st = storage.getItem('id');
      //value.then((value) => st);
      //if (st != null) { st = "19"; }
      setState(() {
        _futureAlbum840 = getRate("840");
        _futureAlbum978 = getRate("978");
        _futureAlbum643 = getRate("643");
        _futureAlbum398 = getRate("398");
        //_futureVideoTxt = getVideoText();
      }); // Do some work.
    }

    Timer scheduleTimeout([int milliseconds = 10000]) =>
        Timer(Duration(milliseconds: milliseconds), handleTimeout);

    List<DataRow> rows = [];
    scheduleTimeout(60 * 1000); // 5 seconds.
    rows.add(DataRow(cells: [
      DataCell(
        Text("Валюта",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        //buildFutureBuilder(),
      ),
      DataCell(
        Text("Покупка",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        //buildFutureBuilder(),
      ),
      DataCell(
        Text("Продажа",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        //buildFutureBuilder(),
      ),
    ]));
    for (var i = 0; i < _userTransactionList.length; i++) {
      rows.add(DataRow(cells: [
        DataCell(
          Text(_userTransactionList[i][0].toString(),
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40)),
          //buildFutureBuilder(),
        ),
        DataCell(
          //Text(_userTransactionList[i][2].toString(),
          //    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)
          //),
          (_userTransactionList[i][0].toString() == "USD")
              ? buildFutureBuilder840Buy()
              : (_userTransactionList[i][0].toString() == "EUR")
                  ? buildFutureBuilder978Buy()
                  : (_userTransactionList[i][0].toString() == "RUB")
                      ? buildFutureBuilder643Buy()
                      : (_userTransactionList[i][0].toString() == "KZT")
                          ? buildFutureBuilder398Buy()
                          : buildFutureBuilder398Buy(),
        ),
        DataCell(
          //Text(_userTransactionList[i][1].toString(),
          //    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)
          //),
          (_userTransactionList[i][0].toString() == "USD")
              ? buildFutureBuilder840Sell()
              : (_userTransactionList[i][0].toString() == "EUR")
                  ? buildFutureBuilder978Sell()
                  : (_userTransactionList[i][0].toString() == "RUB")
                      ? buildFutureBuilder643Sell()
                      : (_userTransactionList[i][0].toString() == "KZT")
                          ? buildFutureBuilder398Sell()
                          : buildFutureBuilder398Sell(),
        ),
      ]));
    }
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        //child: _getData01(_userTransactionList, context)
        child: DataTable(
          columnSpacing: 15.0,
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                'Акча',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
            DataColumn(
              label: Text(
                'Алуу',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
            DataColumn(
              label: Text(
                'Сатуу',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
          ],
          rows: rows,
        ));
  }
}

/////////////////////////////

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<List<Rate>> getRate(String curId) async {
  await storage.ready;
  var st = await storage.getItem('id');
  //if (st!=null) {officeId = st;}
  final response = await http.post(
    //Uri.parse('https://tunduk.capital.kg:88/api/Arithemetic/GetRates?officeId=19&curId=840'),
    Uri.parse(
        //  'https://tunduk.capital.kg:88/api/Arithemetic/GetRates?officeId=' +
        'https://report.capital.kg:4051/api/Arithemetic/GetRates?officeId=' +
            st +
            '&curId=' +
            curId),
    //Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    /*
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),

     */
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    //return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    List<Rate> album = (json.decode(response.body) as List)
        .map((data) => Rate.fromJson(data))
        .toList();
    return album;
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

class Rate {
  final String officeID;
  final String currencyID;
  final String buyRate;
  final String sellRate;
  final String typeID;

  const Rate(
      {required this.officeID,
      required this.currencyID,
      required this.buyRate,
      required this.sellRate,
      required this.typeID});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      officeID: json['officeID'] as String,
      currencyID: json['currencyID'] as String,
      buyRate: json['buyRate'] as String,
      sellRate: json['sellRate'] as String,
      typeID: json['typeID'].toString(),
    );
  }
}

/////////////////////////////

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Player Demo',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late Future<String> futureVideoText;
  String VideoText = "";

  FocusNode _icon1FocusNode = FocusNode();

  void handleTimeout() {
    // callback function
    setState(() {
      //_futureVideoTxt = getVideoText();
      //VideoText = getVideoText();
    }); // Do some work.
  }

  @override
  void initState() {
    super.initState();
    //futureVideoText = getVideoText();
    // getVideoText().then((message){
    //  VideoText = message;
    // });

    //VideoText = getVideoText();

    //var VideoText2 = buildFutureVideoText();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    // _controller = VideoPlayerController.networkUrl(
    //   Uri.parse(
    //     'https://online.capitalbank.kg/InternetBanking/VideoFiles/1.mp4',
    //     //  VideoText,
    //   ),
    // );

    _controller = VideoPlayerController.asset('assets/videos/1.mp4')
      ..initialize().then((_) {
        setState(() {});
      });

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Butterfly Video'),),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      /*
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Wrap the play or pause in a call to `setState`. This ensures the
            // correct icon is shown.
            setState(() {
              // If the video is playing, pause it.
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                // If the video is paused, play it.
                _controller.play();
              }
            });
          },
          // Display the correct icon depending on the state of the player.
          child: Focus(
            focusNode: _icon1FocusNode,
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          )), */
    );
  }
}
//////////////////////////

/////////////////////////////////////////////////

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key, required this.myParam});

  final String myParam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройка')),
      body: MyApp(myParam),
    );
  }
}

class User {
  const User(this.id, this.name);

  final String name;
  final String id;
}

class MyApp extends StatefulWidget {
  final String myParam;
  MyApp(this.myParam);

  State createState() => new MyAppState(myParam);
}

class MyAppState extends State<MyApp> {
  final String myParam;
  MyAppState(this.myParam);

  User? selectedUser;
  List<User> users = <User>[
    const User('3', 'Сберкасса №030-0-03'),
    const User('4', 'Сберкасса №030-0-04'),
    const User('5', 'Сберкасса №030-0-05'),
    const User('6', 'Сберкасса №030-0-06'),
    const User('19', 'ОАО Капитал Банк'),
    const User('51', 'Ошский филиал ОАО Капитал Банк'),
    const User('52', 'Сберкасса №030-02-07'),
    const User('53', 'Сберкасса №030-02-08'),
    const User('58', 'Кызыл-Кийский филиал ОАО Капитал Банк'),
    const User('59', 'Сберкасса №030-02-09'),
    const User('60', 'Сберкасса №030-03-10'),
    const User('61', 'Сберкасса №030-02-11'),
    const User('62', 'Сберкасса №030-02-12'),
    const User('63', 'Сберкасса №030-00-13'),
    const User('64', 'Сберкасса №030-00-14'),
    const User('65', 'Сберкасса №030-02-15'),
    const User('66', 'Сберкасса №030-03-16'),
    const User('67', 'Джалал-Абадский филиал ОАО Капитал Банк'),
    const User('68', 'Сберкасса №030-02-17'),
    const User('69', 'Сберкасса №030-04-18'),
    const User('70', 'Сберкасса №030-03-19'),
    const User('71', 'Араванский филиал ОАО Капитал Банк'),
    const User('72', 'Сберкасса №030-02-12'),
    const User('73', 'Караколский филиал ОАО Капитал Банк'),
    const User('74', 'Сберкасса №030-02-20'),
    const User('75', 'Сберкасса №030-00-21'),
    const User('76', 'Сберкасса №030-04-22'),
    const User('77', 'Бишкекский филиал Капитал Банк Центр'),
    const User('78', 'Сберкасса №030-00-23'),
    const User('79', 'Таласский филил ОАО Капитал Банк'),
    const User('80', 'Сберкасса №030-04-24'),
    const User('81', 'Сберкасса №030-03-25'),
    const User('82', 'Сберкасса №030-06-28'),
    const User('83', 'Сберкасса №030-00-26'),
    const User('84', 'Сберкасса №030-03-27'),
    const User('85', 'Сберкасса №030-06-30'),
    const User('86', 'Сберкасса №030-00-29'),
    const User('87', 'Сберкасса №030-04-31'),
    const User('88', 'Сберкасса № 030-07-32'),
    const User('89', 'Сберкасса №030-03-33'),
    const User('90', 'Сберкасса №030-02-34'),
    const User('91', 'Сберкасса №030-02-35'),
  ];

  @override
  void initState() {
    int id = 0;
    //storage.ready;
    //String idstr = (storage.getItem('id')!=null) ? storage.getItem('id') : "0";
    String idstr = myParam;
    for (var i = 0; i < users.length; i++) {
      if (users[i].id == idstr) {
        id = i;
      }
    }
    selectedUser = users[id];
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Center(
              child: new DropdownButton<User>(
                value: selectedUser,
                onChanged: (User? newValue) {
                  setState(() {
                    selectedUser = newValue;
                  });
                },
                items: users.map((User user) {
                  return new DropdownMenuItem<User>(
                    value: user,
                    child: new Text(
                      user.name,
                      style: new TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
            // new Text("selected user name is ${selectedUser?.name} : and Id is : ${selectedUser?.id}"),
            // new Text("Выбран офис: ${selectedUser?.name}"),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () async {
                //final storage = new FlutterSecureStorage();
                //await storage.write(key: "id", value: "19");
                //await storage.write(key: "name", value: "selectedUser?.name");
                await storage.setItem("id", selectedUser?.id.toString());
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

/*

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];


class DropdownButtonApp extends StatelessWidget {
  const DropdownButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //appBar: AppBar(title: const Text('DropdownButton Sample')),
        body: //const Center(
        DropdownButtonExample(),
        //),
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

 */
/////////////////////////////
