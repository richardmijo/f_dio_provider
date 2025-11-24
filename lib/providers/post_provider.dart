// lib/providers/post_provider.dart

import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_api_service.dart';

/// Estados principales para el listado de posts.
enum PostStatus {
  idle,    // estado inicial
  loading, // estamos pidiendo datos al servidor
  loaded,  // datos cargados correctamente
  error,   // ocurrió un error
}

/// Provider que gestiona:
///  - la lista de posts
///  - las operaciones CRUD (GET, POST, PUT, PATCH, DELETE)
///  - los estados de loading / error
class PostProvider extends ChangeNotifier {
  final PostApiService _apiService;

  PostProvider(this._apiService);

  // --------- Estado principal del listado ---------

  PostStatus _status = PostStatus.idle;
  PostStatus get status => _status;

  final List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts); // lista solo lectura

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --------- Flags para operaciones individuales ---------

  bool _isSaving = false;   // POST, PUT, PATCH
  bool get isSaving => _isSaving;

  bool _isDeleting = false; // DELETE
  bool get isDeleting => _isDeleting;

  // --------- Métodos públicos que usará la UI ---------

  /// Carga el listado de posts (GET) y actualiza el estado general.
  Future<void> loadPosts({int limit = 10}) async {
    _status = PostStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getPosts(limit: limit);
      _posts
        ..clear()
        ..addAll(result);
      _status = PostStatus.loaded;
    } catch (e) {
      _status = PostStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Crea un nuevo post (POST) y lo agrega al inicio de la lista.
  Future<void> addPost({
    required String title,
    required String body,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Creamos un Post sin id (el servidor lo devuelve con id simulado)
      final newPost = Post(
        title: title,
        body: body,
        userId: 1,
      );

      final created = await _apiService.createPost(newPost);

      // Lo insertamos al inicio de la lista para verlo inmediatamente
      _posts.insert(0, created);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Actualiza completamente un post con PUT.
  Future<void> updatePostWithPut(Post updatedPost) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updatePostPut(updatedPost);

      // Buscamos el índice del post en la lista para reemplazarlo
      final index = _posts.indexWhere((p) => p.id == result.id);
      if (index != -1) {
        _posts[index] = result;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Actualiza parcialmente un post con PATCH (por ejemplo, solo el título).
  Future<void> updatePostTitleWithPatch({
    required int id,
    required String newTitle,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updatePostPatch(
        id: id,
        title: newTitle,
      );

      final index = _posts.indexWhere((p) => p.id == result.id);
      if (index != -1) {
        _posts[index] = result;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Elimina un post (DELETE) y lo quita de la lista local.
  Future<void> deletePost(int id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deletePost(id);
      _posts.removeWhere((p) => p.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
