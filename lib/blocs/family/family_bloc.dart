// lib/blocs/family/family_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'family_event.dart';
import 'family_state.dart';
import '../../repositories/family_repository.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyRepository familyRepository;

  FamilyBloc({required this.familyRepository}) : super(FamilyInitial()) {
    on<JoinFamily>(_onJoinFamily);
    on<CreateFamily>(_onCreateFamily);
  }

  Future<void> _onJoinFamily(JoinFamily event, Emitter<FamilyState> emit) async {
    emit(FamilyLoading());
    try {
      await familyRepository.joinFamily(event.code);
      emit(FamilyJoinSuccess());
    } catch (e) {
      emit(FamilyJoinFailure(error: e.toString()));
    }
  }

  Future<void> _onCreateFamily(CreateFamily event, Emitter<FamilyState> emit) async {
    emit(FamilyLoading());
    try {
      await familyRepository.createFamily(event.familyName);
      emit(FamilyCreateSuccess());
    } catch (e) {
      emit(FamilyCreateFailure(error: e.toString()));
    }
  }
}
