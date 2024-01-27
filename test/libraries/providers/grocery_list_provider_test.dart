import 'package:flutter_test/flutter_test.dart';
import 'package:smartcado/libraries/db_handler.dart';
import 'package:smartcado/libraries/providers/grocery_list_provider.dart';
import 'package:smartcado/libraries/sqlite_init.dart';
import 'package:smartcado/objects/grocery_list.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  late Database db;
  late GroceryListProvider provider;

  setUp(() async {
    SqliteInitialization.initializeSqliteDatabase();
    DatabaseHandler().setupDatabase(path: inMemoryDatabasePath);
    db = await DatabaseHandler().getDatabase(path: inMemoryDatabasePath);
    provider = GroceryListProvider.instance;
    provider.initialize(db);
  });

  group('test grocery list store', () {
    test('single list', () async {
      var groceryList = GroceryList(title: "Fruits");

      await GroceryListProvider.instance
          .saveSingleResource(groceryList.toMap());

      var result = await db.query("grocery_lists");
      expect(result.first, containsPair("title", "Fruits"));
      expect(result.first, containsPair("archived", 0));
    });

    test('collection list', () async {
      var groceries = [
        GroceryList(title: "Fruits"),
        GroceryList(title: "Vegetables"),
        GroceryList(title: "Appliances"),
      ];

      await GroceryListProvider.instance.saveCollectionResource(groceries);

      final listsFromDb = await db.query("grocery_lists");
      final titleMatcher = isIn(["Fruits", "Vegetables", "Appliances"]);

      expect(listsFromDb, hasLength(3));
      for (final groceryList in listsFromDb) {
        expect(groceryList['id'], isInstanceOf<int>());
        expect(groceryList['id'], isNotNull);
        expect(groceryList['title'], titleMatcher);
        expect(groceryList['uuid'], isNotNull);
        expect(groceryList['archived'], isZero);
      }
    });
  });

  group('test grocery list get', () {
    test('single list', () async {
      await db.insert("grocery_lists", GroceryList(title: "Fruits").toMap());

      var groceryList =
          await GroceryListProvider.instance.loadSingleResource('1');
      expect(groceryList[0]['id'], isNotNull);
      expect(groceryList[0]['title'], equals("Fruits"));
    });

    test('collection list', () async {
      var table = "grocery_lists";
      await db.insert(table, GroceryList(title: "Fruits").toMap());
      await db.insert(table, GroceryList(title: "Vegetables").toMap());
      await db.insert(table, GroceryList(title: "Appliances").toMap());

      var listOfGroceries =
          await GroceryListProvider.instance.loadCollectionResource(null);

      expect(listOfGroceries, hasLength(3));
    });

    test('filtered collection list', () {});
  });

  tearDown(() => db.close());
}
