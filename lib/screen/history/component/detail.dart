import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sos/src/constant.dart';
import '../../../src/api.dart';
import '../../../src/device_utils.dart';
import '../../../src/preference.dart';
import '../../../src/toast.dart';
import '../../../src/utils.dart';
import 'package:badges/badges.dart' as badges;

// ignore: must_be_immutable
class HistoryDetail extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  String sosId;

  final Map? listDetail;
  HistoryDetail({
    Key? key,
    required this.sosId,
    required this.listDetail,
  }) : super(key: key);

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  List<dynamic> sortedData = [];
  String sosId = "";
  String lastHistoryStatus = "";
  bool history = true;
  

  String fullname = "";
  int userId = 0;
  String idFinish = '';

  final ScrollController _scrollController = ScrollController();
  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    getData(widget.sosId);
    
    super.initState();
  }

  getData(id) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosDetail;
      var uri = '$url/$id';
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);

      if (content['status'] == '200') {
        listData.add(content['data']);
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
      finishSos(idFinish);
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

  historySos() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosHistory;
      var uri = url;
      // print(uri);
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);
      // print(response.statusCode.toString());
      // print(content.toString());

      if (content['status'] == '200') {
        setState(() {
          print("object");
          sortedData.clear;
          // sortedData.clear();
          // Urutkan data berdasarkan tanggal pembuatan secara menurun
          sortedData = List.from(content['data']);
          sortedData.sort((a, b) {
            DateTime dateA = DateTime.parse(a['created_at']);
            DateTime dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA);
          });

          // Ambil sos_id dari entri pertama setelah pengurutan
          sosId = sortedData[0]['sos_id'].toString();
          lastHistoryStatus = sortedData[0]['status'].toString();
          history = lastHistoryStatus == 'Finish' ? true : false;
          print("Latest SOS ID: $sosId");
          // print(lastHistoryStatus);
          isProcess = false;
        });
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
      history = lastHistoryStatus == 'Finish' ? true : false;
      isProcess = false;
    });
  }

  finishSos(id) async {
    try {
      final params = {
        "latitude": '${_currentPosition?.latitude ?? ""}',
        "longitude": '${_currentPosition?.longitude ?? ""}',
        // "note_finish": note,
      };
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosFinish;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()}, body: params);
      var content = json.decode(response.body);
      // print(content.toString());

      if (content['status_code'] == 200) {
        historySos();
        setState(() {
          // ignore: use_build_context_synchronously
          toastShort(context, "SOS Telah Diselesaikan");
          sortedData.clear;
          historySos();
          Navigator.of(context).pop();
          // isProcess = true;
        });
      } else {
        // ignore: use_build_context_synchronously
        toastShort(context, "SOS Telah Diselesaikan");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      toastShort(context, "SOS Telah Diselesaikan");
    }

    setState(() {
      history = lastHistoryStatus == 'Finish' ? true : false;
      isProcess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.white,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail History",
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
              var row = widget.listDetail as Map;
              List<dynamic> getHistory = row['gethistory'] ?? [];
              var handler = row['gethandler'];

              var status = row['status'];
              
              idFinish= row['id'].toString();

              var img = "";
              var avatar = row['attachment'] ?? "";
              if (avatar != "" && avatar != null) {
                img = '${ApiService.folder}/$avatar';
              } else if (avatar != null) {
                img = ApiService.imgDefault;
              } else {
                img = ApiService.imgDefault;
              }

              // setState(() {
              //   idFinish= row['id'].toString();
              // });

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      // width: 200,
                      // height: 200,
                      imageUrl: img,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15, top: 25, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sender",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.2575,
                                letterSpacing: 1,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              row['getsender']['fullname'] ?? "",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.2575,
                                letterSpacing: 1,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Handle",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.2575,
                                letterSpacing: 1,
                                color: Colors.black,
                              ),
                            ),
                            handler != null
                                ? Text(
                                    row['gethandler']['fullname'].toString(),
                                    style: SafeGoogleFont(
                                      'SF Pro Text',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2575,
                                      letterSpacing: 1,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    "no handle",
                                    style: SafeGoogleFont(
                                      'SF Pro Text',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2575,
                                      letterSpacing: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15, top: 5, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
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
                        Text(
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
                      ],
                    ),
                  ),
                  ListView.separated(
                    padding: const EdgeInsets.only(
                        bottom: 5, top: 5, left: 5.0, right: 5.0),
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      var reversedIndex = getHistory.length - 1 - index;
                      var historyEntry = getHistory[reversedIndex];

                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 15, top: 5, left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              badges.Badge(
                                badgeStyle: badges.BadgeStyle(
                                  shape: badges.BadgeShape.square,
                                  borderRadius: BorderRadius.circular(5),
                                  badgeColor:
                                      historyEntry['status'].toString() ==
                                              "Finish"
                                          ? clrDone
                                          : historyEntry['status'].toString() ==
                                                  "Request"
                                              ? clrPrimary
                                              : clrSecondary,
                                ),
                                position: badges.BadgePosition.custom(
                                    start: 10, top: 10),
                                badgeContent: Text(
                                  historyEntry['status'].toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(historyEntry['message']),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, index) => const SizedBox(
                      height: 5,
                    ),
                    itemCount: getHistory.isEmpty ? 0 : getHistory.length,
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      "Note Finish",
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
                      row['note_finish'] ?? "-",
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
                  ListTile(
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
                      row['location'] ?? "",
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
                  const SizedBox(
                    height: 5,
                  ),
                  status == "Request" || status == "Handle"
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: SizedBox(
                            width: w,
                            height: h / 14.7,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: clrDone,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                _getCurrentPosition();
                                // finishSos(row['id'].toString());

                                // historySos();
                                // Navigator.of(context).pop();
                                // logoutDialog(context);
                              },
                              child: const Text(
                                "Done",
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
