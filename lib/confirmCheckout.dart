import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

class confirmCheckout extends StatefulWidget {
  const confirmCheckout({super.key});

  @override
  State<confirmCheckout> createState() => _confirmCheckoutState();
}

class _confirmCheckoutState extends State<confirmCheckout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SlideAction(
        borderRadius: 20,
        innerColor: Colors.white,
        outerColor: Colors.red,
        text: "Slide to confirm",
        onSubmit: () {},
      ),
    );
  }
}
