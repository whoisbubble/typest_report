// Шаблон по пособию ДВГУПС 2022 года.
// document-kind: "student" для СУР, "vkr" для выпускной работы.

#let _page-number-footer(start-at: 2) = context {
  let number = counter(page).get().first()
  if number >= start-at {
    align(center, text(font: "Times New Roman", size: 12pt, str(number)))
  }
}

#let _signature-row(role, person, credentials: none) = {
  block(breakable: false)[
    #grid(
      columns: (1.2fr, 38mm, 1fr),
      column-gutter: 3mm,
      align: (left, center, right),
      [#role],
      [#line(length: 100%, stroke: 0.5pt)],
      [#person],
    )
    #grid(
      columns: (1.2fr, 38mm, 1fr),
      column-gutter: 3mm,
      align: (left, center, right),
      [#if credentials != none { credentials }],
      [#text(size: 10pt)[подпись, дата]],
      [],
    )
  ]
}

#let _student-title(
  title: none,
  author: none,
  group: none,
  department: none,
  work-type: none,
  discipline: none,
  supervisor: none,
  supervisor-title: none,
  supervisor-credentials: none,
  reviewer: none,
  code: none,
  city: none,
  year: none,
) = {
  set par(first-line-indent: 0pt, justify: false, leading: 0.25em, spacing: 0pt)
  align(center)[
    #text(size: 12pt)[Министерство транспорта Российской Федерации]
    #linebreak()
    #text(size: 12pt)[Федеральное агентство железнодорожного транспорта]
    #linebreak()
    #text(size: 12pt)[Федеральное государственное бюджетное]
    #linebreak()
    #text(size: 12pt)[образовательное учреждение высшего образования]
    #linebreak()
    #text(size: 12pt)[«Дальневосточный государственный университет путей сообщения»]
    #v(6mm)
    #department
  ]

  v(1fr)
  align(center)[
    #text(size: 14pt, weight: "bold", hyphenate: false)[#upper(title)]
    #v(5mm)
    #work-type
    #if discipline != none {
      linebreak()
      [дисциплина «#discipline»]
    }
    #if code != none {
      v(4mm)
      [#code]
    }
  ]

  v(1fr)
  _signature-row([Студент гр. #group], author)
  v(4mm)
  _signature-row(supervisor-title, supervisor, credentials: supervisor-credentials)
  if reviewer != none {
    v(4mm)
    _signature-row([Рецензент], reviewer)
  }

  v(1fr)
  align(center)[#city – #year]
}

#let _vkr-title(
  title: none,
  author: none,
  group: none,
  department: none,
  work-type: none,
  supervisor: none,
  supervisor-title: none,
  supervisor-credentials: none,
  reviewer: none,
  approval-person: none,
  code: none,
  city: none,
  year: none,
) = {
  set par(first-line-indent: 0pt, justify: false, leading: 0.25em, spacing: 0pt)
  align(center)[
    #text(size: 12pt)[Министерство транспорта Российской Федерации]
    #linebreak()
    #text(size: 12pt)[Федеральное агентство железнодорожного транспорта]
    #linebreak()
    #text(size: 12pt)[ФЕДЕРАЛЬНОЕ ГОСУДАРСТВЕННОЕ БЮДЖЕТНОЕ]
    #linebreak()
    #text(size: 12pt)[ОБРАЗОВАТЕЛЬНОЕ УЧРЕЖДЕНИЕ ВЫСШЕГО ОБРАЗОВАНИЯ]
    #linebreak()
    #text(size: 12pt)[«ДАЛЬНЕВОСТОЧНЫЙ ГОСУДАРСТВЕННЫЙ]
    #linebreak()
    #text(size: 12pt)[УНИВЕРСИТЕТ ПУТЕЙ СООБЩЕНИЯ»]
    #v(6mm)
    #department
  ]

  v(6mm)
  align(right, block(width: 76mm)[
    *К ЗАЩИТЕ ДОПУСТИТЬ*
    #linebreak()
    Заведующий кафедрой
    #linebreak()
    #line(length: 26mm, stroke: 0.5pt) #approval-person
    #linebreak()
    «#line(length: 10mm, stroke: 0.5pt)» #line(length: 25mm, stroke: 0.5pt) #year г.
  ])

  v(1fr)
  align(center)[
    #text(size: 14pt, weight: "bold", hyphenate: false)[#upper(title)]
    #v(5mm)
    #work-type
    #if code != none {
      v(4mm)
      [#code]
    }
  ]

  v(1fr)
  _signature-row([Студент гр. #group], author)
  v(4mm)
  _signature-row(supervisor-title, supervisor, credentials: supervisor-credentials)
  if reviewer != none {
    v(4mm)
    _signature-row([Рецензент], reviewer)
  }

  v(1fr)
  align(center)[#city – #year]
}

#let structural-heading(title, outlined: true) = {
  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    bookmarked: outlined,
    upper(title),
  )
}

#let dvgups-contents(title: "СОДЕРЖАНИЕ", depth: 4) = {
  structural-heading(title, outlined: false)
  set par(first-line-indent: 0pt, leading: 0.5em, spacing: 0pt)
  outline(title: none, depth: depth, indent: 7.5mm)
}

#let dvgups-table(caption: none, body) = {
  figure(kind: table, supplement: [Таблица], caption: caption, body)
}

#let dvgups-appendix(letter: "А", title: none, body) = {
  pagebreak(weak: true)
  set text(size: 12pt)
  set par(first-line-indent: 7.5mm, justify: true, leading: 0.5em, spacing: 0pt)
  align(right)[*ПРИЛОЖЕНИЕ #letter*]
  v(14pt)
  if title != none {
    align(center)[*#title*]
    v(14pt)
  }
  body
}

#let dvgups-work(
  title: none,
  author: none,
  group: none,
  department: none,
  work-type: "Исследовательская работа",
  discipline: none,
  supervisor: none,
  supervisor-title: "Руководитель",
  supervisor-credentials: none,
  reviewer: none,
  city: "Хабаровск",
  year: datetime.today().year(),
  document-kind: "student",
  approval-person: "И. О. Фамилия",
  code: none,
  body,
) = {
  set document(title: title, author: author)
  let margins = if document-kind == "vkr" {
    (left: 30mm, right: 10mm, top: 20mm, bottom: 20mm)
  } else {
    (left: 20mm, right: 15mm, top: 20mm, bottom: 30mm)
  }
  set page(
    paper: "a4",
    margin: margins,
    numbering: none,
    footer: _page-number-footer(start-at: 2),
  )
  set text(font: "Times New Roman", size: 14pt, lang: "ru", fill: black)
  set par(justify: true, first-line-indent: 7.5mm, leading: 0.5em, spacing: 0pt)
  set heading(numbering: "1.1.1.1")
  set list(indent: 7.5mm, body-indent: 5mm, spacing: 4pt)
  set enum(indent: 7.5mm, body-indent: 5mm, spacing: 4pt)
  set math.equation(numbering: "(1)", supplement: [формула])
  set figure(numbering: "1", supplement: [Рисунок], gap: 14pt)
  set figure.caption(separator: [ – ])

  show list.item: set par(first-line-indent: 0pt)
  show enum.item: set par(first-line-indent: 0pt)
  show figure.caption: set text(size: 12pt, hyphenate: false)
  show figure.where(kind: table): set figure(gap: 0pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: it => block(above: 14pt, below: 14pt, breakable: false)[#it]
  show heading: set text(size: 14pt, hyphenate: false)
  show heading.where(level: 1): set text(weight: "bold")
  show heading.where(level: 2): set text(weight: "bold")
  show heading.where(level: 3): set text(weight: "regular")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set par(first-line-indent: 0pt)
    if it.numbering == none {
      block(below: 28pt, breakable: false)[#align(center)[#it]]
    } else {
      block(below: 28pt, breakable: false)[#pad(left: 7.5mm)[#it]]
    }
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt)
    block(above: 14pt, below: 14pt, breakable: false)[#pad(left: 7.5mm)[#it]]
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt)
    block(above: 14pt, below: 14pt, breakable: false)[#pad(left: 7.5mm)[#it]]
  }

  if document-kind == "vkr" {
    _vkr-title(
      title: title,
      author: author,
      group: group,
      department: department,
      work-type: work-type,
      supervisor: supervisor,
      supervisor-title: supervisor-title,
      supervisor-credentials: supervisor-credentials,
      reviewer: reviewer,
      approval-person: approval-person,
      code: code,
      city: city,
      year: year,
    )
  } else {
    _student-title(
      title: title,
      author: author,
      group: group,
      department: department,
      work-type: work-type,
      discipline: discipline,
      supervisor: supervisor,
      supervisor-title: supervisor-title,
      supervisor-credentials: supervisor-credentials,
      reviewer: reviewer,
      code: code,
      city: city,
      year: year,
    )
  }
  pagebreak()
  set par(justify: true, first-line-indent: 7.5mm, leading: 0.5em, spacing: 0pt)
  body
}

#let dvgups-article(
  title: none,
  authors: none,
  affiliation: none,
  email: none,
  udc: none,
  abstract-ru: none,
  keywords-ru: none,
  abstract-en: none,
  keywords-en: none,
  city: "Хабаровск",
  body,
) = {
  set document(title: title, author: authors)
  set page(
    paper: "a4",
    margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 30mm),
    numbering: none,
  )
  set text(font: "Times New Roman", size: 14pt, lang: "ru", fill: black)
  set par(justify: true, first-line-indent: 7.5mm, leading: 0.4em, spacing: 0pt)
  set heading(numbering: "1.1.1")
  set list(indent: 7.5mm, body-indent: 5mm, spacing: 4pt)
  set enum(indent: 7.5mm, body-indent: 5mm, spacing: 4pt)
  set math.equation(numbering: "(1)", supplement: [формула])
  set figure(numbering: "1", supplement: [Рисунок], gap: 14pt)
  set figure.caption(separator: [ – ])

  show list.item: set par(first-line-indent: 0pt)
  show enum.item: set par(first-line-indent: 0pt)
  show figure.caption: set text(size: 12pt, hyphenate: false)
  show figure.where(kind: table): set figure(gap: 0pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: it => block(above: 14pt, below: 14pt, breakable: false)[#it]
  show heading: set text(size: 14pt, hyphenate: false)
  show heading.where(level: 1): set text(weight: "bold")
  show heading.where(level: 2): set text(weight: "bold")
  show heading.where(level: 3): set text(weight: "regular")
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt)
    block(above: 14pt, below: 14pt, breakable: false)[#it]
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt)
    block(above: 14pt, below: 14pt, breakable: false)[#it]
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt)
    block(above: 14pt, below: 14pt, breakable: false)[#it]
  }

  set par(first-line-indent: 0pt, justify: false)
  if udc != none {
    align(left)[УДК #udc]
    v(4mm)
  }
  align(center)[
    #text(weight: "bold", hyphenate: false)[#upper(title)]
    #v(4mm)
    #authors
    #linebreak()
    #affiliation, #city
    #if email != none [#linebreak()#email]
  ]
  v(5mm)

  [*Аннотация.* #abstract-ru]
  v(2mm)
  [*Ключевые слова:* #keywords-ru]
  if abstract-en != none {
    v(4mm)
    [*Abstract.* #abstract-en]
  }
  if keywords-en != none {
    v(2mm)
    [*Keywords:* #keywords-en]
  }
  v(6mm)
  set par(first-line-indent: 7.5mm, justify: true, leading: 0.4em, spacing: 0pt)
  body
}
