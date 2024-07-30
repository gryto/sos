import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sos/src/constant.dart';
import 'package:sos/src/loader.dart';
import '../../src/api.dart';
import '../../src/device_utils.dart';
import '../../src/preference.dart';
import 'package:http/http.dart' as http;

import 'component/list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  List listUser = [];

  String fullname = "";
  int userId = 0;

  final ScrollController _scrollController = ScrollController();
  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    listData.clear();
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

  Future<void> _pullRefresh() async {
    setState(() {
      listData.clear();
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clrBackgroundLight,
      body: Container(
        height: DeviceUtils.getScaledHeight(context, 1),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: clrBackgroundLight,
        ),
        child: RefreshIndicator(
          color: clrPrimary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1500));
            setState(() {
              isProcess = true;
              listData.clear();
              _pullRefresh();
            });
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: !isProcess
                ? HistoryList(data: listData)
                : loaderDialog(context),
          ),
        ),
      ),
    );
  }
}
