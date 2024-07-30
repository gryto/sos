import 'package:flutter/material.dart';
import 'package:sos/src/constant.dart';
import '../src/device_utils.dart';
import '../src/utils.dart';
import 'chat_bubble.dart';

class SentMessage extends StatelessWidget {
  final Widget child;
  final String time;
   final dynamic onLongPress;
  const SentMessage({
    Key? key,
    required this.child,
    required this.time,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = GestureDetector(
      onLongPress: onLongPress,
      child: Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              time,
              textAlign: TextAlign.right,
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.2575,
                letterSpacing: 1,
                color: const Color(0xff77838f),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Align(
              alignment: Alignment
                  .topRight, //Change this to Alignment.topRight or Alignment.topLeft
              child: Column(
                children: [
                  CustomPaint(
                    painter: ChatBubble(
                        color: clrBackground,
                        alignment: Alignment.topRight),
                    child: Container(
                      constraints: BoxConstraints(
                          minWidth: 100,
                          maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 20, top: 10, bottom: 10),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}
