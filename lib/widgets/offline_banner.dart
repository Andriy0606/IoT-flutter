import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(Icons.wifi_off),
            SizedBox(width: 8),
            Expanded(
              child: Text('No Internet connection. Showing cached room data.'),
            ),
          ],
        ),
      ),
    );
  }
}
