from hashlib import sha256
from pathlib import Path

from PIL import Image
from pypdf import PdfReader, PdfWriter
from pypdf.generic import (
    DecodedStreamObject,
    DictionaryObject,
    NameObject,
    NumberObject,
)


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "output/pdf"
STAMP = ROOT / "pechat-diryutin_new.png"
JOBS = [
    ("first", "practice-review-stamped.pdf", 575),
    ("second", "practice-diary-stamped.pdf", 420),
]


def image_stream(pixels, width, height, color_space):
    stream = DecodedStreamObject()
    stream.set_data(pixels)
    stream.update({
        NameObject("/Type"): NameObject("/XObject"),
        NameObject("/Subtype"): NameObject("/Image"),
        NameObject("/Width"): NumberObject(width),
        NameObject("/Height"): NumberObject(height),
        NameObject("/ColorSpace"): NameObject(color_space),
        NameObject("/BitsPerComponent"): NumberObject(8),
    })
    return stream.flate_encode()


OUTPUT.mkdir(parents=True, exist_ok=True)
with Image.open(STAMP) as source_image:
    stamp_image = source_image.convert("RGBA")
    width, height = stamp_image.size
    rgb_pixels = stamp_image.convert("RGB").tobytes()
    alpha_pixels = stamp_image.getchannel("A").tobytes()

for folder, output_name, top in JOBS:
    source = ROOT / "reports/practice_documents" / folder / "report.pdf"
    destination = OUTPUT / output_name
    if destination.exists():
        raise FileExistsError(destination)
    original_hash = sha256(source.read_bytes()).hexdigest()
    reader = PdfReader(source)
    assert len(reader.pages) == 1
    assert not reader.get_fields()
    writer = PdfWriter()
    writer.clone_document_from_reader(reader)
    page = writer.pages[0]
    mask = image_stream(alpha_pixels, width, height, "/DeviceGray")
    stamp = image_stream(rgb_pixels, width, height, "/DeviceRGB")
    stamp[NameObject("/SMask")] = writer._add_object(mask)
    resources = page["/Resources"].get_object()
    if "/XObject" not in resources:
        resources[NameObject("/XObject")] = DictionaryObject()
    objects = resources["/XObject"].get_object()
    assert "/AuthorizedStamp" not in objects
    objects[NameObject("/AuthorizedStamp")] = writer._add_object(stamp)
    stamp_width = 40 * 72 / 25.4
    stamp_height = stamp_width * height / width
    left = 25 * 72 / 25.4
    bottom = float(page.mediabox.height) - top - stamp_height
    assert bottom > 0
    content = page.get_contents().get_data()
    updated_content = DecodedStreamObject()
    updated_content.set_data(
        b"q\n" + content + b"\nQ\n"
        + f"q {stamp_width:.6f} 0 0 {stamp_height:.6f} {left:.6f} {bottom:.6f} cm /AuthorizedStamp Do Q\n".encode("ascii")
    )
    page[NameObject("/Contents")] = writer._add_object(updated_content)
    with destination.open("wb") as output_file:
        writer.write(output_file)
    result = PdfReader(destination)
    assert len(result.pages) == len(reader.pages)
    assert result.pages[0].extract_text().rstrip() == reader.pages[0].extract_text().rstrip()
    assert result.pages[0].mediabox == reader.pages[0].mediabox
    assert sha256(source.read_bytes()).hexdigest() == original_hash
    assert len(result.pages[0].images) == len(reader.pages[0].images) + 1
    print(f"Verified: {destination}")
