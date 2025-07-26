import 'package:dio/dio.dart';
import '../core/http_client.dart';

class SubscriptionService {
  final HttpClient _httpClient = HttpClient();

  // 获取认购计划列表
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.get('/api/dinggou-jihuas');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '获取认购计划成功',
          'data': response.data['data'] ?? []
        };
      } else {
        return {
          'success': false,
          'message': '获取认购计划失败',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取认购计划时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 获取认购计划详情
  Future<Map<String, dynamic>> getSubscriptionPlanDetail(int planId) async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.get('/api/dinggou-jihuas/$planId');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '获取认购计划详情成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '获取认购计划详情失败',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取认购计划详情时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 获取用户认购订单
  Future<Map<String, dynamic>> getUserOrders() async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.get('/api/dinggou-dingdans');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '获取认购订单成功',
          'data': response.data['data'] ?? []
        };
      } else {
        return {
          'success': false,
          'message': '获取认购订单失败',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取认购订单时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 创建认购订单
  Future<Map<String, dynamic>> createSubscriptionOrder({
    required int planId,
    required String amount,
    required String paymentMethod,
    String? description,
  }) async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.post('/api/dinggou-dingdans', data: {
        'jihua': planId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'description': description ?? '用户认购',
        'status': 'pending'
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': '认购订单创建成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '认购订单创建失败',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': '创建认购订单时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 获取订单详情
  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.get('/api/dinggou-dingdans/$orderId');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '获取订单详情成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '获取订单详情失败',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取订单详情时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 取消订单
  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.put('/api/dinggou-dingdans/$orderId', data: {
        'status': 'cancelled'
      });
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '订单取消成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '订单取消失败',
          'data': null
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'data': null
      };
    } catch (e) {
      return {
        'success': false,
        'message': '取消订单时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 处理Dio错误
  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return e.response?.data?['error']?['message'] ?? '请求参数错误';
      case 401:
        return '用户未登录，请重新登录';
      case 403:
        return '权限不足';
      case 404:
        return 'API路径不存在，请联系管理员';
      case 422:
        return e.response?.data?['error']?['details'] ?? '数据验证失败';
      case 429:
        return '请求过于频繁，请稍后再试';
      case 500:
        return '服务器内部错误，请稍后重试';
      default:
        return e.response?.data?['error']?['message'] ??
               e.response?.data?['message'] ??
               '网络请求失败';
    }
  }
} 