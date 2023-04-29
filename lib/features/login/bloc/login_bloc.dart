import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_online_auction_app/shared/shared.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(LoginInitial()) {
    on<LoginRequested>(_login);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _login(LoginRequested event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoading());

      final String? token = await _authenticationRepository.login(
        username: event.username,
        password: event.password,
      );

      if (token != null) {
        _authenticationRepository.changeAuthStatus(status: Authenticated(accessToken: token));
        return emit(LoginSuccess());
      }
      return emit(const LoginFailure(errors: ['Failed to retrieve token']));
    } on DioError catch (e) {
      emit(LoginFailure(errors: e.errorsMessages));
    } catch (e) {
      emit(LoginFailure(errors: [e.toString()]));
    }
  }
}
