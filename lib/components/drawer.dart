import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Weight tracker menu')),
          ListTile(
            title: const Text('Overview'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            title: const Text('Participants'),
            onTap: () {
              // Navigate
              Navigator.pop(context);
              Navigator.pushNamed(context, '/persons');
            },
          )
        ],
      ),
    );
  }
}
