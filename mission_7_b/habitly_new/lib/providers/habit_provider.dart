import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

/// ================= FILTER & SORT PROVIDERS =================
enum HabitStatus { all, upcoming, ongoing, completed }

enum SortBy { newest, oldest, alphabetical }

final habitStatusFilterProvider = StateProvider<HabitStatus>(
  (ref) => HabitStatus.all,
);

final habitSortByProvider = StateProvider<SortBy>((ref) => SortBy.newest);

/// ================= STATE =================
class HabitState {
  final List<Habit> habits;
  final bool isLoading;
  final String? errorMessage;

  HabitState({required this.habits, this.isLoading = false, this.errorMessage});

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ================= NOTIFIER =================
class HabitNotifier extends StateNotifier<HabitState> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _habitsSub;

  HabitNotifier() : super(HabitState(habits: [], isLoading: true)) {
    _authSub = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _habitsSub?.cancel();
        _habitsSub = null;
        state = HabitState(habits: [], isLoading: false);
        return;
      }
      _startHabitsListener(user.uid);
    });
  }

  /// STREAM REALTIME HABIT
  void _startHabitsListener(String userId) {
    state = state.copyWith(isLoading: true);

    _habitsSub?.cancel();
    _habitsSub = _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final habits = snapshot.docs.map((doc) {
              final data = doc.data();
              return Habit.fromJson(data, doc.id);
            }).toList();

            state = HabitState(habits: habits, isLoading: false);
          },
          onError: (e) {
            state = HabitState(
              habits: [],
              isLoading: false,
              errorMessage: 'Gagal memuat data: $e',
            );
          },
        );
  }

  @override
  void dispose() {
    _habitsSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  /// ADD HABIT
  Future<void> addHabit(
    String name,
    String frequency,
    int target, {
    DateTime? dueDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('habits').add({
        'name': name,
        'frequency': frequency,
        'target': target,
        'currentProgress': 0,
        'userId': user.uid,
        'dueDate': dueDate ?? DateTime.now().add(const Duration(days: 7)),
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menambah habit: $e');
    }
  }

  /// UPDATE HABIT
  Future<void> updateHabit(
    String docId,
    String name,
    String frequency,
    int target, {
    DateTime? dueDate,
  }) async {
    try {
      await _firestore.collection('habits').doc(docId).update({
        'name': name,
        'frequency': frequency,
        'target': target,
        if (dueDate != null) 'dueDate': dueDate,
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update habit: $e');
    }
  }

  /// DELETE HABIT
  Future<void> deleteHabit(String docId) async {
    try {
      await _firestore.collection('habits').doc(docId).delete();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal hapus habit: $e');
    }
  }

  /// INCREMENT PROGRESS
  Future<void> incrementProgress(String docId, int currentProgress) async {
    try {
      await _firestore.collection('habits').doc(docId).update({
        'currentProgress': currentProgress + 1,
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update progress: $e');
    }
  }

  /// RESET PROGRESS
  Future<void> resetProgress(String docId) async {
    try {
      await _firestore.collection('habits').doc(docId).update({
        'currentProgress': 0,
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal reset progress: $e');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// ================= PROVIDER =================
final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  return HabitNotifier();
});

/// ================= FILTERED & SORTED HABITS PROVIDER =================
final filteredAndSortedHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitProvider).habits;
  final statusFilter = ref.watch(habitStatusFilterProvider);
  final sortBy = ref.watch(habitSortByProvider);

  // FILTER
  List<Habit> filtered = habits;
  if (statusFilter != HabitStatus.all) {
    filtered = habits.where((h) {
      switch (statusFilter) {
        case HabitStatus.upcoming:
          return h.status == 'Upcoming';
        case HabitStatus.ongoing:
          return h.status == 'Ongoing';
        case HabitStatus.completed:
          return h.status == 'Completed';
        default:
          return true;
      }
    }).toList();
  }

  // SORT
  List<Habit> sorted = [...filtered];
  switch (sortBy) {
    case SortBy.newest:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortBy.oldest:
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortBy.alphabetical:
      sorted.sort((a, b) => a.name.compareTo(b.name));
      break;
  }

  return sorted;
});
