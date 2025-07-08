import 'package:flutter/services.dart';

class VpnPermissionHelper {
  static const MethodChannel _channel = MethodChannel('vpn_permission');

  // VPN izni kontrolü
  static Future<bool> hasVpnPermission() async {
    try {
      final result = await _channel.invokeMethod('hasVpnPermission');
      return result == true;
    } on PlatformException catch (e) {
      print('VPN izin kontrol hatası: ${e.message}');
      return false;
    }
  }

  // VPN izni isteme
  static Future<bool> requestVpnPermission() async {
    try {
      final result = await _channel.invokeMethod('requestVpnPermission');
      return result == true;
    } on PlatformException catch (e) {
      print('VPN izin isteme hatası: ${e.message}');
      return false;
    }
  }

  // VPN servis durumunu kontrol et
  static Future<bool> isVpnServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isVpnServiceRunning');
      return result == true;
    } on PlatformException catch (e) {
      print('VPN servis durumu kontrol hatası: ${e.message}');
      return false;
    }
  }

  // VPN profili kur
  static Future<bool> setupVpnProfile(Map<String, dynamic> config) async {
    try {
      final result = await _channel.invokeMethod('setupVpnProfile', config);
      return result == true;
    } on PlatformException catch (e) {
      print('VPN profil kurulum hatası: ${e.message}');
      return false;
    }
  }

  // VPN bağlantı ayarları
  static Map<String, dynamic> getVpnConfig() {
    return {
      'serverAddress': '18.157.158.244',
      'serverPort': '1194',
      'protocol': 'udp',
      'domain': 'vpnkullanim.online',
      'dnsServers': ['8.8.8.8', '8.8.4.4'],
      'routes': ['0.0.0.0/0'],
      'searchDomains': ['vpnkullanim.online'],
      'mtu': 1500,
      'sessionName': 'VPN Test Session',
    };
  }
}