// ДВГУПС. Основа для КР и бакалаврской ВКР. Самостоятельный файл рядом с report.typ.
// Приоритет: профильное пособие бакалавров и презентация преподавателя;
// для библиографии — ГОСТ Р 7.0.100–2018 из комплекта.
// Числа ниже — миллиметры/пункты из пособий, а не декоративные настройки.

#let page-numbers = state("page-numbers", false)
#let appendix-code = state("appendix-code", none)

// Слайд 2: A4, левое поле >=30 мм, остальные >=10/20/20 мм; номер справа внизу.
#let document-style(body) = {
  set page(
    paper: "a4",
    margin: (left: 30mm, right: 10mm, top: 20mm, bottom: 20mm),
    footer: context {
      if page-numbers.get() {
        align(right)[#text(font: "Times New Roman", size: 12pt)[#counter(page).display()]]
      }
    },
  )
  set text(font: "Times New Roman", size: 14pt, fill: black, lang: "ru", hyphenate: false)
  // Слайд 4 и пособие бакалавров, с. 20, 75: 1,5 интервала, красная строка 7,5 мм.
  set par(justify: true, first-line-indent: (amount: 7.5mm, all: true),
    leading: 0.72em, spacing: 0.72em)
  set heading(numbering: "1.1.1.1")
  show heading: it => {
    set text(hyphenate: false)
    let numbered = it.numbering != none
    if it.level == 1 { pagebreak(weak: true) }
    if numbered and it.level == 1 {
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
    }
    let gap-before = if it.level == 1 { 0pt } else { 24pt }
    let gap-after = if it.level == 1 { 48pt } else { 24pt }
    let displayed = if numbered {
      [#h(7.5mm)#counter(heading).display() #it.body]
    } else {
      align(center, it.body)
    }
    block(width: 100%, above: gap-before, below: gap-after, sticky: true)[
      #set text(size: 16pt, weight: "regular")
      #set par(first-line-indent: 0pt, justify: false, leading: 0.72em, spacing: 0pt)
      #displayed
    ]
  }
  // Слайды 6, 11, 15: отдельная нумерация объектов по разделам.
  set figure(numbering: (..nums) => context {
    let n = nums.pos().last()
    let app = appendix-code.get()
    let section = counter(heading).get().first()
    if app != none { [#app.#n] }
    else { [#section.#n] }
  })
  set figure.caption(separator: [ – ])
  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: table): it => block(width: 100%, above: 12pt, below: 12pt, breakable: true)[
    #if it.caption != none [
      #block(below: 6pt, sticky: true)[
        #set text(size: 12pt)
        #set par(first-line-indent: 0pt, justify: false)
        #align(center)[#it.caption]
      ]
    ]
    #it.body
  ]
  show figure.where(kind: image): it => block(width: 100%, above: 12pt, below: 24pt, breakable: false)[
    #align(center)[#it.body]
    #if it.caption != none [
      #v(12pt)
      #set text(size: 12pt)
      #set par(first-line-indent: 0pt, justify: false)
      #align(center)[#it.caption]
    ]
  ]
  // Слайды 7–9: шапка и тело 12 пт, одинарный интервал, отступ ячейки 1 мм.
  show table: it => {
    set text(size: 12pt)
    set par(first-line-indent: 0pt, leading: 0.2em, spacing: 0pt)
    it
  }
  // Пособие бакалавров, с. 26: высота строки не менее 7 мм.
  // Вертикальная отбивка обеспечивает этот минимум для однострочной ячейки.
  set table(inset: (x: 1mm, y: 2.25mm), stroke: 0.5pt + black)
  set math.equation(numbering: (..nums) => context {
    let n = nums.pos().last()
    let app = appendix-code.get()
    let section = counter(heading).get().first()
    if app != none { [(#app.#n)] }
    else { [(#section.#n)] }
  })
  // Слайды 18–19: основной маркер — короткое тире; вложенные варианты задаются в report.typ.
  set list(marker: [–], indent: 7.5mm, body-indent: 7.5mm, tight: false)
  set enum(numbering: "1)", indent: 7.5mm, body-indent: 7.5mm, tight: false)
  // В обычной фразе «рисунок @fig» выводится только номер, без дублирования слова.
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      link(el.location())[#numbering(el.numbering, ..el.counter.at(el.location()))]
    } else if el != none and el.func() == math.equation {
      link(el.location())[#numbering(el.numbering, ..counter(math.equation).at(el.location()))]
    } else { it }
  }
  body
}

// Титул КР повторяет структуру образца Шафарчука 2026 из Student2027:
// тема, вид, дисциплина, шифр, ДВЕ линии для подписей, фамилии, город и год.
// Для другой дисциплины кафедра может требовать иные реквизиты — сверить с заданием.
#let coursework-title(
  title: "ТЕМА КУРСОВОЙ РАБОТЫ",
  topic: none,
  discipline: "Название дисциплины",
  cipher: "КР [укажите шифр]",
  department: "Кафедра «Цифровая индустрия и защита информации»",
  student: "И. О. Фамилия",
  group: none,
  supervisor: "И. О. Фамилия",
  supervisor-role: "должность, учёная степень",
  city: "Хабаровск", year: "2026",
) = {
  page-numbers.update(false)
  set par(first-line-indent: 0pt, justify: false, leading: 0.35em)
  align(center)[
    #text(size: 12pt)[Министерство транспорта Российской Федерации\
      Федеральное агентство железнодорожного транспорта]
    #v(8pt)
    #text(size: 12pt)[Федеральное государственное бюджетное образовательное учреждение\
      высшего образования\
      «Дальневосточный государственный университет путей сообщения»]
    #v(8pt)
    #text(size: 12pt)[#department]
  ]
  v(28mm)
  align(center)[
    #set par(leading: 0.5em, spacing: 0pt, justify: false)
    #set text(hyphenate: false)
    #block(width: 100%, text(size: 16pt)[#upper(title)], below: 8pt)
    #if topic != none {
      block(width: 100%, text(size: 12pt)[#topic], below: 8pt)
    }
    #block(width: 100%, text(size: 16pt)[Курсовая работа], below: 7pt)
    #block(width: 100%, text(size: 16pt)[дисциплина «#discipline»], below: 7pt)
    #block(width: 100%, text(size: 16pt, hyphenate: false)[#cipher], below: 0pt)
  ]
  v(35mm)
  let signature-field = box(width: 100%)[
    #align(center)[
      #box(width: 100%, stroke: (bottom: 0.5pt), height: 12pt)[]
      #v(-6pt)
      #text(size: 12pt, style: "italic")[(подпись, дата)]
    ]
  ]
  grid(columns: (auto, 1fr, auto), column-gutter: 14pt, row-gutter: 20pt,
    [#text(size: 14pt)[Студент]], signature-field, [#text(size: 14pt)[#student]],
    [#text(size: 14pt)[Проверил]], signature-field, [#text(size: 14pt)[#supervisor]],
  )
  v(1fr)
  align(center)[#city #year]
  pagebreak()
}

// Титульный лист ВКР: пособие бакалавров, с. 11–13, приложение Е (с. 70).
#let bachelor-title(
  title: "ТЕМА БАКАЛАВРСКОЙ РАБОТЫ",
  cipher: "БР 09.03.02 БО241ИСТ ПЗ",
  department: "Кафедра «Цифровая индустрия и защита информации»",
  student: "И. О. Фамилия", group: "Номер группы",
  supervisor: "И. О. Фамилия", supervisor-role: "должность, учёная степень",
  chair: "И. О. Фамилия", controller: "И. О. Фамилия",
  controller-role: "должность, учёная степень",
  consultant: none, consultant-role: "должность, учёная степень",
  consultant2: none, consultant2-role: "должность, учёная степень",
  city: "Хабаровск", year: "2026",
) = {
  page-numbers.update(false)
  set par(first-line-indent: 0pt, justify: false, leading: 0.25em)
  align(center)[
    #text(size: 12pt)[Министерство транспорта Российской Федерации\
      Федеральное агентство железнодорожного транспорта]
    #v(6pt)
    #text(size: 12pt)[ФЕДЕРАЛЬНОЕ ГОСУДАРСТВЕННОЕ БЮДЖЕТНОЕ\
      ОБРАЗОВАТЕЛЬНОЕ УЧРЕЖДЕНИЕ ВЫСШЕГО ОБРАЗОВАНИЯ\
      «ДАЛЬНЕВОСТОЧНЫЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ ПУТЕЙ СООБЩЕНИЯ»]
    #v(6pt)
    #text(size: 12pt)[#department]
  ]
  v(12mm)
  align(right)[К ЗАЩИТЕ ДОПУСТИТЬ\
    Заведующий кафедрой #chair\
    Подпись ————————— Дата —————————]
  v(22mm)
  align(center)[
    #text(size: 16pt)[#upper(title)]
    #v(9pt)
    Пояснительная записка к бакалаврской работе
    #v(7pt)
    #cipher
  ]
  v(23mm)
  let approval-signature = box(width: 100%)[
    #align(center)[
      #box(width: 100%, stroke: (bottom: 0.5pt), height: 12pt)[]
      #v(-5pt)
      #text(size: 8pt, style: "italic")[(подпись, дата)]
    ]
  ]
  grid(columns: (1.5fr, 0.65fr, 1fr), row-gutter: 15pt,
    [Студент группы #group], approval-signature, [#student],
    ..(if consultant != none { ([Консультант\ #consultant-role], approval-signature, [#consultant]) } else { () }),
    ..(if consultant2 != none { ([Консультант\ #consultant2-role], approval-signature, [#consultant2]) } else { () }),
    [Руководитель\ #supervisor-role], approval-signature, [#supervisor],
    [Нормоконтроль\ #controller-role], approval-signature, [#controller],
  )
  v(1fr)
  align(center)[#city – #year]
  pagebreak()
}

// В пособии, с. 10–11, перед титулом предусмотрена обложка с описью.
// Эти страницы не входят в сквозную нумерацию ПЗ. Сведения о листах вписать после сборки.
#let bachelor-cover(student: "И. О. Фамилия") = {
  page-numbers.update(false)
  set par(first-line-indent: 0pt, justify: false)
  v(48mm)
  text(size: 40pt)[БАКАЛАВРСКАЯ\ РАБОТА]
  v(60mm)
  text(size: 28pt)[#student]
  pagebreak()
  align(center)[ОПИСЬ ДОКУМЕНТОВ]
  v(8mm)
  table(columns: (1fr, 4fr, 1.4fr),
    table.header([№], [Наименование документа], [Количество листов]),
    [1], [Пояснительная записка], [Уточнить],
    [2], [Задание на ВКР], [По бланку],
    [3], [Отзыв руководителя], [По бланку],
  )
  v(8mm)
  [Иные документы по требованию кафедры добавляются в опись после фактического комплектования.]
  pagebreak()
  counter(page).update(1)
}

#let start-numbered-body() = {
  pagebreak(weak: true)
  page-numbers.update(true)
}

#let contents() = {
  page-numbers.update(false)
  outline(title: [СОДЕРЖАНИЕ], indent: 8mm)
}

// Расшифровка непосредственно под формулой: слайд 16, пособие с. 29.
#let formula-where(..items) = {
  set par(first-line-indent: 0pt)
  let values = items.pos()
  block(below: 12pt)[
    #for (i, item) in values.enumerate() {
      if i == 0 { [где #item] } else { [\ #h(12mm) #item] }
    }
  ]
}

// Пособие бакалавров, с. 19: каждое приложение с новой страницы, буква кириллицей.
#let appendix(letter: "А", title: "Название приложения", body) = {
  pagebreak(weak: true)
  appendix-code.update(letter)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  { show heading: it => none
    heading(numbering: none, outlined: true)[Приложение #letter #title]
  }
  align(right)[ПРИЛОЖЕНИЕ #letter]
  v(12pt)
  align(center)[#title]
  v(24pt)
  set text(size: 12pt)
  body
}

