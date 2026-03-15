// services/recommendation_service.dart — Rule-based bike recommendation logic
class RecommendationService {
  /// Returns a recommendation tip string based on bike attributes,
  /// or null if no specific tip applies.
  static String? getTip(Map<String, dynamic> bike) {
    final String? bikeType = bike['bike_type']?.toString().toLowerCase();
    final int? engineCC    = int.tryParse(bike['engine_cc']?.toString() ?? '');
    final double? priceHr  = double.tryParse(bike['price_per_hour']?.toString() ?? '');

    // ── Rule 1: Budget tip (< ₹200/hr → scooter recommendation) ──
    // If the bike is expensive and it's not a scooter, suggest going scooter
    if (priceHr != null && priceHr >= 200 && bikeType != 'scooter') {
      return '💡 On a budget? Consider booking a scooter — same freedom, lower cost (under ₹200/hr).';
    }

    // ── Rule 2: Long distance tip (engine < 150cc for non-electric) ──
    // For long trips (>50 km), suggest a higher CC bike
    if (engineCC != null && engineCC < 150 && bikeType != 'electric') {
      return '🛣️ Planning a long trip (50+ km)? A 150cc+ bike will be more comfortable and fuel-efficient.';
    }

    // ── Rule 3: City commute → recommend electric ──────────────────
    if (bikeType == 'electric') {
      return '⚡ Great choice! Electric bikes are perfect for city commutes — zero emissions and low cost.';
    }

    // ── Rule 4: Scooter for city ───────────────────────────────────
    if (bikeType == 'scooter') {
      return '🏙️ Scooters are ideal for city rides — easy to park and manoeuvre through traffic.';
    }

    // ── Rule 5: Cruiser/sports for experience ──────────────────────
    if (bikeType == 'cruiser' || bikeType == 'sports') {
      return '🏍️ This ${bikeType} offers a premium riding experience — best for highway or leisure rides.';
    }

    return null; // No tip for this bike
  }

  /// Given user preferences, return the recommended bike type.
  /// Can be used to filter the bike list on the listing screen.
  static String recommendBikeType({
    double? budgetPerHour,
    double? tripDistanceKm,
    String? tripPurpose, // 'city', 'highway', 'leisure'
  }) {
    // Rule 1: Low budget → scooter
    if (budgetPerHour != null && budgetPerHour < 200) {
      return 'scooter';
    }

    // Rule 2: Long distance → high CC bike
    if (tripDistanceKm != null && tripDistanceKm > 50) {
      return 'cruiser'; // 150cc+
    }

    // Rule 3: City commute → electric
    if (tripPurpose?.toLowerCase() == 'city') {
      return 'electric';
    }

    // Default
    return 'scooter';
  }
}
