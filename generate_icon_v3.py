#!/usr/bin/env python3
"""
Generate GitaPearls app icon v3
Design: Clean glowing pearl with Om symbol
Rich saffron/gold gradient background
"""

from PIL import Image, ImageDraw, ImageFilter
import math

# Create 1024x1024 image
size = 1024
img = Image.new("RGBA", (size, size))
draw = ImageDraw.Draw(img)

# Color palette - rich saffron to gold gradient
color_saffron = (232, 130, 12)  # Deep saffron #E8820C
color_gold = (245, 197, 66)  # Warm gold #F5C542
color_cream = (255, 248, 230)  # Cream white
color_light_gold = (255, 225, 160)  # Light gold
color_om = (120, 60, 20)  # Dark brown for Om

# Draw gradient background (top to bottom)
for y in range(size):
    ratio = y / size
    r = int(color_saffron[0] * (1 - ratio) + color_gold[0] * ratio)
    g = int(color_saffron[1] * (1 - ratio) + color_gold[1] * ratio)
    b = int(color_saffron[2] * (1 - ratio) + color_gold[2] * ratio)
    draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

center = size // 2

# Draw soft radial glow behind pearl
glow_radius = 300
for r in range(glow_radius, 0, -5):
    alpha = int(25 * (1 - r / glow_radius))
    if alpha > 0:
        glow_color = (255, 230, 180, alpha)
        draw.ellipse([center - r, center - r, center + r, center + r], fill=glow_color)


# Draw simple stylized lotus - 8 soft petals
def draw_soft_petal(cx, cy, angle, length, width, color):
    """Draw a soft lotus petal"""
    rad = math.radians(angle)
    perp = rad + math.pi / 2

    # Points for petal
    tip = (cx + length * math.cos(rad), cy + length * math.sin(rad))
    left = (cx + width * math.cos(perp), cy + width * math.sin(perp))
    right = (cx - width * math.cos(perp), cy - width * math.sin(perp))

    # Control points for curves
    ctrl1 = (
        cx + length * 0.5 * math.cos(rad) + width * 0.5 * math.cos(perp),
        cy + length * 0.5 * math.sin(rad) + width * 0.5 * math.sin(perp),
    )
    ctrl2 = (
        cx + length * 0.5 * math.cos(rad) - width * 0.5 * math.cos(perp),
        cy + length * 0.5 * math.sin(rad) - width * 0.5 * math.sin(perp),
    )

    # Draw as polygon approximation
    points = []
    # Left curve
    for t in range(0, 11):
        t = t / 10
        x = (1 - t) ** 2 * left[0] + 2 * (1 - t) * t * ctrl1[0] + t**2 * tip[0]
        y = (1 - t) ** 2 * left[1] + 2 * (1 - t) * t * ctrl1[1] + t**2 * tip[1]
        points.append((x, y))
    # Right curve
    for t in range(0, 11):
        t = t / 10
        x = (1 - t) ** 2 * tip[0] + 2 * (1 - t) * t * ctrl2[0] + t**2 * right[0]
        y = (1 - t) ** 2 * tip[1] + 2 * (1 - t) * t * ctrl2[1] + t**2 * right[1]
        points.append((x, y))

    draw.polygon(points, fill=color)


# Draw outer lotus petals (8 petals)
petal_color = (255, 200, 140, 200)  # Soft gold, slightly transparent
for i in range(8):
    angle = i * 45 - 90  # Start from top
    draw_soft_petal(center, center, angle, 180, 55, petal_color)

# Draw inner lotus petals (6 petals, smaller)
inner_petal_color = (255, 220, 170, 220)
for i in range(6):
    angle = i * 60 - 90 + 30  # Offset
    draw_soft_petal(center, center, angle, 120, 40, inner_petal_color)


# Draw central glowing pearl
def draw_pearl(cx, cy, radius):
    """Draw a luminous pearl with gradient"""
    # Outer glow
    for r in range(radius + 60, radius, -2):
        alpha = int(60 * (1 - (r - radius) / 60))
        glow = (255, 240, 200, alpha)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=glow)

    # Pearl body gradient
    for r in range(radius, 0, -1):
        ratio = r / radius
        r_col = int(color_cream[0] * (1 - ratio) + color_light_gold[0] * ratio)
        g_col = int(color_cream[1] * (1 - ratio) + color_light_gold[1] * ratio)
        b_col = int(color_cream[2] * (1 - ratio) + color_light_gold[2] * ratio)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_col, g_col, b_col))

    # Highlight for 3D effect
    hl_x = cx - radius * 0.35
    hl_y = cy - radius * 0.35
    hl_r = radius * 0.3
    for r in range(int(hl_r), 0, -1):
        alpha = int(180 * (1 - r / hl_r))
        hl_color = (255, 255, 255, alpha)
        draw.ellipse([hl_x - r, hl_y - r, hl_x + r, hl_y + r], fill=hl_color)


pearl_radius = 130
draw_pearl(center, center, pearl_radius)


# Draw Om symbol using simple shapes (since fonts are unreliable)
def draw_om_symbol(draw, cx, cy, size):
    """Draw Om symbol using curves and shapes"""
    s = size / 100  # Scale factor

    # Color
    c = color_om

    # The 3 curve (lower part)
    # Draw as connected ellipses/arcs
    for i in range(20):
        angle = i * 10
        rad = math.radians(angle)
        # Parametric curve for "3" shape
        t = i / 20
        x = cx + s * (-25 + 35 * math.cos(2 * math.pi * t))
        y = cy + s * (15 + 20 * math.sin(2 * math.pi * t))
        r = s * 8
        draw.ellipse([x - r, y - r, x + r, y + r], fill=c)

    # The vertical stroke and top curve
    # Main stem
    draw.rounded_rectangle(
        [cx - s * 8, cy - s * 35, cx + s * 8, cy + s * 25], radius=int(s * 4), fill=c
    )

    # Top curve (the "moon" shape)
    for r in range(int(s * 20), int(s * 12), -1):
        alpha = int(255 * (r - s * 12) / (s * 8))
        draw.ellipse(
            [cx - r, cy - s * 40 - r // 3, cx + r, cy - s * 40 + r // 3],
            fill=(c[0], c[1], c[2], min(alpha, 255)),
        )

    # The dot above (bindu)
    bindu_y = cy - s * 50
    for r in range(int(s * 10), 0, -1):
        ratio = r / (s * 10)
        col = (int(c[0] * ratio), int(c[1] * ratio), int(c[2] * ratio))
        draw.ellipse([cx - r, bindu_y - r, cx + r, bindu_y + r], fill=col)

    # The crescent (chandrabindu) - arc above
    arc_y = cy - s * 42
    for angle in range(-60, 61, 5):
        rad = math.radians(angle)
        x = cx + s * 25 * math.sin(rad)
        y = arc_y - s * 5 * math.cos(rad)
        r = s * 5
        draw.ellipse([x - r, y - r, x + r, y + r], fill=c)


# Draw Om in center of pearl
draw_om_symbol(draw, center, center + 5, 280)

# Apply very subtle blur for glow
img = img.filter(ImageFilter.GaussianBlur(radius=0.3))

# Convert to RGB
final = Image.new("RGB", (size, size))
# Paste with alpha as mask
r, g, b, a = img.split()
final.paste(Image.merge("RGB", (r, g, b)), mask=a)

# Save
final.save("GitaPearls/Assets.xcassets/AppIcon.appiconset/Icon-1024.png", "PNG")
final.save("app-icon-1024-v3.png", "PNG")
print("✅ Icon generated: Icon-1024.png")
