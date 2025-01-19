class Game {
  final int id;
  final String slug;
  final String name;
  final String released;
  final bool tba;
  final String backgroundImage;
  final double rating;
  final int ratingTop;
  final List<Rating> ratings;
  final int ratingsCount;
  final int reviewsTextCount;
  final int added;
  final AddedByStatus addedByStatus;
  final int metacritic;
  final int playtime;
  final int suggestionsCount;
  final DateTime updated;
  final List<Platform> platforms;
  final List<ParentPlatform> parentPlatforms;
  final List<Genre> genres;
  final List<Store> stores;
  final List<Tag> tags;
  final EsrbRating esrbRating;
  final List<ShortScreenshot> shortScreenshots;
  late double? price;

  Game({
    required this.id,
    required this.slug,
    required this.name,
    required this.released,
    required this.tba,
    required this.backgroundImage,
    required this.rating,
    required this.ratingTop,
    required this.ratings,
    required this.ratingsCount,
    required this.reviewsTextCount,
    required this.added,
    required this.addedByStatus,
    required this.metacritic,
    required this.playtime,
    required this.suggestionsCount,
    required this.updated,
    required this.platforms,
    required this.parentPlatforms,
    required this.genres,
    required this.stores,
    required this.tags,
    required this.esrbRating,
    required this.shortScreenshots,
    this.price,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      released: json['released'],
      tba: json['tba'],
      backgroundImage: json['background_image'],
      rating: json['rating'].toDouble(),
      ratingTop: json['rating_top'],
      ratings:
          (json['ratings'] as List).map((e) => Rating.fromJson(e)).toList(),
      ratingsCount: json['ratings_count'],
      reviewsTextCount: json['reviews_text_count'],
      added: json['added'],
      addedByStatus: AddedByStatus.fromJson(json['added_by_status']),
      metacritic: json['metacritic'],
      playtime: json['playtime'],
      suggestionsCount: json['suggestions_count'],
      updated: DateTime.parse(json['updated']),
      platforms: (json['platforms'] as List)
          .map((e) => Platform.fromJson(e['platform']))
          .toList(),
      parentPlatforms: (json['parent_platforms'] as List)
          .map((e) => ParentPlatform.fromJson(e['platform']))
          .toList(),
      genres: (json['genres'] as List).map((e) => Genre.fromJson(e)).toList(),
      stores: (json['stores'] as List).map((e) => Store.fromJson(e)).toList(),
      tags: (json['tags'] as List).map((e) => Tag.fromJson(e)).toList(),
      esrbRating: EsrbRating.fromJson(json['esrb_rating']),
      shortScreenshots: (json['short_screenshots'] as List)
          .map((e) => ShortScreenshot.fromJson(e))
          .toList(),
    );
  }
}

class Rating {
  final int id;
  final String title;
  final int count;
  final double percent;

  Rating({
    required this.id,
    required this.title,
    required this.count,
    required this.percent,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      title: json['title'],
      count: json['count'],
      percent: json['percent'].toDouble(),
    );
  }
}

class AddedByStatus {
  final int yet;
  final int owned;
  final int beaten;
  final int toplay;
  final int dropped;
  final int playing;

  AddedByStatus({
    required this.yet,
    required this.owned,
    required this.beaten,
    required this.toplay,
    required this.dropped,
    required this.playing,
  });

  factory AddedByStatus.fromJson(Map<String, dynamic> json) {
    return AddedByStatus(
      yet: json['yet'],
      owned: json['owned'],
      beaten: json['beaten'],
      toplay: json['toplay'],
      dropped: json['dropped'],
      playing: json['playing'],
    );
  }
}

class Platform {
  final int id;
  final String name;
  final String slug;
  final String imageBackground;

  Platform({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageBackground,
  });

  factory Platform.fromJson(Map<String, dynamic> json) {
    return Platform(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      imageBackground: json['image_background'],
    );
  }
}

class ParentPlatform {
  final int id;
  final String name;
  final String slug;

  ParentPlatform({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ParentPlatform.fromJson(Map<String, dynamic> json) {
    return ParentPlatform(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class Genre {
  final int id;
  final String name;
  final String slug;
  final String imageBackground;

  Genre({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageBackground,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      imageBackground: json['image_background'],
    );
  }
}

class Store {
  final int id;
  final StoreDetails store;

  Store({
    required this.id,
    required this.store,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      store: StoreDetails.fromJson(json['store']),
    );
  }
}

class StoreDetails {
  final int id;
  final String name;
  final String slug;
  final String domain;
  final int gamesCount;
  final String imageBackground;

  StoreDetails({
    required this.id,
    required this.name,
    required this.slug,
    required this.domain,
    required this.gamesCount,
    required this.imageBackground,
  });

  factory StoreDetails.fromJson(Map<String, dynamic> json) {
    return StoreDetails(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      domain: json['domain'],
      gamesCount: json['games_count'],
      imageBackground: json['image_background'],
    );
  }
}

class Tag {
  final int id;
  final String name;
  final String slug;
  final String language;
  final String imageBackground;

  Tag({
    required this.id,
    required this.name,
    required this.slug,
    required this.language,
    required this.imageBackground,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      language: json['language'],
      imageBackground: json['image_background'],
    );
  }
}

class EsrbRating {
  final int id;
  final String name;
  final String slug;

  EsrbRating({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory EsrbRating.fromJson(Map<String, dynamic> json) {
    return EsrbRating(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class ShortScreenshot {
  final int id;
  final String image;

  ShortScreenshot({
    required this.id,
    required this.image,
  });

  factory ShortScreenshot.fromJson(Map<String, dynamic> json) {
    return ShortScreenshot(
      id: json['id'],
      image: json['image'],
    );
  }
}
