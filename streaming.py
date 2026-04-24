##################################################################################
# Course: Digital Logic
# Engineer(s): Ryan Parhizi (rypa)
#
# Module Name: streaming
# Project Name: FPGA Video Card
# Description: Prepares an image by resizing it to 320x240 resolution and converting to an 8-bit grayscale.
#              Then transmits image data from a host PC to a boolean board via UART. 
##################################################################################

from PIL import Image
import serial
import sys

# Check to make sure command line used the proper serial port and image file location/name
if len(sys.argv) != 3:
    print("Usage: python3 send_image_gray.py <serial_port> <image_file>")
    sys.exit(1)

port = sys.argv[1]
image_file = sys.argv[2]

# Load the image, resize it to 320x240, convert it to grayscale so each pixel can be represented by a single byte (0-255)
img = Image.open(image_file).resize((320, 240)).convert("L")

# Make the image into a bytearray so that it can be easily transferred over UART
pixel_data = bytearray(img.getdata())

print(f"Sending {len(pixel_data)} bytes over UART at 115200 baud...")

# Create a serial connection at 115200 bits per second
ser = serial.Serial(port, 115200)

# Send the entire pixel data byte array through UART then close the serial connection
ser.write(pixel_data)
ser.close()

# To Run:
# finding a port (windows)
# Plug in your device to the USB-C port.
# Open Device Manager (press Win+X, then choose Device Manager).
# Expand the "Ports (COM & LPT)" section.
# Look for something like "USB Serial Device (COM4)" — the number (e.g., COM4) is your serial port.
# You would then run your script like this (replace COM4 with your actual port):
# Python streaming.py COM4 replace_With_path_to_image.jpg