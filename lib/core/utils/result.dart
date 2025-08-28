import 'package:equatable/equatable.dart';

sealed class Result<T> extends Equatable {
  const Result();
  @override
  List<Object?> get props => [];
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  @override
  List<Object?> get props => [value];
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
  @override
  List<Object?> get props => [message];
}
