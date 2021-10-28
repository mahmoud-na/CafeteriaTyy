import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

var ResponseList;
var timeOut = false;
const delayTime = 6;
Future<void> sendMessage(Socket socket, String message) async {
  print("-------------------------------------------\n");
  print('Client: $message');
  print("-------------------------------------------\n");
  socket.write(message);
}

Future connectToServer(String incomingMessage, String decodedDataType) async {
  timeOut = false;
  List<int> toBeDecoded = [];
  late var subscription;
  // var ip = '192.168.15.30';
  var ip = '196.221.70.220';
  // var ip = '192.168.85.35';
  var port = 49151;
  try {
    final socket =
        await Socket.connect(ip, port, timeout: Duration(seconds: delayTime));
    print("-------------------------------------------\n");
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
    print("-------------------------------------------\n");
    await sendMessage(socket, incomingMessage);
    subscription = socket.listen((Uint8List data) {
      toBeDecoded += data;
    }, onError: (error) {
      socket.destroy();
    });
    await subscription
        .asFuture<void>()
        .timeout(const Duration(seconds: delayTime));
    final DecodedData = jsonDecode(utf8.decode(toBeDecoded));
    print("-------------------------------------------\n");
    print('Server: $DecodedData\n');
    print("-------------------------------------------\n");
    ResponseList = DecodedData[decodedDataType];
    print("-------------------------------------------\n");
    print('Server left.');
    print("-------------------------------------------\n");
    socket.destroy();
  } on SocketException {
    print(
        "========================================================= SocketException =========================================================}");
    timeOut = true;
  } on TimeoutException {
    print(
        "========================================================= TimeoutException =========================================================}");
    timeOut = true;
  } catch (e) {
    print(
        "========================================================= Connection error ========================================================= $e}");
    if (toBeDecoded.isNotEmpty) {
      await connectToServer(incomingMessage, decodedDataType);
    }
  }
}
