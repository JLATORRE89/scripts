import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import subprocess
import os
import threading

class VirtualBoxConverter:
    def find_executable(self, name):
        """Find the full path of an executable"""
        # Default paths for VirtualBox executables
        possible_paths = [
            os.path.join(os.environ.get('PROGRAMFILES', ''), 'Oracle', 'VirtualBox'),
            os.path.join(os.environ.get('PROGRAMFILES(X86)', ''), 'Oracle', 'VirtualBox'),
        ]
        
        # Add PATH directories
        if 'PATH' in os.environ:
            possible_paths.extend(os.environ['PATH'].split(os.pathsep))
        
        # Check each possible path
        for base_path in possible_paths:
            executable = f"{name}.exe" if os.name == 'nt' else name
            full_path = os.path.join(base_path, executable)
            
            if os.path.isfile(full_path):
                return full_path
                
        return None

    def check_virtualbox_executables(self):
        """Check if required VirtualBox executables exist in the system"""
        # Find executables
        self.vboxmanage_path = self.find_executable('VBoxManage')
        self.vboximg_path = self.find_executable('vbox-img')
        
        vboxmanage_found = self.vboxmanage_path is not None
        vboximg_found = self.vboximg_path is not None
        
        if not (vboxmanage_found or vboximg_found):
            messagebox.showerror(
                "VirtualBox Not Found",
                "Neither VBoxManage nor vbox-img were found.\n\n"
                "Please install VirtualBox and ensure it's properly installed in the default location\n"
                "or available in your system's PATH."
            )
            self.root.quit()
            return False
        
        if not vboxmanage_found:
            messagebox.showwarning(
                "VBoxManage Not Found",
                "VBoxManage was not found. OVA creation will be disabled.\n\n"
                "Please install VirtualBox completely to enable this feature."
            )
            self.disable_ova_creation = True
        
        if not vboximg_found:
            messagebox.showwarning(
                "vbox-img Not Found",
                "vbox-img was not found. Disk format conversion will be disabled.\n\n"
                "Please install VirtualBox completely to enable this feature."
            )
            self.disable_disk_conversion = True
            
        return True

    def check_command_exists(self, command):
        """Check if a command exists in the system PATH"""
        try:
            subprocess.run([command, '--version'], 
                         stdout=subprocess.PIPE, 
                         stderr=subprocess.PIPE)
            return True
        except (subprocess.SubprocessError, FileNotFoundError):
            return False

    def __init__(self, root):
        self.root = root
        self.root.title("VirtualBox Disk Converter")
        self.root.geometry("700x500")
        
        # List to track active subprocesses
        self.active_processes = []
        # Track current operation and output file
        self.current_operation = None
        self.current_output_file = None
        self.current_vm_name = None
        
        # Register cleanup handlers
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        import atexit
        atexit.register(self.cleanup_processes)
        
        # Bind SIGINT and SIGTERM if on Unix-like systems
        if os.name != 'nt':
            import signal
            signal.signal(signal.SIGINT, self.signal_handler)
            signal.signal(signal.SIGTERM, self.signal_handler)
        
        # Check for required executables
        self.disable_ova_creation = False
        self.disable_disk_conversion = False
        if not self.check_virtualbox_executables():
            return
        
        # Variables
        self.source_path = tk.StringVar()
        self.output_path = tk.StringVar()
        self.vm_name = tk.StringVar()
        self.conversion_type = tk.StringVar(value="disk_only")
        self.disk_format = tk.StringVar(value="vdi")
        
        # Create main frame
        main_frame = ttk.Frame(root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Conversion Type Selection
        ttk.Label(main_frame, text="Conversion Type:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.disk_radio = ttk.Radiobutton(main_frame, text="Disk Format Conversion Only", 
                                         variable=self.conversion_type, value="disk_only")
        self.disk_radio.grid(row=0, column=1, sticky=tk.W, pady=5)
        self.ova_radio = ttk.Radiobutton(main_frame, text="Create OVA", 
                                        variable=self.conversion_type, value="ova")
        self.ova_radio.grid(row=0, column=2, sticky=tk.W, pady=5)
        
        # Disable unavailable options based on executable checks
        if self.disable_disk_conversion:
            self.disk_radio.config(state='disabled')
            self.conversion_type.set("ova")
        if self.disable_ova_creation:
            self.ova_radio.config(state='disabled')
            self.conversion_type.set("disk_only")
        if self.disable_disk_conversion and self.disable_ova_creation:
            messagebox.showerror(
                "No Available Functions",
                "Neither disk conversion nor OVA creation are available.\n"
                "Please ensure VirtualBox is properly installed."
            )
            self.root.quit()
            return
        
        # VM Name (only for OVA conversion)
        ttk.Label(main_frame, text="VM Name:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.vm_name_entry = ttk.Entry(main_frame, textvariable=self.vm_name, width=50)
        self.vm_name_entry.grid(row=1, column=1, columnspan=2, sticky=tk.W, pady=5)
        
        # Source File Selection
        ttk.Label(main_frame, text="Source File:").grid(row=2, column=0, sticky=tk.W, pady=5)
        ttk.Entry(main_frame, textvariable=self.source_path, width=50).grid(row=2, column=1, sticky=tk.W, pady=5)
        ttk.Button(main_frame, text="Browse", command=self.browse_source).grid(row=2, column=2, sticky=tk.W, pady=5)
        
        # Output Format (for disk conversion)
        ttk.Label(main_frame, text="Output Format:").grid(row=3, column=0, sticky=tk.W, pady=5)
        formats = ['vdi', 'vmdk', 'vhd', 'raw']
        self.format_combo = ttk.Combobox(main_frame, textvariable=self.disk_format, values=formats, state='readonly')
        self.format_combo.grid(row=3, column=1, sticky=tk.W, pady=5)
        
        # Output Location
        ttk.Label(main_frame, text="Save Output to:").grid(row=4, column=0, sticky=tk.W, pady=5)
        ttk.Entry(main_frame, textvariable=self.output_path, width=50).grid(row=4, column=1, sticky=tk.W, pady=5)
        ttk.Button(main_frame, text="Browse", command=self.browse_output).grid(row=4, column=2, sticky=tk.W, pady=5)
        
        # Progress Bar
        ttk.Label(main_frame, text="Progress:").grid(row=5, column=0, sticky=tk.W, pady=5)
        self.progress = ttk.Progressbar(main_frame, length=500, mode='determinate')
        self.progress.grid(row=5, column=1, columnspan=2, pady=5, sticky=(tk.W, tk.E))
        
        # Console Output Area
        ttk.Label(main_frame, text="Console Output:").grid(row=6, column=0, sticky=tk.W, pady=5)
        self.console_frame = ttk.Frame(main_frame, relief='sunken', borderwidth=1)
        self.console_frame.grid(row=7, column=0, columnspan=3, sticky=(tk.W, tk.E))
        
        # Create Text widget with scrollbar for console output
        self.console_text = tk.Text(self.console_frame, height=10, width=80, wrap=tk.WORD)
        self.console_scroll = ttk.Scrollbar(self.console_frame, orient='vertical', command=self.console_text.yview)
        self.console_text.configure(yscrollcommand=self.console_scroll.set)
        
        # Pack console widgets
        self.console_text.pack(side='left', fill='both', expand=True)
        self.console_scroll.pack(side='right', fill='y')
        
        # Status Label
        self.status_label = ttk.Label(main_frame, text="")
        self.status_label.grid(row=8, column=0, columnspan=3, pady=5)
        
        # Convert Button
        self.convert_btn = ttk.Button(main_frame, text="Convert", command=self.start_conversion)
        self.convert_btn.grid(row=9, column=0, columnspan=3, pady=10)
        
        # Bind conversion type change
        self.conversion_type.trace('w', self.update_ui_state)
        self.update_ui_state()

    def update_ui_state(self, *args):
        if self.conversion_type.get() == "disk_only":
            self.vm_name_entry.config(state='disabled')
            self.format_combo.config(state='readonly')
        else:
            self.vm_name_entry.config(state='normal')
            self.format_combo.config(state='disabled')

    def browse_source(self):
        filename = filedialog.askopenfilename(
            title="Select source file",
            filetypes=[
                ("Virtual Disk files", "*.vdi;*.vmdk;*.vhd"),
                ("All files", "*.*")
            ]
        )
        if filename:
            self.source_path.set(filename)

    def browse_output(self):
        if self.conversion_type.get() == "ova":
            filetypes = [("OVA files", "*.ova")]
            defaultext = ".ova"
        else:
            ext = self.disk_format.get()
            filetypes = [(f"{ext.upper()} files", f"*.{ext}")]
            defaultext = f".{ext}"
            
        filename = filedialog.asksaveasfilename(
            title="Save output file",
            defaultextension=defaultext,
            filetypes=filetypes
        )
        if filename:
            self.output_path.set(filename)

    def validate_inputs(self):
        if not self.source_path.get():
            messagebox.showerror("Error", "Please select a source file")
            return False
        if not self.output_path.get():
            messagebox.showerror("Error", "Please select an output location")
            return False
        if self.conversion_type.get() == "ova" and not self.vm_name.get():
            messagebox.showerror("Error", "Please enter a VM name")
            return False
        return True

    def convert_disk_format(self):
        try:
            source = self.source_path.get()
            output = self.output_path.get()
            
            self.status_label.config(text="Converting disk format...")
            
            # Use vbox-img for disk conversion
            subprocess.run([
                self.vboximg_path,
                "convert",
                "--srcfilename", source,
                "--dstfilename", output,
                "--dstformat", self.disk_format.get().upper()
            ], check=True)
            
            self.root.after(0, self.conversion_complete)
            
        except subprocess.CalledProcessError as e:
            self.root.after(0, lambda: self.conversion_error(str(e)))

    def create_ova(self):
        try:
            vm_name = self.vm_name.get()
            source = self.source_path.get()
            output = self.output_path.get()

            self.status_label.config(text="Creating VM...")
            
            # Create VM
            subprocess.run([
                self.vboxmanage_path, "createvm",
                "--name", vm_name,
                "--register"
            ], check=True)

            # Attach disk
            subprocess.run([
                self.vboxmanage_path, "storagectl",
                vm_name,
                "--name", "SATA Controller",
                "--add", "sata",
                "--controller", "IntelAhci"
            ], check=True)

            subprocess.run([
                self.vboxmanage_path, "storageattach",
                vm_name,
                "--storagectl", "SATA Controller",
                "--port", "0",
                "--device", "0",
                "--type", "hdd",
                "--medium", source
            ], check=True)

            self.status_label.config(text="Exporting to OVA...")

            # Export to OVA
            subprocess.run([
                self.vboxmanage_path, "export",
                vm_name,
                "-o", output
            ], check=True)

            # Cleanup
            subprocess.run([
                self.vboxmanage_path, "unregistervm",
                vm_name,
                "--delete"
            ], check=True)

            self.root.after(0, self.conversion_complete)

        except subprocess.CalledProcessError as e:
            self.root.after(0, lambda: self.conversion_error(str(e)))

    def start_conversion(self):
        if not self.validate_inputs():
            return

        self.convert_btn.config(state='disabled')
        self.progress.start()
        
        # Start conversion in a separate thread
        if self.conversion_type.get() == "disk_only":
            threading.Thread(target=self.convert_disk_format, daemon=True).start()
        else:
            threading.Thread(target=self.create_ova, daemon=True).start()

    def conversion_complete(self):
        self.progress.stop()
        self.convert_btn.config(state='normal')
        self.status_label.config(text="Conversion completed successfully!")
        messagebox.showinfo("Success", "Conversion completed successfully!")

    def conversion_error(self, error_message):
        self.progress.stop()
        self.convert_btn.config(state='normal')
        self.status_label.config(text="Conversion failed!")
        messagebox.showerror("Error", f"Conversion failed: {error_message}")

if __name__ == "__main__":
    root = tk.Tk()
    app = VirtualBoxConverter(root)
    root.mainloop()
