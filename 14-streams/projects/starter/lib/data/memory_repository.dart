import 'dart:core';
import 'dart:async';
import 'repository.dart';
import 'models/models.dart';

class MemoryRepository extends Repository {
  final List<Recipe> _currentRecipes = <Recipe>[];
  final List<Ingredient> _currentIngredients = <Ingredient>[];

  Stream<List<Recipe>>? _recipeStream;
  Stream<List<Ingredient>>? _ingredientStream;
  final StreamController<List<Recipe>> _recipeStreamController =
      StreamController<List<Recipe>>();
  final StreamController<List<Ingredient>> _ingredientStreamController =
      StreamController<List<Ingredient>>();

  int _currentReceipeId = 0;

  int getNextRecipeId() {
    _currentReceipeId++;
    return _currentReceipeId;
  }
  @override
  Stream<List<Recipe>> watchAllRecipes() {
    if (_recipeStream == null) {
      _recipeStream = _recipeStreamController.stream;
    }
    return _recipeStream!;
  }

  @override
  Stream<List<Ingredient>> watchAllIngredients() {
    if (_ingredientStream == null) {
        _ingredientStream =
          _ingredientStreamController.stream;
    }
    return _ingredientStream!;
  }


  @override
  Future<List<Recipe>> findAllRecipes() {
    return Future.value(_currentRecipes);
  }

  @override
  Future<Recipe> findRecipeById(int id) {
    return Future.value(_currentRecipes.firstWhere(
                          (recipe) => recipe.id == id));
  }

  @override
  Future<List<Ingredient>> findAllIngredients() {
    return Future.value(_currentIngredients);
  }

  @override
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) {
    final recipe =
        _currentRecipes.firstWhere((recipe) => recipe.id == recipeId);
    final recipeIngredients = _currentIngredients
        .where((ingredient) => ingredient.recipeId == recipe.id)
        .toList();
    return Future.value(recipeIngredients);
  }

  @override
  Future<int> insertRecipe(Recipe recipe) {
    recipe.id = getNextRecipeId();
    _currentRecipes.add(recipe);
    _recipeStreamController.sink.add(_currentRecipes);
    if (recipe.ingredients != null) {
      recipe.ingredients?.forEach((i)=>{
        i.recipeId = recipe.id
      });
      insertIngredients(recipe.ingredients!);
    }
    return Future.value(0);
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    if (ingredients.length != 0) {
      _currentIngredients.addAll(ingredients);
      _ingredientStreamController.sink.add(_currentIngredients);
    }
    return Future.value(<int>[]);
  }

  @override
  Future deleteRecipe(Recipe recipe) {
    _currentRecipes.remove(recipe);
    _recipeStreamController.sink.add(_currentRecipes);
    if (recipe.id != null) {
      deleteRecipeIngredients(recipe.id!);
    }

    return Future.value();
  }

  @override
  Future deleteIngredient(Ingredient ingredient) {
    _currentIngredients.remove(ingredient);
    _ingredientStreamController.sink.add(_currentIngredients);

    return Future.value();
  }

  @override
  Future deleteIngredients(List<Ingredient> ingredients) {
    _currentIngredients
        .removeWhere((ingredient) => ingredients.contains(ingredient));
    _ingredientStreamController.sink.add(_currentIngredients);
    return Future.value();
  }

  @override
  Future deleteRecipeIngredients(int recipeId) {
    _currentIngredients
        .removeWhere((ingredient) => ingredient.recipeId == recipeId);
    _ingredientStreamController.sink.add(_currentIngredients);
    return Future.value();
  }

  @override
  Future init() {
    return Future.value();
  }

  @override
  void close() {
    _recipeStreamController.close();
    _ingredientStreamController.close();
  }
}
