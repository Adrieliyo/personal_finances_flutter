import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class CookieService {
  // Guardar cookie
  static void setCookie(String name, String value, {int? expirationDays}) {
    if (kIsWeb) {
      String cookie = '$name=$value; path=/';

      if (expirationDays != null) {
        final expirationDate = DateTime.now().add(
          Duration(days: expirationDays),
        );
        cookie += '; expires=${expirationDate.toUtc().toString()}';
      }

      html.document.cookie = cookie;
    }
  }

  // Obtener cookie
  static String? getCookie(String name) {
    if (kIsWeb) {
      final cookies = html.document.cookie?.split('; ') ?? [];

      for (var cookie in cookies) {
        final parts = cookie.split('=');
        if (parts.length == 2 && parts[0] == name) {
          return parts[1];
        }
      }
    }
    return null;
  }

  // Eliminar cookie
  static void deleteCookie(String name) {
    if (kIsWeb) {
      html.document.cookie =
          '$name=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
    }
  }

  // Eliminar todas las cookies
  static void deleteAllCookies() {
    if (kIsWeb) {
      final cookies = html.document.cookie?.split('; ') ?? [];

      for (var cookie in cookies) {
        final name = cookie.split('=')[0];
        deleteCookie(name);
      }
    }
  }

  // Verificar si existe una cookie
  static bool hasCookie(String name) {
    return getCookie(name) != null;
  }
}
