import 'package:dio/dio.dart';
import 'package:f_dio_provider/models/post.dart';

class PostApiService{

  late final Dio _dio;

  PostApiService(){
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: Duration(seconds: 5),
        sendTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-App-Name': 'Flutter DIO DEMO'
        }
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
      )
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-App-Version']='1.0.0';
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('Respuesta: [${response.statusCode}]');
          handler.next(response);
        },
        onError: (error, handler) {
          print('Error de DIO: ${error.message}');
          handler.next(error);
        },
      )
    );

  }

  Future<List<Post>> getPosts({int limit=10}) async{

    final response = await _dio.get(
      '/posts',
      queryParameters: {
        '_limit': limit,
        'campo_busqueda': 'Loja'
      }
    );

    final data = response.data as List<dynamic>;

    return data.
    map((json)=> Post.fromJson(json as Map<String, dynamic>)).toList();

  }

  Future<Post> createPost(Post post) async{
    final response = await _dio.post(
      '/posts',
      data: post.toJson(),
    );

    return Post.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Post> updatePostPut(Post post) async{

    if(post.id == null ){
      throw ArgumentError('El post debe tener un id para hacer put');
    }

    final response = await _dio.put(
      '/posts/${post.id}',
      data: post.toJson(),
    );

    return Post.fromJson(response.data as Map<String, dynamic>);

  }

  Future<Post>  updatePostPatch({
    required int id,
    String? title,
    String? body,
  }) async{
    final Map<String,dynamic> partialData={};
    if(title!=null) partialData['title'] = title;
    if(body!=null) partialData['body']= body;

    final reponse = await _dio.patch(
      '/posts/$id',
      data: partialData
    );

    return Post.fromJson(reponse.data as Map<String, dynamic>);
  }

  Future<void> deltePost(int id) async{
    await _dio.delete('/posts/$id');
  }

  
}