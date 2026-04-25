# FPGAVideoCard
Step #1 Vivado Setup:
1. Create a New Project:
    * Open Vivado and click Create Project.
    * Click Next until you reach the Default Part Screen.
    * Search for and select "xc7s50csga324-1" then click finish.
2. Link the IP Repository:
    * In Vivado, go to Tools > Settings > IP > Repository.
    * Click the + (plus) button.
    * Navigate to the downloaded project folder (FPGAVideoCard-main) and select the "ip-repo" folder.
    * Vivado will scan the folder and detect all the IP(s). Click Apply then Ok.
3. Add Verilog and IP Sources:
    * Click Add Sources in the Flow Navigator Panel.
    * Select "Add or create design sources" then click Next.
    * Click Add Files and select the verilog files ("DisplayHDMI.v", "UART.v", and "main.v") from the FPGAVideoCard-main\source folder and 
      add the custom IP .xci files from within each of their respective folders ("FPGAVideoCard-main\source\clk_wiz_0" and 
      "FPGAVideoCard-main\source\rgb2dvi_0") then click Finish.
4. Add Constraints:
    * Click Add Sources > Add or create constraints.
    * Click Add Files then navigate to the FPGAVideoCard-main\constraints folder and select "BooleanBoard.xdc" then click Finish.
5. Generate and Program:
    * Click Generate Bitstream in the Flow Navigator menu.
    * Once generation is complete, plug in the Boolean Board via USB and then connect the Boolean Board to a monitor via HDMI.
    * Open Hardware Manager, click Auto Connect, and click Program Device.

Step #2 Python Setup:
1. Open VS Code.
2. Go to File > Open Folder and select the project folder (FPGAVideoCard-main).
3. Open an integrated terminal in VS Code (Terminal > New Terminal).
4. Set up the Virtual Environment:
    * Mac/Linux: Run the provided setup script:
      chmod +x setup_env.sh
      ./setup_env.sh
      source .venv/bin/activate

    * Windows: Manually setup the environment in the cmd (not powershell) terminal:
      python -m venv .venv
      .venv\\Scripts\\activate
      pip install -r requirements_env.txt

    * Should see a "(.venv)" at the start of your terminal prompt meaning the virtual environment is active.

Step #3 Running the Project:
1. Find your COM Port:
    * Windows: Open Device Manager, expand "Ports", and note your USB Serial Device (e.g. COM4).
    * Mac/Linux: Run ls /deb/tty.* or ls /dev/ttyUSB* in the terminal to find your port (e.g. /dev/ttyUSB0).
2. Run the Streaming Script:
    * In the VS Code terminal, execute the following scripts using your COM port:
        - python streaming.py <Your COM Port Here> images/cu-logo-2.jpg
        - python streaming.py <Your COM Port Here> images/F-22.jpg
