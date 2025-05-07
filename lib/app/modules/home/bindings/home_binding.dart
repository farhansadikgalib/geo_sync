import 'package:get/get.dart';

import '../../../service/signalr_services.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<SignalRService>(() => SignalRService());
  }
}
