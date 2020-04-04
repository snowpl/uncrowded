import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:safe_shop/domain/shop.dart';
import 'package:safe_shop/common/dimensions.dart';
import 'package:safe_shop/common/colors.dart';
import 'package:safe_shop/common/fonts.dart';
import 'package:safe_shop/services/feedback_service.dart';

// Define a custom Form widget.
class FeedbackForm extends StatefulWidget {
  final Shop shop;
  FeedbackForm(this.shop);

  @override
  _FeedbackFormState createState() {
    return _FeedbackFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class _FeedbackFormState extends State<FeedbackForm> {
  // Create a global key that uniquely identifies the Form widget
  //
  // Note: This is a `GlobalKey<FormState>`,
  final _formKey = GlobalKey<FormState>();
  // Allow to send the form once per hour
  final int feedbackInterval = 60;

  CreateFeedbackForm feedback;

  @override
  initState() {
    super.initState();
    BlocProvider.of<FeedbackBloc>(context)
      ..add(FeedbackGetEmptyForm(widget.shop));
    BlocProvider.of<FeedbackBloc>(context)
      ..listen((state) {
        if (state is FeedbackEmptyFormObtained) {
          setState(() => feedback = state.feedback);
        } else if (state is FormSaved) {
          setState(() => feedback = state.feedback);
        } else if (state is FormValidationFailed) {
          setState(() => feedback = state.feedback);
        }
      });
  }

  @override
  Widget build(BuildContext context) {

    if(feedback == null) {
      return getNoFeedbackAllowed();
    }

    DateTime currentDateTime = new DateTime.now();
    DateTime lastSubmittedDateTime =
        new DateTime.fromMillisecondsSinceEpoch(feedback.lastSubmitted);
    int timeSinceLastSubmit =
        currentDateTime.difference(lastSubmittedDateTime).inMinutes;

    // Build a Form widget using the _formKey created above.
    if (feedback.formSaved) {
      return getThankYou();
    } else if (timeSinceLastSubmit >= feedbackInterval) {
      return getForm();
    } else {
      return getNoFeedbackAllowed();
    }
  }

  Form getForm() {
    return Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Padding(
              padding: EdgeInsets.only(top: large),
              child: getFieldLabel(FlutterI18n.translate(
                  context, 'views.feedback.labels.crowded_level'))),
          getSlider(),
          getFieldLabel(
              FlutterI18n.translate(context, 'views.feedback.labels.rating')),
          getStarRatingField(),
          getFieldLabel(
              FlutterI18n.translate(context, 'views.feedback.labels.message')),
          getMessageField(),
          getErrors(),
          getSubmitButton()
          // Add TextFormFields and RaisedButton here.
        ]));
  }

  Text getErrors() {
    return Text(feedback.error, style: errorSubHeaderTextStyle);
  }

  Row getSlider() {
    return Row(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(left: extraLarge),
          child: Icon(
            Icons.person,
            color: iconBaseColor,
            size: largeIcon,
          )),
      Expanded(
          child: Slider(
              activeColor: sliderActiveColor,
              inactiveColor: sliderInactiveColor,
              value: feedback.crowdedLevel,
              min: 0,
              max: 10,
              divisions: 10,
              label: getSliderLabel(),
              onChanged: (value) {
                setState(() {
                  feedback.crowdedLevel = value;
                });
              })),
      Padding(
          padding: EdgeInsets.only(right: large),
          child: Icon(
            Icons.people,
            color: iconBaseColor,
            size: largeIcon,
          ))
    ]);
  }

  String getSliderLabel() {
    if (feedback.crowdedLevel >= 7) {
      return FlutterI18n.translate(context, 'views.feedback.slider.max');
    } else if (feedback.crowdedLevel >= 4) {
      return FlutterI18n.translate(context, 'views.feedback.slider.medium');
    } else {
      return FlutterI18n.translate(context, 'views.feedback.slider.min');
    }
  }

  Center getThankYou() {
    return Center(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Icon(
        Icons.favorite,
        color: iconErrorColor,
        size: largeIcon,
      ),
      Padding(
          padding: EdgeInsets.only(left: medium),
          child: Text(
              FlutterI18n.translate(context, 'views.feedback.thank_you') + ' !',
              style: headerTextStyle))
    ]));
  }

  Center getNoFeedbackAllowed() {
    return Center(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Icon(
        Icons.access_alarm,
        color: iconErrorColor,
        size: largeIcon,
      ),
      Padding(
          padding: EdgeInsets.only(left: medium),
          child: Text(
              FlutterI18n.translate(context, 'views.feedback.interval') + '.',
              style: subHeaderTextStyle))
    ]));
  }

  Padding getSubmitButton() {
    return Padding(
        padding: EdgeInsets.only(left: extraLarge, top: medium),
        child: RaisedButton(
          color: mainBgColor,
          padding: const EdgeInsets.all(8.0),
          textColor: baseFontColor,
          onPressed: () {
            BlocProvider.of<FeedbackBloc>(context)
              ..add(FeedbackFormSubmitted(feedback));
          },
          child: Text(FlutterI18n.translate(context, 'views.feedback.button')
              .toUpperCase()),
        ));
  }

  Padding getFieldLabel(String label) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: extraLarge),
        child: Text(label + ':', style: subHeaderTextStyle));
  }

  Row getStarRatingField() {
    final size = largeIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => _handleRatingsChange(index + 1),
          color: iconBaseColor,
          iconSize: size,
          icon: Icon(
            feedback.rating != null
                ? (index < feedback.rating ? Icons.star : Icons.star_border)
                : Icons.star_border,
          ),
          padding: EdgeInsets.zero,
        );
      }),
    );
  }

  void _handleRatingsChange(int value) {
    setState(() {
      feedback.rating = value;
    });
  }

  Padding getMessageField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: extraLarge),
      child: TextFormField(
        style: new TextStyle(color: baseFontColor),
        onChanged: (String value) {
          feedback.message = value;
        },
        decoration: InputDecoration(
          hintText:
              FlutterI18n.translate(context, 'views.feedback.hints.message') +
                  '...',
          hintStyle: TextStyle(
              fontSize: subHeaderTextStyle.fontSize, color: baseFontColor),
        ),
      ),
    );
  }
}
