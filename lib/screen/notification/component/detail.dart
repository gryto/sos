import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../home.dart';
import '../../../src/api.dart';
import '../../../src/constant.dart';
import '../../../src/device_utils.dart';
import '../../../src/preference.dart';
import '../../../src/toast.dart';
import '../../../src/utils.dart';

class NotificationsDetail extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final id;
  final status;
  const NotificationsDetail({Key? key, required this.id, required this.status})
      : super(key: key);

  @override
  _NotificationsDetailState createState() => _NotificationsDetailState();
}

class _NotificationsDetailState extends State<NotificationsDetail> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  var idUser = '';
  var userrr = '';
  var idUserLogin = "";

  String fullname = "";
  int userId = 0;

  final ScrollController _scrollController = ScrollController();
  var offset = 0;
  var limit = 10;

  var idhandle = '';

  @override
  void initState() {
    getData(widget.id);
    print("widgetid");
    print(widget.id);
    super.initState();
  }

  getData(id) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var idUser = await sharedPref.getPref("id_usr");
      var url = ApiService.sosDetail;
      var uri = '$url/$id';
      // print(uri);
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);
      // print(uri);
      // print(response.statusCode.toString());
      // print(content.toString());

      if (content['status'] == '200') {
        print("object");
        // listData = content['data'];
        listData.add(content['data']);
        setState(() {
          idUserLogin =idUser;
          print("userlogin");
          print(idUserLogin);
        });
        // print(listData);
      } else {
        // ignore: use_build_context_synchronously
        // onBasicAlertPressed(context, 'Error', content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // onBasicAlertPressed(context, 'Error', e.toString());
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = false;
    });
  }

  Position? _currentPosition;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      // _getAddressFromLatLng(_currentPosition!);
      handleSos(widget.id);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  handleSos(id) async {
    final params = {
      "latitude": '${_currentPosition?.latitude ?? ""}',
      "longitude": '${_currentPosition?.longitude ?? ""}',
      // "attachment": receiverId,
    };

    try {
      idUser = await sharedPref.getPref("id_usr");
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosHandle;
      var uri = '$url/$id';
      // print(uri);
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()}, body: params);
      var content = json.decode(response.body);
      // print(uri);
      // print(response.statusCode.toString());
      // print(content.toString());

      if (content['status'] == '200') {
        toastShort(context, "SOS Telah Dihandle");
        userrr = idUser.toString();
        //   print("iseuserrrr");
        // print(content.toString());
      } else {
        // ignore: use_build_context_synchronously
        // onBasicAlertPressed(context, 'Error', content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // onBasicAlertPressed(context, 'Error', e.toString());
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.white,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail Notification",
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 1.2575,
            letterSpacing: 0.6000000238,
            color: const Color(0xff1e2022),
          ),
        ),
        actions: const [],
      ),
      body: Container(
        height: DeviceUtils.getScaledHeight(context, 1),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: listDetail(),
        ),
      ),
    );
  }

  Widget listDetail() {
    double h = MediaQuery.of(context).size.height - 20;
    double w = MediaQuery.of(context).size.width - 0;
    if (listData.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const HeaderWithSearchBar(),
          const SizedBox(
            height: 10,
          ),
          ListView.separated(
            padding:
                const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              var row = listData[index];
              // print(row['id'].toString());
              // var message = row['status'];
              // var item = listData[index];
              var senderId= row['sender_user_id'].toString();
              print("kkkkk");
              print(senderId);

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_alarm),
                    title: Text(
                      "Status",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      row['status'] ?? " ",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.message),
                    title: Text(
                      "Message",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      row['message'] ?? " ",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(
                      "Location",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      row['location'] ?? " ",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(),
                  widget.status == "Request" && senderId  != idUserLogin
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: SizedBox(
                            width: w,
                            height: h / 14.7,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: clrPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                handleSos(row['id'].toString());
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => MainTabBar(
                                              page: 1,
                                              id: idUser.toString(),
                                            )),
                                    (Route<dynamic> route) => false);
                              },
                              child: const Text(
                                "Handle",
                                style: TextStyle(
                                    fontSize: 19, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.all(0),
                        ),
                ],
              );
            },
            separatorBuilder: (_, index) => const SizedBox(
              height: 5,
            ),
            itemCount: listData.isEmpty ? 0 : listData.length,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_clock,
                  size: 90.0,
                  color: Colors.grey.shade400,
                ),
                Text(
                  "Ooops, Belum Ada User Dalam List Chat Anda!",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ],
      );
    }
  }
}
