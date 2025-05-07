import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../service/signalr_services.dart';

class HomeController extends GetxController {
  final signalRService = Get.find<SignalRService>();
  final currentLat = 0.0.obs, currentLon = 0.0.obs;
  final userMode = 'A'.obs;
  final    locationEnabled = false.obs;
  final    isServiceRunning = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
  }

  void setUserMode(String mode) => userMode.value = mode;

  Future<void> checkLocationPermission() async {
    while (true) {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await Geolocator.openLocationSettings();
        continue;
      }
      var status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        await openAppSettings();
        continue;
      }
      break;
    }
    locationEnabled.value = true;
  }

  void startLocationUpdates() {
    if (!locationEnabled.value) {
      checkLocationPermission();
      return;
    }
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((position) {
      if (signalRService.connectionStatus != 'Disconnected') {
        currentLat.value = position.latitude;
        currentLon.value = position.longitude;
        isServiceRunning.value = true;
        if (userMode.value == 'A') sendCurrentLocation();
      }
    });
  }

  void sendCurrentLocation() =>
      signalRService.sendLatLon(currentLat.value, currentLon.value);

  double get receivedLat => signalRService.receivedLat.value;

  double get receivedLon => signalRService.receivedLon.value;

  String get connectionStatus => signalRService.connectionStatus.value;

  void stopLocationUpdates() {
    currentLat.value = currentLon.value = 0.0;
    signalRService.receivedLat.value = signalRService.receivedLon.value = 0.0;
    isServiceRunning.value = false;
  }

  void disconnectSignalR() {
    isServiceRunning.value = false;
    signalRService.stopConnection();
  }

  void reconnectSignalR() {
    if (signalRService.connectionStatus != "Connected") {
      isServiceRunning.value = true;
      signalRService.startConnection();
      sendCurrentLocation();
    }
  }
}
