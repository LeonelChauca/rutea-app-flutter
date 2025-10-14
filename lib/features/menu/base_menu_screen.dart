import 'package:flutter/material.dart';
import 'package:ruteaflutter/features/menu/custom_drawer.dart';

class BaseMenuScreen extends StatelessWidget {
  final Widget body;
  final Widget? topContent;
  final int currentIndex;
  final Function(int)? onMenuItemSelected;
  final String userName;
  final String userEmail;

  const BaseMenuScreen({
    super.key,
    required this.body,
    this.topContent,
    this.currentIndex = 0,
    this.onMenuItemSelected,
    this.userName = '',
    this.userEmail = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: topContent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      drawer: CustomDrawer(
        currentIndex: currentIndex,
        onMenuItemSelected: onMenuItemSelected!,
        userName: userName,
        userEmail: userEmail,
      ),
      body: body,
    );
  }
}
