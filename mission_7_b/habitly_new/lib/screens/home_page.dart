import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitly/screens/habit_form.dart';
import 'package:habitly/screens/habit_list.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_footer.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    final isDarkMode = ref.watch(themeProvider);
    final statusFilter = ref.watch(habitStatusFilterProvider);
    final sortBy = ref.watch(habitSortByProvider);

    // Show error snackbar if any
    if (habitState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(habitState.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(habitProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline),
            SizedBox(width: 8),
            Text("Habitly"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).state = !isDarkMode;
            },
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: habitState.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF2FB969)),
                        SizedBox(height: 16),
                        Text(
                          "Memuat data habit...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Card(
                            color: const Color(0xFF2FB969),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "🎯 Kelola Kebiasaanmu",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Halo, ${user?.email ?? 'User'}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Total ${habitState.habits.length} kebiasaan aktif",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form Section
                          const HabitForm(),
                          const SizedBox(height: 32),

                          // Filter & Sort Section
                          const Text(
                            "Filter & Sort",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<HabitStatus>(
                                  isExpanded: true,
                                  value: statusFilter,
                                  items: HabitStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status == HabitStatus.all
                                            ? "Semua Status"
                                            : status == HabitStatus.upcoming
                                            ? "📅 Upcoming"
                                            : status == HabitStatus.ongoing
                                            ? "🔄 Ongoing"
                                            : "✅ Completed",
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      ref
                                              .read(
                                                habitStatusFilterProvider
                                                    .notifier,
                                              )
                                              .state =
                                          value;
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButton<SortBy>(
                                  isExpanded: true,
                                  value: sortBy,
                                  items: SortBy.values.map((sort) {
                                    return DropdownMenuItem(
                                      value: sort,
                                      child: Text(
                                        sort == SortBy.newest
                                            ? "🆕 Terbaru"
                                            : sort == SortBy.oldest
                                            ? "👴 Tertua"
                                            : "🔤 Alphabetical",
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      ref
                                              .read(
                                                habitSortByProvider.notifier,
                                              )
                                              .state =
                                          value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // List Section
                          const Text(
                            "Daftar Habit",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          const HabitList(),
                        ],
                      ),
                    ),
                  ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
