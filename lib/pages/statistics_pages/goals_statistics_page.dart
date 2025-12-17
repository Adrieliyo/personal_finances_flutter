// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../Services/goal_service.dart';
// import '../creation_pages/create_goal_page.dart';

// class GoalsStatisticsPage extends StatefulWidget {
//   const GoalsStatisticsPage({super.key});

//   @override
//   State<GoalsStatisticsPage> createState() => _GoalsStatisticsPageState();
// }

// class _GoalsStatisticsPageState extends State<GoalsStatisticsPage> {
//   final _goalService = GoalService();
//   List<Map<String, dynamic>> _goals = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadGoals();
//   }

//   Future<void> _loadGoals() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final result = await _goalService.getGoals();

//       if (!mounted) return;

//       if (result['success']) {
//         final data = result['data'];
//         List<Map<String, dynamic>> goals = [];

//         if (data is Map && data.containsKey('data')) {
//           final goalsList = data['data'];
//           if (goalsList is List) {
//             goals = goalsList.map((item) {
//               if (item is Map) {
//                 return Map<String, dynamic>.from(item);
//               }
//               return <String, dynamic>{};
//             }).toList();
//           }
//         }

//         // Ordenar: activas primero, luego por días restantes
//         goals.sort((a, b) {
//           final statusA = a['status']?.toString().toLowerCase() ?? '';
//           final statusB = b['status']?.toString().toLowerCase() ?? '';

//           if (statusA == 'active' && statusB != 'active') return -1;
//           if (statusA != 'active' && statusB == 'active') return 1;

//           final daysA = a['days_remaining'] ?? 0;
//           final daysB = b['days_remaining'] ?? 0;
//           return daysA.compareTo(daysB);
//         });

//         setState(() {
//           _goals = goals;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = result['message'] ?? 'Error al cargar metas';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _errorMessage = 'Error de conexión: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   String _formatAmount(dynamic amount) {
//     try {
//       final numAmount = double.parse(amount.toString());
//       return '\$${numAmount.toStringAsFixed(2)}';
//     } catch (e) {
//       return '\$0.00';
//     }
//   }

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'active':
//         return Colors.green;
//       case 'completed':
//         return Colors.blue;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusLabel(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'active':
//         return 'Activa';
//       case 'completed':
//         return 'Completada';
//       case 'cancelled':
//         return 'Cancelada';
//       default:
//         return status ?? 'N/A';
//     }
//   }

//   Map<String, dynamic> _calculateStatistics() {
//     double totalTarget = 0;
//     double totalCurrent = 0;
//     int activeGoals = 0;
//     int completedGoals = 0;
//     int overdueGoals = 0;

//     for (var goal in _goals) {
//       final target =
//           double.tryParse(goal['target_amount']?.toString() ?? '0') ?? 0;
//       final current =
//           double.tryParse(goal['current_amount']?.toString() ?? '0') ?? 0;
//       final status = goal['status']?.toString().toLowerCase() ?? '';
//       final isOverdue = goal['is_overdue'] == true;

//       totalTarget += target;
//       totalCurrent += current;

//       if (status == 'active') activeGoals++;
//       if (status == 'completed' || goal['is_completed'] == true)
//         completedGoals++;
//       if (isOverdue) overdueGoals++;
//     }

//     return {
//       'totalTarget': totalTarget,
//       'totalCurrent': totalCurrent,
//       'totalRemaining': totalTarget - totalCurrent,
//       'activeGoals': activeGoals,
//       'completedGoals': completedGoals,
//       'overdueGoals': overdueGoals,
//       'overallProgress': totalTarget > 0
//           ? (totalCurrent / totalTarget * 100)
//           : 0,
//     };
//   }

//   Future<void> _navigateToCreateGoal() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const CreateGoalPage()),
//     );

//     if (result == true) {
//       _loadGoals();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final stats = _calculateStatistics();

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _errorMessage != null
//             ? Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: Colors.red[300],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         _errorMessage!,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: _loadGoals,
//                         icon: const Icon(Icons.refresh),
//                         label: const Text('Reintentar'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : Column(
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(Icons.arrow_back),
//                           style: IconButton.styleFrom(
//                             backgroundColor: Colors.green[50],
//                             foregroundColor: Colors.green,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Expanded(
//                           child: Text(
//                             'Estadísticas de Metas',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: _loadGoals,
//                           icon: const Icon(Icons.refresh),
//                           style: IconButton.styleFrom(
//                             backgroundColor: Colors.green[50],
//                             foregroundColor: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Resumen general
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.green.shade400, Colors.green.shade600],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.green.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         const Text(
//                           'Progreso General',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${stats['overallProgress'].toStringAsFixed(1)}%',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: stats['overallProgress'] / 100,
//                             minHeight: 8,
//                             backgroundColor: Colors.white.withOpacity(0.3),
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Ahorrado',
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 Text(
//                                   _formatAmount(stats['totalCurrent']),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 const Text(
//                                   'Meta Total',
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 Text(
//                                   _formatAmount(stats['totalTarget']),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Estadísticas rápidas
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             label: 'Activas',
//                             value: stats['activeGoals'].toString(),
//                             icon: Icons.flag,
//                             color: Colors.green,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             label: 'Completadas',
//                             value: stats['completedGoals'].toString(),
//                             icon: Icons.check_circle,
//                             color: Colors.blue,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             label: 'Vencidas',
//                             value: stats['overdueGoals'].toString(),
//                             icon: Icons.warning,
//                             color: Colors.orange,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Lista de metas
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Mis Metas',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         Text(
//                           '${_goals.length} metas',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   Expanded(
//                     child: _goals.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(24),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     Icons.flag,
//                                     size: 64,
//                                     color: Colors.grey[400],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   'No hay metas registradas',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Crea tu primera meta financiera',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//                                 ElevatedButton.icon(
//                                   onPressed: _navigateToCreateGoal,
//                                   icon: const Icon(Icons.add),
//                                   label: const Text('Crear Meta'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green,
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 24,
//                                       vertical: 12,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : RefreshIndicator(
//                             onRefresh: _loadGoals,
//                             child: ListView.builder(
//                               padding: const EdgeInsets.fromLTRB(
//                                 20,
//                                 0,
//                                 20,
//                                 100,
//                               ),
//                               itemCount: _goals.length,
//                               itemBuilder: (context, index) {
//                                 final goal = _goals[index];
//                                 final name =
//                                     goal['name']?.toString() ?? 'Sin nombre';
//                                 final targetAmount =
//                                     double.tryParse(
//                                       goal['target_amount']?.toString() ?? '0',
//                                     ) ??
//                                     0;
//                                 final currentAmount =
//                                     double.tryParse(
//                                       goal['current_amount']?.toString() ?? '0',
//                                     ) ??
//                                     0;
//                                 final remainingAmount =
//                                     double.tryParse(
//                                       goal['remaining_amount']?.toString() ??
//                                           '0',
//                                     ) ??
//                                     0;
//                                 final progress =
//                                     double.tryParse(
//                                       goal['progress']?.toString() ?? '0',
//                                     ) ??
//                                     0;
//                                 final deadline =
//                                     goal['deadline']?.toString() ?? '';
//                                 final daysRemaining =
//                                     goal['days_remaining'] ?? 0;
//                                 final isOverdue = goal['is_overdue'] == true;
//                                 final isCompleted =
//                                     goal['is_completed'] == true;
//                                 final status =
//                                     goal['status']?.toString() ?? 'active';

//                                 return Container(
//                                   margin: const EdgeInsets.only(bottom: 12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: isOverdue
//                                         ? Border.all(
//                                             color: Colors.orange,
//                                             width: 2,
//                                           )
//                                         : null,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // Nombre y estado
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 name,
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 8,
//                                                     vertical: 4,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 color: _getStatusColor(
//                                                   status,
//                                                 ).withOpacity(0.1),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                               child: Text(
//                                                 _getStatusLabel(status),
//                                                 style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: _getStatusColor(
//                                                     status,
//                                                   ),
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 12),

//                                         // Progreso
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               _formatAmount(currentAmount),
//                                               style: const TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.green,
//                                               ),
//                                             ),
//                                             Text(
//                                               '${progress.toStringAsFixed(1)}%',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.grey[700],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                             10,
//                                           ),
//                                           child: LinearProgressIndicator(
//                                             value: progress / 100,
//                                             minHeight: 8,
//                                             backgroundColor: Colors.grey[200],
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                                   isCompleted
//                                                       ? Colors.blue
//                                                       : isOverdue
//                                                       ? Colors.orange
//                                                       : Colors.green,
//                                                 ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 12),

//                                         // Información adicional
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Icon(
//                                                         Icons.flag_outlined,
//                                                         size: 14,
//                                                         color: Colors.grey[600],
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         'Meta: ${_formatAmount(targetAmount)}',
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color:
//                                                               Colors.grey[600],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(height: 4),
//                                                   Row(
//                                                     children: [
//                                                       Icon(
//                                                         Icons.trending_up,
//                                                         size: 14,
//                                                         color: Colors.grey[600],
//                                                       ),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         'Falta: ${_formatAmount(remainingAmount)}',
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color:
//                                                               Colors.grey[600],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     Icon(
//                                                       Icons.calendar_today,
//                                                       size: 14,
//                                                       color: isOverdue
//                                                           ? Colors.orange
//                                                           : Colors.grey[600],
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       _formatDate(deadline),
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         color: isOverdue
//                                                             ? Colors.orange
//                                                             : Colors.grey[600],
//                                                         fontWeight: isOverdue
//                                                             ? FontWeight.bold
//                                                             : FontWeight.normal,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Row(
//                                                   children: [
//                                                     Icon(
//                                                       isOverdue
//                                                           ? Icons.warning
//                                                           : Icons.access_time,
//                                                       size: 14,
//                                                       color: isOverdue
//                                                           ? Colors.orange
//                                                           : Colors.grey[600],
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       isOverdue
//                                                           ? 'Vencida'
//                                                           : '$daysRemaining días',
//                                                       style: TextStyle(
//                                                         fontSize: 12,
//                                                         color: isOverdue
//                                                             ? Colors.orange
//                                                             : Colors.grey[600],
//                                                         fontWeight: isOverdue
//                                                             ? FontWeight.bold
//                                                             : FontWeight.normal,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//       ),
//       floatingActionButton: _goals.isNotEmpty
//           ? FloatingActionButton.extended(
//               onPressed: _navigateToCreateGoal,
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               icon: const Icon(Icons.add),
//               label: const Text('Nueva Meta'),
//               elevation: 4,
//             )
//           : null,
//     );
//   }

//   Widget _buildStatCard({
//     required String label,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Services/goal_service.dart';
import '../creation_pages/create_goal_page.dart';
import '../details_pages/goal_details_page.dart';

class GoalsStatisticsPage extends StatefulWidget {
  const GoalsStatisticsPage({super.key});

  @override
  State<GoalsStatisticsPage> createState() => _GoalsStatisticsPageState();
}

class _GoalsStatisticsPageState extends State<GoalsStatisticsPage> {
  final _goalService = GoalService();
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _goalService.getGoals();

      if (!mounted) return;

      if (result['success']) {
        final data = result['data'];
        List<Map<String, dynamic>> goals = [];

        if (data is Map && data.containsKey('data')) {
          final goalsList = data['data'];
          if (goalsList is List) {
            goals = goalsList.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }).toList();
          }
        }

        // Ordenar: activas primero, luego por días restantes
        goals.sort((a, b) {
          final statusA = a['status']?.toString().toLowerCase() ?? '';
          final statusB = b['status']?.toString().toLowerCase() ?? '';

          if (statusA == 'active' && statusB != 'active') return -1;
          if (statusA != 'active' && statusB == 'active') return 1;

          final daysA = a['days_remaining'] ?? 0;
          final daysB = b['days_remaining'] ?? 0;
          return daysA.compareTo(daysB);
        });

        setState(() {
          _goals = goals;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Error al cargar metas';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  String _formatAmount(dynamic amount) {
    try {
      final numAmount = double.parse(amount.toString());
      return '\$${numAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Activa';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status ?? 'N/A';
    }
  }

  Map<String, dynamic> _calculateStatistics() {
    double totalTarget = 0;
    double totalCurrent = 0;
    int activeGoals = 0;
    int completedGoals = 0;
    int overdueGoals = 0;

    for (var goal in _goals) {
      final target =
          double.tryParse(goal['target_amount']?.toString() ?? '0') ?? 0;
      final current =
          double.tryParse(goal['current_amount']?.toString() ?? '0') ?? 0;
      final status = goal['status']?.toString().toLowerCase() ?? '';
      final isOverdue = goal['is_overdue'] == true;

      totalTarget += target;
      totalCurrent += current;

      if (status == 'active') activeGoals++;
      if (status == 'completed' || goal['is_completed'] == true) {
        completedGoals++;
      }
      if (isOverdue) overdueGoals++;
    }

    return {
      'totalTarget': totalTarget,
      'totalCurrent': totalCurrent,
      'totalRemaining': totalTarget - totalCurrent,
      'activeGoals': activeGoals,
      'completedGoals': completedGoals,
      'overdueGoals': overdueGoals,
      'overallProgress': totalTarget > 0
          ? (totalCurrent / totalTarget * 100)
          : 0,
    };
  }

  Future<void> _navigateToCreateGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGoalPage()),
    );

    if (result == true) {
      _loadGoals();
    }
  }

  Future<void> _navigateToGoalDetails(String goalId, String goalName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GoalDetailsPage(goalId: goalId, goalName: goalName),
      ),
    );

    if (result == true) {
      _loadGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadGoals,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green[50],
                            foregroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Estadísticas de Metas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _loadGoals,
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green[50],
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Resumen general
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Progreso General',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats['overallProgress'].toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: stats['overallProgress'] / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ahorrado',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatAmount(stats['totalCurrent']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Meta Total',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatAmount(stats['totalTarget']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Estadísticas rápidas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Activas',
                            value: stats['activeGoals'].toString(),
                            icon: Icons.flag,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Completadas',
                            value: stats['completedGoals'].toString(),
                            icon: Icons.check_circle,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Vencidas',
                            value: stats['overdueGoals'].toString(),
                            icon: Icons.warning,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lista de metas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis Metas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_goals.length} metas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _goals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.flag,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay metas registradas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crea tu primera meta financiera',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _navigateToCreateGoal,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear Meta'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadGoals,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                100,
                              ),
                              itemCount: _goals.length,
                              itemBuilder: (context, index) {
                                final goal = _goals[index];
                                final goalId = goal['id']?.toString() ?? '';
                                final name =
                                    goal['name']?.toString() ?? 'Sin nombre';
                                final targetAmount =
                                    double.tryParse(
                                      goal['target_amount']?.toString() ?? '0',
                                    ) ??
                                    0;
                                final currentAmount =
                                    double.tryParse(
                                      goal['current_amount']?.toString() ?? '0',
                                    ) ??
                                    0;
                                final remainingAmount =
                                    double.tryParse(
                                      goal['remaining_amount']?.toString() ??
                                          '0',
                                    ) ??
                                    0;
                                final progress =
                                    double.tryParse(
                                      goal['progress']?.toString() ?? '0',
                                    ) ??
                                    0;
                                final deadline =
                                    goal['deadline']?.toString() ?? '';
                                final daysRemaining =
                                    goal['days_remaining'] ?? 0;
                                final isOverdue = goal['is_overdue'] == true;
                                final isCompleted =
                                    goal['is_completed'] == true;
                                final status =
                                    goal['status']?.toString() ?? 'active';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isOverdue
                                        ? Border.all(
                                            color: Colors.orange,
                                            width: 2,
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        _navigateToGoalDetails(goalId, name),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Nombre y estado
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    status,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _getStatusLabel(status),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getStatusColor(
                                                      status,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Progreso
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatAmount(currentAmount),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Text(
                                                '${progress.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress / 100,
                                              minHeight: 8,
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    isCompleted
                                                        ? Colors.blue
                                                        : isOverdue
                                                        ? Colors.orange
                                                        : Colors.green,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Información adicional
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.flag_outlined,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Meta: ${_formatAmount(targetAmount)}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.trending_up,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Falta: ${_formatAmount(remainingAmount)}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        size: 14,
                                                        color: isOverdue
                                                            ? Colors.orange
                                                            : Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _formatDate(deadline),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isOverdue
                                                              ? Colors.orange
                                                              : Colors
                                                                    .grey[600],
                                                          fontWeight: isOverdue
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                    .normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        isOverdue
                                                            ? Icons.warning
                                                            : Icons.access_time,
                                                        size: 14,
                                                        color: isOverdue
                                                            ? Colors.orange
                                                            : Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isOverdue
                                                            ? 'Vencida'
                                                            : '$daysRemaining días',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isOverdue
                                                              ? Colors.orange
                                                              : Colors
                                                                    .grey[600],
                                                          fontWeight: isOverdue
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                    .normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _goals.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateGoal,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nueva Meta'),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
