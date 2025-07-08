Table posts_index {
  _id string [pk] // ID поста (совпадает с MongoDB)
  title string
  description string
  placeId string
  createdAt datetime
  likes int
  location point // геолокация для geo-запросов
}

Table places_index {
  _id string [pk] // ID места (совпадает с MongoDB)
  name string
  description string
  country string
  region string
  location point
  popularity int
}