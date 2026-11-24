#import "template.typ": sur-outline, sur-report

#set document(
  title: "Импорт и экспорт пространственных данных в PostGIS",
  author: "Чигирёв Тимур Павлович",
)

#show: sur-report.with(
  title: "ИМПОРТ И ЭКСПОРТ ДАННЫХ В POSTGIS",
  work-type: "Лабораторная работа № 1",
  discipline: "Геоинформационные системы",
  cipher: "ЛР 09.03.02.17.01.БОД41ИСТ",
  department: "Кафедра «Цифровая индустрия и защита информации»",
  student-name: "Т. П. Чигирёв",
  supervisor-name: "М. А. Попов",
  supervisor-title: "доцент, к.т.н.",
  city: "Хабаровск",
  year: "2026",
)

#show raw.where(block: true): set block(breakable: true)
#show raw.where(block: true): set text(font: "Consolas", size: 8pt)
#show raw.where(block: true): set par(first-line-indent: 0pt, leading: 0.25em, spacing: 0.25em)

#sur-outline()

#heading(numbering: none)[Введение]

PostGIS расширяет возможности PostgreSQL и позволяет хранить геометрию,
выполнять пространственные запросы и передавать результаты в настольные
геоинформационные системы. В лабораторной работе рассмотрены несколько
способов загрузки одних и тех же типов данных: средствами SQL, утилитами
GDAL/OGR и специализированными программами PostGIS. Такое сравнение позволяет
понять общий конвейер обработки: исходный файл преобразуется в пространственный
слой, загружается в базу данных и отображается в QGIS.

Цель работы: освоить импорт и экспорт табличных, векторных и OpenStreetMap-данных
в PostGIS, проверить их пространственные характеристики и визуализировать
результаты в QGIS.

В заданиях 1-6 использованы исходные файлы, предоставленные преподавателем:
`firenews.csv`, `Global_24h.csv`, виртуальный слой `global_24h.vrt` и набор
`TM_WORLD_BORDERS`. Для задания 7 с сайта OpenStreetMap самостоятельно
получен небольшой фрагмент территории Челябинска в формате OSM XML.

= Исходные данные и программная среда

Работа выполнена в операционной системе Windows. Для управления базами данных
использовались PostgreSQL 18, расширение PostGIS и графическая оболочка pgAdmin.
Преобразование векторных данных выполнялось утилитами `ogr2ogr`, `ogrinfo`,
`shp2pgsql`, `pgsql2shp` и `osm2pgsql`. Пространственные слои проверялись в QGIS.

#figure(
  table(
    columns: (35%, 65%),
    inset: 5pt,
    [*Компонент*], [*Назначение*],
    [PostgreSQL и PostGIS], [хранение атрибутивных и пространственных данных],
    [pgAdmin], [создание таблиц и выполнение SQL-запросов],
    [GDAL/OGR], [чтение, преобразование и экспорт геоданных],
    [QGIS], [проверка структуры слоёв и картографическая визуализация],
    [osm2pgsql], [загрузка данных OpenStreetMap в PostGIS],
  ),
  caption: [Использованное программное обеспечение],
)

В базе `postgis` было включено расширение PostGIS и создана рабочая схема
`chp01`. Наличие расширения проверено функцией `PostGIS_Full_Version()`.

#figure(
  image("figures/01_postgis_table.png", width: 100%),
  caption: [Подготовка таблицы `chp01.firenews` в базе PostGIS],
) <fig:postgis-table>

= Импорт CSV средствами PostgreSQL и PostGIS

Файл `firenews.csv` содержит сведения о пожарах, включая координаты `x` и `y`.
В схеме `chp01` создана таблица `firenews` с атрибутивными полями и столбцом
`the_geom` типа `geometry(Point, 4326)`. Строки CSV загружены командой `COPY`:

```sql
COPY chp01.firenews
  (x, y, place, size, update, startdate, enddate, title, url)
FROM 'C:/GIS_LAB/QGIS1/data/firenews.csv'
WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');
```

Команда импортировала 3006 записей, что подтверждается сообщением `COPY 3006`
на рисунке @fig:csv-copy.

#figure(
  image("figures/02_csv_copy.png", width: 100%),
  caption: [Импорт 3006 записей из файла `firenews.csv`],
) <fig:csv-copy>

После загрузки координаты преобразованы в геометрию функциями `ST_MakePoint`
и `ST_SetSRID`:

```sql
UPDATE chp01.firenews
SET the_geom = ST_SetSRID(ST_MakePoint(x, y), 4326);
```

Проверочный запрос с `ST_AsText` показал корректное формирование объектов
`POINT`. Для геометрического столбца также был создан индекс GiST.

#figure(
  image("figures/03_geometry_check.png", width: 100%),
  caption: [Проверка точечной геометрии импортированных записей],
) <fig:geometry-check>

= Импорт CSV с использованием GDAL

Файл `Global_24h.csv` содержит координаты и характеристики активных пожаров.
Виртуальный файл `global_24h.vrt` описывает создание точек из столбцов
`longitude` и `latitude` и задаёт исходную систему координат EPSG:4326.
Чтение слоя проверено командой `ogrinfo`.

Импорт в PostGIS выполнен утилитой `ogr2ogr`. В таблицу включались только
наблюдения спутника Terra, а координаты преобразовывались в EPSG:3857:

```text
ogr2ogr -overwrite -f PostgreSQL -t_srs EPSG:3857 \
  PG:"host=localhost port=5432 dbname=postgis user=postgres password=PASSWORD" \
  -lco SCHEMA=chp01 -lco GEOMETRY_NAME=the_geom -nln global_24h \
  global_24h.vrt -where "satellite='T'"
```

В таблицу `chp01.global_24h` загружено 9190 объектов. Запрос к метаданным и
функция `ST_AsEWKT` подтвердили тип `POINT` и идентификатор SRID 3857.

#figure(
  image("figures/05_gdal_metadata.png", width: 100%),
  caption: [Проверка системы координат слоя `global_24h`],
) <fig:gdal-metadata>

= Импорт шейп файла с помощью shp2pgsql

Для освоения альтернативного способа виртуальный слой был преобразован в
шейп-файл командой `ogr2ogr`. Затем `shp2pgsql` сформировал SQL-сценарий,
содержащий создание таблицы, операторы вставки и пространственный индекс:

```text
shp2pgsql -d -G -I global_24h.shp \
  chp01.global_24h_geographic > global_24h.sql
```

Ключ `-G` задаёт тип `geography`, а `-I` добавляет пространственный индекс.
Полученный файл выполнен утилитой `psql`.

#figure(
  image("figures/06_shp2pgsql.png", width: 92%),
  caption: [Формирование SQL-сценария утилитой `shp2pgsql`],
) <fig:shp2pgsql>

Представление `geography_columns` показало, что таблица
`global_24h_geographic` содержит точечный столбец `geog` с SRID 4326.

#figure(
  image("figures/07_geography_metadata.png", width: 100%),
  caption: [Проверка метаданных географического столбца],
) <fig:geography-metadata>

Подключение PostGIS было добавлено в QGIS. Таблицы схемы `chp01` распознаны
как пространственные слои, а импортированные точки отобразились на карте мира.

#figure(
  image("figures/08_qgis_points.png", width: 100%),
  caption: [Отображение точек активных пожаров в QGIS],
) <fig:qgis-points>

Распределение объектов охватывает несколько континентов и совпадает с
пространственным охватом исходного набора. Визуальная проверка дополняет SQL-
контроль: координаты распознаны как точки, а слой помещён в ожидаемое положение
без ручного смещения.

= Импорт и экспорт данных с помощью ogr2ogr

Шейп-файл `TM_WORLD_BORDERS` был загружен в PostGIS как таблица
`africa_countries`. При импорте выбраны страны региона Африка, сохранены коды
ISO2 и названия стран. После этого выполнено пространственное соединение
полигонов стран с точками пожаров:

```sql
SELECT ST_AsText(f.the_geom), f.bright_t31,
       ac.iso2, ac.country_name
FROM chp01.global_24h AS f
JOIN chp01.africa_countries AS ac
  ON ST_Contains(ac.the_geom, ST_Transform(f.the_geom, 4326))
ORDER BY f.bright_t31::double precision DESC
LIMIT 100;
```

Результат запроса содержит координаты наиболее ярких очагов и сведения о
странах, в границах которых они расположены.

#figure(
  image("figures/10_spatial_join.png", width: 100%),
  caption: [Результат пространственного соединения пожаров со странами Африки],
) <fig:spatial-join>

Запрос экспортирован в форматы GeoJSON и CSV. Для CSV геометрия представлена
двумя координатными столбцами с помощью параметра `GEOMETRY=AS_XY`.
Полученный GeoJSON успешно открыт в QGIS.

#figure(
  image("figures/11_geojson_map.png", width: 100%),
  caption: [Проверка экспортированного слоя GeoJSON в QGIS],
) <fig:geojson-map>

На карте одновременно видны исходные точки и выборка, полученная после
пространственного соединения. Сохранение положения объектов при переходе из
PostGIS в GeoJSON подтверждает корректность преобразования системы координат
и записи геометрии выходным драйвером GDAL.

= Пакетный экспорт и импорт наборов данных

Для пакетной обработки в PostGIS были подготовлены таблицы `hotspots` и
`countries`. Пространственный запрос подсчитал количество точек пожаров в
каждой стране, после чего итоговая таблица была сохранена в CSV.

Командный файл `export_shapefiles.bat` последовательно обрабатывал строки CSV
и формировал отдельный шейп-файл для каждого кода страны. В консоли выводились
код страны, название и число экспортируемых объектов.

#figure(
  image("figures/12_batch_export.png", width: 62%),
  caption: [Пакетный экспорт точек пожаров по странам],
) <fig:batch-export>

Для обратной загрузки создана таблица `chp01.hs_uploaded`. Сценарий
`import_shapefiles.bat` последовательно передавал шейп-файлы утилите `ogr2ogr`
в режиме добавления. Проверка таблицы показала наличие даты загрузки, имени
исходного файла и восстановленной геометрии. Это подтверждает работоспособность
процесса на успешно обработанных наборах.

#figure(
  image("figures/13_batch_import.png", width: 72%),
  caption: [Запуск пакетного обратного импорта шейп-файлов],
) <fig:batch-import>

#figure(
  image("figures/14_uploaded_rows.png", width: 100%),
  caption: [Проверка записей таблицы `hs_uploaded`],
) <fig:uploaded-rows>

= Экспорт результата запроса с помощью pgsql2shp

Полная таблица границ стран использована для агрегации по субрегионам.
Функция `ST_Union` объединила геометрию стран одного субрегиона, а `SUM`
рассчитала суммарное население:

```sql
SELECT MIN(subregion) AS subregion,
       ST_Union(the_geom) AS the_geom,
       SUM(pop2005) AS pop2005
FROM chp01.countries_full
GROUP BY subregion;
```

Утилита `pgsql2shp` экспортировала результат в `subregions.shp`. Консольное
сообщение подтвердило создание 23 полигональных объектов. В QGIS для поля
`POP2005` применена градуированная классификация по пяти классам.

#figure(
  image("figures/16_graduated_settings.png", width: 100%),
  caption: [Настройка градуированной классификации по полю `POP2005`],
) <fig:graduated-settings>

#figure(
  image("figures/17_subregions_map.png", width: 100%),
  caption: [Карта населения по субрегионам мира],
) <fig:subregions-map>

Светлые оттенки соответствуют меньшим значениям суммарного населения, тёмные
и насыщенные - большим. Таким образом, экспортированный шейп-файл сохранил не
только объединённую геометрию субрегионов, но и рассчитанный показатель,
использованный QGIS для тематического оформления.

= Импорт данных OpenStreetMap

Для самостоятельной части работы на сайте OpenStreetMap выбран небольшой
фрагмент Челябинска и сохранён файл `map.osm`. В отдельной базе `rome` были
включены расширения `postgis` и `hstore`.

#figure(
  image("figures/18_osm_extensions.png", width: 100%),
  caption: [Подключение расширений PostGIS и hstore в базе `rome`],
) <fig:osm-extensions>

Импорт выполнен утилитой `osm2pgsql` с классическим выходным форматом `pgsql`
и хранением дополнительных тегов в `hstore`:

```text
osm2pgsql -H ::1 -P 5432 -U postgres -d rome -O pgsql \
  --create --slim --hstore -S default.style map.osm
```

Завершение постобработки и построения индексов без ошибок показано на рисунке
@fig:osm-import.

#figure(
  image("figures/19_osm_import.png", width: 58%),
  caption: [Загрузка фрагмента Челябинска программой `osm2pgsql`],
) <fig:osm-import>

В схеме `public` созданы таблицы `planet_osm_point`, `planet_osm_line`,
`planet_osm_polygon` и `planet_osm_roads`. Геометрические столбцы имеют SRID
3857, соответствующий проекции Web Mercator.

#figure(
  image("figures/20_osm_tables.png", width: 48%),
  caption: [Таблицы OpenStreetMap в базе `rome`],
) <fig:osm-tables>

Таблица `planet_osm_point` хранит точечные объекты, `planet_osm_line` и
`planet_osm_roads` - линейные объекты, а `planet_osm_polygon` - замкнутые
контуры и мультиполигоны. Такое разделение позволяет подключать в QGIS только
нужные типы геометрии и независимо настраивать их отображение.

#figure(
  image("figures/21_osm_geometry.png", width: 72%),
  caption: [Проверка метаданных таблиц `planet_osm`],
) <fig:osm-geometry>

Для выделения территорий с древесной растительностью создано представление
`rome_trees`. Условие учитывает теги `landcover=trees`, `landuse=forest` и
`natural=wood`:

```sql
CREATE OR REPLACE VIEW rome_trees AS
SELECT osm_id, way, tags
FROM planet_osm_polygon
WHERE (tags -> 'landcover') = 'trees'
   OR landuse = 'forest'
   OR "natural" = 'wood';
```

Проверочный запрос обнаружил в выбранном фрагменте семь полигонов, подходящих
под заданные условия.

#figure(
  image("figures/22_osm_view.png", width: 74%),
  caption: [Создание представления `rome_trees`],
) <fig:osm-view>

#figure(
  image("figures/23_osm_count.png", width: 58%),
  caption: [Количество объектов в представлении `rome_trees`],
) <fig:osm-count>

Таблицы и представление подключены к QGIS. На итоговой карте отображаются
полигоны, линии и точки фрагмента городской территории Челябинска.

#figure(
  image("figures/24_chelyabinsk_map.png", width: 100%),
  caption: [Визуализация импортированных данных Челябинска в QGIS],
) <fig:chelyabinsk-map>

Итоговая карта показывает, что импортирована именно выбранная ограниченная
область города. На ней различимы дорожная сеть, точечные объекты и полигоны
застройки и землепользования. Представление `rome_trees` подключено отдельным
слоем и может оформляться независимо от остальных данных OpenStreetMap.

#heading(numbering: none)[Заключение]

В ходе лабораторной работы выполнен полный цикл импорта, преобразования,
проверки и экспорта пространственных данных. Табличный файл `firenews.csv`
загружен средствами PostgreSQL, а его координаты преобразованы в 3006
точечных геометрий. С помощью виртуального формата GDAL и `ogr2ogr` в PostGIS
импортировано 9190 точек активных пожаров с перепроецированием в EPSG:3857.

Освоена загрузка шейп-файлов программой `shp2pgsql`, выполнены пространственные
соединения точек с границами стран, экспорт результатов в GeoJSON, CSV и
Shapefile, а также пакетная обработка файлов. Результат агрегации стран по
субрегионам представлен в виде градуированной карты населения.

В самостоятельной части небольшой фрагмент Челябинска из OpenStreetMap
загружен программой `osm2pgsql`. В базе сформированы четыре стандартные
пространственные таблицы и представление с объектами древесной растительности.
Итоговые слои успешно подключены и визуализированы в QGIS. Полученные
результаты подтверждают освоение основных способов обмена данными между
файловыми форматами, PostGIS и настольной ГИС.

#heading(numbering: none)[Список использованных источников]

#enum(
  [Импорт и экспорт данных в/из PostGIS: методические указания к лабораторной работе № 1.],
  [PostGIS Development Group. PostGIS Documentation. URL: https://postgis.net/documentation/ (дата обращения: 16.11.2026).],
  [Open Source Geospatial Foundation. GDAL Documentation. URL: https://gdal.org/ (дата обращения: 16.11.2026).],
  [QGIS Project. QGIS Documentation. URL: https://docs.qgis.org/ (дата обращения: 16.11.2026).],
  [osm2pgsql contributors. osm2pgsql Documentation. URL: https://osm2pgsql.org/doc/ (дата обращения: 16.11.2026).],
  [OpenStreetMap contributors. Exporting OpenStreetMap data. URL: https://wiki.openstreetmap.org/wiki/Export (дата обращения: 16.11.2026).],
)
