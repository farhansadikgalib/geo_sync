import 'package:geo_sync/app/helper/print_log.dart';
import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';

class SignalRService extends GetxService {
  final hubUrl = 'https://raintor-api.devdata.top/hub';
  HubConnection? hubConnection;

  final connectionStatus = "Disconnected".obs;
  final receivedLat = 0.0.obs;
  final receivedLon = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    initSignalR();
  }

  @override
  void onClose() {
    hubConnection?.stop();
    receivedLat.value = 0.0;
    receivedLon.value = 0.0;
    super.onClose();
  }

  Future<void> initSignalR() async {
    try {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {});

      hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl)
          .configureLogging(Logger("SignalR"))
          .build();

      hubConnection!.on('ReceiveLatLon', handleReceiveLatLon);
      await startConnection();
    } catch (e) {
      updateStatus("Error: $e");
    }
  }

  Future<void> startConnection() async {
    try {
      updateStatus("Connecting...");
      hubConnection!.start()?.then((_) {
        updateStatus('Connected');
      }).catchError((_) {
        updateStatus('Error');
      });
    } catch (e) {
      updateStatus("Connection Failed: $e");
      await Future.delayed(Duration(seconds: 2));
      startConnection();
    }
  }

  void stopConnection() {
    if (hubConnection?.state == HubConnectionState.Connected) {
      hubConnection?.stop().then((_) {
        updateStatus('Disconnected');
      }).catchError((_) {
        updateStatus('Error');
      });
    }
  }

  Future<void> sendLatLon(double lat, double lon) async {
    try {
      if (hubConnection?.state == HubConnectionState.Connected) {
        await hubConnection!.invoke('SendLatLon', args: [lat, lon]);
        printLog("Location sent: lat=$lat, lon=$lon");
      } else {
        printLog("Cannot send location: SignalR not connected");
        await startConnection();
      }
    } catch (e) {
      printLog("Error sending location: $e");
    }
  }

  void handleReceiveLatLon(List<dynamic>? args) {
    if (args != null && args.isNotEmpty) {
      final data = args[0];
      if (data is Map<String, dynamic> &&
          data.containsKey('lat') &&
          data.containsKey('lon')) {
        receivedLat.value = double.parse(data['lat'].toString());
        receivedLon.value = double.parse(data['lon'].toString());
      } else {
        printLog("Invalid data format: $data");
      }
    } else {
      printLog("No data received or args is null");
    }
  }

  void updateStatus(String status) {
    connectionStatus.value = status;
    printLog(status);
  }
}