Received: from mail.serc.iisc.ernet.in (serc.iisc.ernet.in [10.16.25.10])
	by relay.iisc.ernet.in (8.13.1/8.13.1) with ESMTP id m69EDH18021373
	for <linux-mm@kvack.org>; Wed, 9 Jul 2008 19:43:17 +0530
Received: from mail.serc.iisc.ernet.in (mail.serc.iisc.ernet.in [10.16.25.10])
	by mail.serc.iisc.ernet.in (8.13.1/8.13.1) with ESMTP id m69ERe4n015242
	for <linux-mm@kvack.org>; Wed, 9 Jul 2008 19:57:40 +0530
Message-ID: <2206.10.16.10.158.1215613660.squirrel@mail.serc.iisc.ernet.in>
Date: Wed, 9 Jul 2008 19:57:40 +0530 (IST)
Subject: [Bug]: Oops on ppc64 2.6.5-7.244-pseries64 in mm/objrmap.c
From: kiran@serc.iisc.ernet.in
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------

System crashes with Oops message "kernel: kernel BUG
in page_add_rmap
at mm/objrmap.c"

Full Description of the problem:
--------------------------------------------

This problem is reported for a particular user
executable and it will
be always at 4:15 am when cron.daily runs. After this
system will
crash.

key words:
----------------

Related to kernel virtual memory issue

Output of Oops:
----------------------

==============================
# ksymoops -k /proc/kallsyms </tmp/the_oops.txt
ksymoops 2.4.9 on ppc64 2.6.5-7.244-pseries64.
Options used
-V (default)
-k /proc/kallsyms (specified)
-l /proc/modules (default)
-o /lib/modules/2.6.5-7.244-pseries64/ (default)
-m /boot/System.map-2.6.5-7.244-pseries64
(default)

Warning (read_ksyms): no kernel symbols in ksyms, is
/proc/kallsyms a
valid ksyms file?
No modules in ksyms, skipping objects
No ksyms, skipping lsmod
May 19 04:15:02 cnode41 kernel: kernel BUG in
page_add_rmap at mm/
objrmap.c:325!
May 19 04:15:02 cnode41 kernel: Oops: Exception in
kernel mode, sig: 5
[#1]
May 19 04:15:02 cnode41 kernel: NIP: C0000000000BB02C
XER:
0000000000000000 LR: C0000000000B0198
Using defaults from ksymoops -t elf32-powerpc -a
powerpc:common
May 19 04:15:02 cnode41 kernel: MSR: 8000000000029032
EE: 1 PR: 0 FP:
0 ME: 1 IR/DR: 11
May 19 04:15:02 cnode41 kernel: TASK:
c00000004c8381c0[29042] 'a.out'
THREAD: c0000000423e4000 CPU: 6
May 19 04:15:02 cnode41 kernel: GPR00:
0000000000000000
C0000000423E7A10 C00000000071DCC8 C00000000189FC20
May 19 04:15:02 cnode41 kernel: GPR04:
C00000006E50D970
00000000100037D8 0000000000000000 0000000000000000
May 19 04:15:02 cnode41 kernel: GPR08:
8000000000009032
0000000000000001 0000000000000000 000000007263F900
May 19 04:15:02 cnode41 kernel: GPR12:
0000000028004488
C00000000049D000 00000000100289F0 0000000000000000
May 19 04:15:02 cnode41 kernel: GPR16:
0000000148CE5008
00000001494872A8 0000000148E38000 C000000054575200
May 19 04:15:02 cnode41 kernel: GPR20:
00000000000166A1
C00000006E6E8000 00000000100037D8 0000000000000000
May 19 04:15:02 cnode41 kernel: GPR24:
0000000000000000
C00000006E50D970 0000000010003000 0000000000000001
May 19 04:15:02 cnode41 kernel: GPR28:
000000043B5C0313
C00000000189FC20 C000000000622100 C000000003EC9018
May 19 04:15:02 cnode41 kernel: Call Trace:
May 19 04:15:02 cnode41 kernel: [c0000000423e7a10]
[c0000000000affa4] .do_no_page+0x31c/0xd90
(unreliable)
May 19 04:15:02 cnode41 kernel: [c0000000423e7b00]
[c0000000000b16bc] .handle_mm_fault+0x228/0x11f4
May 19 04:15:02 cnode41 kernel: [c0000000423e7bd0]
[c000000000046b40] .do_page_fault+0x4ec/0x714
May 19 04:15:02 cnode41 kernel: [c0000000423e7d10]
[c00000000000ae40]
InstructionAccess_common+0x114/0x118
Warning (Oops_read): Code line not seen, dumping what
data is
available

>>NIP; c0000000000bb02c <.page_add_rmap+1b4/220>
<=====
>>GPR2; c00000000071dcc8 <head+20/100>
>>GPR5; 100037d8 <__crc_journal_start+13fabc/15e971>
>>GPR8; 8000000000009032
<__crc_set_user_nice+7fffffff0018cf93/bfffffff00183f61>
>>GPR11; 7263f900 <__crc_dequeue_signal+463f3/1f6604>
>>GPR12; 28004488 <__crc_xprt_destroy+ec49/4d190e>
>>GPR13; c00000000049d000 <paca+c000/100000>
>>GPR14; 100289f0 <__crc_proc_root+6363/16d759>
>>GPR16; 0000000148ce5008
<__crc_set_user_nice+48e68f69/bfffffff00183f61>
>>GPR17; 00000001494872a8
<__crc_set_user_nice+4960b209/bfffffff00183f61>
>>GPR18; 0000000148e38000
<__crc_set_user_nice+48fbbf61/bfffffff00183f61>
>>GPR22; 100037d8 <__crc_journal_start+13fabc/15e971>
>>GPR26; 10003000 <__crc_journal_start+13f2e4/15e971>
>>GPR28; 000000043b5c0313
<__crc_set_user_nice+33b744274/bfffffff00183f61>
>>GPR30; c000000000622100 <map+28/90>

Trace; c0000000423e7a10 <END_OF_CODE+41a59a10/????>
Trace; c0000000000affa4 <.do_no_page+31c/d90>
Trace; c0000000423e7b00 <END_OF_CODE+41a59b00/????>
Trace; c0000000000b16bc <.handle_mm_fault+228/11f4>
Trace; c0000000423e7bd0 <END_OF_CODE+41a59bd0/????>
Trace; c000000000046b40 <.do_page_fault+4ec/714>
Trace; c0000000423e7d10 <END_OF_CODE+41a59d10/????>
Trace; c00000000000ae40
<InstructionAccess_common+114/118>

2 warnings issued. Results may not be reliable.
===================================

Environment:
-----------------------

We have IBM open power p720 cluster, running SLES 9
SP3.

Software:
-----------------------------

cnode41:/usr/src/linux # sh scripts/ver_linux
If some fields are empty or look unusual you may have
an old version.
Compare to the current minimal requirements in
Documentation/Changes.

Linux cnode41 2.6.5-7.244-pseries64 #1 SMP Mon Dec 12
18:32:25 UTC
2005 ppc64 ppc64 ppc64 GNU/Linux

Gnu C 3.3.3
Gnu make 3.80
binutils 2.15.90.0.1.1
util-linux 2.12
mount 2.12
module-init-tools 3.0-pre10
e2fsprogs 1.38
jfsutils 1.1.7
xfsprogs 2.6.25
quota-tools 3.11.
PPP 2.4.2
isdn4k-utils 3.4
nfs-utils 1.0.6
Linux C Library x 1 root root 1433982 Aug 9
2006 /lib/tls/
libc.so.6
Dynamic linker (ldd) 2.3.5
Linux C++ Library 5.0.6
Procps 3.2.5
Net-tools 1.60
Kbd 1.12
Sh-utils 5.2.1
Modules Loaded autofs evdev joydev st e1000
pata_pdc2027x
libata ehci_hcd ohci_hcd usbcore sg subfs dm_mod ipr
firmware_class
sr_mod sd_mod scsi_mod

Processor information
---------------------------------

processor : 0
cpu : POWER5 (gr)
clock : 1654.344000MHz
revision : 2.3

processor : 2
cpu : POWER5 (gr)
clock : 1654.344000MHz
revision : 2.3

processor : 4
cpu : POWER5 (gr)
clock : 1654.344000MHz
revision : 2.2

processor : 6
cpu : POWER5 (gr)
clock : 1654.344000MHz
revision : 2.2

timebase : 207048000
machine : CHRP IBM,9124-720

Module Informaiton:
-----------------------------

autofs 44336 4 - Live 0xd000000000c65000
evdev 31032 0 - Live 0xd000000000c4d000
joydev 31136 0 - Live 0xd000000000c44000
st 73080 0 - Live 0xd000000000bcb000
e1000 207268 0 - Live 0xd000000000c7a000
pata_pdc2027x 33524 1 - Live 0xd000000000bc1000
libata 99632 1 pata_pdc2027x, Live 0xd000000000c20000
ehci_hcd 62332 0 - Live 0xd000000000c0f000
ohci_hcd 45740 0 - Live 0xd000000000bb4000
usbcore 184636 4 ehci_hcd,ohci_hcd, Live
0xd000000000be0000
sg 74048 0 - Live 0xd000000000791000
subfs 29784 1 - Live 0xd00000000062c000
dm_mod 112104 7 - Live 0xd0000000000be000
ipr 107808 2 - Live 0xd0000000000e0000
firmware_class 31872 1 ipr, Live 0xd00000000006e000
sr_mod 44124 0 - Live 0xd00000000004a000
sd_mod 44352 3 - Live 0xd000000000057000
scsi_mod 197464 6 st,libata,sg,ipr,sr_mod,sd_mod, Live
0xd00000000008c000

Loaded driver and hardware information
---------------------------------------------------------

cat /proc/modules
autofs 44336 4 - Live 0xd000000000c65000
evdev 31032 0 - Live 0xd000000000c4d000
joydev 31136 0 - Live 0xd000000000c44000
st 73080 0 - Live 0xd000000000bcb000
e1000 207268 0 - Live 0xd000000000c7a000
pata_pdc2027x 33524 1 - Live 0xd000000000bc1000
libata 99632 1 pata_pdc2027x, Live 0xd000000000c20000
ehci_hcd 62332 0 - Live 0xd000000000c0f000
ohci_hcd 45740 0 - Live 0xd000000000bb4000
usbcore 184636 4 ehci_hcd,ohci_hcd, Live
0xd000000000be0000
sg 74048 0 - Live 0xd000000000791000
subfs 29784 1 - Live 0xd00000000062c000
dm_mod 112104 7 - Live 0xd0000000000be000
ipr 107808 2 - Live 0xd0000000000e0000
firmware_class 31872 1 ipr, Live 0xd00000000006e000
sr_mod 44124 0 - Live 0xd00000000004a000
sd_mod 44352 3 - Live 0xd000000000057000
scsi_mod 197464 6 st,libata,sg,ipr,sr_mod,sd_mod, Live
0xd00000000008c000
cnode41:/usr/src/linux # cat /proc/ioports
00000000-000fffff : /pci[at]800000020000002
000b0000-000bffff : PCI Bus 0000:d8
000c0000-000cffff : PCI Bus 0000:d0
000d0000-000dffff : PCI Bus 0000:c0
000e0000-000effff : PCI Bus 0000:cc
000eec00-000eec03 : 0000:cc:01.0
000eec00-000eec03 : pata_pdc2027x
000ef000-000ef003 : 0000:cc:01.0
000ef000-000ef003 : pata_pdc2027x
000ef400-000ef407 : 0000:cc:01.0
000ef400-000ef407 : pata_pdc2027x
000ef800-000ef807 : 0000:cc:01.0
000ef800-000ef807 : pata_pdc2027x
000efc00-000efc0f : 0000:cc:01.0
000efc00-000efc0f : pata_pdc2027x
000f0000-000fffff : PCI Bus 0000:c8
00100000-001fffff : /pci[at]800000020000003
001c0000-001cffff : PCI Bus 0001:d8
001d0000-001dffff : PCI Bus 0001:c0
001e0000-001effff : PCI Bus 0001:d0
001f0000-001fffff : PCI Bus 0001:c8
001ff800-001ff83f : 0001:c8:01.0
001ff800-001ff83f : e1000
001ffc00-001ffc3f : 0001:c8:01.1
001ffc00-001ffc3f : e1000

cat /proc/iomem
40080000000-400bfffffff : /pci[at]800000020000002
40080000000-4009fffffff : PCI Bus 0000:d8
400a0000000-400a7ffffff : PCI Bus 0000:d0
400a8000000-400afffffff : PCI Bus 0000:c0
400b0000000-400b7ffffff : PCI Bus 0000:cc
400b0000000-400b0003fff : 0000:cc:01.0
400b0000000-400b0003fff : pata_pdc2027x
400b8000000-400bfefffff : PCI Bus 0000:c8
400b8000000-400b8000fff : 0000:c8:01.1
400b8000000-400b8000fff : ohci_hcd
400b8001000-400b8001fff : 0000:c8:01.0
400b8001000-400b8001fff : ohci_hcd
400b8002000-400b80020ff : 0000:c8:01.2
400b8002000-400b80020ff : ehci_hcd
401c0000000-401ffffffff : /pci[at]800000020000003
401c0000000-401e7ffffff : PCI Bus 0001:d8
401e8000000-401efffffff : PCI Bus 0001:c0
401f0000000-401f7ffffff : PCI Bus 0001:d0
401f0000000-401f07fffff : 0001:d0:01.0
401f0800000-401f08fffff : 0001:d0:01.0
401f0900000-401f093ffff : 0001:d0:01.0
401f0900000-401f093ffff : ipr
401f8000000-401ffefffff : PCI Bus 0001:c8
401f8000000-401f803ffff : 0001:c8:01.1
401f8040000-401f807ffff : 0001:c8:01.1
401f8040000-401f807ffff : e1000
401f8080000-401f80bffff : 0001:c8:01.0
401f80c0000-401f80fffff : 0001:c8:01.0
401f80c0000-401f80fffff : e1000
401f8100000-401f811ffff : 0001:c8:01.1
401f8100000-401f811ffff : e1000
401f8120000-401f813ffff : 0001:c8:01.0
401f8120000-401f813ffff : e1000

PCI infomation
-------------------

lspci -vvv
0000:00:02.0 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=c0, subordinate=c3,
sec-latency=0
I/O behind bridge: 000d0000-000dffff
Memory behind bridge: e8000000-efffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset+ FastB2B-
Capabilities: [a0] <chain broken>

0000:00:02.2 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=c8, subordinate=cb,
sec-latency=0
I/O behind bridge: 000f0000-000fffff
Memory behind bridge: f8000000-ffefffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset- FastB2B-
Capabilities: [a0] <chain broken>

0000:00:02.3 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=cc, subordinate=cf,
sec-latency=0
I/O behind bridge: 000e0000-000effff
Memory behind bridge: f0000000-f7ffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset- FastB2B-
Capabilities: [a0] <chain broken>

0000:00:02.4 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=d0, subordinate=d3,
sec-latency=0
I/O behind bridge: 000c0000-000cffff
Memory behind bridge: e0000000-e7ffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset+ FastB2B-
Capabilities: [a0] <chain broken>

0000:00:02.6 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=d8, subordinate=db,
sec-latency=0
I/O behind bridge: 000b0000-000bffff
Memory behind bridge: c0000000-dfffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset+ FastB2B-
Capabilities: [a0] <chain broken>

0000:c8:01.0 USB Controller: NEC Corporation USB (rev
43) (prog-if 10
[OHCI])
Subsystem: NEC Corporation USB
Control: I/O- Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
Status: Cap+ 66Mhz- UDF- FastB2B- ParErr-
DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-

Latency: 72 (250ns min, 10500ns max), cache
line size 20
Interrupt: pin A routed to IRQ 133
Region 0: Memory at 00000400b8001000 (32-bit,
non-
prefetchable) [size=4K]
Capabilities: [40] Power Management version 2
Flags: PMEClk- DSI- D1+ D2+
AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
Status: D0 PME-Enable- DSel=0 DScale=0
PME-

0000:c8:01.1 USB Controller: NEC Corporation USB (rev
43) (prog-if 10
[OHCI])
Subsystem: NEC Corporation USB
Control: I/O- Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
Status: Cap+ 66Mhz- UDF- FastB2B- ParErr-
DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-

Latency: 72 (250ns min, 10500ns max), cache
line size 20
Interrupt: pin B routed to IRQ 133
Region 0: Memory at 00000400b8000000 (32-bit,
non-
prefetchable) [size=4K]
Capabilities: [40] Power Management version 2
Flags: PMEClk- DSI- D1+ D2+
AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
Status: D0 PME-Enable- DSel=0 DScale=0
PME-

0000:c8:01.2 USB Controller: NEC Corporation USB 2.0
(rev 04) (prog-if
20 [EHCI])
Subsystem: NEC Corporation USB 2.0
Control: I/O- Mem+ BusMaster+ SpecCycle-
MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B-
Status: Cap+ 66Mhz- UDF- FastB2B- ParErr-
DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-

Latency: 72 (4000ns min, 8500ns max), cache
line size 20
Interrupt: pin C routed to IRQ 133
Region 0: Memory at 00000400b8002000 (32-bit,
non-
prefetchable) [size=256]
Capabilities: [40] Power Management version 2
Flags: PMEClk- DSI- D1+ D2+
AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold-)
Status: D0 PME-Enable- DSel=0 DScale=0
PME-

0000:cc:01.0 Mass storage controller: Promise
Technology, Inc. 20275
(rev 01) (prog-if 85)
Subsystem: Promise Technology, Inc. 20275
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 72 (1000ns min, 4500ns max), cache
line size 20
Interrupt: pin A routed to IRQ 134
Region 0: I/O ports at ef400 [size=8]
Region 1: I/O ports at eec00 [size=4]
Region 2: I/O ports at ef800 [size=8]
Region 3: I/O ports at ef000 [size=4]
Region 4: I/O ports at efc00 [size=16]
Region 5: Memory at 00000400b0000000 (32-bit,
non-
prefetchable) [size=16K]
Capabilities: [60] Power Management version 1
Flags: PMEClk- DSI+ D1+ D2-
AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 PME-Enable- DSel=0 DScale=0
PME-

0001:00:02.0 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=c0, subordinate=c3,
sec-latency=0
I/O behind bridge: 000d0000-000dffff
Memory behind bridge: e8000000-efffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset+ FastB2B-
Capabilities: [a0] <chain broken>

0001:00:02.2 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=c8, subordinate=cb,
sec-latency=0
I/O behind bridge: 000f0000-000fffff
Memory behind bridge: f8000000-ffefffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset- FastB2B-
Capabilities: [a0] <chain broken>

0001:00:02.4 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=d0, subordinate=d3,
sec-latency=0
I/O behind bridge: 000e0000-000effff
Memory behind bridge: f0000000-f7ffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset- FastB2B-
Capabilities: [a0] <chain broken>

0001:00:02.6 PCI bridge: IBM EADS-X PCI-X to PCI-X
Bridge (rev 03)
(prog-if 0f)
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 248, cache line size 20
BIST result: 00
Region 0: Memory at <ignored> (64-bit,
prefetchable)
Bus: primary=00, secondary=d8, subordinate=db,
sec-latency=0
I/O behind bridge: 000c0000-000cffff
Memory behind bridge: c0000000-e7ffffff
Prefetchable memory behind bridge:
0000000000100000-0000000000000000
BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort-
>Reset+ FastB2B-
Capabilities: [a0] <chain broken>

0001:c8:01.0 Ethernet controller: Intel Corporation
82546EB Gigabit
Ethernet Controller (Copper) (rev 01)
Subsystem: IBM: Unknown device 0289
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-

Latency: 144 (63750ns min), cache line size 20
Interrupt: pin A routed to IRQ 165
Region 0: Memory at 00000401f8120000 (64-bit,
non-
prefetchable) [size=128K]
Region 2: Memory at 00000401f80c0000 (64-bit,
non-
prefetchable) [size=256K]
Region 4: I/O ports at 1ff800 [size=64]
Expansion ROM at 00000401f8080000 [disabled]
[size=256K]
Capabilities: [dc] Power Management version 2
Flags: PMEClk- DSI+ D1- D2-
AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 PME-Enable- DSel=0 DScale=1
PME-
Capabilities: [e4] PCI-X non-bridge device.
Command: DPERE- ERO- RBC=2 OST=0
Status: Bus=0 Dev=0 Func=0 64bit-
133MHz- SCD- USC-,
DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-
Capabilities: [f0]
Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
Address: 0000000000000000 Data: 0000

0001:c8:01.1 Ethernet controller: Intel Corporation
82546EB Gigabit
Ethernet Controller (Copper) (rev 01)
Subsystem: IBM: Unknown device 0289
Control: I/O+ Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-

Latency: 144 (63750ns min), cache line size 20
Interrupt: pin B routed to IRQ 166
Region 0: Memory at 00000401f8100000 (64-bit,
non-
prefetchable) [size=128K]
Region 2: Memory at 00000401f8040000 (64-bit,
non-
prefetchable) [size=256K]
Region 4: I/O ports at 1ffc00 [size=64]
Expansion ROM at 00000401f8000000 [disabled]
[size=256K]
Capabilities: [dc] Power Management version 2
Flags: PMEClk- DSI+ D1- D2-
AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 PME-Enable- DSel=0 DScale=1
PME-
Capabilities: [e4] PCI-X non-bridge device.
Command: DPERE- ERO- RBC=2 OST=0
Status: Bus=0 Dev=0 Func=0 64bit-
133MHz- SCD- USC-,
DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-
Capabilities: [f0]
Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
Address: 0000000000000000 Data: 0000

0001:d0:01.0 SCSI storage controller: Mylex
Corporation AcceleRAID
600/500/400/Sapphire support Device (rev 04)
Subsystem: IBM Dual Channel PCI-X U320 SCSI
Adapter
Control: I/O- Mem+ BusMaster+ SpecCycle-
MemWINV- VGASnoop-
ParErr+ Stepping- SERR+ FastB2B-
Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr-
DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
Latency: 144, cache line size 20
Interrupt: pin A routed to IRQ 167
BIST result: 00
Region 0: Memory at 00000401f0900000 (64-bit,
non-
prefetchable) [size=256K]
Region 2: Memory at 00000401f0000000 (64-bit,
prefetchable)
[size=8M]
Expansion ROM at 00000401f0800000 [disabled]
[size=1M]
Capabilities: [40] PCI-X non-bridge device.
Command: DPERE- ERO- RBC=3 OST=3
Status: Bus=0 Dev=0 Func=0 64bit-
133MHz- SCD- USC-,
DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-
Capabilities: [50]
Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
Address: 0000000000000000 Data: 0000
Capabilities: [78] Power Management version 2
Flags: PMEClk- DSI- D1- D2-
AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 PME-Enable- DSel=0 DScale=0
PME-

SCSI infomation:
-------------------------

cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 05 Lun: 00
Vendor: IBM Model: IC35L073UCDY10-0 Rev: S28G
Type: Direct-Access ANSI SCSI
revision: 03
Host: scsi0 Channel: 00 Id: 08 Lun: 00
Vendor: IBM Model: IC35L073UCDY10-0 Rev: S28G
Type: Direct-Access ANSI SCSI
revision: 03
Host: scsi0 Channel: 00 Id: 15 Lun: 00
Vendor: IBM Model: VSBPD4E1 U4SCSI Rev: 4770
Type: Enclosure ANSI SCSI
revision: 02
Host: scsi0 Channel: 255 Id: 255 Lun: 255
Vendor: IBM Model: 570B001 Rev: 0150
Type: Unknown ANSI SCSI
revision: 03
Host: scsi1 Channel: 00 Id: 00 Lun: 00
Vendor: IBM Model: DROM00205 Rev: NR38
Type: CD-ROM ANSI SCSI
revision: 05

Thanking you,
regards,
kiran



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
