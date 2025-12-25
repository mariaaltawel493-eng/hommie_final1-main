import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/modules/owner/controllers/pending_request_controller.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';



final permissions = Get.find<UserPermissionsController>();
final controller = Get.find<PostAdController>();
class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdViewState();
}

class _PostAdViewState extends State<PostAdScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final c = Get.find<PostAdController>();
  
  // ✅ ADD DASHBOARD CONTROLLER
  late final OwnerDashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    c.load();
    
    // ✅ INITIALIZE DASHBOARD CONTROLLER
    dashboardController = Get.put(OwnerDashboardController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Post Ad"),
        bottom: TabBar(
          labelColor: AppColors.backgroundLight,
          unselectedLabelColor: AppColors.textPrimaryLight,
          controller: _tabController,
          tabs: const [
            Tab(text: "Add a Flat"),
            Tab(text: "Pending Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
       // ═══════════════════════════════════════════════════════════
// UPDATED POST AD VIEW - ADD APARTMENT BUTTON SECTION
// Replace the "Add Apartment" button section in your PostAdView
// ═══════════════════════════════════════════════════════════

// Add this at the top of your widget file


// REPLACE your existing "Add Apartment" button with this:
Obx(() {
  final canPost = permissions.canPostApartments;
  final isPending = permissions.isPending;
  final isOwner = permissions.isOwner;

  return Column(
    children: [
      // PENDING APPROVAL WARNING (large, prominent)
      if (isPending && isOwner)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.hourglass_empty,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                '⏳ حسابك في انتظار الموافقة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لا يمكنك إضافة شقق حتى تتم الموافقة على حسابك من قبل الإدارة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Refresh approval status
                  permissions.loadApprovalStatus();
                  Get.snackbar(
                    'تم التحقق',
                    'حالة الموافقة: ${permissions.isPending ? "معلقة" : "موافق عليها"}',
                    backgroundColor: permissions.isPending ? Colors.orange : Colors.green,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('تحقق من الحالة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

      // ADD APARTMENT BUTTON (conditional)
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: canPost
                ? const Color(0xFF4A90E2) // Blue when enabled
                : Colors.grey[300], // Grey when disabled
            foregroundColor: canPost ? Colors.white : Colors.grey[600],
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: canPost ? 2 : 0,
          ),
          icon: Icon(
            canPost ? Icons.add_circle_outline : Icons.lock,
            size: 24,
          ),
          label: Text(
            canPost ? 'أضف شقة جديدة' : 'إضافة شقة (معطل)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: canPost
              ? () {
                  controller.onAddApartmentPressed();
                }
              : null, // DISABLED if can't post
        ),
      ),

      const SizedBox(height: 16),

      // Info text when disabled
      if (!canPost && isOwner)
        Text(
          'سيتم تفعيل زر الإضافة بعد موافقة الإدارة على حسابك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
    ],
  );
}),
          // ═══════════════════════════════════════════════════════
          // TAB 2: PENDING REQUESTS (Owner Dashboard)
          // ═══════════════════════════════════════════════════════
          _buildPendingRequestsTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 PENDING REQUESTS TAB CONTENT
  // ═══════════════════════════════════════════════════════════
  Widget _buildPendingRequestsTab() {
    return Obx(() {
      if (dashboardController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (dashboardController.pendingRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New booking requests will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: dashboardController.refreshRequests,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dashboardController.pendingRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = dashboardController.pendingRequests[index];
            return _buildBookingRequestCard(request);
          },
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 BOOKING REQUEST CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildBookingRequestCard(BookingRequestModel request) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with user info and close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: request.userAvatar != null
                      ? NetworkImage(request.userAvatar!)
                      : null,
                  child: request.userAvatar == null
                      ? Text(
                          request.userName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.dateRange,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(request.paymentMethod),
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.paymentMethod.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Close/Reject button
                IconButton(
                  onPressed: () => dashboardController.rejectRequest(request),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  tooltip: 'Reject',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Accept button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => dashboardController.approveRequest(request),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundLight,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Message button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => dashboardController.goToMessages(request),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 HELPER: Get Payment Icon
  // ═══════════════════════════════════════════════════════════
  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'credit_card':
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
}