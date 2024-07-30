import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../src/api.dart';
import '../../../src/constant.dart';
import '../../../widgets/call_view.dart';
import 'detail.dart';

class HistoryList extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final data;
  // ignore: prefer_typing_uninitialized_variables

  const HistoryList({super.key, required this.data});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  final DateFormat dmy = DateFormat("HH:mm");
  final DateFormat dm = DateFormat("HH:mm");
  List listDetail = [];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
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
              var reversedIndex = widget.data.length - 1 - index;
              var row = widget.data[reversedIndex];
              var local =
                  dmy.format(DateTime.parse(row['created_at']).toLocal());
              var datetime = "$local AM";
              var message = row['status'];
              var sosId = row['id'].toString();

              // List uu = row['gethistory'];
              print("history");
              // print(uu);

              var img = "";
              var avatar = row['getsender']['image'] ?? "";
              if (avatar != "" && avatar != null) {
                img = '${ApiService.folder}/image-user/$avatar';
              } else if (avatar != null) {
                img = ApiService.imgDefault;
              } else {
                img = ApiService.imgDefault;
              }

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HistoryDetail(
                        listDetail: row,
                        sosId: sosId
                      ),
                    
                    ),
                  );
                },
                child: CallCardWidget(
                  name: row['getsender']['fullname'],
                  image: img,
                  isOnline: true,
                  condition: message,
                  secondTitle: row['status'],
                  secondColor: message == "Finish"
                      ? clrDone
                      : message == "Request"
                          ? clrPrimary
                          : clrSecondary,
                  time: datetime,
                ),
              );
            },
            separatorBuilder: (_, index) => const SizedBox(
              height: 5,
            ),
            itemCount: widget.data.isEmpty ? 0 : widget.data.length,
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
