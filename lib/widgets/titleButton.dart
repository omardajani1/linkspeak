import 'package:flutter/material.dart';
import 'title.dart';

class TitleButton extends StatelessWidget {
  const TitleButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: 15.0,
        ),
        child: const MyTitle(),
      ),
    );
  }
}
