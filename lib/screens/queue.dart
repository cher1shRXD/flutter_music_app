import 'package:flutter/material.dart';
import 'package:flutter_music_app/components/header.dart';

class Queue extends StatefulWidget {
  const Queue({super.key});

  @override
  State<Queue> createState() => _QueueState();
}

class _QueueState extends State<Queue> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Header(
            title: 'Queue',
            icon: Icons.music_note,
          )
        ],
      ),
    );
  }
}
