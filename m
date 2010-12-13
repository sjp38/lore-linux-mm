Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 173466B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 12:16:48 -0500 (EST)
Subject: Re: 2.6.36.2 reliably panics in VFS
From: Peter Steiner <sp@med-2-med.com>
In-Reply-To: <20101213170003.D35666FD97@nx.neverkill.us>
References: <20101212113004.94FA96FD97@nx.neverkill.us>
	 <20101213170003.D35666FD97@nx.neverkill.us>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 13 Dec 2010 18:16:49 +0100
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <20101213171621.F0E946FD97@nx.neverkill.us>
Sender: owner-linux-mm@kvack.org
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Cc: viro@zeniv.linux.org.uk, linux-mm@kvack.org, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Mon, 2010-12-13 at 08:49 -0800, Sarah Sharp wrote:
> On Sun, Dec 12, 2010 at 12:26:48PM +0100, Peter Steiner wrote:
> > Hi
> > 
> > compiled latest 2.6.36.2 but it reliably panics() my machine.
> > It happens if I try to dd sda to sdb (backup) using xhci USB3.0
> > (conceptronic CUSB3EXC) but ALSO using native USB 2.0 ports on the
> > machine - after 10-15 minutes of dd.
> 
> Can you run lspci -v and lsusb?  I'm wondering if the USB 2.0 ports are
> part of an EHCI host controller or an xHCI host controller.

USB 2.0 is built in controller, so they are EHCI.

The usb 3.0 ports are on a conceptronic CUSB3EXC ExpressCard expansion
card as I already mentioned. I've the card not at hand now, so here
lspci & lsusb WITHOUT the USB 3.0 card:


00:00.0 Host bridge: Intel Corporation Mobile 945GM/PM/GMS, 943/940GML
and 945GT Express Memory Controller Hub (rev 03)
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, fast devsel, latency 0
        Capabilities: [e0] Vendor Specific Information: Len=09 <?>
        Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation Mobile 945GM/GMS,
943/940GML Express Integrated Graphics Controller (rev 03) (prog-if 00
[VGA controller])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, fast devsel, latency 0, IRQ 16
        Memory at e8400000 (32-bit, non-prefetchable) [size=512K]
        I/O ports at 6000 [size=8]
        Memory at d0000000 (32-bit, prefetchable) [size=256M]
        Memory at e8480000 (32-bit, non-prefetchable) [size=256K]
        Expansion ROM at <unassigned> [disabled]
        Capabilities: [90] MSI: Enable- Count=1/1 Maskable- 64bit-
        Capabilities: [d0] Power Management version 2
        Kernel driver in use: i915

00:02.1 Display controller: Intel Corporation Mobile 945GM/GMS/GME,
943/940GML Express Integrated Graphics Controller (rev 03)
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, fast devsel, latency 0
        Memory at e8500000 (32-bit, non-prefetchable) [size=512K]
        Capabilities: [d0] Power Management version 2

00:1b.0 Audio device: Intel Corporation N10/ICH 7 Family High Definition
Audio Controller (rev 01)
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, fast devsel, latency 0, IRQ 41
        Memory at e8580000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 2
        Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [70] Express Root Complex Integrated Endpoint, MSI
00
        Capabilities: [100] Virtual Channel
        Capabilities: [130] Root Complex Link
        Kernel driver in use: HDA Intel

00:1c.0 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port
1 (rev 01) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=08, subordinate=08, sec-latency=0
        I/O behind bridge: 00007000-00007fff
        Memory behind bridge: e8000000-e80fffff
        Prefetchable memory behind bridge:
00000000cf800000-00000000cf9fffff
        Capabilities: [40] Express Root Port (Slot+), MSI 00
        Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
        Capabilities: [90] Subsystem: Hewlett-Packard Company Device
30aa
        Capabilities: [a0] Power Management version 2
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Root Complex Link

00:1c.2 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port
3 (rev 01) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=18, subordinate=18, sec-latency=0
        I/O behind bridge: 00004000-00005fff
        Memory behind bridge: e4000000-e7ffffff
        Prefetchable memory behind bridge:
00000000cfa00000-00000000cfbfffff
        Capabilities: [40] Express Root Port (Slot+), MSI 00
        Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
        Capabilities: [90] Subsystem: Hewlett-Packard Company Device
30aa
        Capabilities: [a0] Power Management version 2
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Root Complex Link

00:1c.3 PCI bridge: Intel Corporation N10/ICH 7 Family PCI Express Port
4 (rev 01) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=20, subordinate=20, sec-latency=0
        I/O behind bridge: 00002000-00003fff
        Memory behind bridge: e0000000-e3ffffff
        Prefetchable memory behind bridge:
00000000cfc00000-00000000cfdfffff
        Capabilities: [40] Express Root Port (Slot+), MSI 00
        Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
        Capabilities: [90] Subsystem: Hewlett-Packard Company Device
30aa
        Capabilities: [a0] Power Management version 2
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Root Complex Link

00:1d.0 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI
Controller #1 (rev 01) (prog-if 00 [UHCI])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0, IRQ 20
        I/O ports at 6020 [size=32]
        Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI
Controller #2 (rev 01) (prog-if 00 [UHCI])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0, IRQ 21
        I/O ports at 6040 [size=32]
        Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI
Controller #3 (rev 01) (prog-if 00 [UHCI])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0, IRQ 18
        I/O ports at 6060 [size=32]
        Kernel driver in use: uhci_hcd

00:1d.3 USB Controller: Intel Corporation N10/ICH 7 Family USB UHCI
Controller #4 (rev 01) (prog-if 00 [UHCI])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0, IRQ 19
        I/O ports at 6080 [size=32]
        Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation N10/ICH 7 Family USB2 EHCI
Controller (rev 01) (prog-if 20 [EHCI])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0, IRQ 20
        Memory at e8584000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Debug port: BAR=1 offset=00a0
        Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e1)
(prog-if 01 [Subtractive decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=02, subordinate=06, sec-latency=32
        I/O behind bridge: 00008000-00008fff
        Memory behind bridge: e8100000-e83fffff
        Prefetchable memory behind bridge:
00000000ec000000-00000000efffffff
        Capabilities: [50] Subsystem: Hewlett-Packard Company Device
30aa

00:1f.0 ISA bridge: Intel Corporation 82801GBM (ICH7-M) LPC Interface
Bridge (rev 01)
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0
        Capabilities: [e0] Vendor Specific Information: Len=0c <?>

00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE
Controller (rev 01) (prog-if 8a [Master SecP PriP])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 0, IRQ 16
        I/O ports at 01f0 [size=8]
        I/O ports at 03f4 [size=1]
        I/O ports at 0170 [size=8]
        I/O ports at 0374 [size=1]
        I/O ports at 60a0 [size=16]
        Kernel driver in use: ata_piix

00:1f.2 SATA controller: Intel Corporation 82801GBM/GHM (ICH7 Family)
SATA AHCI Controller (rev 01) (prog-if 01 [AHCI 1.0])
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, 66MHz, medium devsel, latency 0, IRQ 40
        I/O ports at 13f0 [size=8]
        I/O ports at 15f4 [size=4]
        I/O ports at 1370 [size=8]
        I/O ports at 1574 [size=4]
        I/O ports at 60d0 [size=16]
        Memory at e8585000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
        Capabilities: [70] Power Management version 2
        Kernel driver in use: ahci

02:06.0 CardBus bridge: Texas Instruments PCIxx12 Cardbus Controller
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 168, IRQ 18
        Memory at e8100000 (32-bit, non-prefetchable) [size=4K]
        Bus: primary=02, secondary=03, subordinate=06, sec-latency=176
        Memory window 0: ec000000-effff000 (prefetchable)
        Memory window 1: f0000000-f3fff000
        I/O window 0: 00008000-000080ff
        I/O window 1: 00008400-000084ff
        16-bit legacy interface ports at 0001
        Kernel driver in use: yenta_cardbus

02:06.2 Mass storage controller: Texas Instruments 5-in-1 Multimedia
Card Reader (SD/MMC/MS/MS PRO/xD)
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 64, IRQ 19
        Memory at e8108000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [44] Power Management version 2
        Kernel driver in use: tifm_7xx1

02:06.3 SD Host controller: Texas Instruments PCIxx12 SDA Standard
Compliant SD Host Controller
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, medium devsel, latency 64, IRQ 22
        Memory at e8109000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [80] Power Management version 2
        Kernel driver in use: sdhci-pci

02:06.4 Communication controller: Texas Instruments PCIxx12 GemCore
based SmartCard controller
        Subsystem: Hewlett-Packard Company nc6310
        Flags: medium devsel, IRQ 10
        Memory at e810a000 (32-bit, non-prefetchable) [size=4K]
        Memory at e810b000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [44] Power Management version 2

02:0e.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5788
Gigabit Ethernet (rev 03)
        Subsystem: Hewlett-Packard Company Device 30aa
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
        Memory at e8110000 (32-bit, non-prefetchable) [size=64K]
        Expansion ROM at <ignored> [disabled]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
        Kernel driver in use: tg3

08:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG
[Golan] Network Connection (rev 02)
        Subsystem: Hewlett-Packard Company Compaq 6710b or nx9420
Notebook
        Flags: bus master, fast devsel, latency 0, IRQ 11
        Memory at e8000000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
        Capabilities: [e0] Express Legacy Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 00-1b-77-ff-ff-70-85-a0



Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         0 Full speed (or root) hub
  bMaxPacketSize0        64
  idVendor           0x1d6b Linux Foundation
  idProduct          0x0002 2.0 root hub
  bcdDevice            2.06
  iManufacturer           3 Linux 2.6.36.2 ehci_hcd
  iProduct                2 EHCI Host Controller
  iSerial                 1 0000:00:1d.7
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           25
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower                0mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      0 Full speed (or root) hub
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0004  1x 4 bytes
        bInterval              12
Hub Descriptor:
  bLength              11
  bDescriptorType      41
  nNbrPorts             8
  wHubCharacteristic 0x000a
    No power switching (usb 1.0)
    Per-port overcurrent protection
  bPwrOn2PwrGood       10 * 2 milli seconds
  bHubContrCurrent      0 milli Ampere
  DeviceRemovable    0x00 0x00
  PortPwrCtrlMask    0xff 0xff
 Hub Port Status:
   Port 1: 0000.0503 highspeed power enable connect
   Port 2: 0000.0100 power
   Port 3: 0000.0503 highspeed power enable connect
   Port 4: 0000.0100 power
   Port 5: 0000.0100 power
   Port 6: 0000.0100 power
   Port 7: 0000.0100 power
   Port 8: 0000.0100 power
Device Status:     0x0003
  Self Powered
  Remote Wakeup Enabled

Bus 001 Device 002: ID 0424:2503 Standard Microsystems Corp. USB 2.0 Hub
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         2 TT per port
  bMaxPacketSize0        64
  idVendor           0x0424 Standard Microsystems Corp.
  idProduct          0x2503 USB 2.0 Hub
  bcdDevice            0.01
  iManufacturer           0 
  iProduct                0 
  iSerial                 0 
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           41
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower                2mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      1 Single TT
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0001  1x 1 bytes
        bInterval              12
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       1
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      2 TT per port
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0001  1x 1 bytes
        bInterval              12
Hub Descriptor:
  bLength               9
  bDescriptorType      41
  nNbrPorts             3
  wHubCharacteristic 0x000d
    Per-port power switching
    Compound device
    Per-port overcurrent protection
    TT think time 8 FS bits
  bPwrOn2PwrGood       50 * 2 milli seconds
  bHubContrCurrent      1 milli Ampere
  DeviceRemovable    0x0e
  PortPwrCtrlMask    0xff
 Hub Port Status:
   Port 1: 0000.0100 power
   Port 2: 0000.0103 power enable connect
   Port 3: 0000.0100 power
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         0 Full speed (or root) hub
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0001
  Self Powered

Bus 001 Device 003: ID 0bda:8187 Realtek Semiconductor Corp. RTL8187
Wireless Adapter
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0 
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x0bda Realtek Semiconductor Corp.
  idProduct          0x8187 RTL8187 Wireless Adapter
  bcdDevice            1.00
  iManufacturer           1 Manufacturer_Realtek_RTL8187_
  iProduct                2 RTL8187_Wireless_LAN_Adapter
  iSerial                 3 00C0CA1B8330
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           39
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          4 Wireless Network Card
    bmAttributes         0x80
      (Bus Powered)
    MaxPower              500mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass         0 (Defined at Interface level)
      bInterfaceSubClass      0 
      bInterfaceProtocol      0 
      iInterface              5 Bulk-IN,Bulk-OUT,Bulk-OUT
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0 
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0000
  (Bus Powered)

Bus 001 Device 004: ID 08ff:2580 AuthenTec, Inc. AES2501 Fingerprint
Sensor
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol       255 Vendor Specific Protocol
  bMaxPacketSize0         8
  idVendor           0x08ff AuthenTec, Inc.
  idProduct          0x2580 AES2501 Fingerprint Sensor
  bcdDevice            6.23
  iManufacturer           0 
  iProduct                1 Fingerprint Sensor
  iSerial                 0 
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           32
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xa0
      (Bus Powered)
      Remote Wakeup
    MaxPower              100mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           2
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass    255 Vendor Specific Subclass
      bInterfaceProtocol    255 Vendor Specific Protocol
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0020  1x 32 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval               0
Device Status:     0x0000
  (Bus Powered)

Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         0 Full speed (or root) hub
  bMaxPacketSize0        64
  idVendor           0x1d6b Linux Foundation
  idProduct          0x0001 1.1 root hub
  bcdDevice            2.06
  iManufacturer           3 Linux 2.6.36.2 uhci_hcd
  iProduct                2 UHCI Host Controller
  iSerial                 1 0000:00:1d.0
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           25
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower                0mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      0 Full speed (or root) hub
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0002  1x 2 bytes
        bInterval             255
Hub Descriptor:
  bLength               9
  bDescriptorType      41
  nNbrPorts             2
  wHubCharacteristic 0x000a
    No power switching (usb 1.0)
    Per-port overcurrent protection
  bPwrOn2PwrGood        1 * 2 milli seconds
  bHubContrCurrent      0 milli Ampere
  DeviceRemovable    0x00
  PortPwrCtrlMask    0xff
 Hub Port Status:
   Port 1: 0000.0100 power
   Port 2: 0000.0100 power
Device Status:     0x0003
  Self Powered
  Remote Wakeup Enabled

Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         0 Full speed (or root) hub
  bMaxPacketSize0        64
  idVendor           0x1d6b Linux Foundation
  idProduct          0x0001 1.1 root hub
  bcdDevice            2.06
  iManufacturer           3 Linux 2.6.36.2 uhci_hcd
  iProduct                2 UHCI Host Controller
  iSerial                 1 0000:00:1d.1
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           25
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower                0mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      0 Full speed (or root) hub
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0002  1x 2 bytes
        bInterval             255
Hub Descriptor:
  bLength               9
  bDescriptorType      41
  nNbrPorts             2
  wHubCharacteristic 0x000a
    No power switching (usb 1.0)
    Per-port overcurrent protection
  bPwrOn2PwrGood        1 * 2 milli seconds
  bHubContrCurrent      0 milli Ampere
  DeviceRemovable    0x00
  PortPwrCtrlMask    0xff
 Hub Port Status:
   Port 1: 0000.0100 power
   Port 2: 0000.0100 power
Device Status:     0x0003
  Self Powered
  Remote Wakeup Enabled

Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         0 Full speed (or root) hub
  bMaxPacketSize0        64
  idVendor           0x1d6b Linux Foundation
  idProduct          0x0001 1.1 root hub
  bcdDevice            2.06
  iManufacturer           3 Linux 2.6.36.2 uhci_hcd
  iProduct                2 UHCI Host Controller
  iSerial                 1 0000:00:1d.2
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           25
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower                0mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      0 Full speed (or root) hub
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0002  1x 2 bytes
        bInterval             255
Hub Descriptor:
  bLength               9
  bDescriptorType      41
  nNbrPorts             2
  wHubCharacteristic 0x000a
    No power switching (usb 1.0)
    Per-port overcurrent protection
  bPwrOn2PwrGood        1 * 2 milli seconds
  bHubContrCurrent      0 milli Ampere
  DeviceRemovable    0x00
  PortPwrCtrlMask    0xff
 Hub Port Status:
   Port 1: 0000.0100 power
   Port 2: 0000.0100 power
Device Status:     0x0003
  Self Powered
  Remote Wakeup Enabled

Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               1.10
  bDeviceClass            9 Hub
  bDeviceSubClass         0 Unused
  bDeviceProtocol         0 Full speed (or root) hub
  bMaxPacketSize0        64
  idVendor           0x1d6b Linux Foundation
  idProduct          0x0001 1.1 root hub
  bcdDevice            2.06
  iManufacturer           3 Linux 2.6.36.2 uhci_hcd
  iProduct                2 UHCI Host Controller
  iSerial                 1 0000:00:1d.3
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           25
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          0 
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower                0mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         9 Hub
      bInterfaceSubClass      0 Unused
      bInterfaceProtocol      0 Full speed (or root) hub
      iInterface              0 
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0002  1x 2 bytes
        bInterval             255
Hub Descriptor:
  bLength               9
  bDescriptorType      41
  nNbrPorts             2
  wHubCharacteristic 0x000a
    No power switching (usb 1.0)
    Per-port overcurrent protection
  bPwrOn2PwrGood        1 * 2 milli seconds
  bHubContrCurrent      0 milli Ampere
  DeviceRemovable    0x00
  PortPwrCtrlMask    0xff
 Hub Port Status:
   Port 1: 0000.0100 power
   Port 2: 0000.0100 power
Device Status:     0x0003
  Self Powered
  Remote Wakeup Enabled


> 
> > Please see attached screenshot (I cannot copy it as text as it takes
> > down the machine and locks up in text console, so I can only make a
> > foto).
> 
> Can you run netconsole to capture more of the messages before that?  If
> you need help with setting up netconsole, see:
> 	http://sarah.thesharps.us/2010-03-26-09-41
> 

I'm afraid I lack the time to play with kernel setup... :(

> > see attached .config.
> > 
> > The bug did NOT happen on 2.6.35.7 - however there the USB3.0 xhci
> > frequently disconnects the sdb backup disk and dd fails after 400GB of
> > copy or so (but no panic).
> 
> Would this happen to be on a Lenovo W510 laptop?  I've received reports
> of different oopses caused by disconnects, while running 2.6.35.8:
> 
> http://marc.info/?l=linux-kernel&m=129131271416325&w=2
> 
> Do you see panics or oopses when you run 2.6.35.8?  Or did you just
> upgrade straight from 2.6.35.7 to 2.6.36.2?

upgraded from 2.6.35.7 to 2.6.36 => panics
so then upgraded from 2.6.36 to 2.6.36.2 => same panic() while dd

As I said this happens equally if I connect my backup station to either
native USB 2.0 (USB3.0 NOT plugged in!) or the conceptronics USB 3.0.
The backup station is Sharkoon SATA Quickport 3.0.

Hope this helps.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
