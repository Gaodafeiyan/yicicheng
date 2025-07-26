import 'package:flutter/material.dart';
import '../../services/subscription_service.dart';
import '../../services/wallet_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SubscriptionService _subscriptionService = SubscriptionService();
  final WalletService _walletService = WalletService();

  List<dynamic> _plans = [];
  List<dynamic> _orders = [];
  Map<String, dynamic>? _walletData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 并行加载数据
      final results = await Future.wait([
        _subscriptionService.getSubscriptionPlans(),
        _subscriptionService.getUserOrders(),
        _walletService.getUserWallet(),
      ]);

      setState(() {
        _plans = results[0]['data'] ?? [];
        _orders = results[1]['data'] ?? [];
        _walletData = results[2]['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载数据失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('认购专区'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '认购计划'),
            Tab(text: '我的订单'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlansTab(),
                    _buildOrdersTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _plans.isEmpty
          ? const Center(
              child: Text('暂无认购计划', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return _buildPlanCard(plan);
              },
            ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan['name'] ?? '未命名计划',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(plan['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(plan['status']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan['description'] ?? '暂无描述',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '认购金额',
                    '${plan['amount'] ?? '0'} USDT',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '预期收益',
                    '${plan['expectedReturn'] ?? '0'}%',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '投资期限',
                    '${plan['duration'] ?? '0'} 天',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSubscribeDialog(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('立即认购'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _orders.isEmpty
          ? const Center(
              child: Text('暂无认购订单', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单 #${order['id']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getOrderStatusColor(order['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getOrderStatusText(order['status']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '认购金额: ${order['amount'] ?? '0'} USDT',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '创建时间: ${_formatDate(order['createdAt'])}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (order['status'] == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelOrder(order['id']),
                        child: const Text('取消订单'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _payOrder(order),
                        child: const Text('立即支付'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return '进行中';
      case 'inactive':
        return '已结束';
      default:
        return '未知';
    }
  }

  Color _getOrderStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(String? status) {
    switch (status) {
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      case 'pending':
        return '待支付';
      default:
        return '未知';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '未知时间';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '未知时间';
    }
  }

  void _showSubscribeDialog(Map<String, dynamic> plan) {
    final amountController = TextEditingController();
    final paymentMethodController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('认购 ${plan['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: '认购金额 (USDT)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paymentMethodController,
              decoration: const InputDecoration(
                labelText: '支付方式',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _createOrder(
                plan['id'],
                amountController.text,
                paymentMethodController.text,
              );
            },
            child: const Text('确认认购'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder(int planId, String amount, String paymentMethod) async {
    try {
      final result = await _subscriptionService.createSubscriptionOrder(
        planId: planId,
        amount: amount,
        paymentMethod: paymentMethod,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadData(); // 刷新数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建订单失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    try {
      final result = await _subscriptionService.cancelOrder(orderId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadData(); // 刷新数据
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('取消订单失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _payOrder(Map<String, dynamic> order) {
    // 这里可以实现支付逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('支付功能开发中...')),
    );
  }
} 