import 'package:flutter/material.dart';
import 'package:flutter_music_app/components/header.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Header(
            title: 'Library',
            icon: Icons.music_note,
          )
        ],
      ),
    );
  }
}
