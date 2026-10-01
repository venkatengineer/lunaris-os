import math
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_DIR = "/home/venkatengineer/aetheris-mobile/aetheris_control/assets/icons"
os.makedirs(OUTPUT_DIR, exist_ok=True)

COLOR_EMERALD = (0, 255, 136)
COLOR_CYAN = (0, 229, 255)
COLOR_WHITE = (236, 239, 241)
COLOR_DISC_BG = (12, 20, 28, 140)
COLOR_HAIRLINE = (0, 229, 255, 45)

def draw_hex_glyph(draw, cx, cy, radius, color=COLOR_EMERALD, width=3, fill=None):
    points = []
    for i in range(6):
        angle = math.radians(60 * i - 30)
        px = cx + radius * math.cos(angle)
        py = cy + radius * math.sin(angle)
        points.append((px, py))
    if fill:
        draw.polygon(points, fill=fill)
    draw.polygon(points, outline=color, width=width)

def generate_icons():
    size = 256
    cx, cy = size // 2, size // 2

    # Scale factor for glyphs to make them prominent and breathable
    glyph_drawings = {
        "phone": lambda d: [
            # Smooth modern spacecraft comms handset
            d.polygon([
                (cx-36, cy+56), (cx-56, cy+36), (cx-36, cy-56), (cx+14, cy-44), 
                (cx-10, cy-12), (cx+14, cy+12), (cx+44, cy-10), (cx+56, cy+36), (cx+36, cy+56)
            ], outline=COLOR_EMERALD, width=9),
            d.ellipse([(cx+18, cy-28), (cx+28, cy-18)], fill=COLOR_CYAN)
        ],
        "messages": lambda d: [
            # Minimal geometric speech nexus
            d.rounded_rectangle([(cx-72, cy-56), (cx+72, cy+38)], radius=18, outline=COLOR_CYAN, width=8),
            d.polygon([(cx-28, cy+38), (cx-50, cy+72), (cx, cy+38)], fill=COLOR_CYAN),
            d.line([(cx-40, cy-10), (cx+40, cy-10)], fill=COLOR_EMERALD, width=6),
            d.line([(cx-40, cy+12), (cx+16, cy+12)], fill=COLOR_EMERALD, width=6),
        ],
        "contacts": lambda d: [
            d.ellipse([(cx-34, cy-72), (cx+34, cy-4)], outline=COLOR_EMERALD, width=8),
            d.arc([(cx-64, cy+8), (cx+64, cy+96)], 195, 345, fill=COLOR_CYAN, width=8),
            d.line([(cx-12, cy-38), (cx+12, cy-38)], fill=COLOR_CYAN, width=6),
        ],
        "camera": lambda d: [
            # Aperture optics
            d.rounded_rectangle([(cx-72, cy-42), (cx+72, cy+62)], radius=20, outline=COLOR_CYAN, width=8),
            d.ellipse([(cx-38, cy-18), (cx+38, cy+48)], outline=COLOR_EMERALD, width=8),
            d.ellipse([(cx-14, cy+6), (cx+14, cy+24)], fill=COLOR_CYAN),
            d.rectangle([(cx-34, cy-62), (cx+10, cy-42)], outline=COLOR_CYAN, width=7),
        ],
        "gallery": lambda d: [
            d.rounded_rectangle([(cx-72, cy-60), (cx+72, cy+60)], radius=18, outline=COLOR_EMERALD, width=8),
            d.polygon([(cx-50, cy+38), (cx-12, cy-12), (cx+16, cy+22), (cx+38, cy-28), (cx+62, cy+38)], outline=COLOR_CYAN, width=7),
            d.ellipse([(cx-42, cy-34), (cx-24, cy-16)], fill=COLOR_EMERALD)
        ],
        "files": lambda d: [
            d.polygon([(cx-72, cy-56), (cx-12, cy-56), (cx+6, cy-32), (cx+72, cy-32), (cx+72, cy+56), (cx-72, cy+56)], outline=COLOR_EMERALD, width=8),
            d.line([(cx-48, cy+14), (cx+48, cy+14)], fill=COLOR_CYAN, width=6),
        ],
        "settings": lambda d: [
            # Hexagonal orbital gear
            draw_hex_glyph(d, cx, cy, 74, color=COLOR_CYAN, width=8),
            d.ellipse([(cx-30, cy-30), (cx+30, cy+30)], outline=COLOR_EMERALD, width=8),
            d.ellipse([(cx-8, cy-8), (cx+8, cy+8)], fill=COLOR_WHITE),
        ],
        "browser": lambda d: [
            # Planetary coordinate sphere
            d.ellipse([(cx-74, cy-74), (cx+74, cy+74)], outline=COLOR_CYAN, width=8),
            d.line([(cx-74, cy), (cx+74, cy)], fill=COLOR_EMERALD, width=6),
            d.ellipse([(cx-34, cy-74), (cx+34, cy+74)], outline=COLOR_EMERALD, width=6),
            d.line([(cx, cy-74), (cx, cy+74)], fill=COLOR_CYAN, width=5),
        ],
        "youtube": lambda d: [
            d.rounded_rectangle([(cx-74, cy-50), (cx+74, cy+50)], radius=22, outline=COLOR_EMERALD, width=8),
            d.polygon([(cx-18, cy-28), (cx+28, cy), (cx-18, cy+28)], fill=COLOR_CYAN),
        ],
        "whatsapp": lambda d: [
            d.ellipse([(cx-72, cy-72), (cx+72, cy+48)], outline=COLOR_EMERALD, width=8),
            d.polygon([(cx-50, cy+32), (cx-72, cy+74), (cx-22, cy+50)], fill=COLOR_EMERALD),
            d.line([(cx-28, cy-22), (cx+28, cy+18)], fill=COLOR_CYAN, width=8),
            d.ellipse([(cx+14, cy-22), (cx+24, cy-12)], fill=COLOR_CYAN),
        ],
        "instagram": lambda d: [
            d.rounded_rectangle([(cx-72, cy-72), (cx+72, cy+72)], radius=32, outline=COLOR_CYAN, width=8),
            d.ellipse([(cx-36, cy-36), (cx+36, cy+36)], outline=COLOR_EMERALD, width=8),
            d.ellipse([(cx+36, cy-44), (cx+48, cy-32)], fill=COLOR_EMERALD),
        ],
        "spotify": lambda d: [
            d.ellipse([(cx-74, cy-74), (cx+74, cy+74)], outline=COLOR_EMERALD, width=8),
            d.arc([(cx-50, cy-44), (cx+50, cy+12)], 200, 340, fill=COLOR_EMERALD, width=9),
            d.arc([(cx-42, cy-22), (cx+42, cy+28)], 200, 340, fill=COLOR_CYAN, width=8),
            d.arc([(cx-34, cy-2), (cx+34, cy+44)], 200, 340, fill=COLOR_CYAN, width=7),
        ],
        "github": lambda d: [
            d.ellipse([(cx-74, cy-74), (cx+74, cy+74)], outline=COLOR_CYAN, width=8),
            draw_hex_glyph(d, cx, cy, 42, color=COLOR_EMERALD, width=7),
            d.ellipse([(cx-10, cy-10), (cx+10, cy+10)], fill=COLOR_WHITE),
        ],
        "terminal": lambda d: [
            d.rounded_rectangle([(cx-74, cy-60), (cx+74, cy+60)], radius=16, outline=COLOR_EMERALD, width=8),
            d.line([(cx-44, cy-28), (cx-16, cy), (cx-44, cy+28)], fill=COLOR_CYAN, width=8),
            d.line([(cx-6, cy+28), (cx+40, cy+28)], fill=COLOR_EMERALD, width=8),
        ],
        "maps": lambda d: [
            d.polygon([(cx, cy-72), (cx+52, cy-28), (cx, cy+72), (cx-52, cy-28)], outline=COLOR_CYAN, width=8),
            d.ellipse([(cx-18, cy-28), (cx+18, cy+8)], fill=COLOR_EMERALD),
        ],
        "calendar": lambda d: [
            d.rounded_rectangle([(cx-72, cy-60), (cx+72, cy+60)], radius=16, outline=COLOR_EMERALD, width=8),
            d.line([(cx-72, cy-22), (cx+72, cy-22)], fill=COLOR_CYAN, width=7),
            d.line([(cx-38, cy-72), (cx-38, cy-48)], fill=COLOR_CYAN, width=8),
            d.line([(cx+38, cy-72), (cx+38, cy-48)], fill=COLOR_CYAN, width=8),
            d.rectangle([(cx-12, cy+2), (cx+12, cy+26)], fill=COLOR_WHITE),
        ],
        "clock": lambda d: [
            d.ellipse([(cx-74, cy-74), (cx+74, cy+74)], outline=COLOR_CYAN, width=8),
            d.line([(cx, cy), (cx, cy-42)], fill=COLOR_EMERALD, width=8),
            d.line([(cx, cy), (cx+32, cy)], fill=COLOR_EMERALD, width=8),
            d.ellipse([(cx-8, cy-8), (cx+8, cy+8)], fill=COLOR_CYAN),
        ],
        "calculator": lambda d: [
            d.rounded_rectangle([(cx-62, cy-72), (cx+62, cy+72)], radius=18, outline=COLOR_EMERALD, width=8),
            d.line([(cx-40, cy-44), (cx+40, cy-44)], fill=COLOR_CYAN, width=7),
            d.line([(cx-32, cy+12), (cx-10, cy+12)], fill=COLOR_CYAN, width=7),
            d.line([(cx+10, cy+12), (cx+32, cy+12)], fill=COLOR_CYAN, width=7),
            d.line([(cx-21, cy-2), (cx-21, cy+24)], fill=COLOR_CYAN, width=7),
            d.line([(cx+10, cy+42), (cx+32, cy+42)], fill=COLOR_CYAN, width=7),
        ],
        "notes": lambda d: [
            d.polygon([(cx-62, cy-72), (cx+22, cy-72), (cx+62, cy-32), (cx+62, cy+72), (cx-62, cy+72)], outline=COLOR_CYAN, width=8),
            d.line([(cx-40, cy-16), (cx+40, cy-16)], fill=COLOR_EMERALD, width=7),
            d.line([(cx-40, cy+16), (cx+40, cy+16)], fill=COLOR_EMERALD, width=7),
            d.line([(cx-40, cy+44), (cx+16, cy+44)], fill=COLOR_EMERALD, width=7),
        ],
        "playstore": lambda d: [
            d.polygon([(cx-62, cy-72), (cx+62, cy), (cx-62, cy+72)], outline=COLOR_EMERALD, width=9),
            d.line([(cx-62, cy-72), (cx+22, cy+28)], fill=COLOR_CYAN, width=7),
            d.line([(cx-62, cy+72), (cx+22, cy-28)], fill=COLOR_CYAN, width=7),
        ]
    }

    for name, draw_fn in glyph_drawings.items():
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Subtle dark translucent circular disc behind glyph (floating, organic, NO heavy square borders)
        disc_radius = 114
        draw.ellipse([
            (cx - disc_radius, cy - disc_radius),
            (cx + disc_radius, cy + disc_radius)
        ], fill=(8, 14, 22, 180), outline=(0, 229, 255, 30), width=2)

        # Draw the clean floating glyph
        draw_fn(draw)

        dest = os.path.join(OUTPUT_DIR, f"{name}.png")
        img.save(dest, "PNG", optimize=True)
        print(f"Generated clean floating icon: {dest}")

if __name__ == "__main__":
    generate_icons()
