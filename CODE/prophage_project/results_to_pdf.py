
#!/usr/bin/env python3

import csv
import html
import re
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table,
    TableStyle, PageBreak, Preformatted
)


def read_table(path):
    delimiter = "\t" if path.suffix.lower() == ".tsv" else ","
    with path.open("r", encoding="utf-8-sig", errors="replace") as f:
        return [row for row in csv.reader(f, delimiter=delimiter)
                if any(cell.strip() for cell in row)]


def footer(canvas, doc):
    canvas.saveState()
    width, _ = doc.pagesize
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.grey)
    canvas.drawString(12 * mm, 8 * mm, "Results Folder Review")
    canvas.drawRightString(width - 12 * mm, 8 * mm, f"Page {doc.page}")
    canvas.restoreState()


def make_table(rows, width, styles):
    if not rows:
        return [Paragraph("This file is empty.", styles["BodyText"])]

    rows = rows[:501]
    columns = max(len(row) for row in rows)
    col_width = width / columns
    data = []

    for i, row in enumerate(rows):
        row = row + [""] * (columns - len(row))
        style = styles["HeaderCell"] if i == 0 else styles["Cell"]
        cells = []
        for value in row:
            value = str(value)
            if len(value) > 160:
                value = value[:159] + "..."
            cells.append(Paragraph(escape(value), style))
        data.append(cells)

    table = Table(data, colWidths=[col_width] * columns, repeatRows=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e6edf3")),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.lightgrey),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("FONTSIZE", (0, 0), (-1, -1), 7),
        ("LEFTPADDING", (0, 0), (-1, -1), 3),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3),
    ]))
    result = [table]

    if len(rows) > 500:
        result.append(Paragraph(
            "Display limited to the first 500 rows.",
            styles["Note"]
        ))
    return result


def main():
    root = Path("~/prophage_project/results").expanduser()
    output = root / "results_review.pdf"

    if not root.is_dir():
        raise SystemExit(f"Results folder not found: {root}")

    files = sorted(
        p for p in root.rglob("*")
        if p.is_file()
        and p != output
        and p.suffix.lower() != ".pdf"
    )

    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(
        name="MainTitle", parent=styles["Title"],
        fontSize=20, alignment=1,
        textColor=colors.HexColor("#14532d")
    ))
    styles.add(ParagraphStyle(
        name="Section", parent=styles["Heading1"],
        fontSize=13, textColor=colors.HexColor("#14532d")
    ))
    styles.add(ParagraphStyle(
        name="Cell", parent=styles["BodyText"],
        fontSize=6.5, leading=8, wordWrap="CJK"
    ))
    styles.add(ParagraphStyle(
        name="HeaderCell", parent=styles["BodyText"],
        fontName="Helvetica-Bold", fontSize=6.5, leading=8,
        wordWrap="CJK"
    ))
    styles.add(ParagraphStyle(
        name="Note", parent=styles["BodyText"],
        fontSize=8, textColor=colors.grey
    ))

    doc = SimpleDocTemplate(
        str(output), pagesize=landscape(A4),
        leftMargin=12 * mm, rightMargin=12 * mm,
        topMargin=12 * mm, bottomMargin=15 * mm
    )

    story = [
        Paragraph("Results Folder Review", styles["MainTitle"]),
        Spacer(1, 5 * mm),
        Paragraph(escape(str(root)), styles["BodyText"]),
        Paragraph(f"Files found: {len(files)}", styles["Heading2"]),
        Paragraph(
            "TSV/CSV files are rendered as tables. Text files are included "
            "as text. HTML reports are listed with their titles; open the "
            "original HTML files in a browser to see their graphics.",
            styles["Note"]
        ),
        Spacer(1, 4 * mm),
        Paragraph("File inventory", styles["Section"])
    ]

    inventory = [["File", "Type", "Size"]]
    for p in files:
        inventory.append([
            str(p.relative_to(root)),
            p.suffix.lower(),
            f"{p.stat().st_size:,} bytes"
        ])
    story.extend(make_table(inventory, doc.width, styles))

    for p in files:
        story.append(PageBreak())
        story.append(Paragraph(
            escape(str(p.relative_to(root))), styles["Section"]
        ))

        suffix = p.suffix.lower()
        try:
            if suffix in {".tsv", ".csv"}:
                story.extend(make_table(read_table(p), doc.width, styles))

            elif suffix in {".html", ".htm"}:
                content = p.read_text(encoding="utf-8", errors="replace")
                match = re.search(
                    r"<title[^>]*>(.*?)</title>", content, re.I | re.S
                )
                title = html.unescape(match.group(1)).strip() if match else p.name
                story.append(Paragraph(escape(title), styles["BodyText"]))
                story.append(Paragraph(
                    "Open this HTML file in a browser to view its full report.",
                    styles["Note"]
                ))

            elif suffix in {
                ".txt", ".log", ".gff", ".gff3", ".bed",
                ".fa", ".fasta", ".fna", ".gb", ".gbk", ".md"
            }:
                content = p.read_text(encoding="utf-8", errors="replace")
                content = content[:80000]
                story.append(Preformatted(
                    content,
                    ParagraphStyle(
                        name="Mono", fontName="Courier",
                        fontSize=6.5, leading=8
                    )
                ))

            else:
                story.append(Paragraph(
                    "File listed in inventory; content not embedded.",
                    styles["Note"]
                ))

        except Exception as error:
            story.append(Paragraph(
                escape(f"Could not read file: {error}"),
                styles["Note"]
            ))

    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    print(f"PDF created: {output}")
    print(f"Files scanned: {len(files)}")


if __name__ == "__main__":
    main()
