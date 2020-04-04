
import 'package:flutter/material.dart';

import '../common/fonts.dart';

enum InformationEnum {
  Symptons,
  Prevention,
  TreatmentSelfCare,
  TreatmentMedical
}

class InformationData {
  String title;
  Widget information;
  String link;
  String subTitle;

  InformationData({this.title, this.information, this.link, this.subTitle});
}

InformationData getInformationData(InformationEnum informationType) {
  if(informationType == InformationEnum.Symptons)
    return InformationData(
      title: 'Objawy',
      information: Text('Może pojawić się: katar, ból gardła, kaszel, gorączka, trudności z oddychaniem (w poważnych przypadkach).', style: baseTextStyle),
      link: 'https://www.who.int/news-room/q-a-detail/q-a-coronaviruses#:~:text=symptoms',
      subTitle: 'Choroba koronawirusowa (COVID-19) ma łagodne objawy – takie jak katar, ból gardła, kaszel i gorączka. U niektórych osób ma ona cięższy przebieg i może prowadzić do zapalenia płuc lub trudności z oddychaniem. W rzadkich przypadkach choroba bywa śmiertelna. U osób starszych i chorujących na inne choroby (takie jak astma, cukrzyca lub choroby serca) zakażenie koronawirusem może prowadzić do ciężkiej choroby.'
    );
  if(informationType == InformationEnum.Prevention){
    return InformationData(
      title: 'Profilaktyka',
      information: Text('Aby zmniejszyć ryzyko zarażenia: Często myj ręce wodą i mydłem lub środkiem dezynfekującym na bazie alkoholu. Gdy kaszlesz lub kichasz, zakrywaj usta i nos chusteczką lub wewnętrzną stroną łokcia. Unikaj bezpośredniego kontaktu (mniej niż 1 metr) z osobami mającymi objawy przeziębienia lub grypy.', style: baseTextStyle),
      link: 'https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public',
      subTitle: 'Obecnie nie istnieje szczepionka przeciwko chorobie koronawirusowej (COVID-19).'
    );
  }if(informationType == InformationEnum.TreatmentSelfCare){
    return InformationData(
      title: 'Leczenie - samoopieka',
      information: Text('Jeśli masz łagodne objawy, nie wychodź z domu, dopóki nie wyzdrowiejesz. Aby złagodzić objawy: dużo odpoczywaj i śpij, wygrzej się, pij dużo płynów, używaj nawilżacza powietrza lub bierz gorące prysznice, by złagodzić kaszel i ból gardła.', style: baseTextStyle),
      link: 'https://www.who.int/news-room/q-a-detail/q-a-coronaviruses#:~:text=protect',
      subTitle: 'Nie ma leku pozwalającego zapobiegać chorobie koronawirusowej (COVID-19) lub ją leczyć. Chorzy mogą wymagać wspomagania oddychania.'
    );
  }else{
    return InformationData(
      title: 'Leczenie - zabiegi medyczne',
      information: Text('W razie gorączki i kaszlu zostań w domu, dopóki nie wyzdrowiejesz i przez co najmniej 14 dni, by nie zarażać innych.', style: baseTextStyle),
      link: 'https://www.who.int/news-room/q-a-detail/q-a-coronaviruses#:~:text=treatment',
      subTitle: 'Nie ma leku pozwalającego zapobiegać chorobie koronawirusowej (COVID-19) lub ją leczyć. Chorzy mogą wymagać wspomagania oddychania.'
    );
  }
}