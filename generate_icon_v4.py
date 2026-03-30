#!/usr/bin/env python3
"""
Generate GitaPearls app icon v4
Clean, modern design: Gradient + simple lotus + glowing pearl
"""

from PIL import Image, ImageDraw, ImageFilter
import math

size = 1024
img = Image.new("RGBA", (size, size))
draw = ImageDraw.Draw(img)

# Colors
bg_top = (232, 130, 12)  # Saffron #E8820C
bg_bottom = (245, 197, 66)  # Gold #F5C542
pearl_center = (255, 250, 240)
pearl_outer = (255, 220, 160)
glow_color = (255, 240, 200)

# Draw gradient background
for y in range(size):
    ratio = y / size
    r = int(bg_top[0] * (1 - ratio) + bg_bottom[0] * ratio)
    g = int(bg_top[1] * (1 - ratio) + bg_bottom[1] * ratio)
    b = int(bg_top[2] * (1 - ratio) + bg_bottom[2] * ratio)
    draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

center = size // 2

# Draw subtle radial glow
for r in range(350, 0, -10):
    alpha = int(20 * (1 - r / 350))
    if alpha > 0:
        c = (255, 235, 180, alpha)
        draw.ellipse([center - r, center - r, center + r, center + r], fill=c)

# Draw 8 simple lotus petals as soft ellipses
petal_color = (255, 210, 150, 180)
for i in range(8):
    angle = i * 45 - 90
    rad = math.radians(angle)
    dist = 90
    px = center + dist * math.cos(rad)
    py = center + dist * math.sin(rad)

    # Draw petal as ellipse
    w, h = 70, 140
    # Rotate ellipse by drawing it at angle
    for j in range(0, 360, 10):
        jr = math.radians(j + angle)
        x = px + w * math.cos(jr) * 0.5
        y = py + h * math.sin(jr) * 0.5
        r = 25
        draw.ellipse([x - r, y - r, x + r, y + r], fill=petal_color)

# Draw central pearl with smooth gradient
pearl_r = 110

# Pearl glow
for r in range(pearl_r + 40, pearl_r, -2):
    alpha = int(60 * (1 - (r - pearl_r) / 40))
    c = (255, 245, 220, alpha)
    draw.ellipse([center - r, center - r, center + r, center + r], fill=c)

# Pearl body - smooth radial gradient
for r in range(pearl_r, 0, -1):
    ratio = r / pearl_r
    r_col = int(pearl_center[0] * (1 - ratio) + pearl_outer[0] * ratio)
    g_col = int(pearl_center[1] * (1 - ratio) + pearl_outer[1] * ratio)
    b_col = int(pearl_center[2] * (1 - ratio) + pearl_outer[2] * ratio)
    draw.ellipse(
        [center - r, center - r, center + r, center + r], fill=(r_col, g_col, b_col)
    )

# Highlight on pearl
hl_x, hl_y = center - 35, center - 35
for r in range(30, 0, -1):
    alpha = int(200 * (1 - r / 30))
    c = (255, 255, 255, alpha)
    draw.ellipse([hl_x - r, hl_y - r, hl_x + r, hl_y + r], fill=c)

# Draw simple Om using Unicode with fallback to drawing
try:
    from PIL import ImageFont

    # Try to load a Devanagari font
    font_paths = [
        "/System/Library/Fonts/Supplemental/Devanagari Sangam MN.ttc",
        "/System/Library/Fonts/Devanagari Sangam MN.ttc",
        "/usr/share/fonts/truetype/noto/NotoSansDevanagari-Regular.ttf",
    ]

    om_font = None
    for fp in font_paths:
        try:
            om_font = ImageFont.truetype(fp, 160)
            break
        except:
            continue

    if om_font:
        om_text = "ॐ"
        bbox = draw.textbbox((0, 0), om_text, font=om_font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        tx = center - tw // 2
        ty = center - th // 2 - 5

        # Shadow
        draw.text((tx + 2, ty + 2), om_text, font=om_font, fill=(100, 60, 30))
        # Main text
        draw.text((tx, ty), om_text, font=om_font, fill=(139, 69, 19))
    else:
        raise Exception("No font found")

except Exception as e:
    # Fallback: draw simplified symbol
    print(f"Font failed ({e}), using fallback")

    # Draw a simplified "3" like curve
    c = (139, 69, 19)

    # Lower curve
    for t in range(0, 100):
        angle = math.radians(180 + t * 2.5)
        r = 35
        x = center - 10 + r * math.cos(angle)
        y = center + 20 + r * 0.6 * math.sin(angle)
        draw.ellipse([x - 10, y - 10, x + 10, y + 10], fill=c)

    # Vertical line
    draw.rounded_rectangle(
        [center - 8, center - 50, center + 8, center + 25], radius=4, fill=c
    )

    # Top curve (crescent)
    for angle in range(-50, 51, 3):
        rad = math.radians(angle)
        x = center + 20 * math.sin(rad)
        y = center - 55 + 8 * math.cos(rad)
        draw.ellipse([x - 8, y - 6, x + 8, y + 6], fill=c)

    # Dot
    draw.ellipse([center - 10, center - 70, center + 10, center - 50], fill=c)

# Subtle blur
img = img.filter(ImageFilter.GaussianBlur(radius=0.5))

# Convert to RGB
final = Image.new("RGB", (size, size))
r, g, b, a = img.split()
final.paste(Image.merge("RGB", (r, g, b)), mask=a)

# Save
final.save("GitaPearls/Assets.xcassets/AppIcon.appiconset/Icon-1024.png", "PNG")
final.save("app-icon-1024-v4.png", "PNG")
print("✅ Icon generated: Icon-1024.png")
