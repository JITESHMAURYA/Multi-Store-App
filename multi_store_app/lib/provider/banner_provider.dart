import 'package:flutter_riverpod/legacy.dart';
import 'package:multi_store_app/models/banner_model.dart';

class BannerProvider extends StateNotifier<List<BannerModel>> {
  BannerProvider() : super([]);

  //set the list of banners
  void setBanners(List<BannerModel> banners) {
    state = banners;
  }
}

final bannerProvider = StateNotifierProvider<BannerProvider, List<BannerModel>>(
  (ref) {
    return BannerProvider();
  },
);
