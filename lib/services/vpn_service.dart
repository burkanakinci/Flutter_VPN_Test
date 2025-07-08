import 'package:flutter/services.dart';

class VpnService {
  static const MethodChannel _channel = MethodChannel('vpn_service');

  // VPN yapılandırma sabitleri
  static const String VPN_SERVER_IP = '18.157.158.244';
  static const String VPN_DOMAIN = 'vpnkullanim.online';
  static const String VPN_SERVER_PORT = '1194';

  // VPN durumu enum
  enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  }

  static VpnStatus _currentStatus = VpnStatus.disconnected;

  // Mevcut VPN durumunu al
  static VpnStatus get currentStatus => _currentStatus;

  // VPN bağlantısı başlat
  static Future<bool> startVpn() async {
  try {
  _currentStatus = VpnStatus.connecting;

  // Platform kanalı üzerinden VPN servisini başlat
  final result = await _channel.invokeMethod('startVpn', {
  'serverIp': VPN_SERVER_IP,
  'serverPort': VPN_SERVER_PORT,
  'domain': VPN_DOMAIN,
  });

  if (result == true) {
  _currentStatus = VpnStatus.connected;
  return true;
  } else {
  _currentStatus = VpnStatus.disconnected;
  return false;
  }
  } on PlatformException catch (e) {
  print('VPN başlatma hatası: ${e.message}');
  _currentStatus = VpnStatus.disconnected;
  return false;
  }
  }

  // VPN bağlantısını durdur
  static Future<bool> stopVpn() async {
  try {
  _currentStatus = VpnStatus.disconnecting;

  // Platform kanalı üzerinden VPN servisini durdur
  final result = await _channel.invokeMethod('stopVpn');

  if (result == true) {
  _currentStatus = VpnStatus.disconnected;
  return true;
  } else {
  return false;
  }
  } on PlatformException catch (e) {
  print('VPN durdurma hatası: ${e.message}');
  return false;
  }
  }

  // VPN durumunu kontrol et
  static Future<VpnStatus> checkVpnStatus() async {
  try {
  final result = await _channel.invokeMethod('getVpnStatus');

  switch (result) {
  case 'connected':
  _currentStatus = VpnStatus.connected;
  break;
  case 'connecting':
  _currentStatus = VpnStatus.connecting;
  break;
  case 'disconnecting':
  _currentStatus = VpnStatus.disconnecting;
  break;
  default:
  _currentStatus = VpnStatus.disconnected;
  }

  return _currentStatus;
  } on PlatformException catch (e) {
  print('VPN durum kontrol hatası: ${e.message}');
  return VpnStatus.disconnected;
  }
  }

  // VPN izin kontrolü
  static Future<bool> hasVpnPermission() async {
  try {
  final result = await _channel.invokeMethod('hasVpnPermission');
  return result == true;
  } on PlatformException catch (e) {
  print('VPN izin kontrol hatası: ${e.message}');
  return false;
  }
  }

  // VPN izni iste
  static Future<bool> requestVpnPermission() async {
  try {
  final result = await _channel.invokeMethod('requestVpnPermission');
  return result == true;
  } on PlatformException catch (e) {
  print('VPN izin isteme hatası: ${e.message}');
  return false;
  }
  }
}