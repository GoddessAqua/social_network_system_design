# System Design социальной сети для курса по System Design (https://balun.courses/courses/system_design)

---
## Функциональные требования:
- публикация постов из путешествий с фотографиями, небольшим описанием и привязкой к конкретному месту путешествия;
- оценка и комментарии постов других путешественников;
- подписка на других путешественников, чтобы следить за их активностью;
- поиск популярных мест для путешествий и просмотр постов с этих мест;
- просмотр ленты других путешественников и ленты пользователя, основанной на подписках в обратном хронологическом порядке;

---
## Нефункциональные требования:
- DAU 10 000 000
- Данные будем хранить всегда
- Аудитория стран СНГ
- Активности пользователей:
	- в среднем пользователь делает 1 публикацию постов в сутки
	- в среднем пользователь оценивает и комментирует посты других путешественников суммарно 10 раз в сутки
	- в среднем пользователь подписывается на других путешественников, чтобы следить за их активностью, 2 раза в сутки
	- в среднем пользователь осуществляет поиск популярных мест для путешествий и просмотр постов с этих мест 3 раза в сутки
	- в среднем пользователь просматривает ленты других путешественников и ленты пользователя, основанной на подписках в обратном хронологическом порядке, 20 раз за сутки
- Лимиты:
  - Макс. подписчиков у пользователя : 1 000 000
  - Макс. подписок у пользователя : 5000
  - Лимит новых подписок/день : 100
  - Макс. постов в день : 50
  - Макс. фото в посте : 3
  - Размер фото : 1.5 MB/фото
  - Длина описания : 1000 символов
  - Постов в ленте : 5
  - Лайков в день : 1000
  - Комментариев в день	: 100
  - Длина комментария : 500 символов
  - Макс. геометок в день в посте : 7
- Сезонность : нет, можно пользоваться в любое время, но в периоды с июня по август и в Новый год возможно увеличение нагрузки на 20%, так как это основные сезоны для путешествий
- Тайминги :
  - создание публикации поста с фото с макс. количеством фото : 3 секунды
  - лайк/комментарий : 2 секунды
  - подписка/отписка : 2 секунды
  - поиск мест : 2 секунды
  - загрузка ленты подписок : 3 секунды
- Доступность приложения : 99.9% 


photo (size 200B):
id
post_id

post (size 500B):
id
geoposition_id
user_id
description
created_at

like (size 400B):
id
post_id
user_id
created_at

comment (size 500B):
id
post_id
user_id	
text
created_at

---
## Оценка нагрузки:

Публикация постов :
RPS(write) = 10 000 000 * 1 / 86 400 ~ 116 

Оценки (лайки + комментарии) :
RPS(write) = 10 000 000 * 10 / 86 400 ~ 1157

Просмотр ленты :
RPS(read) = 10 000 000 * 20 / 86 400 ~ 2314

- Траффик:
	- Публикация постов : Traffic (write) = 116 * 500 = 58 000 B/s = 58 kB/s
	- Оценки (лайки + комментарии) : Traffic (write) = 1157 * 900 = 1 041 300 B/s = 1041,3 kB/s
	- Просмотр ленты : Traffic (read) = 2314 * 500 * 5 = 5 785 000 B/s = 5785 kB/s
    - Для медиа : Traffic (write) = 116 * 1.5 MB/фото * 3 фото/на 1 пост = 522 MB/s
    (при 10 фото на 10 MB : Traffic (write) = 116 * 10 MB/фото * 10 фото/на 1 пост = 11 600 MB/s = 11,6 ГБ/сек)

---
# Ресурсы:

## Для MongoDB:

### 1. Публикация постов:

    Capacity = 58 kB/s * 86400 сек/день * 365 дней ~ 1.83 TB

#### Для HDD (32 TB, 100 MB/s, 100 IOPS):

    Disks_for_capacity = capacity / disk_capacity = 1.83 TB / 2 ТБ = 0.915 → 1 диск
    Disks_for_throughput = traffic_per_second / disk_throughput = 0.058 MB/s / 100 MB/s = 0.0006 -> 1 диск
    Disks_for_iops = iops / disk_iops = 116 / 100 = 1.16 -> 2 диска
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(1, 1, 2) = 2 диска

#### Для SATA SSD (100TB, 1,000 IOPS, 500 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 1.83 TB / 2 ТБ = 0.915 → 1 диск
    Disks_for_throughput = traffic_per_second / disk_throughput = 0.058 MB/s / 500 MB/s = 0.0001 -> 1 диск
    Disks_for_iops = iops / disk_iops = 116 / 1000 = 0.116 -> 1 диск
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(1, 1, 1) = 1 диск

####  Для NVMe SSD (30TB, 10,000 IOPS, 3,000 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 1.83 TB / 2 ТБ = 0.915 → 1 диск
    Disks_for_throughput = traffic_per_second / disk_throughput = 0.058 MB/s / 3000 MB/s = 0.00002 -> 1 диск
    Disks_for_iops = iops / disk_iops = 116 / 10000 = 0.0116 -> 1 диск
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(1, 1, 1) = 1 диск

#### Итого : 2 HDD по 2 ТВ или 1 SATA SSD по 2 ТВ или 1 NVMe SSD по 2 ТБ

### 2. Оценки (лайки + комментарии):

    Capacity = 1041,3 kB/s * 86400 сек/день * 365 дней ~ 32.84 TB

#### Для HDD (32 TB, 100 MB/s, 100 IOPS):

    Disks_for_capacity = capacity / disk_capacity = 32.84 TB / 32 TB = 1.03 → 2 диска
    Disks_for_throughput = traffic_per_second / disk_throughput = 1.0413 MB/s / 100 MB/s = 0.01 -> 1 диск
    Disks_for_iops = iops / disk_iops = 1157 / 100 = 11.57 -> 12 дисков
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(2, 1, 12) = 12 дисков

#### Для SATA SSD (100TB, 1,000 IOPS, 500 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 32.84 TB / 32 TB = 1.03 → 2 диска
    Disks_for_throughput = traffic_per_second / disk_throughput = 1.0413 MB/s / 500 MB/s = 0.002 -> 1 диск
    Disks_for_iops = iops / disk_iops = 1157 / 1000 = 1.157 -> 2 диска
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(2, 1, 2) = 2 диска

####  Для NVMe SSD (30TB, 10,000 IOPS, 3,000 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 32.84 TB / 32 TB = 1.03 → 2 диска
    Disks_for_throughput = traffic_per_second / disk_throughput = 1.0413 MB/s / 3000 MB/s = 0.0003 -> 1 диск
    Disks_for_iops = iops / disk_iops = 1157 / 10000 = 0.1157 -> 1 диск
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(2, 1, 1) = 2 диска

#### Итого : 12 HDD по 32 ТВ или 2 SATA SSD по 32 ТВ или 2 NVMe SSD по 32 ТБ

## Для S3:

    Capacity = 522 MB/s * 86400 сек/день * 365 дней ~ 16 461 TB

#### Для HDD (32 TB, 100 MB/s, 100 IOPS):

    Disks_for_capacity = capacity / disk_capacity = 16 461 TB / 32 ТБ = 514.406 → 515 дисков
    Disks_for_throughput = traffic_per_second / disk_throughput = 522 MB/s / 100 MB/s = 5.22 -> 6 дисков
    Disks_for_iops = iops / disk_iops = (116 + 1157 + 2314) / 100 = 35.87 -> 36 дисков
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(515, 6, 36) = 515 дисков

#### Для SATA SSD (100TB, 1,000 IOPS, 500 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 16 461 TB / 100 ТБ = 164.61 → 165 дисков
    Disks_for_throughput = traffic_per_second / disk_throughput = 522 MB/s / 500 MB/s = 1.044 -> 2 диска
    Disks_for_iops = iops / disk_iops = (116 + 1157 + 2314) / 1000 = 3.587 -> 4 диска
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(165, 2, 4) = 165 дисков

####  Для NVMe SSD (30TB, 10,000 IOPS, 3,000 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 16 461 TB / 30 ТБ = 548.7 → 549 дисков
    Disks_for_throughput = traffic_per_second / disk_throughput = 522 MB/s / 3000 MB/s = 0.174 -> 1 диск
    Disks_for_iops = iops / disk_iops = (116 + 1157 + 2314) / 10000 = 0.3587 -> 1 диск
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(549, 1, 1) = 549 дисков

#### Итого : 515 HDD по 32 ТВ или 165 SATA SSD по 100 TB

## Для Elasticsearch:

Capacity = (58 kB/s + 1041,3 kB/s) * 86400 сек/день * 365 дней ~ 33.95 TB

#### Для HDD (32 TB, 100 MB/s, 100 IOPS):

    Disks_for_capacity = capacity / disk_capacity = 33.95 TB / 32 ТБ = 1.060 → 2 диска
    Disks_for_throughput = traffic_per_second / disk_throughput = 1.073MB/s / 100 MB/s = 0.01073 -> 1 диск
    Disks_for_iops = iops / disk_iops = (116 + 1157) / 100 = 12.73 -> 12 дисков
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(2, 1, 12) = 12 дисков

#### Для SATA SSD (100TB, 1,000 IOPS, 500 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 33.95 TB / 32 ТБ = 1.060 → 2 диска
    Disks_for_throughput = traffic_per_second / disk_throughput = 1.073MB/s / 500 MB/s = 0.002146 -> 1 диск
    Disks_for_iops = iops / disk_iops = 1273 / 1000 = 1.273 → 2 диска
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(2, 1, 2) = 2 диска

####  Для NVMe SSD (30TB, 10,000 IOPS, 3,000 MB/s):

    Disks_for_capacity = capacity / disk_capacity = 33.95 TB / 32 ТБ = 1.060 → 2 диска
    Disks_for_throughput = traffic_per_second / disk_throughput = 1.073MB/s / 3000 MB/s = 0.000358 -> 1 диск
    Disks_for_iops = iops / disk_iops = 1273 / 10000 = 0.1273 -> 1 диск
    Disks = max(ceil(Disks_for_capacity), ceil(Disks_for_throughput), ceil(Disks_for_iops)) = max(2, 1, 1) = 2 диска

#### Итого : 12 HDD по 32 ТВ или 2 SATA SSD по 32 ТВ или 2 NVMe SSD по 32 ТБ