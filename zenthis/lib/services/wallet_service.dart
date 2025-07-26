import 'package:dio/dio.dart';
import '../core/http_client.dart';

class WalletService {
  final HttpClient _httpClient = HttpClient();

  // 获取用户钱包余额
  Future<Map<String, dynamic>> getUserWallet() async {
    try {
      _httpClient.init();
      
      // 先测试API连接
      final isConnected = await _httpClient.testConnection();
      if (!isConnected) {
        return {
          'success': false,
          'message': 'API连接失败',
          'data': null
        };
      }
      
      final response = await _httpClient.dio.get('/api/qianbao-yues/user-wallet');
      
      if (response.statusCode == 200) {
        final walletData = response.data['data'];
        return {
          'success': true,
          'message': '获取钱包成功',
          'data': {
            'usdtYue': walletData['usdtYue'] ?? '0',
            'aiYue': walletData['aiYue'] ?? '0',
            'aiTokenBalances': walletData['aiTokenBalances'] ?? '{}',
          }
        };
      } else {
        return {
          'success': false,
          'message': '获取钱包失败',
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
        'message': '获取钱包时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 获取代币余额
  Future<Map<String, dynamic>> getTokenBalances() async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.get('/api/qianbao-yues/token-balances');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '获取代币余额成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '获取代币余额失败',
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
        'message': '获取代币余额时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 创建充值记录
  Future<Map<String, dynamic>> createRechargeRecord({
    required String amount,
    required String type,
    String? description,
  }) async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.post('/api/qianbao-yues/recharge-records', data: {
        'amount': amount,
        'type': type,
        'description': description ?? '用户充值',
        'status': 'pending'
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': '充值记录创建成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '充值记录创建失败',
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
        'message': '创建充值记录时发生未知错误: $e',
        'data': null
      };
    }
  }

  // 创建提现记录
  Future<Map<String, dynamic>> createWithdrawalRecord({
    required String amount,
    required String type,
    String? address,
    String? description,
  }) async {
    try {
      _httpClient.init();
      final response = await _httpClient.dio.post('/api/qianbao-yues/withdrawal-records', data: {
        'amount': amount,
        'type': type,
        'address': address,
        'description': description ?? '用户提现',
        'status': 'pending'
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': '提现记录创建成功',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': '提现记录创建失败',
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
        'message': '创建提现记录时发生未知错误: $e',
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