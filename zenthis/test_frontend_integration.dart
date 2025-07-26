import 'dart:io';
import 'package:dio/dio.dart';

// 测试Flutter前端与后端的集成
void main() async {
  print('🧪 开始测试Flutter前端与后端集成...\n');

  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:1337',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 1. 测试API连接
  print('1. 测试API连接...');
  try {
    final response = await dio.get('/api/qianbao-yues/test');
    print('✅ API连接正常: ${response.statusCode}');
  } catch (e) {
    print('❌ API连接失败: $e');
    return;
  }

  // 2. 测试钱包API
  print('\n2. 测试钱包API...');
  try {
    final response = await dio.get('/api/qianbao-yues/user-wallet');
    print('✅ 钱包API正常: ${response.statusCode}');
    print('钱包数据: ${response.data}');
  } catch (e) {
    print('❌ 钱包API失败: $e');
  }

  // 3. 测试认购计划API
  print('\n3. 测试认购计划API...');
  try {
    final response = await dio.get('/api/dinggou-jihuas');
    print('✅ 认购计划API正常: ${response.statusCode}');
    print('计划数量: ${response.data['data']?.length ?? 0}');
  } catch (e) {
    print('❌ 认购计划API失败: $e');
  }

  // 4. 测试认购订单API
  print('\n4. 测试认购订单API...');
  try {
    final response = await dio.get('/api/dinggou-dingdans');
    print('✅ 认购订单API正常: ${response.statusCode}');
    print('订单数量: ${response.data['data']?.length ?? 0}');
  } catch (e) {
    print('❌ 认购订单API失败: $e');
  }

  // 5. 测试Flutter应用启动
  print('\n5. 测试Flutter应用...');
  try {
    final result = await Process.run('flutter', ['doctor']);
    if (result.exitCode == 0) {
      print('✅ Flutter环境正常');
    } else {
      print('❌ Flutter环境有问题');
    }
  } catch (e) {
    print('❌ Flutter命令执行失败: $e');
  }

  print('\n🎯 测试完成！');
  print('\n📱 要运行Flutter应用，请执行以下命令：');
  print('cd zenthis');
  print('flutter pub get');
  print('flutter run');
}

// 模拟Flutter HTTP客户端
class MockFlutterHttpClient {
  final Dio _dio;

  MockFlutterHttpClient() : _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:1337',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await _dio.get('/api/qianbao-yues/test');
      return {
        'success': true,
        'message': 'API连接正常',
        'data': response.data
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'API连接失败: $e',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> getUserWallet() async {
    try {
      final response = await _dio.get('/api/qianbao-yues/user-wallet');
      return {
        'success': true,
        'message': '获取钱包成功',
        'data': response.data['data']
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取钱包失败: $e',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await _dio.get('/api/dinggou-jihuas');
      return {
        'success': true,
        'message': '获取认购计划成功',
        'data': response.data['data'] ?? []
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取认购计划失败: $e',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final response = await _dio.get('/api/dinggou-dingdans');
      return {
        'success': true,
        'message': '获取认购订单成功',
        'data': response.data['data'] ?? []
      };
    } catch (e) {
      return {
        'success': false,
        'message': '获取认购订单失败: $e',
        'data': null
      };
    }
  }
} 