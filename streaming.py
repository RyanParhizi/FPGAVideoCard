from os import replace

from PIL import Image
import serial
import sys

if len(sys.argv) != 3:
    print("Usage: python3 send_image_gray.py <serial_port> <image_file>")
    sys.exit(1)

port = sys.argv[1]
image_file = sys.argv[2]

# Load image and convert to grayscale
img = Image.open(image_file).convert("L")

# Compute average brightness 0..255
pixels = list(img.getdata())
avg_gray = sum(pixels) // len(pixels)

print(f"Sending grayscale value: {avg_gray}")

# Send one byte to FPGA
ser = serial.Serial(port, 115200)
ser.write(bytes([avg_gray]))
ser.close()

#run with python streaming.py port myimage.png

# finding a port (windows)
# Plug in your device to the USB-C port.
# Open Device Manager (press Win+X, then choose Device Manager).
# Expand the "Ports (COM & LPT)" section.
# Look for something like "USB Serial Device (COM4)" — the number (e.g., COM4) is your serial port.
# You would then run your script like this (replace COM4 with your actual port):
# Python streaming.py COM4 replace_With_path_to_image.jpg