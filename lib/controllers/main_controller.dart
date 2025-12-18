import 'package:get/get.dart';
import '../widgets/sidebar.dart';

class MainController extends GetxController {
  final selectedMenuItem = MenuItem.today.obs;

  void selectMenuItem(MenuItem item) {
    selectedMenuItem.value = item;
  }
}

