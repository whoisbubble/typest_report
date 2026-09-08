// Одностраничный документ практики для печати на A4.
#let practice-document(body) = {
  set page(paper: "a4", margin: (left: 25mm, right: 20mm, top: 23mm, bottom: 22mm), numbering: none)
  set text(font: "Times New Roman", size: 12pt, lang: "ru", hyphenate: false)
  set par(justify: true, first-line-indent: 0pt, leading: 0.38em, spacing: 7pt)
  body
}
#let field(body) = underline(stroke: 0.45pt, offset: 1.5pt, body)
#let signing() = {
  v(10mm)
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [#box(width: 35mm, line(length: 100%, stroke: 0.5pt)) /М. С. Дирютин/],
    [«19» #underline[июля] 2026 г.],
  )
}
