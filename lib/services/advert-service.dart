import 'package:firebase_admob/firebase_admob.dart';

class AdvertService {
  static final AdvertService _instance = AdvertService._internal();
  factory AdvertService() => _instance;
  MobileAdTargetingInfo _targetingInfo;

  AdvertService._internal() {
    _targetingInfo = MobileAdTargetingInfo();
  }

  showBanner() {
    BannerAd banner = BannerAd(
        adUnitId: "ca-app-pub-5357294044573280/4999779697",
        size: AdSize.smartBanner,
        targetingInfo: _targetingInfo);

    banner
      ..load()
      ..show(anchorType: AnchorType.top);
    banner.dispose();
  }

  showIntersitial() {
    InterstitialAd interstitialAd = InterstitialAd(
        adUnitId: "ca-app-pub-5357294044573280/6762070467",
        targetingInfo: _targetingInfo);
    interstitialAd
      ..load()
      ..show();
    interstitialAd.dispose();
  }
}
