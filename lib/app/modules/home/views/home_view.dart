import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GEO SYNC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => connectionStatus(controller)),
            const SizedBox(height: 20),
            const Text(
              'Select User Mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() => userModeToggle(controller)),
            const SizedBox(height: 30),
            Obx(
              () =>
                  controller.userMode.value == 'A'
                      ? senderCard(controller)
                      : receiverCard(controller),
            ),
            const SizedBox(height: 20),
            actionButtons(controller),
          ],
        ),
      ),
    );
  }

  connectionStatus(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            controller.connectionStatus.contains('Connected')
                ? Colors.green.shade100
                : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.connectionStatus.contains('Connected')
                ? Icons.signal_cellular_alt
                : Icons.warning,
            color:
                controller.connectionStatus.contains('Connected')
                    ? Colors.green
                    : Colors.red,
          ),
          const SizedBox(width: 5),
          Text(
            'SignalR Status: ${controller.connectionStatus}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  userModeToggle(HomeController controller) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      isSelected: [
        controller.userMode.value == 'A',
        controller.userMode.value == 'B',
      ],
      onPressed: (index) => controller.setUserMode(index == 0 ? 'A' : 'B'),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Text('Sender', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            'Receiver',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  senderCard(HomeController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Latitude: ${controller.isServiceRunning.value ? controller.currentLat.toStringAsFixed(6) : 0.0}',
            ),
            Text(
              'Longitude: ${controller.isServiceRunning.value ? controller.currentLon.toStringAsFixed(6) : 0.0}',
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: Get.width / 1.5,
                child: ElevatedButton.icon(
                  icon: Icon(
                    controller.isServiceRunning.value
                        ? Icons.stop
                        : Icons.location_on,
                  ),
                  label: Text(
                    controller.isServiceRunning.value
                        ? 'Stop Location Sharing'
                        : 'Start Location Sharing',
                  ),
                  onPressed:
                      () =>
                          controller.isServiceRunning.value
                              ? controller.stopLocationUpdates()
                              : controller.startLocationUpdates(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  receiverCard(HomeController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receive Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Latitude: ${controller.receivedLat.toStringAsFixed(6)}'),
            Text('Longitude: ${controller.receivedLon.toStringAsFixed(6)}'),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Listening for location updates',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  actionButtons(HomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.sync),
            label: const Text('Reconnect'),
            onPressed: controller.reconnectSignalR,
            style: ElevatedButton.styleFrom(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Disconnect'),
            onPressed: controller.disconnectSignalR,
            style: ElevatedButton.styleFrom(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
