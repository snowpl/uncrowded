import 'package:flutter/cupertino.dart';
import 'package:safe_shop/domain/shop.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  get props => [];
}

class FeedbackInitialized extends FeedbackState {}

class FeedbackEmptyFormObtained extends FeedbackState {
  final CreateFeedbackForm feedback;
  FeedbackEmptyFormObtained(this.feedback);

  @override
  get props => [feedback];
}

class FormSaved extends FeedbackState {
  final CreateFeedbackForm feedback;
  FormSaved(this.feedback);
}

class FormValidationFailed extends FeedbackState {
  final CreateFeedbackForm feedback;
  FormValidationFailed(this.feedback);
}

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  get props => [];
}

class FeedbackGetEmptyForm extends FeedbackEvent {
  final Shop shop;
  FeedbackGetEmptyForm(this.shop);
}

class FeedbackFormSubmitted extends FeedbackEvent {
  final feedback;
  FeedbackFormSubmitted(this.feedback);

  @override
  get props => [feedback];
}

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  @override
  get initialState => FeedbackInitialized();

  @override
  mapEventToState(FeedbackEvent event) async* {
    int lastSubmitted = await getSurveySubmitTimestamp();

    if (event is FeedbackGetEmptyForm) {
      CreateFeedbackForm feedback = CreateFeedbackForm(
          shopId: event.shop.id, lastSubmitted: lastSubmitted);
      yield FeedbackEmptyFormObtained(feedback);
    } else if (event is FeedbackFormSubmitted) {
      if (!validate(event.feedback)) {
        event.feedback.error = "Proszę wypełnić conajmniej jedno polę";
        yield FormValidationFailed(event.feedback);
      } else {
        sendFeedback(event.feedback);
        CreateFeedbackForm feedback = CreateFeedbackForm(
            shopId: event.feedback.shopId,
            formSaved: true,
            lastSubmitted: lastSubmitted);
        yield FormSaved(feedback);
      }
    }
  }

  bool validate(CreateFeedbackForm feedback) {
    if(feedback.rating == 0 && feedback.message == null && feedback.crowdedLevel == 0.0) {
      return false;
    }

    return true;
  }

  void sendFeedback(CreateFeedbackForm feedback) {
    createFeedback(feedback);
    setSurveySubmitTimestamp();
  }

  void createFeedback(CreateFeedbackForm feedback) async {
    Map feedbackJson = feedback.toJson();
    final http.Response response = await http.post(
      'https://jsonplaceholder.typicode.com/posts',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'shopId': feedbackJson['shopId'],
        'crowdedLevel': feedbackJson['crowdedLevel'],
        'rating': feedbackJson['rating'],
        'message': feedbackJson['message'],
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create feedback');
    }
  }

  setSurveySubmitTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('LAST_SURVEY_SUBMIT_TIMESTAMP',
        new DateTime.now().millisecondsSinceEpoch);
  }

  getSurveySubmitTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int timestamp = prefs.getInt('LAST_SURVEY_SUBMIT_TIMESTAMP');

    return timestamp ?? 0;
  }
}

class CreateFeedbackForm {
  String shopId;
  double crowdedLevel;
  String message;
  int rating;
  bool formSaved;
  int lastSubmitted;
  String error;

  CreateFeedbackForm({
    @required this.shopId,
    this.message,
    this.lastSubmitted = 0,
    this.crowdedLevel = 0.0,
    this.rating = 0,
    this.formSaved = false,
    this.error = '',
  });

  Map<String,dynamic> toJson() {
    return {
      "shopId": this.shopId,
      "crowdedLevel": this.crowdedLevel.toString(),
      "rating": this.rating.toString(),
      "message": this.message
    };
  }

  @override
  String toString() {
    return "CreateFeedbackForm [shopId=${this.shopId},message=${this.message},crowdedLevel=${this.crowdedLevel},rating=${this.rating},formSaved=${this.formSaved},lastSubmitted=${this.lastSubmitted},error=${this.error}]";
  }
}
