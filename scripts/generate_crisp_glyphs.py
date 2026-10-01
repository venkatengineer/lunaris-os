import math
import os
from PIL import Image, ImageDraw, ImageFilter

OUTPUT_DIR = "/home/venkatengineer/aetheris-mobile/aetheris_control/assets/icons"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SCALE = 4
SIZE = 256 * SCALE  # 1024x1024
CX, CY = SIZE // 2, SIZE // 2

COLOR_EMERALD = (0, 255, 140, 255)
COLOR_CYAN = (0, 235, 255, 255)
COLOR_WHITE = (240, 248, 255, 255)

def draw_hex(draw, cx, cy, r, color=COLOR_CYAN, width=28):
    pts = []
    for i in range(6):
        a = math.radians(60 * i - 30)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    draw.polygon(pts, outline=color, width=width)

def generate_all():
    glyphs = {
        "phone": lambda d: [
            d.polygon([
                (CX - 120, CY + 200), (CX - 200, CY + 120), (CX - 120, CY - 200), 
                (CX + 60, CY - 160), (CX - 20, CY - 40), (CX + 60, CY + 40), 
                (CX + 160, CY - 20), (CX + 200, CY + 120), (CX + 120, CY + 200)
            ], outline=COLOR_EMERALD, width=32),
            d.ellipse([(CX + 50, CY - 80), (CX + 90, CY - 40)], fill=COLOR_CYAN)
        ],
        "messages": lambda d: [
            d.rounded_rectangle([(CX - 240, CY - 180), (CX + 240, CY + 120)], radius=60, outline=COLOR_CYAN, width=30),
            d.polygon([(CX - 100, CY + 120), (CX - 170, CY + 230), (CX - 10, CY + 120)], fill=COLOR_CYAN),
            d.line([(CX - 140, CY - 30), (CX + 140, CY - 30)], fill=COLOR_EMERALD, width=24),
            d.line([(CX - 140, CY + 40), (CX + 60, CY + 40)], fill=COLOR_EMERALD, width=24),
        ],
        "contacts": lambda d: [
            d.ellipse([(CX - 110, CY - 240), (CX + 110, CY - 20)], outline=COLOR_EMERALD, width=30),
            d.arc([(CX - 230, CY + 20), (CX + 230, CY + 330)], 195, 345, fill=COLOR_CYAN, width=30),
            d.line([(CX - 40, CY - 130), (CX + 40, CY - 130)], fill=COLOR_CYAN, width=22),
        ],
        "camera": lambda d: [
            d.rounded_rectangle([(CX - 240, CY - 130), (CX + 240, CY + 210)], radius=64, outline=COLOR_CYAN, width=30),
            d.ellipse([(CX - 130, CY - 50), (CX + 130, CY + 160)], outline=COLOR_EMERALD, width=30),
            d.ellipse([(CX - 45, CY + 25), (CX + 45, CY + 95)], fill=COLOR_CYAN),
            d.rectangle([(CX - 120, CY - 200), (CX + 30, CY - 130)], outline=COLOR_CYAN, width=26),
        ],
        "gallery": lambda d: [
            d.rounded_rectangle([(CX - 240, CY - 200), (CX + 240, CY + 200)], radius=60, outline=COLOR_EMERALD, width=30),
            d.polygon([(CX - 170, CY + 130), (CX - 40, CY - 40), (CX + 50, CY + 70), (CX + 120, CY - 80), (CX + 210, CY + 130)], outline=COLOR_CYAN, width=26),
            d.ellipse([(CX - 140, CY - 120), (CX - 70, CY - 50)], fill=COLOR_EMERALD)
        ],
        "files": lambda d: [
            d.polygon([(CX - 240, CY - 180), (CX - 40, CY - 180), (CX + 20, CY - 100), (CX + 240, CY - 100), (CX + 240, CY + 180), (CX - 240, CY + 180)], outline=COLOR_EMERALD, width=30),
            d.line([(CX - 150, CY + 50), (CX + 150, CY + 50)], fill=COLOR_CYAN, width=24),
        ],
        "settings": lambda d: [
            draw_hex(d, CX, CY, 240, color=COLOR_CYAN, width=30),
            d.ellipse([(CX - 100, CY - 100), (CX + 100, CY + 100)], outline=COLOR_EMERALD, width=30),
            d.ellipse([(CX - 30, CY - 30), (CX + 30, CY + 30)], fill=COLOR_WHITE),
        ],
        "browser": lambda d: [
            d.ellipse([(CX - 240, CY - 240), (CX + 240, CY + 240)], outline=COLOR_CYAN, width=30),
            d.line([(CX - 240, CY), (CX + 240, CY)], fill=COLOR_EMERALD, width=24),
            d.ellipse([(CX - 110, CY - 240), (CX + 110, CY + 240)], outline=COLOR_EMERALD, width=26),
            d.line([(CX, CY - 240), (CX, CY + 240)], fill=COLOR_CYAN, width=20),
        ],
        "youtube": lambda d: [
            d.rounded_rectangle([(CX - 240, CY - 170), (CX + 240, CY + 170)], radius=70, outline=COLOR_EMERALD, width=30),
            d.polygon([(CX - 60, CY - 90), (CX + 100, CY), (CX - 60, CY + 90)], fill=COLOR_CYAN),
        ],
        "whatsapp": lambda d: [
            d.ellipse([(CX - 230, CY - 230), (CX + 230, CY + 150)], outline=COLOR_EMERALD, width=30),
            d.polygon([(CX - 160, CY + 100), (CX - 230, CY + 240), (CX - 70, CY + 160)], fill=COLOR_EMERALD),
            d.line([(CX - 90, CY - 70), (CX + 90, CY + 60)], fill=COLOR_CYAN, width=28),
            d.ellipse([(CX + 40, CY - 70), (CX + 80, CY - 30)], fill=COLOR_CYAN),
        ],
        "instagram": lambda d: [
            d.rounded_rectangle([(CX - 230, CY - 230), (CX + 230, CY + 230)], radius=100, outline=COLOR_CYAN, width=30),
            d.ellipse([(CX - 115, CY - 115), (CX + 115, CY + 115)], outline=COLOR_EMERALD, width=30),
            d.ellipse([(CX + 115, CY - 145), (CX + 155, CY - 105)], fill=COLOR_EMERALD),
        ],
        "spotify": lambda d: [
            d.ellipse([(CX - 240, CY - 240), (CX + 240, CY + 240)], outline=COLOR_EMERALD, width=30),
            d.arc([(CX - 160, CY - 140), (CX + 160, CY + 40)], 200, 340, fill=COLOR_EMERALD, width=32),
            d.arc([(CX - 135, CY - 70), (CX + 135, CY + 90)], 200, 340, fill=COLOR_CYAN, width=28),
            d.arc([(CX - 110, CY - 5), (CX + 110, CY + 140)], 200, 340, fill=COLOR_CYAN, width=24),
        ],
        "github": lambda d: [
            d.ellipse([(CX - 240, CY - 240), (CX + 240, CY + 240)], outline=COLOR_CYAN, width=30),
            draw_hex(d, CX, CY, 130, color=COLOR_EMERALD, width=26),
            d.ellipse([(CX - 35, CY - 35), (CX + 35, CY + 35)], fill=COLOR_WHITE),
        ],
        "terminal": lambda d: [
            d.rounded_rectangle([(CX - 240, CY - 190), (CX + 240, CY + 190)], radius=50, outline=COLOR_EMERALD, width=30),
            d.line([(CX - 140, CY - 90), (CX - 50, CY), (CX - 140, CY + 90)], fill=COLOR_CYAN, width=28),
            d.line([(CX - 20, CY + 90), (CX + 130, CY + 90)], fill=COLOR_EMERALD, width=28),
        ],
        "maps": lambda d: [
            d.polygon([(CX, CY - 240), (CX + 180, CY - 90), (CX, CY + 240), (CX - 180, CY - 90)], outline=COLOR_CYAN, width=30),
            d.ellipse([(CX - 60, CY - 90), (CX + 60, CY + 30)], fill=COLOR_EMERALD),
        ],
        "calendar": lambda d: [
            d.rounded_rectangle([(CX - 230, CY - 190), (CX + 230, CY + 190)], radius=50, outline=COLOR_EMERALD, width=30),
            d.line([(CX - 230, CY - 70), (CX + 230, CY - 70)], fill=COLOR_CYAN, width=26),
            d.line([(CX - 120, CY - 230), (CX - 120, CY - 150)], fill=COLOR_CYAN, width=28),
            d.line([(CX + 120, CY - 230), (CX + 120, CY - 150)], fill=COLOR_CYAN, width=28),
            d.rectangle([(CX - 40, CY), (CX + 40, CY + 80)], fill=COLOR_WHITE),
        ],
        "clock": lambda d: [
            d.ellipse([(CX - 240, CY - 240), (CX + 240, CY + 240)], outline=COLOR_CYAN, width=30),
            d.line([(CX, CY), (CX, CY - 140)], fill=COLOR_EMERALD, width=28),
            d.line([(CX, CY), (CX + 100, CY)], fill=COLOR_EMERALD, width=28),
            d.ellipse([(CX - 28, CY - 28), (CX + 28, CY + 28)], fill=COLOR_CYAN),
        ],
        "calculator": lambda d: [
            d.rounded_rectangle([(CX - 200, CY - 230), (CX + 200, CY + 230)], radius=60, outline=COLOR_EMERALD, width=30),
            d.line([(CX - 130, CY - 140), (CX + 130, CY - 140)], fill=COLOR_CYAN, width=26),
            d.line([(CX - 100, CY + 40), (CX - 30, CY + 40)], fill=COLOR_CYAN, width=26),
            d.line([(CX + 30, CY + 40), (CX + 100, CY + 40)], fill=COLOR_CYAN, width=26),
            d.line([(CX - 65, CY - 5), (CX - 65, CY + 85)], fill=COLOR_CYAN, width=26),
            d.line([(CX + 30, CY + 140), (CX + 100, CY + 140)], fill=COLOR_CYAN, width=26),
        ],
        "notes": lambda d: [
            d.polygon([(CX - 200, CY - 230), (CX + 70, CY - 230), (CX + 200, CY - 100), (CX + 200, CY + 230), (CX - 200, CY + 230)], outline=COLOR_CYAN, width=30),
            d.line([(CX - 130, CY - 50), (CX + 130, CY - 50)], fill=COLOR_EMERALD, width=26),
            d.line([(CX - 130, CY + 50), (CX + 130, CY + 50)], fill=COLOR_EMERALD, width=26),
            d.line([(CX - 130, CY + 140), (CX + 50, CY + 140)], fill=COLOR_EMERALD, width=26),
        ],
        "playstore": lambda d: [
            d.polygon([(CX - 200, CY - 230), (CX + 200, CY), (CX - 200, CY + 230)], outline=COLOR_EMERALD, width=32),
            d.line([(CX - 200, CY - 230), (CX + 70, CY + 90)], fill=COLOR_CYAN, width=26),
            d.line([(CX - 200, CY + 230), (CX + 70, CY - 90)], fill=COLOR_CYAN, width=26),
        ]
    }

    for name, draw_fn in glyphs.items():
        hi_img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        d = ImageDraw.Draw(hi_img)
        draw_fn(d)

        # Subtle atmospheric glow layer (20% opacity, 16px blur)
        glow = hi_img.filter(ImageFilter.GaussianBlur(radius=20))
        glow_alpha = glow.split()[3].point(lambda p: int(p * 0.22))
        glow.putalpha(glow_alpha)

        # Merge glow and crisp vector lines
        combined = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        combined.paste(glow, (0, 0), glow)
        combined.paste(hi_img, (0, 0), hi_img)

        # Downsample with Lanczos to 256x256
        final = combined.resize((256, 256), Image.Resampling.LANCZOS)
        dest = os.path.join(OUTPUT_DIR, f"{name}.png")
        final.save(dest, "PNG", optimize=True)
        print(f"Generated floating icon: {dest}")

if __name__ == "__main__":
    generate_all()
