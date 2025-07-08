import 'package:flutter/material.dart';
import '../services/vpn_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VpnService.VpnStatus _vpnStatus = VpnService.VpnStatus.disconnected;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkVpnStatus();
  }

  // VPN durumunu kontrol et
  Future<void> _checkVpnStatus() async {
    final status = await VpnService.checkVpnStatus();
    setState(() {
      _vpnStatus = status;
    });
  }

  // VPN bağlantısını başlat
  Future<void> _connectVpn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // VPN izni kontrol et
      bool hasPermission = await VpnService.hasVpnPermission();

      if (!hasPermission) {
        // İzin iste
        bool permissionGranted = await VpnService.requestVpnPermission();

        if (!permissionGranted) {
          _showToast('VPN izni reddedildi');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // VPN bağlantısını başlat
      bool success = await VpnService.startVpn();

      if (success) {
        _showToast('VPN Bağlantısı Başlatıldı');
        setState(() {
          _vpnStatus = VpnService.VpnStatus.connected;
        });
      } else {
        _showToast('VPN bağlantısı başlatılamadı');
      }
    } catch (e) {
      _showToast('Hata: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // VPN bağlantısını kes
  Future<void> _disconnectVpn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await VpnService.stopVpn();

      if (success) {
        _showToast('VPN bağlantısı kesildi');
        setState(() {
          _vpnStatus = VpnService.VpnStatus.disconnected;
        });
      } else {
        _showToast('VPN bağlantısı kesilemedi');
      }
    } catch (e) {
      _showToast('Hata: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Toast mesajı göster
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // VPN durumuna göre renk al
  Color _getStatusColor() {
    switch (_vpnStatus) {
      case VpnService.VpnStatus.connected:
        return Colors.green;
      case VpnService.VpnStatus.connecting:
        return Colors.orange;
      case VpnService.VpnStatus.disconnecting:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  // VPN durumuna göre metin al
  String _getStatusText() {
    switch (_vpnStatus) {
      case VpnService.VpnStatus.connected:
        return 'Bağlandı';
      case VpnService.VpnStatus.connecting:
        return 'Bağlanıyor...';
      case VpnService.VpnStatus.disconnecting:
        return 'Kesiliyor...';
      default:
        return 'Bağlantı Yok';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VPN Test'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // VPN Logo/İkon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(),
              ),
              child: Icon(
                Icons.vpn_lock,
                size: 60,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            // VPN Durum Metni
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),

            SizedBox(height: 20),

            // Sunucu Bilgisi
            Text(
              'Sunucu: ${VpnService.VPN_SERVER_IP}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 50),

            // VPN Bağlan Butonu
            if (_vpnStatus == VpnService.VpnStatus.disconnected)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _connectVpn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'VPN Bağlan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Bağlantı Kes Butonu
            if (_vpnStatus == VpnService.VpnStatus.connected)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _disconnectVpn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Bağlantı Kes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 30),

            // Durum Bilgisi
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Durum:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}