Received: by ug-out-1314.google.com with SMTP id h3so16722ugf.29
        for <linux-mm@kvack.org>; Tue, 10 Jun 2008 23:04:33 -0700 (PDT)
Date: Wed, 11 Jun 2008 10:00:29 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: 2.6.26-rc5-mm2: OOM with 1G free swap
Message-ID: <20080611060029.GA5011@martell.zuzino.mipt.ru>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080609223145.5c9a2878.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Jun 09, 2008 at 10:31:45PM -0700, Andrew Morton wrote:
> - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
>   vmscan.c bug which would have prevented testing of the other vmscan.c
>   bugs^Wchanges.

OOM condition happened with 1G free swap.

4G RAM, 1G swap partition, normally LTP survives during much, much higher
load.

vm.overcommit_memory = 0
vm.overcommit_ratio = 50

[    0.442034] TCP bind hash table entries: 65536 (order: 9, 3670016 bytes)
[    0.447278] TCP: Hash tables configured (established 262144 bind 65536)
[    0.447411] TCP reno registered
[    0.459744] NET: Registered protocol family 1
[    0.477840] msgmni has been set to 7862
[    0.477840] io scheduler noop registered
[    0.477840] io scheduler cfq registered (default)
[    0.478136] pci 0000:01:00.0: Boot video device
[    0.487568] Real Time Clock Driver v1.12ac
[    0.487568] Linux agpgart interface v0.103
[    0.487701] ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 19 (level, low) -> IRQ 19
[    0.487869] Int: type 0, pol 3, trig 3, bus 03, IRQ 00, APIC ID 2, APIC INT 13
[    0.488008] PCI: Setting latency timer of device 0000:03:00.0 to 64
[    0.488132] atl1 0000:03:00.0: version 2.1.3
[    0.507047] Switched to high resolution mode on CPU 1
[    0.508123] Switched to high resolution mode on CPU 0
[    0.524910] 8139too Fast Ethernet driver 0.9.28
[    0.524910] ACPI: PCI Interrupt 0000:05:02.0[A] -> GSI 23 (level, low) -> IRQ 23
[    0.524910] Int: type 0, pol 3, trig 3, bus 05, IRQ 08, APIC ID 2, APIC INT 17
[    0.525909] eth1: RealTek RTL8139 at 0xb800, 00:80:48:2e:06:2e, IRQ 23
[    0.525909] eth1:  Identified 8139 chip type 'RTL-8100B/8139D'
[    0.526049] netconsole: local port 6665
[    0.526049] netconsole: local IP 192.168.0.1
[    0.526052] netconsole: interface eth0
[    0.526136] netconsole: remote port 9353
[    0.526220] netconsole: remote IP 192.168.0.42
[    0.526307] netconsole: remote ethernet address 00:1b:38:af:22:49
[    0.526410] netconsole: device eth0 not up yet, forcing it
[    2.599764] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex
[    2.611844] console [netcon0] enabled
[    2.639955] netconsole: network logging started
[    2.640951] Driver 'sd' needs updating - please use bus_type methods
[    2.640951] ahci 0000:02:00.0: version 3.0
[    2.641083] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
[    2.641087] Int: type 0, pol 3, trig 3, bus 02, IRQ 00, APIC ID 2, APIC INT 10
[    3.641717] ahci 0000:02:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x3 impl SATA mode
[    3.641863] ahci 0000:02:00.0: flags: 64bit ncq pm led clo pmp pio slum part 
[    3.641977] PCI: Setting latency timer of device 0000:02:00.0 to 64
[    3.642969] scsi0 : ahci
[    3.643761] scsi1 : ahci
[    3.643909] ata1: SATA max UDMA/133 abar m8192@0xfe8fe000 port 0xfe8fe100 irq 16
[    3.644305] ata2: SATA max UDMA/133 abar m8192@0xfe8fe000 port 0xfe8fe180 irq 16
[    3.948878] ata1: SATA link down (SStatus 0 SControl 300)
[    4.253877] ata2: SATA link down (SStatus 0 SControl 300)
[    4.255424] ata_piix 0000:00:1f.2: version 2.12
[    4.255439] ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
[    4.255439] Int: type 0, pol 3, trig 3, bus 00, IRQ 7d, APIC ID 2, APIC INT 13
[    4.255439] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    4.255439] PCI: Setting latency timer of device 0000:00:1f.2 to 64
[    4.256020] scsi2 : ata_piix
[    4.256442] scsi3 : ata_piix
[    4.271440] ata3: SATA max UDMA/133 cmd 0xec00 ctl 0xe880 bmdma 0xe400 irq 19
[    4.271440] ata4: SATA max UDMA/133 cmd 0xe800 ctl 0xe480 bmdma 0xe408 irq 19
[    4.727413] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    4.733939] ata3.00: ATA-8: ST3750330AS, SD15, max UDMA/133
[    4.734040] ata3.00: 1465149168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    4.762309] ata3.01: ATA-7: ST3160811AS, 3.AAE, max UDMA/133
[    4.762309] ata3.01: 312581808 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    4.768953] ata3.00: configured for UDMA/133
[    4.820319] ata3.01: configured for UDMA/133
[    5.277391] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    5.314308] ata4.00: ATA-7: ST3250620AS, 3.AAE, max UDMA/133
[    5.314308] ata4.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    5.389318] ata4.00: configured for UDMA/133
[    5.401449] scsi 2:0:0:0: Direct-Access     ATA      ST3750330AS      SD15 PQ: 0 ANSI: 5
[    5.402833] sd 2:0:0:0: [sda] 1465149168 512-byte hardware sectors (750156 MB)
[    5.402833] sd 2:0:0:0: [sda] Write Protect is off
[    5.402833] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    5.402833] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.403459] sd 2:0:0:0: [sda] 1465149168 512-byte hardware sectors (750156 MB)
[    5.403633] sd 2:0:0:0: [sda] Write Protect is off
[    5.403726] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    5.403854] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.404020]  sda: sda1 sda2
[    5.419348] sd 2:0:0:0: [sda] Attached SCSI disk
[    5.420304] scsi 2:0:1:0: Direct-Access     ATA      ST3160811AS      3.AA PQ: 0 ANSI: 5
[    5.420304] sd 2:0:1:0: [sdb] 312581808 512-byte hardware sectors (160042 MB)
[    5.420360] sd 2:0:1:0: [sdb] Write Protect is off
[    5.420453] sd 2:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    5.421728] sd 2:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.421728] sd 2:0:1:0: [sdb] 312581808 512-byte hardware sectors (160042 MB)
[    5.421728] sd 2:0:1:0: [sdb] Write Protect is off
[    5.421728] sd 2:0:1:0: [sdb] Mode Sense: 00 3a 00 00
[    5.421764] sd 2:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.421916]  sdb: sdb1
[    5.438802]  sdb1: <solaris: [s0] sdb5 [s2] sdb6 [s7] sdb7 [s8] sdb8 [s9] sdb9 >
[    5.449741] sd 2:0:1:0: [sdb] Attached SCSI disk
[    5.449741] scsi 3:0:0:0: Direct-Access     ATA      ST3250620AS      3.AA PQ: 0 ANSI: 5
[    5.449790] sd 3:0:0:0: [sdc] 488397168 512-byte hardware sectors (250059 MB)
[    5.449938] sd 3:0:0:0: [sdc] Write Protect is off
[    5.450031] sd 3:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    5.451043] sd 3:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.451316] sd 3:0:0:0: [sdc] 488397168 512-byte hardware sectors (250059 MB)
[    5.451462] sd 3:0:0:0: [sdc] Write Protect is off
[    5.451555] sd 3:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    5.451733] sd 3:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.452040]  sdc: sdc1
[    5.473742] sd 3:0:0:0: [sdc] Attached SCSI disk
[    5.473742] ACPI: PCI Interrupt 0000:00:1f.5[B] -> GSI 19 (level, low) -> IRQ 19
[    5.473742] Int: type 0, pol 3, trig 3, bus 00, IRQ 7d, APIC ID 2, APIC INT 13
[    5.473742] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
[    5.474115] PCI: Setting latency timer of device 0000:00:1f.5 to 64
[    5.474731] scsi4 : ata_piix
[    5.474731] scsi5 : ata_piix
[    5.483731] ata5: SATA max UDMA/133 cmd 0xd400 ctl 0xd080 bmdma 0xc880 irq 19
[    5.483731] ata6: SATA max UDMA/133 cmd 0xd000 ctl 0xcc00 bmdma 0xc888 irq 19
[    5.798531] ata5: SATA link down (SStatus 0 SControl 300)
[    6.113887] ata6: SATA link down (SStatus 0 SControl 300)
[    6.114972] ACPI: PCI Interrupt 0000:02:00.1[B] -> GSI 17 (level, low) -> IRQ 17
[    6.115147] Int: type 0, pol 3, trig 3, bus 02, IRQ 01, APIC ID 2, APIC INT 11
[    6.115147] PCI: Setting latency timer of device 0000:02:00.1 to 64
[    6.115147] scsi6 : pata_jmicron
[    6.115147] scsi7 : pata_jmicron
[    6.119168] ata7: PATA max UDMA/100 cmd 0xac00 ctl 0xa880 bmdma 0xa400 irq 17
[    6.119168] ata8: PATA max UDMA/100 cmd 0xa800 ctl 0xa480 bmdma 0xa408 irq 17
[    6.425169] ata7.01: ATAPI: _NEC DV-5800C, D9S2, max UDMA/33
[    6.425706] ata7.01: configured for UDMA/33
[    6.738619] scsi 6:0:1:0: CD-ROM            _NEC     DV-5800C         D9S2 PQ: 0 ANSI: 5
[    6.740239] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    6.740239] PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
[    6.741256] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.742190] mice: PS/2 mouse device common for all mice
[    6.742194] Advanced Linux Sound Architecture Driver Version 1.0.17rc1.
[    6.743302] ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
[    6.744495] Int: type 0, pol 3, trig 3, bus 00, IRQ 6c, APIC ID 2, APIC INT 16
[    6.744495] PCI: Setting latency timer of device 0000:00:1b.0 to 64
[    6.764499] input: AT Translated Set 2 keyboard as /class/input/input0
[    7.128547] ALSA device list:
[    7.128633]   #0: HDA Intel at 0xfebf8000 irq 22
[    7.128757] TCP cubic registered
[    7.172920] kjournald starting.  Commit interval 5 seconds
[    7.166937] EXT3-fs: mounted filesystem with ordered data mode.
[    7.166937] VFS: Mounted root (ext3 filesystem) readonly.
[    7.166937] debug: unmapping init memory ffffffff805ec000..ffffffff8062d000
[    7.166937] Write protecting the kernel read-only data: 3456k
[    7.173142] Testing CPA: undo ffffffff80209000-ffffffff80569000
[    7.173351] Testing CPA: again
[    9.087986] Driver 'sr' needs updating - please use bus_type methods
[    9.089815] sr0: scsi3-mmc drive: 48x/48x cd/rw xa/form2 cdda tray
[    9.089925] Uniform CD-ROM driver Revision: 3.20
[    9.090656] sr 6:0:1:0: Attached scsi CD-ROM sr0
[    9.234590] usbcore: registered new interface driver usbfs
[    9.235088] usbcore: registered new interface driver hub
[    9.270956] usbcore: registered new device driver usb
[    9.335654] USB Universal Host Controller Interface driver v3.0
[    9.336351] ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
[    9.336648] Int: type 0, pol 3, trig 3, bus 00, IRQ 68, APIC ID 2, APIC INT 10
[    9.336807] PCI: Setting latency timer of device 0000:00:1a.0 to 64
[    9.336914] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    9.340181] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    9.340365] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000dc00
[    9.340893] usb usb1: configuration #1 chosen from 1 choice
[    9.341152] hub 1-0:1.0: USB hub found
[    9.341325] hub 1-0:1.0: 2 ports detected
[    9.442398] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[    9.442510] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.442662] usb usb1: Product: UHCI Host Controller
[    9.442769] usb usb1: Manufacturer: Linux 2.6.26-rc5-mm2 uhci_hcd
[    9.442868] usb usb1: SerialNumber: 0000:00:1a.0
[    9.443336] ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
[    9.443518] Int: type 0, pol 3, trig 3, bus 00, IRQ 6a, APIC ID 2, APIC INT 12
[    9.443675] PCI: Setting latency timer of device 0000:00:1a.7 to 64
[    9.443775] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    9.443955] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 2
[    9.448149] ehci_hcd 0000:00:1a.7: debug port 1
[    9.448263] PCI: cache line size of 32 is not supported by device 0000:00:1a.7
[    9.448418] ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfebffc00
[    9.458045] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[    9.458448] usb usb2: configuration #1 chosen from 1 choice
[    9.458634] hub 2-0:1.0: USB hub found
[    9.458820] hub 2-0:1.0: 4 ports detected
[    9.559686] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    9.559800] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.559953] usb usb2: Product: EHCI Host Controller
[    9.560047] usb usb2: Manufacturer: Linux 2.6.26-rc5-mm2 ehci_hcd
[    9.560150] usb usb2: SerialNumber: 0000:00:1a.7
[    9.560286] ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 17 (level, low) -> IRQ 17
[    9.560512] Int: type 0, pol 3, trig 3, bus 00, IRQ 69, APIC ID 2, APIC INT 11
[    9.560663] PCI: Setting latency timer of device 0000:00:1a.1 to 64
[    9.560774] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    9.560942] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 3
[    9.561114] uhci_hcd 0000:00:1a.1: irq 17, io base 0x0000e000
[    9.561559] usb usb3: configuration #1 chosen from 1 choice
[    9.561754] hub 3-0:1.0: USB hub found
[    9.561867] hub 3-0:1.0: 2 ports detected
[    9.663268] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    9.663379] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.663527] usb usb3: Product: UHCI Host Controller
[    9.663625] usb usb3: Manufacturer: Linux 2.6.26-rc5-mm2 uhci_hcd
[    9.663723] usb usb3: SerialNumber: 0000:00:1a.1
[    9.663776] ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
[    9.663978] Int: type 0, pol 3, trig 3, bus 00, IRQ 74, APIC ID 2, APIC INT 17
[    9.664268] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[    9.664370] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    9.664537] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 4
[    9.668593] ehci_hcd 0000:00:1d.7: debug port 1
[    9.668692] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
[    9.668852] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfebff800
[    9.678073] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[    9.678517] usb usb4: configuration #1 chosen from 1 choice
[    9.678702] hub 4-0:1.0: USB hub found
[    9.678807] hub 4-0:1.0: 6 ports detected
[    9.779677] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    9.779780] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.779920] usb usb4: Product: EHCI Host Controller
[    9.779920] usb usb4: Manufacturer: Linux 2.6.26-rc5-mm2 ehci_hcd
[    9.779920] usb usb4: SerialNumber: 0000:00:1d.7
[    9.821941] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
[    9.821941] Int: type 0, pol 3, trig 3, bus 00, IRQ 74, APIC ID 2, APIC INT 17
[    9.822041] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[    9.822142] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    9.822304] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
[    9.822471] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000d480
[    9.823026] usb usb5: configuration #1 chosen from 1 choice
[    9.823098] hub 5-0:1.0: USB hub found
[    9.823204] hub 5-0:1.0: 2 ports detected
[    9.924258] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    9.924368] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.924504] usb usb5: Product: UHCI Host Controller
[    9.924597] usb usb5: Manufacturer: Linux 2.6.26-rc5-mm2 uhci_hcd
[    9.925136] usb usb5: SerialNumber: 0000:00:1d.0
[    9.925136] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
[    9.925136] Int: type 0, pol 3, trig 3, bus 00, IRQ 75, APIC ID 2, APIC INT 13
[    9.925288] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[    9.925389] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    9.925549] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
[    9.925716] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000d800
[    9.926139] usb usb6: configuration #1 chosen from 1 choice
[    9.926139] hub 6-0:1.0: USB hub found
[    9.926249] hub 6-0:1.0: 2 ports detected
[   10.028390] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[   10.028390] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   10.028390] usb usb6: Product: UHCI Host Controller
[   10.028390] usb usb6: Manufacturer: Linux 2.6.26-rc5-mm2 uhci_hcd
[   10.028390] usb usb6: SerialNumber: 0000:00:1d.1
[   10.028390] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
[   10.028571] Int: type 0, pol 3, trig 3, bus 00, IRQ 76, APIC ID 2, APIC INT 12
[   10.028715] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[   10.028815] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   10.028977] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
[   10.029141] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000d880
[   10.029406] usb usb7: configuration #1 chosen from 1 choice
[   10.029589] hub 7-0:1.0: USB hub found
[   10.029693] hub 7-0:1.0: 2 ports detected
[   10.131207] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[   10.131310] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   10.131370] usb usb7: Product: UHCI Host Controller
[   10.131370] usb usb7: Manufacturer: Linux 2.6.26-rc5-mm2 uhci_hcd
[   10.131370] usb usb7: SerialNumber: 0000:00:1d.2
[   12.038580] EXT3 FS on sda2, internal journal
[   12.332820] usbcore: registered new interface driver usblp
[   12.443020] Adding 9775512k swap on /dev/sda1.  Priority:-1 extents:1 across:9775512k
[   20.894033] ip_tables: (C) 2000-2006 Netfilter Core Team
[   20.953082] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   22.864494] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
[   30.791234] CPA self-test:
[   30.793894]  4k 16384 large 2528 gb 0 x 0[0-0] miss 262144
[   30.802800]  4k 184832 large 2199 gb 0 x 0[0-0] miss 262144
[   30.809919]  4k 184832 large 2199 gb 0 x 0[0-0] miss 262144
[   30.810133] ok.
[  392.069650] warning: `capget01' uses 32-bit capabilities (legacy support in use)
[  671.162065] Adding 65528k swap on ./swapfile01.  Priority:-2 extents:22 across:74340k
[  673.061968] Adding 65528k swap on ./swapfile01.  Priority:-3 extents:26 across:83212k
[  675.047306] Adding 65528k swap on ./swapfile01.  Priority:-4 extents:28 across:113412k
[  675.137018] Unable to find swap-space signature
[  675.165587] Adding 32k swap on alreadyused.  Priority:-5 extents:1 across:32k
[  675.186455] Adding 32k swap on swapfile02.  Priority:-6 extents:1 across:32k
[  675.199282] Adding 32k swap on swapfile03.  Priority:-7 extents:1 across:32k
[  675.213209] Adding 32k swap on swapfile04.  Priority:-8 extents:1 across:32k
[  675.227104] Adding 32k swap on swapfile05.  Priority:-9 extents:1 across:32k
[  675.240072] Adding 32k swap on swapfile06.  Priority:-10 extents:1 across:32k
[  675.253960] Adding 32k swap on swapfile07.  Priority:-11 extents:2 across:32k
[  675.265936] Adding 32k swap on swapfile08.  Priority:-12 extents:1 across:32k
[  675.278533] Adding 32k swap on swapfile09.  Priority:-13 extents:1 across:32k
[  675.292014] Adding 32k swap on swapfile10.  Priority:-14 extents:1 across:32k
[  675.305921] Adding 32k swap on swapfile11.  Priority:-15 extents:1 across:32k
[  675.319235] Adding 32k swap on swapfile12.  Priority:-16 extents:1 across:32k
[  675.334037] Adding 32k swap on swapfile13.  Priority:-17 extents:1 across:32k
[  675.348552] Adding 32k swap on swapfile14.  Priority:-18 extents:1 across:32k
[  675.362114] Adding 32k swap on swapfile15.  Priority:-19 extents:1 across:32k
[  675.376051] Adding 32k swap on swapfile16.  Priority:-20 extents:1 across:32k
[  675.389001] Adding 32k swap on swapfile17.  Priority:-21 extents:1 across:32k
[  675.402549] Adding 32k swap on swapfile18.  Priority:-22 extents:1 across:32k
[  675.416451] Adding 32k swap on swapfile19.  Priority:-23 extents:1 across:32k
[  675.429779] Adding 32k swap on swapfile20.  Priority:-24 extents:1 across:32k
[  675.443145] Adding 32k swap on swapfile21.  Priority:-25 extents:1 across:32k
[  675.456604] Adding 32k swap on swapfile22.  Priority:-26 extents:1 across:32k
[  675.471061] Adding 32k swap on swapfile23.  Priority:-27 extents:1 across:32k
[  675.483801] Adding 32k swap on swapfile24.  Priority:-28 extents:1 across:32k
[  675.498078] Adding 32k swap on swapfile25.  Priority:-29 extents:1 across:32k
[  675.510248] Adding 32k swap on swapfile26.  Priority:-30 extents:1 across:32k
[  675.523151] Adding 32k swap on swapfile27.  Priority:-31 extents:1 across:32k
[  675.537062] Adding 32k swap on swapfile28.  Priority:-32 extents:1 across:32k
[  675.550037] Adding 32k swap on swapfile29.  Priority:-33 extents:1 across:32k
[  675.563951] Adding 32k swap on swapfile30.  Priority:-34 extents:1 across:32k
[  675.602548] Adding 32k swap on firstswapfile.  Priority:-35 extents:1 across:32k
[  675.602716] Adding 32k swap on secondswapfile.  Priority:-36 extents:1 across:32k
[  675.937348] warning: process `sysctl01' used the deprecated sysctl system call with 1.1.
[  675.937593] warning: process `sysctl01' used the deprecated sysctl system call with 1.2.
[  675.941949] warning: process `sysctl03' used the deprecated sysctl system call with 1.1.
[  675.943554] warning: process `sysctl03' used the deprecated sysctl system call with 1.1.
[  675.948054] warning: process `sysctl04' used the deprecated sysctl system call with 
[ 1234.754237] eth1: link down
[ 3308.107702] Adding 65528k swap on ./swapfile01.  Priority:-37 extents:30 across:83136k
[ 3309.952087] Adding 65528k swap on ./swapfile01.  Priority:-38 extents:30 across:120800k
[ 3311.775546] Adding 65528k swap on ./swapfile01.  Priority:-39 extents:24 across:141676k
[ 3311.841524] Unable to find swap-space signature
[ 3311.869869] Adding 32k swap on alreadyused.  Priority:-40 extents:1 across:32k
[ 3311.890259] Adding 32k swap on swapfile02.  Priority:-41 extents:1 across:32k
[ 3311.907461] Adding 32k swap on swapfile03.  Priority:-42 extents:1 across:32k
[ 3311.921087] Adding 32k swap on swapfile04.  Priority:-43 extents:1 across:32k
[ 3311.933232] Adding 32k swap on swapfile05.  Priority:-44 extents:1 across:32k
[ 3311.947855] Adding 32k swap on swapfile06.  Priority:-45 extents:3 across:60k
[ 3311.962967] Adding 32k swap on swapfile07.  Priority:-46 extents:1 across:32k
[ 3311.975935] Adding 32k swap on swapfile08.  Priority:-47 extents:1 across:32k
[ 3311.989916] Adding 32k swap on swapfile09.  Priority:-48 extents:1 across:32k
[ 3312.003532] Adding 32k swap on swapfile10.  Priority:-49 extents:1 across:32k
[ 3312.017640] Adding 32k swap on swapfile11.  Priority:-50 extents:1 across:32k
[ 3312.030819] Adding 32k swap on swapfile12.  Priority:-51 extents:1 across:32k
[ 3312.043809] Adding 32k swap on swapfile13.  Priority:-52 extents:1 across:32k
[ 3312.057654] Adding 32k swap on swapfile14.  Priority:-53 extents:1 across:32k
[ 3312.072483] Adding 32k swap on swapfile15.  Priority:-54 extents:1 across:32k
[ 3312.084766] Adding 32k swap on swapfile16.  Priority:-55 extents:1 across:32k
[ 3312.098372] Adding 32k swap on swapfile17.  Priority:-56 extents:1 across:32k
[ 3312.111681] Adding 32k swap on swapfile18.  Priority:-57 extents:1 across:32k
[ 3312.125582] Adding 32k swap on swapfile19.  Priority:-58 extents:1 across:32k
[ 3312.138583] Adding 32k swap on swapfile20.  Priority:-59 extents:1 across:32k
[ 3312.152541] Adding 32k swap on swapfile21.  Priority:-60 extents:1 across:32k
[ 3312.165441] Adding 32k swap on swapfile22.  Priority:-61 extents:1 across:32k
[ 3312.178315] Adding 32k swap on swapfile23.  Priority:-62 extents:1 across:32k
[ 3312.192572] Adding 32k swap on swapfile24.  Priority:-63 extents:1 across:32k
[ 3312.205582] Adding 32k swap on swapfile25.  Priority:-64 extents:1 across:32k
[ 3312.218830] Adding 32k swap on swapfile26.  Priority:-65 extents:1 across:32k
[ 3312.231925] Adding 32k swap on swapfile27.  Priority:-66 extents:1 across:32k
[ 3312.244696] Adding 32k swap on swapfile28.  Priority:-67 extents:1 across:32k
[ 3312.258158] Adding 32k swap on swapfile29.  Priority:-68 extents:1 across:32k
[ 3312.273575] Adding 32k swap on swapfile30.  Priority:-69 extents:1 across:32k
[ 3312.311974] Adding 32k swap on firstswapfile.  Priority:-70 extents:1 across:32k
[ 3312.312159] Adding 32k swap on secondswapfile.  Priority:-71 extents:1 across:32k
[ 5941.121015] Adding 65528k swap on ./swapfile01.  Priority:-72 extents:27 across:91572k
[ 5943.036742] Adding 65528k swap on ./swapfile01.  Priority:-73 extents:22 across:116792k
[ 5944.890222] Adding 65528k swap on ./swapfile01.  Priority:-74 extents:29 across:82880k
[ 5944.958795] Unable to find swap-space signature
[ 5944.987839] Adding 32k swap on alreadyused.  Priority:-75 extents:2 across:80k
[ 5945.007865] Adding 32k swap on swapfile02.  Priority:-76 extents:1 across:32k
[ 5945.021265] Adding 32k swap on swapfile03.  Priority:-77 extents:1 across:32k
[ 5945.035659] Adding 32k swap on swapfile04.  Priority:-78 extents:1 across:32k
[ 5945.047803] Adding 32k swap on swapfile05.  Priority:-79 extents:1 across:32k
[ 5945.061365] Adding 32k swap on swapfile06.  Priority:-80 extents:1 across:32k
[ 5945.074579] Adding 32k swap on swapfile07.  Priority:-81 extents:1 across:32k
[ 5945.087749] Adding 32k swap on swapfile08.  Priority:-82 extents:1 across:32k
[ 5945.100881] Adding 32k swap on swapfile09.  Priority:-83 extents:1 across:32k
[ 5945.113835] Adding 32k swap on swapfile10.  Priority:-84 extents:1 across:32k
[ 5945.127685] Adding 32k swap on swapfile11.  Priority:-85 extents:1 across:32k
[ 5945.143102] Adding 32k swap on swapfile12.  Priority:-86 extents:1 across:32k
[ 5945.156064] Adding 32k swap on swapfile13.  Priority:-87 extents:1 across:32k
[ 5945.170481] Adding 32k swap on swapfile14.  Priority:-88 extents:1 across:32k
[ 5945.183410] Adding 32k swap on swapfile15.  Priority:-89 extents:1 across:32k
[ 5945.196625] Adding 32k swap on swapfile16.  Priority:-90 extents:1 across:32k
[ 5945.210600] Adding 32k swap on swapfile17.  Priority:-91 extents:1 across:32k
[ 5945.223734] Adding 32k swap on swapfile18.  Priority:-92 extents:1 across:32k
[ 5945.236676] Adding 32k swap on swapfile19.  Priority:-93 extents:1 across:32k
[ 5945.249780] Adding 32k swap on swapfile20.  Priority:-94 extents:1 across:32k
[ 5945.262881] Adding 32k swap on swapfile21.  Priority:-95 extents:1 across:32k
[ 5945.275698] Adding 32k swap on swapfile22.  Priority:-96 extents:1 across:32k
[ 5945.288959] Adding 32k swap on swapfile23.  Priority:-97 extents:1 across:32k
[ 5945.302151] Adding 32k swap on swapfile24.  Priority:-98 extents:1 across:32k
[ 5945.315415] Adding 32k swap on swapfile25.  Priority:-99 extents:1 across:32k
[ 5945.328968] Adding 32k swap on swapfile26.  Priority:-100 extents:1 across:32k
[ 5945.342986] Adding 32k swap on swapfile27.  Priority:-101 extents:1 across:32k
[ 5945.355948] Adding 32k swap on swapfile28.  Priority:-102 extents:1 across:32k
[ 5945.369935] Adding 32k swap on swapfile29.  Priority:-103 extents:1 across:32k
[ 5945.384916] Adding 32k swap on swapfile30.  Priority:-104 extents:1 across:32k
[ 5945.422373] Adding 32k swap on firstswapfile.  Priority:-105 extents:1 across:32k
[ 5945.422541] Adding 32k swap on secondswapfile.  Priority:-106 extents:1 across:32k
[ 6773.608125] init invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[ 6773.608215] Pid: 1, comm: init Not tainted 2.6.26-rc5-mm2 #2
[ 6773.608888] 
[ 6773.608888] Call Trace:
[ 6773.610887]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6773.610887]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6773.610887]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6773.610887]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6773.610887]  [<ffffffff8026f71c>] __do_page_cache_readahead+0xfc/0x210
[ 6773.610887]  [<ffffffff8026fc8f>] do_page_cache_readahead+0x5f/0x80
[ 6773.610887]  [<ffffffff80269310>] filemap_fault+0x250/0x4c0
[ 6773.610887]  [<ffffffff80276bf0>] __do_fault+0x50/0x490
[ 6773.610887]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
[ 6773.610887]  [<ffffffff80278972>] handle_mm_fault+0x242/0x780
[ 6773.610887]  [<ffffffff8022146f>] ? do_page_fault+0x2df/0x8d0
[ 6773.610887]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6773.610887]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6773.610887] 
[ 6773.610887] Mem-info:
[ 6773.610887] DMA per-cpu:
[ 6773.610887] CPU    0: hi:    0, btch:   1 usd:   0
[ 6773.610887] CPU    1: hi:    0, btch:   1 usd:   0
[ 6773.610887] DMA32 per-cpu:
[ 6773.610887] CPU    0: hi:  186, btch:  31 usd:  45
[ 6773.610952] CPU    1: hi:  186, btch:  31 usd:   0
[ 6773.611462] Normal per-cpu:
[ 6773.611513] CPU    0: hi:  186, btch:  31 usd: 161
[ 6773.611573] CPU    1: hi:  186, btch:  31 usd: 107
[ 6773.611634] Active_anon:0 active_file:473789 inactive_anon0
[ 6773.611635]  inactive_file:473447 dirty:41471 writeback:0 unstable:0
[ 6773.611636]  free:5688 slab:45896 mapped:1 pagetables:415 bounce:0
[ 6773.611829] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6773.612003] lowmem_reserve[]: 0 1975 3995 3995
[ 6773.612086] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:911668kB inactive_file:911232kB present:2023200kB pages_scanned:5792629 all_unreclaimable? no
[ 6773.612459] lowmem_reserve[]: 0 0 2020 2020
[ 6773.613544] Normal free:3980kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:0kB active_file:983488kB inactive_file:982556kB present:2068480kB pages_scanned:5756927 all_unreclaimable? no
[ 6773.613544] lowmem_reserve[]: 0 0 0 0
[ 6773.613544] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6773.613544] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6773.613544] Normal: 1*4kB 4*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3940kB
[ 6773.613544] 675611 total pagecache pages
[ 6773.613544] Swap cache: add 3407179, delete 3407179, find 2573/2828
[ 6773.613544] Free swap  = 9765272kB
[ 6773.613603] Total swap = 9775512kB
[ 6773.631577] 1572864 pages of RAM
[ 6773.631639] 566471 reserved pages
[ 6773.631693] 652567 pages shared
[ 6773.631745] 0 pages swap cached
[ 6773.631799] Out of memory: kill process 4788 (sshd) score 11194 or a child
[ 6773.631876] Killed process 4789 (bash)
[ 6776.348287] runltp invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=0
[ 6776.348414] Pid: 6846, comm: runltp Not tainted 2.6.26-rc5-mm2 #2
[ 6776.349219] 
[ 6776.349219] Call Trace:
[ 6776.349219]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6776.349219]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6776.349219]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6776.349219]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6776.349219]  [<ffffffff802830cc>] read_swap_cache_async+0x9c/0xf0
[ 6776.349219]  [<ffffffff8028319a>] swapin_readahead+0x7a/0xb0
[ 6776.349219]  [<ffffffff80467ef0>] ? _spin_unlock+0x30/0x60
[ 6776.349219]  [<ffffffff80278b9f>] handle_mm_fault+0x46f/0x780
[ 6776.349219]  [<ffffffff802213a0>] ? do_page_fault+0x210/0x8d0
[ 6776.349243]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6776.349308]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6776.349372]  [<ffffffff8020ace0>] ? do_notify_resume+0x400/0x940
[ 6776.349439]  [<ffffffff8020ac53>] ? do_notify_resume+0x373/0x940
[ 6776.350233]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6776.350233]  [<ffffffff80468022>] ? _spin_unlock_irqrestore+0x42/0x80
[ 6776.350233]  [<ffffffff80247dc6>] ? remove_wait_queue+0x36/0x50
[ 6776.350233]  [<ffffffff804675f7>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 6776.350233]  [<ffffffff8020b75d>] ? sysret_signal+0x21/0x31
[ 6776.350233]  [<ffffffff8020ba57>] ? ptregscall_common+0x67/0xb0
[ 6776.350233] 
[ 6776.350233] Mem-info:
[ 6776.350233] DMA per-cpu:
[ 6776.350233] CPU    0: hi:    0, btch:   1 usd:   0
[ 6776.350233] CPU    1: hi:    0, btch:   1 usd:   0
[ 6776.350233] DMA32 per-cpu:
[ 6776.350272] CPU    0: hi:  186, btch:  31 usd:  45
[ 6776.350332] CPU    1: hi:  186, btch:  31 usd:   0
[ 6776.350392] Normal per-cpu:
[ 6776.350442] CPU    0: hi:  186, btch:  31 usd: 169
[ 6776.351264] CPU    1: hi:  186, btch:  31 usd: 136
[ 6776.351264] Active_anon:0 active_file:473303 inactive_anon0
[ 6776.351265]  inactive_file:473775 dirty:41471 writeback:0 unstable:0
[ 6776.351265]  free:5692 slab:45891 mapped:1 pagetables:391 bounce:0
[ 6776.351265] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6776.351265] lowmem_reserve[]: 0 1975 3995 3995
[ 6776.351265] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:911376kB inactive_file:910924kB present:2023200kB pages_scanned:11657571 all_unreclaimable? no
[ 6776.351274] lowmem_reserve[]: 0 0 2020 2020
[ 6776.351390] Normal free:4080kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:0kB active_file:981836kB inactive_file:984176kB present:2068480kB pages_scanned:7345571 all_unreclaimable? no
[ 6776.352237] lowmem_reserve[]: 0 0 0 0
[ 6776.352237] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6776.352237] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6776.352237] Normal: 32*4kB 7*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 4088kB
[ 6776.352312] 675597 total pagecache pages
[ 6776.352423] Swap cache: add 3407179, delete 3407179, find 2573/2831
[ 6776.353218] Free swap  = 9765988kB
[ 6776.353218] Total swap = 9775512kB
[ 6776.372465] 1572864 pages of RAM
[ 6776.373219] 566471 reserved pages
[ 6776.373219] 652711 pages shared
[ 6776.373219] 0 pages swap cached
[ 6776.373219] Out of memory: kill process 4801 (sshd) score 11194 or a child
[ 6776.373219] Killed process 4802 (bash)
[ 6776.454812] init invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[ 6776.454902] Pid: 1, comm: init Not tainted 2.6.26-rc5-mm2 #2
[ 6776.454966] 
[ 6776.454966] Call Trace:
[ 6776.455072]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6776.455081]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6776.455081]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6776.455081]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6776.455081]  [<ffffffff8026f71c>] __do_page_cache_readahead+0xfc/0x210
[ 6776.455081]  [<ffffffff8026fc8f>] do_page_cache_readahead+0x5f/0x80
[ 6776.455081]  [<ffffffff80269310>] filemap_fault+0x250/0x4c0
[ 6776.455081]  [<ffffffff80276bf0>] __do_fault+0x50/0x490
[ 6776.455081]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
[ 6776.455081]  [<ffffffff80278972>] handle_mm_fault+0x242/0x780
[ 6776.455081]  [<ffffffff8022146f>] ? do_page_fault+0x2df/0x8d0
[ 6776.455154]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6776.455221]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6776.455283] 
[ 6776.455328] Mem-info:
[ 6776.455377] DMA per-cpu:
[ 6776.455427] CPU    0: hi:    0, btch:   1 usd:   0
[ 6776.455487] CPU    1: hi:    0, btch:   1 usd:   0
[ 6776.455547] DMA32 per-cpu:
[ 6776.455597] CPU    0: hi:  186, btch:  31 usd:  45
[ 6776.455657] CPU    1: hi:  186, btch:  31 usd:   0
[ 6776.455717] Normal per-cpu:
[ 6776.455767] CPU    0: hi:  186, btch:  31 usd: 113
[ 6776.455827] CPU    1: hi:  186, btch:  31 usd: 135
[ 6776.455888] Active_anon:0 active_file:473015 inactive_anon8
[ 6776.455889]  inactive_file:474167 dirty:41471 writeback:0 unstable:0
[ 6776.455890]  free:5702 slab:45890 mapped:1 pagetables:377 bounce:0
[ 6776.456148] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6776.456323] lowmem_reserve[]: 0 1975 3995 3995
[ 6776.456407] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:910200kB inactive_file:912244kB present:2023200kB pages_scanned:12128635 all_unreclaimable? no
[ 6776.456593] lowmem_reserve[]: 0 0 2020 2020
[ 6776.456675] Normal free:4120kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:32kB active_file:981860kB inactive_file:984424kB present:2068480kB pages_scanned:0 all_unreclaimable? no
[ 6776.456858] lowmem_reserve[]: 0 0 0 0
[ 6776.456956] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6776.457081] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6776.457270] Normal: 32*4kB 6*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 4080kB
[ 6776.457453] 675667 total pagecache pages
[ 6776.457510] Swap cache: add 3407211, delete 3407179, find 2573/2834
[ 6776.457576] Free swap  = 9766888kB
[ 6776.457629] Total swap = 9775512kB
[ 6776.478350] 1572864 pages of RAM
[ 6776.478411] 566471 reserved pages
[ 6776.478465] 652700 pages shared
[ 6776.478528] 32 pages swap cached
[ 6776.478583] Out of memory: kill process 7372 (sshd) score 11194 or a child
[ 6776.480177] Killed process 7373 (bash)
[ 6776.502332] syslog-ng invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=0
[ 6776.502454] Pid: 3780, comm: syslog-ng Not tainted 2.6.26-rc5-mm2 #2
[ 6776.503268] 
[ 6776.503268] Call Trace:
[ 6776.503268]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6776.503268]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6776.503268]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6776.503268]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6776.503268]  [<ffffffff802830cc>] read_swap_cache_async+0x9c/0xf0
[ 6776.503268]  [<ffffffff8028319a>] swapin_readahead+0x7a/0xb0
[ 6776.503268]  [<ffffffff80467ef0>] ? _spin_unlock+0x30/0x60
[ 6776.503268]  [<ffffffff80278b9f>] handle_mm_fault+0x46f/0x780
[ 6776.503268]  [<ffffffff802213a0>] ? do_page_fault+0x210/0x8d0
[ 6776.503268]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6776.503339]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6776.503403]  [<ffffffff80247daf>] ? remove_wait_queue+0x1f/0x50
[ 6776.503470]  [<ffffffff802a0584>] ? do_sys_poll+0x364/0x3b0
[ 6776.504329]  [<ffffffff802a054d>] ? do_sys_poll+0x32d/0x3b0
[ 6776.504329]  [<ffffffff802a11e0>] ? __pollwait+0x0/0x110
[ 6776.504329]  [<ffffffff8022b940>] ? default_wake_function+0x0/0x10
[ 6776.504329]  [<ffffffff8022b940>] ? default_wake_function+0x0/0x10
[ 6776.504329]  [<ffffffff8022b940>] ? default_wake_function+0x0/0x10
[ 6776.504329]  [<ffffffff80362530>] ? do_con_write+0xd60/0x1f60
[ 6776.504329]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
[ 6776.504329]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
[ 6776.504329]  [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
[ 6776.504329]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6776.504329]  [<ffffffff80468022>] ? _spin_unlock_irqrestore+0x42/0x80
[ 6776.504338]  [<ffffffff8034f7d1>] ? tty_ldisc_deref+0x61/0x80
[ 6776.504404]  [<ffffffff8035229c>] ? tty_write+0x22c/0x260
[ 6776.504468]  [<ffffffff80354c80>] ? write_chan+0x0/0x3c0
[ 6776.505314]  [<ffffffff804675f7>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 6776.505314]  [<ffffffff802a0603>] ? sys_poll+0x33/0x90
[ 6776.505315]  [<ffffffff8020b6bb>] ? system_call_after_swapgs+0x7b/0x80
[ 6776.505315] 
[ 6776.505315] Mem-info:
[ 6776.505315] DMA per-cpu:
[ 6776.505315] CPU    0: hi:    0, btch:   1 usd:   0
[ 6776.505315] CPU    1: hi:    0, btch:   1 usd:   0
[ 6776.505315] DMA32 per-cpu:
[ 6776.505315] CPU    0: hi:  186, btch:  31 usd:  45
[ 6776.505315] CPU    1: hi:  186, btch:  31 usd:   0
[ 6776.505315] Normal per-cpu:
[ 6776.505315] CPU    0: hi:  186, btch:  31 usd: 121
[ 6776.505317] CPU    1: hi:  186, btch:  31 usd: 182
[ 6776.505384] Active_anon:0 active_file:473872 inactive_anon0
[ 6776.505385]  inactive_file:473358 dirty:41471 writeback:0 unstable:0
[ 6776.505386]  free:5681 slab:45890 mapped:1 pagetables:346 bounce:0
[ 6776.506305] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6776.506305] lowmem_reserve[]: 0 1975 3995 3995
[ 6776.506305] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:912156kB inactive_file:910452kB present:2023200kB pages_scanned:12291693 all_unreclaimable? no
[ 6776.506305] lowmem_reserve[]: 0 0 2020 2020
[ 6776.506305] Normal free:4036kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:0kB active_file:983332kB inactive_file:982980kB present:2068480kB pages_scanned:10240 all_unreclaimable? no
[ 6776.506357] lowmem_reserve[]: 0 0 0 0
[ 6776.506443] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6776.507314] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6776.507314] Normal: 5*4kB 5*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3964kB
[ 6776.507314] 675667 total pagecache pages
[ 6776.507314] Swap cache: add 3407211, delete 3407207, find 2573/2837
[ 6776.507314] Free swap  = 9767376kB
[ 6776.507317] Total swap = 9775512kB
[ 6776.527266] 1572864 pages of RAM
[ 6776.527266] 566471 reserved pages
[ 6776.527266] 652681 pages shared
[ 6776.527266] 4 pages swap cached
[ 6776.527322] Out of memory: kill process 4788 (sshd) score 8976 or a child
[ 6776.527404] Killed process 4788 (sshd)
[ 6776.707635] growfiles invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=0
[ 6776.708459] Pid: 10340, comm: growfiles Not tainted 2.6.26-rc5-mm2 #2
[ 6776.708459] 
[ 6776.708459] Call Trace:
[ 6776.708459]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6776.708459]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6776.708459]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6776.708459]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6776.708459]  [<ffffffff80266e9a>] __grab_cache_page+0x6a/0xa0
[ 6776.708459]  [<ffffffff802e5f55>] ext3_write_begin+0x65/0x1b0
[ 6776.708459]  [<ffffffff802677dd>] generic_file_buffered_write+0x14d/0x740
[ 6776.708459]  [<ffffffff80467ef0>] ? _spin_unlock+0x30/0x60
[ 6776.708517]  [<ffffffff802ac0fe>] ? mnt_drop_write+0x7e/0x160
[ 6776.708627]  [<ffffffff80268260>] __generic_file_aio_write_nolock+0x2a0/0x460
[ 6776.708701]  [<ffffffff80268486>] generic_file_aio_write+0x66/0xd0
[ 6776.709510]  [<ffffffff802e1846>] ext3_file_write+0x26/0xc0
[ 6776.709510]  [<ffffffff802e1820>] ? ext3_file_write+0x0/0xc0
[ 6776.709510]  [<ffffffff80291e9b>] do_sync_readv_writev+0xeb/0x130
[ 6776.709510]  [<ffffffff8028c078>] ? check_bytes_and_report+0x38/0xd0
[ 6776.709510]  [<ffffffff80247ae0>] ? autoremove_wake_function+0x0/0x40
[ 6776.709510]  [<ffffffff8028bccf>] ? init_object+0x4f/0x90
[ 6776.709510]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6776.709510]  [<ffffffff80291cd5>] ? rw_copy_check_uvector+0x95/0x130
[ 6776.709510]  [<ffffffff802925d3>] do_readv_writev+0xc3/0x120
[ 6776.709510]  [<ffffffff802a26de>] ? locks_free_lock+0x3e/0x60
[ 6776.709518]  [<ffffffff802a26de>] ? locks_free_lock+0x3e/0x60
[ 6776.709584]  [<ffffffff802a3c38>] ? fcntl_setlk+0x58/0x2c0
[ 6776.709648]  [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
[ 6776.709733]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6776.710459]  [<ffffffff80292669>] vfs_writev+0x39/0x60
[ 6776.710459]  [<ffffffff80292a30>] sys_writev+0x50/0x90
[ 6776.710459]  [<ffffffff8020b6bb>] system_call_after_swapgs+0x7b/0x80
[ 6776.710459] 
[ 6776.710459] Mem-info:
[ 6776.710459] DMA per-cpu:
[ 6776.710459] CPU    0: hi:    0, btch:   1 usd:   0
[ 6776.710459] CPU    1: hi:    0, btch:   1 usd:   0
[ 6776.710459] DMA32 per-cpu:
[ 6776.710459] CPU    0: hi:  186, btch:  31 usd:  45
[ 6776.710459] CPU    1: hi:  186, btch:  31 usd:   0
[ 6776.710459] Normal per-cpu:
[ 6776.710467] CPU    0: hi:  186, btch:  31 usd: 159
[ 6776.710528] CPU    1: hi:  186, btch:  31 usd: 175
[ 6776.710589] Active_anon:0 active_file:474168 inactive_anon0
[ 6776.710590]  inactive_file:473082 dirty:41471 writeback:0 unstable:0
[ 6776.710591]  free:5681 slab:45890 mapped:1 pagetables:315 bounce:0
[ 6776.711459] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6776.711459] lowmem_reserve[]: 0 1975 3995 3995
[ 6776.711459] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:912196kB inactive_file:910632kB present:2023200kB pages_scanned:12656936 all_unreclaimable? no
[ 6776.711459] lowmem_reserve[]: 0 0 2020 2020
[ 6776.711459] Normal free:4036kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:0kB active_file:984600kB inactive_file:981696kB present:2068480kB pages_scanned:213813 all_unreclaimable? no
[ 6776.711544] lowmem_reserve[]: 0 0 0 0
[ 6776.711628] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6776.712536] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6776.712536] Normal: 5*4kB 5*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3964kB
[ 6776.712536] 675667 total pagecache pages
[ 6776.712536] Swap cache: add 3407219, delete 3407215, find 2573/2837
[ 6776.712536] Free swap  = 9767576kB
[ 6776.712539] Total swap = 9775512kB
[ 6776.733460] 1572864 pages of RAM
[ 6776.733460] 566471 reserved pages
[ 6776.733460] 652585 pages shared
[ 6776.733460] 4 pages swap cached
[ 6776.733460] Out of memory: kill process 4801 (sshd) score 8976 or a child
[ 6776.733460] Killed process 4801 (sshd)
[ 6782.551918] syslog-ng invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=0
[ 6782.552041] Pid: 3780, comm: syslog-ng Not tainted 2.6.26-rc5-mm2 #2
[ 6782.552109] 
[ 6782.552109] Call Trace:
[ 6782.552214]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6782.552281]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6782.552345]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6782.552411]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6782.552481]  [<ffffffff802830cc>] read_swap_cache_async+0x9c/0xf0
[ 6782.552548]  [<ffffffff8028319a>] swapin_readahead+0x7a/0xb0
[ 6782.552614]  [<ffffffff80467ef0>] ? _spin_unlock+0x30/0x60
[ 6782.552680]  [<ffffffff80278b9f>] handle_mm_fault+0x46f/0x780
[ 6782.552747]  [<ffffffff802213a0>] ? do_page_fault+0x210/0x8d0
[ 6782.552812]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6782.552886]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6782.552950]  [<ffffffff80247daf>] ? remove_wait_queue+0x1f/0x50
[ 6782.553017]  [<ffffffff802a0584>] ? do_sys_poll+0x364/0x3b0
[ 6782.553083]  [<ffffffff802a054d>] ? do_sys_poll+0x32d/0x3b0
[ 6782.553147]  [<ffffffff802a11e0>] ? __pollwait+0x0/0x110
[ 6782.553211]  [<ffffffff8022b940>] ? default_wake_function+0x0/0x10
[ 6782.553279]  [<ffffffff8022b940>] ? default_wake_function+0x0/0x10
[ 6782.553346]  [<ffffffff8022b940>] ? default_wake_function+0x0/0x10
[ 6782.553414]  [<ffffffff80362530>] ? do_con_write+0xd60/0x1f60
[ 6782.553480]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
[ 6782.553547]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
[ 6782.553614]  [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
[ 6782.555205]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6782.555273]  [<ffffffff80468022>] ? _spin_unlock_irqrestore+0x42/0x80
[ 6782.555342]  [<ffffffff8034f7d1>] ? tty_ldisc_deref+0x61/0x80
[ 6782.555408]  [<ffffffff8035229c>] ? tty_write+0x22c/0x260
[ 6782.555471]  [<ffffffff80354c80>] ? write_chan+0x0/0x3c0
[ 6782.555535]  [<ffffffff804675f7>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 6782.556543]  [<ffffffff802a0603>] ? sys_poll+0x33/0x90
[ 6782.556607]  [<ffffffff8020b6bb>] ? system_call_after_swapgs+0x7b/0x80
[ 6782.556675] 
[ 6782.556720] Mem-info:
[ 6782.557142] DMA per-cpu:
[ 6782.557193] CPU    0: hi:    0, btch:   1 usd:   0
[ 6782.557253] CPU    1: hi:    0, btch:   1 usd:   0
[ 6782.557312] DMA32 per-cpu:
[ 6782.557363] CPU    0: hi:  186, btch:  31 usd: 179
[ 6782.557423] CPU    1: hi:  186, btch:  31 usd:   0
[ 6782.557482] Normal per-cpu:
[ 6782.557533] CPU    0: hi:  186, btch:  31 usd: 160
[ 6782.557593] CPU    1: hi:  186, btch:  31 usd: 171
[ 6782.557655] Active_anon:0 active_file:471412 inactive_anon0
[ 6782.557656]  inactive_file:475671 dirty:20776 writeback:0 unstable:0
[ 6782.557657]  free:5694 slab:45816 mapped:1 pagetables:313 bounce:0
[ 6782.557773] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6782.557773] lowmem_reserve[]: 0 1975 3995 3995
[ 6782.557773] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:911432kB inactive_file:911236kB present:2023200kB pages_scanned:25924478 all_unreclaimable? no
[ 6782.557962] lowmem_reserve[]: 0 0 2020 2020
[ 6782.558047] Normal free:4088kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:0kB active_file:974216kB inactive_file:991560kB present:2068480kB pages_scanned:3915748 all_unreclaimable? no
[ 6782.558231] lowmem_reserve[]: 0 0 0 0
[ 6782.558312] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6782.558501] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6782.558687] Normal: 38*4kB 4*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 4088kB
[ 6782.558993] 675600 total pagecache pages
[ 6782.559049] Swap cache: add 3407223, delete 3407223, find 2573/2837
[ 6782.559115] Free swap  = 9767776kB
[ 6782.559169] Total swap = 9775512kB
[ 6782.579598] 1572864 pages of RAM
[ 6782.579660] 566471 reserved pages
[ 6782.579713] 652752 pages shared
[ 6782.579766] 0 pages swap cached
[ 6782.579820] Out of memory: kill process 7372 (sshd) score 8976 or a child
[ 6782.579909] Killed process 7372 (sshd)
[ 6785.203761] pan invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=0
[ 6785.203850] Pid: 6957, comm: pan Not tainted 2.6.26-rc5-mm2 #2
[ 6785.203931] 
[ 6785.203932] Call Trace:
[ 6785.204701]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6785.204701]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6785.204701]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6785.204701]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6785.204701]  [<ffffffff802830cc>] read_swap_cache_async+0x9c/0xf0
[ 6785.204701]  [<ffffffff8028319a>] swapin_readahead+0x7a/0xb0
[ 6785.204701]  [<ffffffff80467ef0>] ? _spin_unlock+0x30/0x60
[ 6785.204701]  [<ffffffff80278b9f>] handle_mm_fault+0x46f/0x780
[ 6785.204701]  [<ffffffff802213a0>] ? do_page_fault+0x210/0x8d0
[ 6785.204701]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6785.204745]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6785.204809]  [<ffffffff8020ace0>] ? do_notify_resume+0x400/0x940
[ 6785.204875]  [<ffffffff8020ac53>] ? do_notify_resume+0x373/0x940
[ 6785.205734]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6785.205734]  [<ffffffff80468022>] ? _spin_unlock_irqrestore+0x42/0x80
[ 6785.205734]  [<ffffffff80247dc6>] ? remove_wait_queue+0x36/0x50
[ 6785.205734]  [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
[ 6785.205734]  [<ffffffff804675f7>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 6785.205734]  [<ffffffff8020b75d>] ? sysret_signal+0x21/0x31
[ 6785.205734]  [<ffffffff8020ba57>] ? ptregscall_common+0x67/0xb0
[ 6785.205734] 
[ 6785.205734] Mem-info:
[ 6785.205734] DMA per-cpu:
[ 6785.205734] CPU    0: hi:    0, btch:   1 usd:   0
[ 6785.205734] CPU    1: hi:    0, btch:   1 usd:   0
[ 6785.205741] DMA32 per-cpu:
[ 6785.205793] CPU    0: hi:  186, btch:  31 usd: 179
[ 6785.205852] CPU    1: hi:  186, btch:  31 usd:   0
[ 6785.205911] Normal per-cpu:
[ 6785.206717] CPU    0: hi:  186, btch:  31 usd: 183
[ 6785.206717] CPU    1: hi:  186, btch:  31 usd: 172
[ 6785.206717] Active_anon:0 active_file:473406 inactive_anon2
[ 6785.206717]  inactive_file:473879 dirty:20776 writeback:0 unstable:0
[ 6785.206717]  free:5654 slab:45813 mapped:1 pagetables:313 bounce:0
[ 6785.206717] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6785.206717] lowmem_reserve[]: 0 1975 3995 3995
[ 6785.206717] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:897288kB inactive_file:925568kB present:2023200kB pages_scanned:32582125 all_unreclaimable? no
[ 6785.206767] lowmem_reserve[]: 0 0 2020 2020
[ 6785.206850] Normal free:3928kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:8kB active_file:1006008kB inactive_file:960220kB present:2068480kB pages_scanned:5891220 all_unreclaimable? no
[ 6785.207745] lowmem_reserve[]: 0 0 0 0
[ 6785.207745] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6785.207745] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
[ 6785.207745] Normal: 0*4kB 0*8kB 0*16kB 2*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3840kB
[ 6785.207810] 675665 total pagecache pages
[ 6785.207867] Swap cache: add 3407250, delete 3407249, find 2573/2840
[ 6785.207933] Free swap  = 9767976kB
[ 6785.208725] Total swap = 9775512kB
[ 6785.228706] 1572864 pages of RAM
[ 6785.228706] 566471 reserved pages
[ 6785.228706] 652569 pages shared
[ 6785.228706] 1 pages swap cached
[ 6785.228706] Out of memory: kill process 8405 (mutt) score 5096 or a child
[ 6785.228706] Killed process 8405 (mutt)
[ 6789.051344] pan invoked oom-killer: gfp_mask=0x1200d2, order=0, oomkilladj=0
[ 6789.051435] Pid: 6957, comm: pan Not tainted 2.6.26-rc5-mm2 #2
[ 6789.051500] 
[ 6789.051501] Call Trace:
[ 6789.051609]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
[ 6789.051662]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
[ 6789.051662]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
[ 6789.051662]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
[ 6789.051662]  [<ffffffff802830cc>] read_swap_cache_async+0x9c/0xf0
[ 6789.051662]  [<ffffffff8028319a>] swapin_readahead+0x7a/0xb0
[ 6789.051662]  [<ffffffff80467ef0>] ? _spin_unlock+0x30/0x60
[ 6789.051662]  [<ffffffff80278b9f>] handle_mm_fault+0x46f/0x780
[ 6789.051662]  [<ffffffff802213a0>] ? do_page_fault+0x210/0x8d0
[ 6789.051662]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
[ 6789.051662]  [<ffffffff8046842d>] error_exit+0x0/0xa9
[ 6789.051733]  [<ffffffff8020ace0>] ? do_notify_resume+0x400/0x940
[ 6789.051799]  [<ffffffff8020ac53>] ? do_notify_resume+0x373/0x940
[ 6789.051868]  [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
[ 6789.051933]  [<ffffffff80468022>] ? _spin_unlock_irqrestore+0x42/0x80
[ 6789.052002]  [<ffffffff80247dc6>] ? remove_wait_queue+0x36/0x50
[ 6789.052069]  [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
[ 6789.052138]  [<ffffffff804675f7>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 6789.052207]  [<ffffffff8020b75d>] ? sysret_signal+0x21/0x31
[ 6789.052271]  [<ffffffff8020ba57>] ? ptregscall_common+0x67/0xb0
[ 6789.052337] 
[ 6789.052382] Mem-info:
[ 6789.052431] DMA per-cpu:
[ 6789.052481] CPU    0: hi:    0, btch:   1 usd:   0
[ 6789.052647] CPU    1: hi:    0, btch:   1 usd:   0
[ 6789.052706] DMA32 per-cpu:
[ 6789.052758] CPU    0: hi:  186, btch:  31 usd: 170
[ 6789.052823] CPU    1: hi:  186, btch:  31 usd:   0
[ 6789.052883] Normal per-cpu:
[ 6789.052933] CPU    0: hi:  186, btch:  31 usd: 174
[ 6789.052993] CPU    1: hi:  186, btch:  31 usd: 127
[ 6789.053055] Active_anon:0 active_file:546753 inactive_anon3
[ 6789.053056]  inactive_file:400462 dirty:20776 writeback:0 unstable:0
[ 6789.053057]  free:5684 slab:45813 mapped:8 pagetables:293 bounce:0
[ 6789.053251] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
[ 6789.053426] lowmem_reserve[]: 0 1975 3995 3995
[ 6789.053510] DMA32 free:12048kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:1060096kB inactive_file:762452kB present:2023200kB pages_scanned:42193 all_unreclaimable? no
[ 6789.053694] lowmem_reserve[]: 0 0 2020 2020
[ 6789.053811] Normal free:3964kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:12kB active_file:1126916kB inactive_file:839396kB present:2068480kB pages_scanned:62177 all_unreclaimable? no
[ 6789.053996] lowmem_reserve[]: 0 0 0 0
[ 6789.054077] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
[ 6789.054253] DMA32: 1528*4kB 7*8kB 4*16kB 1*32kB 27*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 12088kB
[ 6789.054439] Normal: 31*4kB 0*8kB 0*16kB 2*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3964kB
[ 6789.054646] 675699 total pagecache pages
[ 6789.054703] Swap cache: add 3407293, delete 3407282, find 2579/2851
[ 6789.054769] Free swap  = 9769312kB
[ 6789.054828] Total swap = 9775512kB
[ 6789.075440] 1572864 pages of RAM
[ 6789.075501] 566471 reserved pages
[ 6789.075555] 652638 pages shared
[ 6789.075607] 11 pages swap cached
[ 6789.077178] Out of memory: kill process 4807 (ssu) score 4485 or a child
[ 6789.077254] Killed process 4808 (bash)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
