import 'package:flutter/material.dart';
import 'package:flutter_music_app/components/header.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Header(
            title: 'Search',
            icon: Icons.music_note,
          )
        ],
      ),
    );
  }
}
