class VpnConfig {
  // Sunucu yapılandırması
  static const String SERVER_IP = '18.157.158.244';
  static const String SERVER_DOMAIN = 'vpnkullanim.online';
  static const String SERVER_PORT = '1194';
  static const String PROTOCOL = 'udp';

  // DNS yapılandırması
  static const List<String> DNS_SERVERS = ['8.8.8.8', '8.8.4.4'];

  // VPN yapılandırma parametreleri
  static const String VPN_SESSION_NAME = 'VPN Test Session';
  static const int MTU_SIZE = 1500;
  static const int CONNECTION_TIMEOUT = 30; // saniye
  static const int KEEPALIVE_INTERVAL = 10; // saniye

  // Güvenlik ayarları
  static const String ENCRYPTION_CIPHER = 'AES-256-CBC';
  static const String AUTH_ALGORITHM = 'SHA256';

  // VPN profil ayarları
  static const String VPN_PROFILE_NAME = 'VPN Test Profile';
  static const String VPN_PROFILE_ID = 'com.vpntest.profile';

  // Bağlantı rotaları
  static const List<String> ROUTES = ['0.0.0.0/0'];
  static const List<String> SEARCH_DOMAINS = ['vpnkullanim.online'];

  // Tam VPN yapılandırma objesi oluştur
  static Map<String, dynamic> createVpnConfig() {
    return {
      'serverAddress': SERVER_IP,
      'serverPort': SERVER_PORT,
      'serverDomain': SERVER_DOMAIN,
      'protocol': PROTOCOL,
      'dnsServers': DNS_SERVERS,
      'sessionName': VPN_SESSION_NAME,
      'mtu': MTU_SIZE,
      'connectionTimeout': CONNECTION_TIMEOUT,
      'keepAliveInterval': KEEPALIVE_INTERVAL,
      'encryptionCipher': ENCRYPTION_CIPHER,
      'authAlgorithm': AUTH_ALGORITHM,
      'profileName': VPN_PROFILE_NAME,
      'profileId': VPN_PROFILE_ID,
      'routes': ROUTES,
      'searchDomains': SEARCH_DOMAINS,
    };
  }

  // OpenVPN yapılandırma dosyası string'i oluştur
  static String generateOpenVpnConfig() {
    return '''
client
dev tun
proto $PROTOCOL
remote $SERVER_IP $SERVER_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
cipher $ENCRYPTION_CIPHER
auth $AUTH_ALGORITHM
verb 3
mute 20
ping $KEEPALIVE_INTERVAL
ping-restart ${KEEPALIVE_INTERVAL * 2}
dhcp-option DNS ${DNS_SERVERS[0]}
dhcp-option DNS ${DNS_SERVERS[1]}
redirect-gateway def1
''';
  }

  // IKEv2 yapılandırması
  static Map<String, dynamic> createIKEv2Config() {
    return {
      'serverAddress': SERVER_IP,
      'serverDomain': SERVER_DOMAIN,
      'remoteIdentifier': SERVER_DOMAIN,
      'localIdentifier': 'vpntest_user',
      'authenticationMethod': 'SharedSecret',
      'sharedSecret': 'vpntest_shared_secret',
      'dnsServers': DNS_SERVERS,
      'routes': ROUTES,
      'mtu': MTU_SIZE,
    };
  }

  // L2TP yapılandırması
  static Map<String, dynamic> createL2TPConfig() {
    return {
      'serverAddress': SERVER_IP,
      'username': 'vpntest_user',
      'password': 'vpntest_pass',
      'sharedSecret': 'vpntest_l2tp_secret',
      'dnsServers': DNS_SERVERS,
      'routes': ROUTES,
      'mtu': MTU_SIZE,
    };
  }

  // Yapılandırma doğrulaması
  static bool validateConfig(Map<String, dynamic> config) {
    // Gerekli alanların kontrolü
    final requiredFields = ['serverAddress', 'serverPort', 'protocol'];

    for (String field in requiredFields) {
      if (!config.containsKey(field) || config[field] == null || config[field].toString().isEmpty) {
        print('Geçersiz yapılandırma: $field alanı eksik');
        return false;
      }
    }

    // IP adres formatı kontrolü
    if (!_isValidIpAddress(config['serverAddress'])) {
      print('Geçersiz IP adresi: ${config['serverAddress']}');
      return false;
    }

    // Port numarası kontrolü
    try {
      int port = int.parse(config['serverPort']);
      if (port < 1 || port > 65535) {
        print('Geçersiz port numarası: $port');
        return false;
      }
    } catch (e) {
      print('Port numarası parse hatası: ${config['serverPort']}');
      return false;
    }

    return true;
  }

  // IP adres formatı kontrolü
  static bool _isValidIpAddress(String ip) {
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');

    if (!ipRegex.hasMatch(ip)) {
      return false;
    }

    final parts = ip.split('.');
    for (String part in parts) {
      int num = int.parse(part);
      if (num < 0 || num > 255) {
        return false;
      }
    }

    return true;
  }
}