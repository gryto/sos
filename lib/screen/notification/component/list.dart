import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../../../widgets/notification_widget.dart';
import 'detail.dart';

class NotificationList extends StatefulWidget {
  final data;
  final sosId;
  const NotificationList({super.key, required this.data, required this.sosId});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
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
              var reversedIndex =
                  widget.data.length - 1 - index; // Menghitung indeks terbalik
              var row = widget.data[reversedIndex];
              List<dynamic> getHistory = row['gethistory'] ?? [];
              // var row = widget.data[index];
              var message = row['status'];
              print("sosid");
              // var sosId = row['id'].toString();
              // print(sosId);
              // var item = listData[index];

              return ListView.separated(
                padding: const EdgeInsets.only(
                    bottom: 5, top: 5, left: 5.0, right: 5.0),
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  var reversedIndex = getHistory.length - 1 - index;
                  var historyEntry = getHistory[reversedIndex];
                  var messageHistory = historyEntry['status'].toString();
                  var sosId = historyEntry['sos_id'].toString();
                  print(sosId);

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationsDetail(id: sosId, status: message),
                        ),
                      );
                    },
                    child: NotificationCardWidget(
                      image: Assets.images.user2.path,
                      isOnline: messageHistory == 'Handle'
                          ? true
                          : messageHistory == 'Request'
                              ? true
                              : false,
                      message: historyEntry['message'] ?? "",
                      unReadCount: messageHistory,
                      count: '2',
                      isUnReadCountShow: true,
                      time: messageHistory == 'Handle'
                          ? 'Currently in progress'
                          : messageHistory == 'Request'
                              ? 'SOS Alert'
                              : 'Handling Completed',
                    ),
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: getHistory.isEmpty ? 0 : getHistory.length,

                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) =>
                //             NotificationsDetail(id: sosId, status: message),
                //       ),
                //     );
                //   },
                //   child:

                // NotificationCardWidget(
                //   image: Assets.images.user7.path,
                //   isOnline: message == 'Handle'
                //       ? true
                //       : message == 'Request'
                //           ? true
                //           : false,
                //   message: row['message'] ?? "",
                //   unReadCount: message,
                //   count: '2',
                //   isUnReadCountShow: true,
                //   time: message == 'Handle'
                //       ? 'Currently in progress'
                //       : message == 'Request'
                //           ? 'SOS Alert'
                //           : 'Handling Completed',
                // ),
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
