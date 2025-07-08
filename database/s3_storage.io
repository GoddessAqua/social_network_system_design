Table s3_storage {
  key string [pk] // путь к файлу
  url string // публичная или подписанная ссылка на файл в S3
  contentType string // MIME-тип файла
  uploadedAt datetime // Дата и время загрузки файла
  size int // размер файла в байтах
}