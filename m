Received: (from koconnor@localhost)
	by armstrong.cse.Buffalo.EDU (8.10.1/8.10.1) id e5BHA2U15796
	for linux-mm@kvack.org; Sun, 11 Jun 2000 13:10:02 -0400 (EDT)
Date: Sun, 11 Jun 2000 13:10:02 -0400
From: "Kevin O'Connor" <koconnor@cse.Buffalo.EDU>
Subject: 2.4.0-ac13 reproducible kswapd oops
Message-ID: <20000611131002.A15728@armstrong.cse.Buffalo.EDU>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=X1bOJ3K7DJ5YkBrT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii

I am able to reliably crash ac13 on my ABIT bp6 dual celeron machine.  The
procedure I used is the following:

boot machine
login as root
umount /dev/hde1
fsck -f /dev/hde1

The fsck completes around 5-10% before causing a kernel panic.
/dev/hde1 is mounted on /usr/src and is not used for any critical
resources.  The hde1 interface uses the HPT366 IDE interface, while the
root directory (/dev/hda) uses the Intel chipset.  DMA is enabled at boot;
no manual hdparm modifications have been made.


I am including as attachments:

IDE bootup messages
ksymoops output (from hand-copied kernel OOPS)
lspci
/proc/cpuinfo
/proc/modules
/proc/version

-Kevin

-- 
 ------------------------------------------------------------------------
 | Kevin O'Connor                     "BTW, IMHO we need a FAQ for      |
 | koconnor@cse.buffalo.edu            'IMHO', 'FAQ', 'BTW', etc. !"    |
 ------------------------------------------------------------------------

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain
Content-Disposition: attachment; filename="newoops.txt"

ksymoops 0.7c on i686 2.4.0-test1-ac13.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.0-test1-ac13/ (default)
     -m /usr/src/linux/System.map (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

invalid operand: 0000
CPU:    0
EIP:    0010:[<c0139957>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 0000001d   ebx: c0228504     ecx: 00000009       edx:c022560c
esi: c7d5c5c0   edi: c7d5c5c0     ebp: c7d5c5c0       esp:c129df70
ds: 0018        es: 0018       ss: 0018
Process kswapd (pid: 2, stackpage=c129d000)
Stack: c01e84e4 c01e88ba 0000098b c12531b8 c12531d4 0000001a0 0000003e 00000018
       00000003 c01285a7 c12531b8 00000000 00000002 000000040 c02265e0 00000004
       00000000 c0130b1a 00000040 00000004 c02265e0 000000001 c02265e0 c129c000
Call Trace: [<c01e84e4>] [<c01e88ba>] [<c01285a7>] [<c0130b1a>] [<c0130c40>] [<c0108f70>]
Code: 0f 0b 83 c4 0c 8d 74 26 00 56 e8 12 d2 ff ff 83 c4 04 eb 13

>>EIP; c0139957 <try_to_free_buffers+bf/234>   <=====
Trace; c01e84e4 <tvecs+4d5c/11c58>
Trace; c01e88ba <tvecs+5132/11c58>
Trace; c01285a7 <shrink_mmap+f7/36c>
Trace; c0130b1a <do_try_to_free_pages+46/e4>
Trace; c0130c40 <kswapd+88/bc>
Trace; c0108f70 <kernel_thread+28/38>
Code;  c0139957 <try_to_free_buffers+bf/234>
00000000 <_EIP>:
Code;  c0139957 <try_to_free_buffers+bf/234>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c0139959 <try_to_free_buffers+c1/234>
   2:   83 c4 0c                  add    $0xc,%esp
Code;  c013995c <try_to_free_buffers+c4/234>
   5:   8d 74 26 00               lea    0x0(%esi,1),%esi
Code;  c0139960 <try_to_free_buffers+c8/234>
   9:   56                        push   %esi
Code;  c0139961 <try_to_free_buffers+c9/234>
   a:   e8 12 d2 ff ff            call   ffffd221 <_EIP+0xffffd221> c0136b78 <__remove_from_queues+0/34>
Code;  c0139966 <try_to_free_buffers+ce/234>
   f:   83 c4 04                  add    $0x4,%esp
Code;  c0139969 <try_to_free_buffers+d1/234>
  12:   eb 13                     jmp    27 <_EIP+0x27> c013997e <try_to_free_buffers+e6/234>


1 warning issued.  Results may not be reliable.

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain
Content-Disposition: attachment; filename="cpuinfo.txt"

processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 6
model name	: Celeron (Mendocino)
stepping	: 5
cpu MHz		: 367.502950
cache size	: 128 KB
fdiv_bug	: no
hlt_bug		: no
sep_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr
bogomips	: 732.36

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 6
model name	: Celeron (Mendocino)
stepping	: 5
cpu MHz		: 367.502950
cache size	: 128 KB
fdiv_bug	: no
hlt_bug		: no
sep_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr
bogomips	: 734.00


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain
Content-Disposition: attachment; filename="ideboot.txt"

Jun 11 03:04:51 ohio kernel: ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
Jun 11 03:04:51 ohio kernel: PIIX4: IDE controller on PCI bus 00 dev 39
Jun 11 03:04:51 ohio kernel: PIIX4: chipset revision 1
Jun 11 03:04:51 ohio rc: Starting linuxconf succeeded
Jun 11 03:04:51 ohio kernel: PIIX4: not 100% native mode: will probe irqs later
Jun 11 03:04:51 ohio kernel:     ide0: BM-DMA at 0xf000-0xf007, BIOS settings: hda:DMA, hdb:pio
Jun 11 03:04:51 ohio kernel:     ide1: BM-DMA at 0xf008-0xf00f, BIOS settings: hdc:pio, hdd:pio
Jun 11 03:04:51 ohio kernel: HPT366: onboard version of chipset, pin1=1 pin2=2
Jun 11 03:04:51 ohio kernel: HPT366: IDE controller on PCI bus 00 dev 98
Jun 11 03:04:51 ohio kernel: HPT366: chipset revision 1
Jun 11 03:04:51 ohio kernel: HPT366: not 100% native mode: will probe irqs later
Jun 11 03:04:51 ohio kernel:     ide2: BM-DMA at 0xd400-0xd407, BIOS settings: hde:DMA, hdf:pio
Jun 11 03:04:51 ohio kernel: HPT366: IDE controller on PCI bus 00 dev 99
Jun 11 03:04:51 ohio kernel: HPT366: chipset revision 1
Jun 11 03:04:52 ohio kernel: HPT366: not 100% native mode: will probe irqs later
Jun 11 03:04:52 ohio kernel:     ide3: BM-DMA at 0xe000-0xe007, BIOS settings: hdg:pio, hdh:pio
Jun 11 03:04:52 ohio kernel: hda: WDC AC28400R, ATA DISK drive
Jun 11 03:04:52 ohio kernel: hdd: Hewlett-Packard CD-Writer Plus 8100, ATAPI CDROM drive
Jun 11 03:04:52 ohio kernel: hde: Maxtor 52049U4, ATA DISK drive
Jun 11 03:04:52 ohio kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Jun 11 03:04:52 ohio kernel: ide1 at 0x170-0x177,0x376 on irq 15
Jun 11 03:04:52 ohio kernel: ide2 at 0xcc00-0xcc07,0xd002 on irq 18
Jun 11 03:04:52 ohio kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Jun 11 03:04:52 ohio kernel: ide1 at 0x170-0x177,0x376 on irq 15
Jun 11 03:04:52 ohio kernel: ide2 at 0xcc00-0xcc07,0xd002 on irq 18
Jun 11 03:04:52 ohio kernel: hda: 16514064 sectors (8455 MB) w/512KiB Cache, CHS=16383/16/63, UDMA(33)
Jun 11 03:04:52 ohio kernel: hde: 40020624 sectors (20491 MB) w/2048KiB Cache, CHS=39703/16/63, UDMA(66)
Jun 11 03:04:52 ohio kernel: Partition check:
Jun 11 03:04:52 ohio kernel:  hda: hda1 hda2 < hda5 hda6 >
Jun 11 03:04:52 ohio kernel:  hde: hde1

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain
Content-Disposition: attachment; filename="modules.txt"

nfsd                   48456   0 (autoclean)
lockd                  44084   0 (autoclean) [nfsd]
sunrpc                 67364   0 (autoclean) [nfsd lockd]
8139too                15640   1 (autoclean)
unix                   19108   6 (autoclean)

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain
Content-Disposition: attachment; filename="pci.txt"

00:00.0 Host bridge: Intel Corporation 440BX/ZX - 82443BX/ZX Host bridge (rev 03)
00:01.0 PCI bridge: Intel Corporation 440BX/ZX - 82443BX/ZX AGP bridge (rev 03)
00:07.0 ISA bridge: Intel Corporation 82371AB PIIX4 ISA (rev 02)
00:07.1 IDE interface: Intel Corporation 82371AB PIIX4 IDE (rev 01)
00:07.2 USB Controller: Intel Corporation 82371AB PIIX4 USB (rev 01)
00:07.3 Bridge: Intel Corporation 82371AB PIIX4 ACPI (rev 02)
00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
00:0d.0 Multimedia audio controller: Ensoniq ES1371 [AudioPCI-97] (rev 06)
00:13.0 Unknown mass storage controller: Triones Technologies, Inc. HPT366 (rev 01)
00:13.1 Unknown mass storage controller: Triones Technologies, Inc. HPT366 (rev 01)
01:00.0 VGA compatible controller: Matrox Graphics, Inc. MGA G400 AGP (rev 04)

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain
Content-Disposition: attachment; filename="version.txt"

Linux version 2.4.0-test1-ac13 (kevin@ohio.localdomain) (gcc version 2.95.2 19991024 (release)) #1 SMP Sun Jun 11 02:37:37 EDT 2000

--X1bOJ3K7DJ5YkBrT--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
