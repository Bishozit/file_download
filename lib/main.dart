import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
   const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
   final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
   flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final imageUrl = 'https://drive.google.com/file/d/1e5c7cArWCRpLMFIFVOr14Y4eOiNcbbzV/view?usp=drive_link';
  bool downloading = false;
  var progressString = "";
  final Dio dio = Dio();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> showNotification(String title, String body) async{
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('download_channel',
      'Download Notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,);
     const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'download',
    );
  }

Future<void> downloadFile() async {
  try {
    var dir = await getApplicationDocumentsDirectory();
    await dio.download(imageUrl, "${dir.path}/myimage.jpg",
        onReceiveProgress: (received, total) {
      setState(() {
        downloading = true;
        progressString = ((received / total) * 100).toStringAsFixed(0) + "%";
        showNotification('Downloading', 'Download progress: $progressString');
      });
    });
    setState(() {
      downloading = false;
      progressString = "Completed";
      showNotification('Download Completed', 'File downloaded successfully');
    });
  } catch (e) {
    print(e);
    setState(() {
      downloading = false;
      progressString = "Error";
      showNotification('Error', 'Download failed');
    });
  }
}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Download"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.35),
              Container(
                width: 200,
                child: FloatingActionButton(
                  onPressed: () {
                    downloadFile();
                  },
                  backgroundColor: Colors.black,
                  child: const Text(
                    "Download",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              downloading
                  ? Container(
                      height: size.height * 0.2,
                      width: size.width * 0.6,
                      color: Colors.black,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           CircularProgressIndicator(),
                           SizedBox(height: 10),
                           Text(
                            "Downloading file...",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    )
                  : const Text("Not Downloading"),
            ],
          ),
        ),
      ),
    );
  }
}

