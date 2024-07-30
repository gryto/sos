import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sos/src/loader.dart';
import '../../src/api.dart';
import '../../src/device_utils.dart';
import '../../src/preference.dart';
import '../../src/utils.dart';
import 'package:http/http.dart' as http;

import 'component/list.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key? key,
  }) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  List id = [];

  String fullname = "";
  int userId = 0;

  final ScrollController _scrollController = ScrollController();
  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosAll;
      var uri = url;
      // print(uri);
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);
      // print(response.statusCode.toString());
      // print(content.toString());

      if (content['status'] == '200') {
        print("object");
        listData = content['data'];
        // print(listData);
        for (int i = 0; i < content['data'].length; i++) {
           id.add(content['data'][i]['sos_id']);
          }
          // print(id);
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
          "Notification",
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.2575,
            letterSpacing: 1,
            color: Colors.black87,
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
          child: !isProcess
              ? NotificationList(data: listData, sosId:id)
              : loaderDialog(context),
        ),
      ),
    );
  }
}
