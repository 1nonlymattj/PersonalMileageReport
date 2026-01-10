class CacheKeys {
  // mileage drafts
  static const mileageStart = 'mileageStart';
  static const mileageEnd = 'mileageEnd';
  static const mileageAmount = 'mileageAmount';

  // when user last changed any mileage field (millis)
  static const mileageDraftTouchedAt = 'mileageDraftTouchedAt';

  // last time we fired a mileage reminder (millis)
  static const mileageDraftLastRemindedAt = 'mileageDraftLastRemindedAt';

  // maintenance drafts
  static const maintType = 'maintType';
  static const maintCost = 'maintCost';

  // when user last changed any maintenance field (millis)
  static const maintDraftTouchedAt = 'maintDraftTouchedAt';

  // last time we fired a maintenance reminder (millis)
  static const maintDraftLastRemindedAt = 'maintDraftLastRemindedAt';
}
