import '../models/satay_item.dart';
import '../services/database_service.dart';

class MenuRepository {
  final DatabaseService _dbService;

  MenuRepository(this._dbService);

  Stream<List<SatayItem>> getMenuItems() {
    return _dbService.getMenuItems();
  }
}
