import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/Admin/mainPage.dart';
import 'package:project_gemastik/Admin/transaction.dart';

class TrashPickup extends StatefulWidget {
  const TrashPickup({Key? key}) : super(key: key);

  @override
  State<TrashPickup> createState() => _TrashPickupState();
}

class _TrashPickupState extends State<TrashPickup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color.fromARGB(212, 206, 205, 241),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                WelcomeWidget(),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(TransactionPage());
                  },
                  child: itemAppBar(
                    iconbarColor: Color.fromARGB(160, 126, 186, 148),
                    iconbar: Icon(
                      MdiIcons.receiptClockOutline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
