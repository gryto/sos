import 'package:flutter/material.dart';
import 'package:sos/src/constant.dart';
import '../../gen/assets.gen.dart';
import '../src/device_utils.dart';
import '../src/utils.dart';
import 'spacer/spacer_custom.dart';

class HeaderWithSearchBar extends StatelessWidget {
  const HeaderWithSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 48, 16, 25),
      width: double.infinity,
      height: 113,
      decoration: BoxDecoration(
        color: clrPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: double.infinity,
            width: DeviceUtils.getScaledWidth(context, 0.8),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomWidthSpacer(size: 0.03,),

                Image.asset(
                  Assets.icons.icMessage.path,
                  width: 15,
                  height: 15,
                ),

                CustomWidthSpacer(size: 0.03,),

                Text(
                  'Search',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: clrBackground,
                  ),
                ),
                //Spacer()
              ],
            ),
          ),

          Spacer(),

          Image.asset(
            Assets.images.user4.path,
            width: 32,
            height: 32,
          ),
        ],
      ),
    );
  }
}