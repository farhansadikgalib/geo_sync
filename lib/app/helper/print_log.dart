import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

var logger = Logger();

const showAllDebug = true;
const singleKey = "112324";
printLog(massage, {String level = "i", key = "1"}) {
  if (kDebugMode) {
    if (showAllDebug && singleKey != key) {
      switch (level) {
        case "v":
          {
            logger.v(massage);
          }
          break;

        case "i":
          {
            logger.i(massage);
          }
          break;

        case "w":
          {
            logger.w(massage);
          }
          break;

        case "e":
          {
            logger.e(massage);
          }
          break;
        case "d":
          {
            logger.d(massage);
          }
          break;
        case "wtf":
          {
            logger.wtf(massage);
          }
          break;

        default:
          {
            logger.d(massage);
          }
          break;
      }
    }
  }
}
