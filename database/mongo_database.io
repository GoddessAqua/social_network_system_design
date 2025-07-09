Table users {
  _id objectid [pk]
  username string [unique]
  email string [unique]
  password string
  name string
  avatar_url string // S3 URLs
  bio string
  created_at datetime
}

Table posts {
  _id objectid [pk]
  author_id objectid [ref: > users._id]
  place_id objectid [ref: > places._id]
  description string
  photo_urls string[] // S3 URLs
  created_at datetime
  comments_count int
}

Table comments {
  _id objectid [pk]
  post_id objectid [ref: > posts._id]
  author_id objectid [ref: > users._id]
  text string
  created_at datetime
}

Table likes {
  _id objectid [pk]
  post_id objectid [ref: > posts._id]
  user_id objectid [ref: > users._id]
  created_at datetime
}

Table follows {
  _id objectid [pk]
  follower_id objectid [ref: > users._id]
  following_id objectid [ref: > users._id]
}

Table places {
  _id objectid [pk]
  name string
  country string
  location point // GeoJSON
}