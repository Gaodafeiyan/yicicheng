import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;
  static const String baseUrl = 'http://localhost:1337'; // 后端API地址

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证token
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🌐 API请求: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ API响应: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) async {
        print('❌ API错误: ${error.response?.statusCode} ${error.requestOptions.path}');
        
        if (error.response?.statusCode == 401) {
          // Token过期，清除本地存储并跳转登录
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('jwt_token');
          await prefs.remove('user_data');
          // 这里可以触发全局登录状态更新
        } else if (error.response?.statusCode == 404) {
          // API路径不存在
          print('API路径不存在: ${error.requestOptions.path}');
          print('错误详情: ${error.response?.data}');
        } else if (error.response?.statusCode == 405) {
          // Method Not Allowed，通常是路由写错
          print('API路由错误: ${error.requestOptions.path}');
        }
        
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // 获取存储的token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // 测试API连接
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/api/qianbao-yues/test');
      return response.statusCode == 200;
    } catch (e) {
      print('API连接测试失败: $e');
      return false;
    }
  }
}

// 重试拦截器
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({this.maxRetries = 3, this.retryDelay = const Duration(seconds: 1)});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    int retryCount = err.requestOptions.extra['retryCount'];

    if (retryCount < maxRetries && _shouldRetry(err)) {
      retryCount++;
      err.requestOptions.extra['retryCount'] = retryCount;

      print('🔄 重试请求 (${retryCount}/$maxRetries): ${err.requestOptions.path}');

      await Future.delayed(retryDelay);

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.response?.statusCode == 500 ||
           err.response?.statusCode == 502 ||
           err.response?.statusCode == 503 ||
           err.response?.statusCode == 504;
  }
} 