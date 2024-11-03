import 'package:flutter/material.dart';
import 'package:flutter_music_app/screens/home.dart';
import 'package:flutter_music_app/screens/library.dart';
import 'package:flutter_music_app/screens/profile.dart';
import 'package:flutter_music_app/screens/queue.dart';
import 'package:flutter_music_app/screens/search.dart';
import 'package:get/get.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigateController());

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Obx(
            () => ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                height: 80,
                elevation: 0,
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) =>
                    controller.selectedIndex.value = index,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.search, size: 24),
                    selectedIcon: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: const Icon(
                          Icons.search,
                          size: 28,
                          color: Colors.white,
                        )),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.queue_music, size: 24),
                    selectedIcon: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: const Icon(
                          Icons.queue_music,
                          size: 28,
                          color: Colors.white,
                        )),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.home, size: 24),
                    selectedIcon: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: const Icon(
                          Icons.home,
                          size: 28,
                          color: Colors.white,
                        )),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.my_library_music, size: 24),
                    selectedIcon: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: const Icon(
                          Icons.my_library_music,
                          size: 28,
                          color: Colors.white,
                        )),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person, size: 24),
                    selectedIcon: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100))),
                        child: const Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.white,
                        )),
                    label: '',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigateController extends GetxController {
  final Rx<int> selectedIndex = 2.obs;

  final screens = [
    const Search(),
    const Queue(),
    const Home(),
    const Library(),
    const Profile(),
  ];
}
