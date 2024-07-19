import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_widgets/view/bottom_bar.dart';
import 'package:ios_widgets/view/cupertino_context_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(


      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      home: BottomBarNavigation(),
      // home: CupertinContextMenus(),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:user_trace/view/home_screen.dart';
import 'package:user_trace/view/notification_accept_screen.dart';
import 'package:user_trace/view/responder_screen.dart';
import 'package:user_trace/view/signup_screen.dart';

import 'di/home_binding.dart';
import 'view/help_screen.dart';
import 'view/lading_screen.dart';
import 'di/login_binding.dart';
import 'firebase_options.dart';
import 'view/request_detail_screen.dart';
import 'view/verification_code.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
    playSound: true,
    showBadge: true
);


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';


@pragma('vm:entry-point')
Future<void>_firebaseMessagingBackgroundHandler(RemoteMessage message)async{

  await Firebase.initializeApp();
  print('A bg message just showed up: ${message}');




}






@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
  print("Background notification clicked: ${response.payload}");


  if (response.payload != null) {
    // Store the payload to handle navigation when the app is brought to foreground
    Get.toNamed(response.payload!,);



  }
}

void _onDidReceiveNotificationResponse(NotificationResponse response) {
  print("Foreground notification clicked: ${response.payload}");
  if (response.payload != null) {
    Get.toNamed(response.payload!, );
  }
}

var auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();




  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final List<DarwinNotificationCategory> darwinNotificationCategories =
  <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      // didReceiveLocalNotificationStream.add(
      //   ReceivedNotification(
      //     id: id,
      //     title: title,
      //     body: body,
      //     payload: payload,
      //   ),
      // );
    },
    notificationCategories: darwinNotificationCategories,
  );

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin
    ,);


  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,

  );


  await notificationFistCall();

  await initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Track App',
      initialNotificationContent: 'Running....',
      foregroundServiceNotificationId: 041,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // final box = GetStorage();
  // // await preferences.reload();
  // final log = box.read('log') ?? <String>[];
  // log.add(DateTime.now().toIso8601String());
  // await box.write('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  // DartPluginRegistrant.ensureInitialized();

  /// OPTIONAL when use custom notification

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });


  // bring to foreground
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // flutterLocalNotificationsPlugin.show(
        //   888,
        //   'COOL SERVICE',
        //   'Awesome ${DateTime.now()}',
        //   const NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       'my_foreground',
        //       'MY FOREGROUND SERVICE',
        //       icon: 'ic_bg_service_small',
        //       ongoing: true,
        //     ),
        //   ),
        // );
        _uploadLocation();

        // print("======appService.getId()====>${appService.getId()}");

        // print("===DateTime==>${DateTime.now()}");


        // if (id != null) {
        //   await FirebaseFirestore.instance.collection("userss").doc(id).update({
        //     "lat": position.latitude,
        //     "long": position.longitude,
        //   });
        // }

        // if you don't using custom notification, uncomment this

        service.setForegroundNotificationInfo(
          title: "Track App",
          content: "Active",
          // content: "Updated at ${DateTime.now()}",
        );
      }
    }

    // service.invoke(
    //   'update',
    //   {
    //     "current_date": DateTime.now().toIso8601String(),
    //     "device": device,
    //   },
    // );
  });
}

_uploadLocation() async
{
  var _user = auth.currentUser;
  if(_user != null)
  {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    var uid = _user.uid;
    var latitude = position.latitude;
    var longitude = position.longitude;
    try {
      CollectionReference damRef = _firestore.collection('Users');
      await damRef.doc(uid).update({
        'lat': latitude,
        'long': longitude,
      });
      print(
          "_uploadLocation $latitude, longitude: $longitude,");
    } catch (e) {
      print('Error updating data in Firestore: $e');
    }
  }

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey(debugLabel: 'Main Navigator');

  @override
  Widget build(BuildContext context) {

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
            navigatorKey: navigatorKey,
            title: 'User Trace',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),



            initialRoute: "/login",
            // initialRoute: "/notificationAcceptScreen",
            getPages: [
              GetPage(
                name: "/login",
                page: () =>  SignupScreen(),
                binding: LoginBinding(),
              ),
              GetPage(
                name: "/verification",
                page: () => VerificationPage(),
                binding: LoginBinding(),
              ),
              GetPage(
                  name: "/landing",
                  page: () =>  LandingPage(),
                  binding: HomeBinding()
              ),
              GetPage(
                  name: "/home",
                  page: () => const HomeScreen(),
                  binding: HomeBinding()
              ),
              GetPage(
                  name: "/responderScreen",
                  page: () =>  const ResponderScreen(),
                  binding: HomeBinding()

              ),
              GetPage(
                  name: "/helpScreen",
                  page: () => const HelpScreen(),
                  binding: HomeBinding()
              ),
              GetPage(
                  name: "/requestDetailScreen",
                  page: () =>     const RequestDetailScreen(),
                  binding: HomeBinding()
              ),

              GetPage(
                  name: "/notificationAcceptScreen",
                  page: () =>   NotificationAcceptScreen(),
                  binding: HomeBinding()
              ),

            ]
        );
      },
    );
  }
}


Future<void> notificationFistCall( ) async {


  // final homc = Get.put(HomeController());

//  homc.fetchDeviceToken();


  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,

  );


  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    var isAcceptRequest =  message.data["isAcceptValue"];
    if(isAcceptRequest=="true"){
      print("hello flutter isAcceptRequest  main ");
      Get.toNamed("/responderScreen",arguments: message.data);
      // Get.to(const ResponderScreen(), arguments: message.data);
    }

    else
    {
      if(message.data.isNotEmpty )
      {
        Get.toNamed("/notificationAcceptScreen",arguments: message.data);
      }

    }
  });



  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    // handleMessageOpenedApp1(message);
    var isAcceptRequest =  message.data["isAcceptValue"];
    // _handleMessage(message);
    print("isAcceptRequest=======$isAcceptRequest");
    if(isAcceptRequest=="true"){

      Get.toNamed("/responderScreen",arguments: message.data);
    }else
    {
      if(message.data.isNotEmpty )
      {
        Get.toNamed("/notificationAcceptScreen",arguments: message.data);
      }

    }
  });


}


void _handleMessageOpenedApp(BuildContext context, RemoteMessage message) {
  print('A new onMessageOpenedApp event was published!');
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  print("+++++++++++++++++++++++notification++${notification}");
  if (notification != null && android != null) {
    showDialog(
      context: context,
      builder: (_) {
        print("Title: ${notification.title}");
        return AlertDialog(
          title: Text(notification.title ?? 'No Title'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.body ?? 'No Body',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to SpecificPage when button is clicked
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LandingPage(),
                      ),
                    );
                  },
                  child: const Text('Go to Specific Page'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _handleMessage(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null ) {
    var docid =  message.data['docId'];
    print("+++++_______-docid${docid}");
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      payload: '/notificationAcceptScreen',
      NotificationDetails(
        android: AndroidNotificationDetails(
          subText: "no user",
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          silent: false,
        ),
      ),
    );
  }
  if(message.data.isNotEmpty)
  {
    flutterLocalNotificationsPlugin.show(
      1,
      'notification.title',
      'notification.body',
      payload:   '/notificationAcceptScreen',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          silent: false,

        ),


      ),
    );
  }
}


void handleMessageOpenedApp1(RemoteMessage message) {
  String? screen = message.data['screen'];
  if (screen != null) {

    Get.toNamed(screen);
  }
}







Future<Position> locateUser() async {
  return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:googleapis_auth/auth_io.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user_trace/Model/request_model.dart';
import 'package:user_trace/Model/user_model.dart';
import 'package:user_trace/controller/landing/landing_controller.dart';

import '../data/resAutocomplete.dart';
import '../rep/api_base_helper.dart';
import '../utils/dialog.dart';

class HomeController extends GetxController {
  Razorpay razorpay = Razorpay();


  bool isLoading = false;
  bool notificationSuccess = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final TextEditingController detailController = TextEditingController();
  final TextEditingController acceptMobileNumberC = TextEditingController();
  final TextEditingController acceptNameC = TextEditingController();

  List<UserLocation> userLocations = [];

  LatLng? tappedLocation;
  LatLng? currentTapedLocation;

  LatLng? currentLocation;
  LatLng? mapLatLng;

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // String? deviceId;
  double? latitude;
  double? longitude;
  StreamSubscription<Position>? positionStream;

  GoogleMapController? googleMapController;

  var auth = FirebaseAuth.instance;

  String? deviceToken;
  String? refreshToken;
  String? bearerToken;
  List<UserLocation>? nearbyUserLocations;
  UserLocation? userLocationShow;
  List<UserLocation> usergetList = [];

  double? getLatitude;
  double? getLongitude;

  String? mapStyle;
  User? user;
  String? uid;
  var sessionToken = '';
  bool allowSearch = false;
  String? detailData;
  List<Prediction> predictions = [];
  final currentcontext = Get.context;

  @override
  void onInit() {
    super.onInit();
    checkAndRequestNotificationPermission();
    fetchDeviceToken();
    sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    _loadMapStyle();
    checkUser();

    initializeRazorpayment();

    allMethods();
  }

  @override
  void onClose() {
    positionStream?.cancel();
    detailController.dispose();
    razorpay.clear();

    super.onClose();
  }

  _loadMapStyle() {
    rootBundle.loadString('assets/map_style.txt').then((string) {
      mapStyle = string;
    });
  }

  Future<void> allMethods() async {
//    await fetchDeviceId();
    // getUserData();
    await fetchDeviceToken();
    startLocationUpdates();
    fethDataUser();
    generateBearerToken();
  }

  checkUser() {
    var user = auth.currentUser;
    if (user != null) {
      this.user = user;
      uid = user.uid;

      print("kdfjuid ==========$uid");
    }
    print("+++++ ==========$uid");
  }

  void updateTappedLocation(
      LatLng latLng,
      ) {
    tappedLocation = latLng;
    print("tapeld location${latLng}");
    currentTapedLocation =
        LatLng(tappedLocation!.latitude, tappedLocation!.longitude);
    print("++++++++++++++++)+++++++++$currentTapedLocation");
    update();
  }

  Future<void> acceptUpdateRequest(
      String acceptDocId, String acceptToken) async {
    try {
      if (acceptDocId == null) {
        throw Exception('acceptDocId is null');
      }
      DocumentReference userDoc =
      _firestore.collection('Requests').doc(acceptDocId);
      DocumentSnapshot docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        print("accept docid = = $acceptDocId");
        print("accept acceptTokenUser = = $acceptToken");



        sendAcceptNotification(acceptToken,acceptDocId);

        await userDoc.update({
          'isAcceptRequest': true,
          'acceptName': user!.displayName,
          'acceptMobileNumber': user!.phoneNumber
        });


        print('User data updated successfully.');
      } else {
        print('accep document does not exist.');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude);
  }

  Future<void> checkAndRequestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    // If the permission is not granted, request it.
    if (!status.isGranted) {
      Permission.locationAlways;
      status = await Permission.notification.request();
      // You can check the status after the request.
    } else if (status.isPermanentlyDenied) {
      print(
          'Notification permission permanently denied. Please enable it from settings.');
      // Optionally, open app settings.
      openAppSettings();
    } else {
      print('Notification permission already granted.');
    }
  }

  void startLocationUpdates() {
    positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen((Position position) async {
          latitude = position.latitude;
          longitude = position.longitude;
          currentLocation = LatLng(position.latitude, position.longitude);
          mapLatLng ??= LatLng(position.latitude, position.longitude);

          if (uid != null && latitude != null && longitude != null) {
            try {
              CollectionReference damRef = _firestore.collection('Users');
              await damRef.doc(uid).update({
                'lat': latitude,
                'long': longitude,
                'deviceToken': deviceToken,
              });
              print(
                  "Updated Firestore with latitude: $latitude, longitude: $longitude, deviceToken: $deviceToken");
            } catch (e) {
              print('Error updating data in Firestore: $e');
            }
          } else {
            print('Error: User ID, latitude, or longitude is null.');
          }

          update();
          print("Updated latitude: $latitude, longitude: $longitude");
        });
  }

  fetchDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        deviceToken ??= token;
        update();
        print("Device Token: $token");
      } else {
        print("Failed to retrieve device token");
      }
    } catch (e) {
      print("Error fetching device token: $e");
    }
  }

  Future<String?> getDeviceId() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await _deviceInfoPlugin.androidInfo;
      return androidDeviceInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await _deviceInfoPlugin.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    }
    return null;
  }

  Future<void> addRequestMessage(
      List<String?> tokens, List<String> nearUserId) async {
    if (user != null && latitude != null && longitude != null) {
      int currentNotificationCount = await retrieveNotificationCount();
      print("currentNotificationCount$currentNotificationCount");

      if ( currentNotificationCount < 5) {
        print("Device Token: $deviceToken");
        RequestMessage requestMessage = RequestMessage(
          id: uid ?? user!.uid,
          // username: loginc.user!.displayName ?? '',
          username: user!.displayName ?? '',
          lat: latitude!,
          long: longitude!,
          createdon: FieldValue.serverTimestamp(),
          deviceToken: deviceToken ?? "",
          isAcceptRequest: false,
          // mobileNumber: loginc.user!.phoneNumber ?? '',
          mobileNumber: user!.phoneNumber ?? '',
          details: detailController.text.toString() ?? "",
        );
        try {
          DocumentReference damRef = _firestore.collection('Requests').doc();
          await damRef.set(requestMessage.toJson());


          await updateNotificationCount(currentNotificationCount + 1);

          print("hello flutter");


          await updateNotificationCount(currentNotificationCount + 1);

          sendNotificationToDevice(tokens, damRef.id, nearUserId);

          print('Request message added and notification sent.');
        } catch (e) {
          print('Error adding request message and sending notification: $e');
        }
      } else {
        CustomDialog.show(
          context: currentcontext!,
          title: "Notification Limit Reached",
          content:
          "Unable to send more notifications. Please make a payment to continue.",
          cancelButtonText: "Cancel",
          payButtonText: "Pay",
          onCancel: () {
            Get.back();
          },
          onPay: () {
            razorPayment();
            Get.back();
          },
        );

      }
    } else {
      print('Error: User, latitude, or longitude is null.');
    }
  }

  Future<void> addRequestMessagePaymentSuccess(
      List<String?> tokens, List<String> nearUserId) async {
    if (user != null && latitude != null && longitude != null) {
      print("Device Token: $deviceToken");
      RequestMessage requestMessage = RequestMessage(
        id: uid ?? user!.uid,
        // username: loginc.user!.displayName ?? '',
        username: user!.displayName ?? '',
        lat: latitude!,
        long: longitude!,
        createdon: FieldValue.serverTimestamp(),
        deviceToken: deviceToken ?? "",
        isAcceptRequest: false,
        // mobileNumber: loginc.user!.phoneNumber ?? '',
        mobileNumber: user!.phoneNumber ?? '',
        details: detailController.text.toString() ?? "",
      );
      try {
        DocumentReference damRef = _firestore.collection('Requests').doc();
        await damRef.set(requestMessage.toJson());

        sendNotificationToDevice(tokens, damRef.id, nearUserId);
        print("success payment notificaon");
        print('Request message added and notification sent.');
      } catch (e) {
        print('Error adding request message and sending notification: $e');
      }
    } else {
      print('Error: User, latitude, or longitude is null.');
    }
  }

  Future<int> retrieveNotificationCount() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('Users').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        var notification = data?['notificationCount'] ?? 0;
        var notificationPaidLimit = data?['notificationPaidLimit'] ?? false;
        print("==================================${notification}");
        print("==================================${notificationPaidLimit}");
        return data?['notificationCount'] ?? 0;
      } else {
        await _firestore
            .collection('Users')
            .doc(uid)
            .set({'notificationCount': 0});
        return 0;
      }
    } catch (e) {
      print('Error retrieving notification count: $e');
      return 0;
    }
  }

  Future<void> updateNotificationCount(int count) async {
    try {
      await _firestore
          .collection('Users')
          .doc(uid)
          .update({'notificationCount': count});
      print('Notification count updated successfully.');
    } catch (e) {
      print('Error updating notification count: $e');
    }
  }

  void fethDataUser() {
    _firestore
        .collection("Users")
    //   .where('id',isNotEqualTo: uid)
        .snapshots()
        .listen((querySnapshot) {
      userLocations.clear();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        if (data.containsKey('lat') &&
            data.containsKey('long') &&
            data.containsKey('id')) {
          var id = data['id'];
          if (uid == id) {
            var lat = data['lat'];
            var long = data['long'];
            if (lat != null && long != null && lat != 0.0 && long != 0.0) {
              currentLocation ??= LatLng(lat, long);
              mapLatLng ??= LatLng(lat, long);
            }
            deviceToken = data['deviceToken'];
          } else {
            UserLocation userLocation = UserLocation(
                lat: data['lat'],
                long: data['long'],
                id: data['id'],
                deviceToken: data['deviceToken'],
                username: data['username']);
            userLocations.add(userLocation);
          }

          // print(
          //     "User Latitude: ${userLocation.lat}, Longitude: ${userLocation.long}, TokenFeth ${userLocation.deviceToken}");

          update();
        } else {
          print(
              "Document ${doc.id} does not contain latitude and/or longitude fields.");
        }
      }
      print("Total users fetched: ${userLocations.length}");
    }, onError: (e) {
      print("Error fetching user data: $e");
    });
  }

/*
  void findAndNotifyNearbyUsers() async {
    nearbyUserLocations = userLocations.where((userLocation) {
      LatLng userLatLng = LatLng(userLocation.lat, userLocation.long);
      double distance = calculateDistance(mapLatLng!, userLatLng);
      print('Distance from tapped location to $distance mtr');
      return distance <= 750;
    }).toList();
    String? currentUserDeviceToken = deviceToken;
    print("cureent device tokne${deviceToken}");
    List<String?> deviceTokens = nearbyUserLocations!
        .where((userLocation) =>
            userLocation.deviceToken != currentUserDeviceToken)
        .map((userLocation) => userLocation.deviceToken)
        .where((token) => token != null)
        .cast<String>()
        .toList();
    if (deviceTokens.isNotEmpty) {
      print("divece token not null ${deviceTokens.length}");

      addRequestMessage(deviceTokens);
    } else {
      print('No device tokens available for nearby users');
    }
  }
*/

  Future<void> findAndNotifyNearbyUsers() async {
    nearbyUserLocations = userLocations.where((userLocation) {
      LatLng userLatLng = LatLng(userLocation.lat, userLocation.long);
      double distance = calculateDistance(mapLatLng!, userLatLng);
      print('Distance from tapped location to $distance meters');
      return distance <= 500;
    }).toList();

    String? currentUserDeviceToken = deviceToken;
    print("Current device token: $deviceToken");

    List<Map<String, dynamic>> tokensAndIds = nearbyUserLocations!
        .where((userLocation) =>
    userLocation.deviceToken != currentUserDeviceToken)
        .map((userLocation) {
      return {
        'id': userLocation.id,
        'deviceToken': userLocation.deviceToken,
      };
    }).toList();

    if (tokensAndIds.isNotEmpty) {
      tokensAndIds.forEach((item) {
        print("User ID: ${item['id']}, Device Token: ${item['deviceToken']}");
      });
      List<String> deviceTokens = tokensAndIds
          .where((item) => item['deviceToken'] != null)
          .map((item) => item['deviceToken'] as String)
          .toList();
      List<String> nearUserId = tokensAndIds
          .where((item) => item['id'] != null)
          .map((item) => item['id'] as String)
          .toList();
      print("Device tokens found for nearby users: ${deviceTokens.length}");

      addRequestMessage(deviceTokens, nearUserId);
    } else {
      print('No device tokens available for nearby users');
    }
  }
  Future<void> findAndNotifyNearbyUsers1() async {
    nearbyUserLocations = userLocations.where((userLocation) {
      LatLng userLatLng = LatLng(userLocation.lat, userLocation.long);
      double distance = calculateDistance(mapLatLng!, userLatLng);
      print('Distance from tapped location to $distance meters');
      return distance <= 500;
    }).toList();

    String? currentUserDeviceToken = deviceToken;
    print("Current device token: $deviceToken");

    List<Map<String, dynamic>> tokensAndIds = nearbyUserLocations!
        .where((userLocation) =>
    userLocation.deviceToken != currentUserDeviceToken)
        .map((userLocation) {
      return {
        'id': userLocation.id,
        'deviceToken': userLocation.deviceToken,
      };
    }).toList();

    if (tokensAndIds.isNotEmpty) {
      tokensAndIds.forEach((item) {
        print("User ID: ${item['id']}, Device Token: ${item['deviceToken']}");
      });
      List<String> deviceTokens = tokensAndIds
          .where((item) => item['deviceToken'] != null)
          .map((item) => item['deviceToken'] as String)
          .toList();
      List<String> nearUserId = tokensAndIds
          .where((item) => item['id'] != null)
          .map((item) => item['id'] as String)
          .toList();
      print("Device tokens found for nearby users: ${deviceTokens.length}");

      addRequestMessagePaymentSuccess(deviceTokens, nearUserId);
    } else {
      print('No device tokens available for nearby users');
    }
  }

  void toggleSearch() {
    allowSearch = !allowSearch;
    predictions = [];
    update();
  }

  void searchAddress(String s) {
    if (s.isNotEmpty) {
      _searchPlace(input: s);
    } else {
      sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
      predictions = [];
      update();
    }
  }

  Future<void> _searchPlace({required String input}) async {
    Map map = Map();
    map.putIfAbsent('input', () => input);
    map.putIfAbsent('key', () => 'AIzaSyDCGwhmssjcE4XnKOfKYFZEhow23mlYeG0');
    map.putIfAbsent('sessiontoken', () => sessionToken);
    // map.putIfAbsent('types', () => 'geocode');

    // if(currentLocation != null)
    // {
    //   map.putIfAbsent('location', () => '${currentLocation!.latitude},${currentLocation!.longitude}');
    //   map.putIfAbsent('radius', () => '50000');
    //   if(input.length < 10)
    //     map.putIfAbsent('strictbounds', () => '');
    // }
    //else
    // if(_countryCode != '')
    //   map.putIfAbsent('components', () => 'country:$_countryCode');

    await ApiBaseHelper(
        request: 'place/autocomplete/json?',
        parms: map,
        showProgress: false,
        isBase2Need: true)
        .get('')
        .then((value) {
      print('locationdata $value');
      ResAutocomplete resAutocomplete = ResAutocomplete.fromJson(value);
      if (resAutocomplete.status == 'OK') {
        predictions = resAutocomplete.predictions ?? [];
        update();
      }
    });
  }

  Future<void> placeDetails({String? place_id}) async {
    allowSearch = false;
    update();
    Map map = Map();
    map.putIfAbsent('place_id', () => place_id);
    map.putIfAbsent('key', () => 'AIzaSyDCGwhmssjcE4XnKOfKYFZEhow23mlYeG0');
    map.putIfAbsent('fields', () => 'geometry');
    map.putIfAbsent('sessiontoken', () => sessionToken);
    await ApiBaseHelper(
        request: 'place/details/json?',
        parms: map,
        showProgress: false,
        isBase2Need: true)
        .get('')
        .then((value) {
      print('placeDetails::::::::: $value');
      var status = value['status'];
      sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
      if (status == 'OK') {
        var result = value['result'];
        var geometry = result['geometry'];
        var location = geometry['location'];
        var lat = location['lat'];
        var lng = location['lng'];
        print('placeDetails:::::::::==========> $lat: $lng');
        mapLatLng = LatLng(lat, lng);
        update();
        _moveMap();
      }
    });
  }

  Future<void> _moveMap() async {
    if (mapLatLng != null) {
      CameraPosition _kLake = CameraPosition(
        //   bearing: 192.8334901395799,
          target: mapLatLng ?? const LatLng(0.0, 0.0),
          //   tilt: 59.440717697143555,
          zoom: 15);
      await googleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(_kLake));
    }
  }

  void setController(GoogleMapController controller) {
    googleMapController = controller;
  }

  Future<void> sendNotificationToDevice(
      List<String?> tokens, String docId, List<String> nearUserId) async {
    isLoading = true;
    update();
    bearerToken ??= await generateBearerToken();
    print("Bearer Token = =$bearerToken");
    print("+++++++++++++++++++++++++token ${tokens.length}");
    print("+++doc id ++docId ${docId}");
    if (tokens.isNotEmpty) {
      // print("toke++++++++${tokens.length}");
      String serverKey = 'Bearer $bearerToken';
      final Uri url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/nftrace-32ff6/messages:send');
      final headers = {
        'Authorization': serverKey,
      };
      for (String? token in tokens) {
        print("tokens===========#${token}");
        final body = jsonEncode({
          "message": {
            "token": token,
            "notification": {
              "body": detailController.text.toString(),
              "title": user!.displayName,
            },
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "screen": "notificationAcceptScreen",
              "sound": "default",
              "status": "done",
              "details": detailController.text.toString(),
              "title": user!.displayName,
              "docId": docId,
              "isAcceptValue": "false",
              'token': deviceToken,
              'type': '1',
              "isRequest": "true",
              'sid': "$uid",
              'name': user!.displayName,
            },
            "android": {"priority": "high"},
          }
        });
        try {
          final response = await http.post(url, headers: headers, body: body);
          print('Statuscode${response.statusCode}');
          // print("bodY${response.body}");
          if (response.statusCode == 200) {
            print('Notification sent successfully');
            for (String userId in nearUserId) {
              DocumentReference damUsers =
              _firestore.collection('Users').doc(userId);
              await damUsers.update({
                'requestId': docId,
                'isRequest': true,
              });
            }

            /*    Get.snackbar(
              "Success",
              "Notification sent successfully",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );*/

            // update();
            Get.back();

            // Get.toNamed('/landing');
            isLoading = false;
            update();
          } else {
            isLoading = false;
            update();
            print('Failed to send notification: ${response.body}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error sending notification: $e');
          }
        }
      }
    } else {
      print('Device tokens list is empty');
    }
  }

  Future<void> sendAcceptNotification(
      String acceptToken,
      [String?acceptDocId]
      ) async {
    isLoading = true;
    update();
    print("aceepter = docid ==${acceptDocId}");
    bearerToken ??= await generateBearerToken();
    print("Bearer Token = =$bearerToken");
    print("+++++++++++++++++++++++++token $acceptToken");
    if (acceptToken.isNotEmpty) {
      String serverKey = 'Bearer $bearerToken';
      final Uri url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/nftrace-32ff6/messages:send');
      final headers = {
        // 'Content-Type': 'application/json',
        'Authorization': serverKey,
      };
      print("tokens===========#$acceptToken");
      final body = jsonEncode({
        "message": {
          "token": acceptToken,
          "notification": {
            "body": user!.phoneNumber,
            "title": user!.displayName,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "sound": "default",
            "status": "done",
            "isAcceptValue": "true",
            "acceptPhoneNumber": user!.phoneNumber,
            "acceptUserName": user!.displayName,
            "acceptDocId": acceptDocId,

            // 'token':deviceToken
            // "screen": "VerificationPage",
          },
          /*"android": {
            "priority": "high"
          }*/
        }
      });
      try {
        final response = await http.post(url, headers: headers, body: body);
        print('Statuscode${response.statusCode}');
        if (response.statusCode == 200) {
          print('Accept Notifcation Notification sent successfully');




/*
          Get.snackbar(
            "Success",
            "Respond sent successfully",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );*/
          isLoading = false;
          // update();
        } else {
          print('Failed to send notification: ${response.body}');
        }
      } catch (e) {
        isLoading = false;
        update();
        if (kDebugMode) {
          print('Error sending notification: $e');
        }
      }
    } else {
      isLoading = false;
      update();
      print('Device tokens list is empty')  ;
    }
  }

  Future<String> generateBearerToken() async {
    final serviceAccount =
    await rootBundle.loadString('assets/service_account.json');
    final Map<String, dynamic> serviceAccountJson = json.decode(serviceAccount);
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final authClient = await clientViaServiceAccount(credentials, scopes);
    final token = authClient.credentials.accessToken.data;

    print('Generated Bearer Token: $token');
    bearerToken = token;
    return token;
  }

  void initializeRazorpayment() {
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
  }

  void razorPayment() {
    var options = {
      // 'key': 'rzp_live_ILgsfZCZoFIKMb',
      'key': 'rzp_test_GcZZFDPP0jHtC4',
      'amount': 100,
      'name': 'User Trace',
      'currency': 'INR',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    CustomDialog.show(
      context: currentcontext!,
      title: "Payment Failed",
      content: "\n${response.message}",
      cancelButtonText: "OK",
      onCancel: () {
        Get.back();
      },
    );
  }

  Future<void> handlePaymentSuccessResponse(
      PaymentSuccessResponse response) async {

    print('Hello flutter is task perform is a');



    await findAndNotifyNearbyUsers1();


    print("hello flutter");


/*
    CustomDialog.show(
      context: currentcontext!,
      title: "Payment Successful",
      content: "${response.paymentId}",
      cancelButtonText: "OK",
      onCancel: () {
        Get.back();
      },
    );
*/




  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    CustomDialog.show(
      context: currentcontext!,
      title: "External Wallet Selected",
      content: "${response.walletName}",
      cancelButtonText: "OK",
      onCancel: () {
        Get.back();
      },
    );
  }
}
