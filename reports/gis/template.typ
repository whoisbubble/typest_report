// =============================================================================
// ШАБЛОН СТУДЕНЧЕСКИХ УЧЕБНЫХ РАБОТ (СУР) ДВГУПС
// Требования: учебно-методическое пособие Д. Ю. Дроголова (2022), разделы о СУР
// =============================================================================

#let sur-appendix-prefix = state("sur-appendix-prefix", none)

// Оглавление СУР. Заголовки структурных элементов передаются в обычном
// регистре, а их прописное начертание на страницах задаётся ниже шаблоном.
#let sur-outline() = outline(
  title: [ОГЛАВЛЕНИЕ],
  indent: 0.75cm,
)

#let sur-report(
  title: "НАЗВАНИЕ РАБОТЫ",
  work-type: "Практическая работа",
  discipline: "Название дисциплины", // Или вид практики
  cipher: "КР 23.05.03.17.18.СО151ЛОК",
  department: "Кафедра «Цифровая индустрия и защита информации»",
  student-name: "И. О. Фамилия",
  supervisor-name: "С. А. Шухарев",
  supervisor-title: "доцент, к. т. н.",
  city: "Хабаровск",
  year: "2026",
  // Титульный лист не нумеруется. Укажите 2, если после него вставлен лист
  // задания (РГР, КР, КП и отчёт о прохождении практики).
  unprinted-front-pages: 1,
  // Для отчёта о практике значение определяется автоматически как none.
  // Его также можно явно задать строкой или значением none.
  discipline-label: auto,
  body,
) = {
  sur-appendix-prefix.update(none)

  // 1. Поля страницы СУР (п. 1.3: левое 20, верхнее 20, правое 15, нижнее 30 мм)
  set page(
    paper: "a4",
    margin: (left: 20mm, top: 20mm, right: 15mm, bottom: 30mm),
    header: none,
    footer: context {
      let page-num = counter(page).get().first()
      if page-num > unprinted-front-pages {
        align(center)[#text(font: "Times New Roman", size: 12pt)[#page-num]]
      }
    },
  )

  // 2. Основной шрифт (п. 1.4: Times New Roman 14 пт, переносы включены)
  set text(
    font: "Times New Roman",
    size: 14pt,
    fill: black,
    lang: "ru",
    hyphenate: true,
  )

  // 3. Абзацный отступ 0,75 см и полуторный интервал (пп. 7.2, 8.5)
  // 1,05 em даёт для Times New Roman 14 пт шаг строк около 24 пт,
  // соответствующий полуторному интервалу в образцах пособия.
  set par(
    justify: true,
    first-line-indent: (amount: 0.75cm, all: true),
    leading: 1.05em,
    spacing: 1.05em,
  )

  // 4. ТИТУЛЬНЫЙ ЛИСТ СУР (п. 2.2)
  {
    set par(
      leading: 0.5em,
      spacing: 0.5em,
      first-line-indent: 0cm,
      justify: false,
    )

    align(center)[
      #text(size: 12pt)[
        Министерство транспорта Российской Федерации\
        Федеральное агентство железнодорожного транспорта
      ]
      #v(8pt)
      #text(size: 12pt)[
        Федеральное государственное бюджетное\
        образовательное учреждение высшего образования\
        «Дальневосточный государственный университет путей сообщения»
      ]
      #v(8pt)
      #text(size: 12pt)[#department]
    ]

    v(2.8cm)

    align(center)[
      #set par(leading: 0.65em, spacing: 0pt, justify: false)
      #set text(hyphenate: false)
      #block(text(size: 20pt)[#upper(title)], below: 10pt)
      #if work-type != "" and work-type != none [
        #block(text(size: 18pt)[#work-type], below: 10pt)
      ]
      #if discipline != "" and discipline != none [
        #let resolved-discipline-label = if discipline-label == auto {
          if work-type != none and work-type.contains("практик") { none } else { "дисциплина" }
        } else {
          discipline-label
        }
        #block(
          text(size: 18pt)[
            #if resolved-discipline-label == none or resolved-discipline-label == "" {
              discipline
            } else if discipline.starts-with(resolved-discipline-label) {
              discipline
            } else {
              [#resolved-discipline-label «#discipline»]
            }
          ],
          below: 10pt,
        )
      ]
      #block(text(size: 20pt, hyphenate: false)[#cipher], below: 0pt)
    ]

    v(2.8cm)

    // Поле сплошной линии с подстрочной надписью под ней
    let signature-field(label) = box(width: 100%)[
      #align(center)[
        #box(width: 100%, stroke: (bottom: 0.5pt), height: 12pt)[]
        #v(-6pt)
        #text(size: 10pt, style: "italic")[#label]
      ]
    ]

    // Блок подписей студента и руководителя (по образцу кафедры ЦИиЗИ)
    align(left)[
      #grid(
        columns: (auto, 1fr, 1fr, auto),
        column-gutter: 14pt,
        row-gutter: 8pt,
        align: (left + top, center + top, center + top, right + top),

        // Строка 1: Студент
        [#text(size: 14pt)[Студент]],
        signature-field("подпись"),
        signature-field("дата"),
        [#text(size: 14pt)[#student-name]],

        // Строка 2: Руководитель
        grid.cell(colspan: 4)[#text(size: 14pt)[Руководитель]],
        [#if supervisor-title != "" and supervisor-title != none {
          text(size: 14pt)[#supervisor-title]
        }],
        signature-field("подпись"),
        signature-field("дата"),
        [#text(size: 14pt)[#supervisor-name]],
      )
    ]

    v(1fr)
    align(center)[#text(size: 12pt)[#city – #year]]
  }

  pagebreak()

  // ===========================================================================
  // 5. ЗАГОЛОВКИ И СТРУКТУРНЫЕ ЭЛЕМЕНТЫ (пп. 6–10)
  // ===========================================================================
  set heading(numbering: "1.1.1.1")

  show heading: it => {
    set text(hyphenate: false)

    // Формируем блок заголовка
    let h-body = if it.numbering == none {
      // Структурные заголовки печатаются прописными, кроме списка источников.
      // В оглавлении сохраняется исходный регистр: «Введение», «Заключение».
      let displayed-body = if it.body == [Список использованных источников] {
        it.body
      } else {
        upper(it.body)
      }
      pagebreak(weak: true)
      align(center)[
        #block(width: 100%, above: 0pt, below: 28pt, sticky: true)[
          #text(size: 14pt, weight: "bold")[#displayed-body]
        ]
      ]
    } else if it.level == 1 {
      // Разделы: с новой страницы, ПРОПИСНЫМИ, 28 пт снизу
      pagebreak(weak: true)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)

      block(width: 100%, inset: (left: 0.75cm), above: 0pt, below: 28pt, sticky: true)[
        #text(size: 14pt, weight: "bold")[
          #counter(heading).display() #h(0.5em) #upper(it.body)
        ]
      ]
    } else if it.level == 2 {
      // Подразделы: 14 пт до и после
      block(width: 100%, inset: (left: 0.75cm), above: 14pt, below: 14pt, sticky: true)[
        #text(size: 14pt, weight: "bold")[
          #counter(heading).display() #h(0.5em) #it.body
        ]
      ]
    } else {
      // Пункты и подпункты: обычное начертание, 14 пт до и после
      block(width: 100%, inset: (left: 0.75cm), above: 14pt, below: 14pt, sticky: true)[
        #text(size: 14pt, weight: "regular")[
          #counter(heading).display() #h(0.5em) #it.body
        ]
      ]
    }

    // Выводим заголовок
    h-body
  }

  // 6. АВТОНУМЕРАЦИЯ ФИГУР ПО РАЗДЕЛАМ (Рисунок 1.1, Таблица 1.1 по пп. 8.7, 8.8).
  // Для СУР исключения не указано, поэтому используется обязательная схема
  // «номер раздела + порядковый номер внутри раздела».
  set figure(numbering: (..nums) => context {
    let number = nums.pos().last()
    let appendix-prefix = sur-appendix-prefix.get()
    if appendix-prefix != none {
      [#appendix-prefix.#number]
    } else {
      let sec = counter(heading).get().first()
      if sec > 0 { [#sec.#number] } else { [#number] }
    }
  })

  set figure.caption(separator: [ – ])

  // 7. ТАБЛИЦЫ (п. 8.7): заголовок сверху, от левого края без абзацного
  // отступа; при переносе строки — выравнивание по ширине.
  // Для обычной однострочной головки нижняя граница сделана усиленной,
  // чтобы визуально отделить её двойной линией согласно пособию.
  show table: set table(stroke: (x, y) => if y == 0 {
    (top: 0.5pt + black, bottom: 1.5pt + black, left: 0.5pt + black, right: 0.5pt + black)
  } else {
    0.5pt + black
  })
  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): it => {
    block(width: 100%, above: 14pt, below: 14pt, breakable: true)[
      #set text(size: 14pt)
      #if it.caption != none [
        #block(width: 100%, below: 6pt, sticky: true)[
          #set text(hyphenate: false)
          #set par(justify: true, first-line-indent: 0cm)
          #align(left)[#it.caption]
        ]
      ]
      // Не оборачивать таблицу в align: такая обёртка делает длинную таблицу
      // неделимой и приводит к наложению строк у нижнего края страницы.
      #it.body
    ]
  }

  // 8. РИСУНКИ: внешние интервалы 14 пт, от рисунка до подписи — 6 пт.
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: image): it => {
    block(width: 100%, above: 14pt, below: 14pt)[
      #align(center)[#it.body]
      #if it.caption != none [
        #v(6pt)
        #block(width: 100%, above: 0pt)[
          #set text(size: 12pt, hyphenate: false)
          #set par(justify: false, first-line-indent: 0cm, leading: 0.5em, spacing: 0.5em)
          #align(center)[#it.caption]
        ]
      ]
    ]
  }

  // 9. ССЫЛКИ В ТЕКСТЕ: выводят только номер (напр. «на рисунке 6.1», «в таблице 2.1»)
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      link(el.location())[#numbering(el.numbering, ..el.counter.at(el.location()))]
    } else {
      it
    }
  }

  // 10. ПЕРЕЧИСЛЕНИЯ (п. 8.9): основной уровень — дефис/тире с отступом
  // 0,75 см. Арабская нумерация оставлена в формате «1.» для списка
  // источников; детализацию «1)» следует задавать локально.
  set list(indent: 0.75cm, marker: [–])
  set enum(indent: 0.75cm, numbering: "1.")

  // 11. ФОРМУЛЫ (п. 8.6): номер раздела/приложения и номер формулы.
  set math.equation(numbering: (..nums) => context {
    let number = nums.pos().last()
    let appendix-prefix = sur-appendix-prefix.get()
    if appendix-prefix != none {
      [(#appendix-prefix.#number)]
    } else {
      let sec = counter(heading).get().first()
      if sec > 0 { [(#sec.#number)] } else { [(#number)] }
    }
  })

  body
}

// Вспомогательная функция расшифровки формул «где» (п. 8.6.1)
#let formula-where(..items) = {
  set par(first-line-indent: (amount: 0cm, all: true))
  let pos = items.pos()
  if pos.len() > 0 {
    [где #pos.at(0)]
    for item in pos.slice(1) {
      [\ #h(0.75cm) #item]
    }
  }
}

// Шаблон приложения (п. 12.2)
#let appendix(letter: "А", title: "Название приложения", body) = {
  pagebreak(weak: true)

  sur-appendix-prefix.update(letter)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)

  // Невидимый заголовок нужен только для корректной записи приложения
  // в автоматически формируемом оглавлении.
  {
    show heading: it => none
    heading(numbering: none, outlined: true, bookmarked: true)[
      Приложение #letter #title
    ]
  }

  align(right)[#text(size: 14pt, weight: "bold")[ПРИЛОЖЕНИЕ #letter]]
  v(14pt)
  align(center)[#text(size: 14pt, weight: "bold")[#title]]
  v(14pt)
  set text(size: 12pt)
  body
}
