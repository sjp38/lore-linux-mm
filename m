Date: Mon, 31 Dec 2007 20:13:21 +0000 (GMT)
From: richard parkins <p1rpp@yahoo.co.uk>
Subject: Kernel bug report
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <990213.66542.qm@web27604.mail.ukl.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[1.] One line summary of the problem:
shrinking mremap succeeds on unmapped pages

[2.] Full description of the problem/report:
If mremap is called to shrink an old region that isn't in the process's memory
map, it returns old_address. According to the man page it should return
-EFAULT.

[3.] Keywords (i.e., modules, networking, kernel):
Memory Management, mremap, mremap.c

[4.] Kernel version (from /proc/version):
Linux version 2.6.18.8-0.7-default (geeko@buildhost) (gcc version 4.1.2
20061115 (prerelease) (SUSE Linux)) #1 SMP Tue Oct 2 17:21:08 UTC 2007

[5.] Most recent kernel version which did not have the bug:
Not known (possibly none)

[6.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)
N/A

[7.] A small shell script or example program which triggers the
     problem (if possible)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#define __USE_GNU
#include <sys/mman.h>
int main (int argc __attribute__ ((unused)), char * argv[] __attribute__
((unused)))
{
    void * retval = mremap((void*)4096, 8192, 4096, MREMAP_MAYMOVE);
    if (retval != MAP_FAILED)
    {
        fprintf(stderr, "mremap succeeded with bad old_address\n");
        exit(-1);
    }
    exit(0);
}

[8.] Environment
[8.1.] Software (add the output of the ver_linux script here)
Linux rparkins64 2.6.18.8-0.7-default #1 SMP Tue Oct 2 17:21:08 UTC 2007 x86_64
x86_64 x86_64 GNU/Linux

Gnu C                  4.1.2
Gnu make               3.81
binutils               2.17.50.0.5
util-linux             2.12r
mount                  2.12r
module-init-tools      3.2.2
e2fsprogs              1.39
jfsutils               1.1.11
reiserfsprogs          3.6.19
xfsprogs               2.8.11
PPP                    2.4.4
Linux C Library        > libc.2.5
Dynamic linker (ldd)   2.5
Procps                 3.2.7
Net-tools              1.60
Kbd                    1.12
Sh-utils               6.4
udev                   103
Modules Loaded         arc4 ieee80211_crypt_wep af_packet xt_pkttype ipt_LOG
xt_limit snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device cpufreq_conservative
cpufreq_ondemand cpufreq_userspace cpufreq_powersave speedstep_centrino
freq_table button battery ac ip6t_REJECT xt_tcpudp ipt_REJECT xt_state
iptable_mangle iptable_nat ip_nat iptable_filter ip6table_mangle ip_conntrack
nfnetlink ip_tables ip6table_filter ip6_tables x_tables ipv6 apparmor
aamatch_pcre nls_utf8 ntfs loop dm_mod usbhid pcmcia nvidia ehci_hcd ohci1394
yenta_socket rsrc_nonstatic ipw3945 ieee80211 ieee80211_crypt uhci_hcd usbcore
ieee1394 pcmcia_core firmware_class i2c_i801 i2c_core intel_agp tg3
snd_hda_intel snd_hda_codec snd_pcm snd_timer snd soundcore snd_page_alloc
parport_pc lp parport ext3 mbcache jbd edd sg fan sr_mod cdrom ata_piix libata
thermal processor sd_mod scsi_mod

[8.2.] Processor information (from /proc/cpuinfo):
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Core(TM)2 CPU         T7200  @ 2.00GHz
stepping        : 6
cpu MHz         : 1000.000
cache size      : 4096 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall nx lm
constant_tsc pni monitor ds_cpl vmx est tm2 cx16 xtpr lahf_lm
bogomips        : 3995.21
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Core(TM)2 CPU         T7200  @ 2.00GHz
stepping        : 6
cpu MHz         : 1000.000
cache size      : 4096 KB
physical id     : 0
siblings        : 2
core id         : 1
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall nx lm
constant_tsc pni monitor ds_cpl vmx est tm2 cx16 xtpr lahf_lm
bogomips        : 3990.10
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

[8.3.] Module information (from /proc/modules):
arc4 18944 1 - Live 0xffffffff88cdd000
ieee80211_crypt_wep 22400 1 - Live 0xffffffff88cd6000
af_packet 57356 4 - Live 0xffffffff88cc6000
xt_pkttype 18816 3 - Live 0xffffffff88cc0000
ipt_LOG 23808 8 - Live 0xffffffff88cb9000
xt_limit 20224 8 - Live 0xffffffff88cb3000
snd_pcm_oss 71680 0 - Live 0xffffffff88ca0000
snd_mixer_oss 35840 1 snd_pcm_oss, Live 0xffffffff88c96000
snd_seq 82976 0 - Live 0xffffffff88c80000
snd_seq_device 26516 1 snd_seq, Live 0xffffffff88c78000
cpufreq_conservative 25608 0 - Live 0xffffffff88c70000
cpufreq_ondemand 24592 1 - Live 0xffffffff88c68000
cpufreq_userspace 24064 0 - Live 0xffffffff88c61000
cpufreq_powersave 18688 0 - Live 0xffffffff88c5b000
speedstep_centrino 27680 1 - Live 0xffffffff88c53000
freq_table 22912 1 speedstep_centrino, Live 0xffffffff88c4c000
button 24736 0 - Live 0xffffffff88c44000
battery 28296 0 - Live 0xffffffff88c3c000
ac 22792 0 - Live 0xffffffff88c35000
ip6t_REJECT 22528 3 - Live 0xffffffff88c2e000
xt_tcpudp 20352 3 - Live 0xffffffff88c28000
ipt_REJECT 22528 3 - Live 0xffffffff88c21000
xt_state 19200 12 - Live 0xffffffff88c1b000
iptable_mangle 19840 0 - Live 0xffffffff88c15000
iptable_nat 24964 0 - Live 0xffffffff88c0d000
ip_nat 37804 1 iptable_nat, Live 0xffffffff88c02000
iptable_filter 19968 1 - Live 0xffffffff88bfc000
ip6table_mangle 19456 0 - Live 0xffffffff88bf6000
ip_conntrack 78372 3 xt_state,iptable_nat,ip_nat, Live 0xffffffff88be1000
nfnetlink 24648 2 ip_nat,ip_conntrack, Live 0xffffffff88bd9000
ip_tables 39784 3 iptable_mangle,iptable_nat,iptable_filter, Live
0xffffffff88bce000
ip6table_filter 19840 1 - Live 0xffffffff88bc8000
ip6_tables 33480 2 ip6table_mangle,ip6table_filter, Live 0xffffffff88bbe000
x_tables 37384 10
xt_pkttype,ipt_LOG,xt_limit,ip6t_REJECT,xt_tcpudp,ipt_REJECT,xt_state,iptable_nat,ip_tables,ip6_tables,
Live 0xffffffff88bb3000
ipv6 357728 17 ip6t_REJECT, Live 0xffffffff88b5a000
apparmor 74264 0 - Live 0xffffffff88b46000
aamatch_pcre 31232 1 apparmor, Live 0xffffffff88b3d000
nls_utf8 18944 1 - Live 0xffffffff88142000
ntfs 209032 1 - Live 0xffffffff88b08000
loop 34192 0 - Live 0xffffffff88afe000
dm_mod 81872 0 - Live 0xffffffff88ae9000
usbhid 69792 0 - Live 0xffffffff8812f000
pcmcia 58648 0 - Live 0xffffffff88ad9000
nvidia 8163256 29 - Live 0xffffffff8830f000
ehci_hcd 51080 0 - Live 0xffffffff882ff000
ohci1394 52040 0 - Live 0xffffffff882ef000
yenta_socket 45836 1 - Live 0xffffffff882e0000
rsrc_nonstatic 29824 1 yenta_socket, Live 0xffffffff882d7000
ipw3945 217888 1 - Live 0xffffffff882a0000
ieee80211 50248 1 ipw3945, Live 0xffffffff88292000
ieee80211_crypt 23680 2 ieee80211_crypt_wep,ieee80211, Live 0xffffffff8828b000
uhci_hcd 42520 0 - Live 0xffffffff8827f000
usbcore 163368 4 usbhid,ehci_hcd,uhci_hcd, Live 0xffffffff88256000
ieee1394 130552 1 ohci1394, Live 0xffffffff88235000
pcmcia_core 61988 3 pcmcia,yenta_socket,rsrc_nonstatic, Live 0xffffffff88224000
firmware_class 28288 2 pcmcia,ipw3945, Live 0xffffffff88207000
i2c_i801 25364 0 - Live 0xffffffff8821c000
i2c_core 41472 2 nvidia,i2c_i801, Live 0xffffffff88210000
intel_agp 44224 1 - Live 0xffffffff881fb000
tg3 125572 0 - Live 0xffffffff881db000
snd_hda_intel 37660 1 - Live 0xffffffff881d0000
snd_hda_codec 220288 1 snd_hda_intel, Live 0xffffffff88199000
snd_pcm 115464 3 snd_pcm_oss,snd_hda_intel,snd_hda_codec, Live
0xffffffff8817b000
snd_timer 44680 2 snd_seq,snd_pcm, Live 0xffffffff8816f000
snd 89384 10
snd_pcm_oss,snd_mixer_oss,snd_seq,snd_seq_device,snd_hda_intel,snd_hda_codec,snd_pcm,snd_timer,
Live 0xffffffff88158000
soundcore 28192 1 snd, Live 0xffffffff88150000
snd_page_alloc 28560 2 snd_hda_intel,snd_pcm, Live 0xffffffff88148000
parport_pc 58984 1 - Live 0xffffffff8811f000
lp 30664 0 - Live 0xffffffff88116000
parport 59660 2 parport_pc,lp, Live 0xffffffff88106000
ext3 167696 3 - Live 0xffffffff880dc000
mbcache 27016 1 ext3, Live 0xffffffff880d4000
jbd 90872 1 ext3, Live 0xffffffff880bc000
edd 27912 0 - Live 0xffffffff880b4000
sg 55224 0 - Live 0xffffffff880a3000
fan 22408 0 - Live 0xffffffff8809c000
sr_mod 34596 0 - Live 0xffffffff88090000
cdrom 54056 1 sr_mod, Live 0xffffffff88081000
ata_piix 34308 5 - Live 0xffffffff88077000
libata 145568 1 ata_piix, Live 0xffffffff88052000
thermal 33552 0 - Live 0xffffffff88048000
processor 53864 2 speedstep_centrino,thermal, Live 0xffffffff88039000
sd_mod 39296 6 - Live 0xffffffff8802e000
scsi_mod 173744 4 sg,sr_mod,libata,sd_mod, Live 0xffffffff88002000

[8.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : libata
01f0-01f7 : libata
02f8-02ff : serial
0378-037a : parport0
03c0-03df : vga+
03f8-03ff : serial
1000-1005 : motherboard
  1000-1003 : ACPI PM1a_EVT_BLK
  1004-1005 : ACPI PM1a_CNT_BLK
1006-1007 : motherboard
1008-100f : motherboard
  1008-100b : ACPI PM_TMR
1010-102f : motherboard
  1010-1015 : ACPI CPU throttle
  1020-1020 : ACPI PM2_CNT_BLK
  1028-102f : ACPI GPE0_BLK
1060-107f : motherboard
1080-10bf : motherboard
10c0-10df : 0000:00:1f.3
  10c0-10df : motherboard
    10c0-10df : i801_smbus
2000-2fff : PCI Bus #03
  2000-20ff : PCI CardBus #04
  2400-24ff : PCI CardBus #04
bf20-bf3f : 0000:00:1d.3
  bf20-bf3f : uhci_hcd
bf40-bf5f : 0000:00:1d.2
  bf40-bf5f : uhci_hcd
bf60-bf7f : 0000:00:1d.1
  bf60-bf7f : uhci_hcd
bf80-bf9f : 0000:00:1d.0
  bf80-bf9f : uhci_hcd
bfa0-bfaf : 0000:00:1f.2
  bfa0-bfaf : libata
e000-efff : PCI Bus #0d
f400-f4fe : motherboard
00000000-0009efff : System RAM
  00000000-00000000 : Crash kernel
0009f000-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000cffff : Video ROM
000f0000-000fffff : System ROM
00100000-7fe813ff : System RAM
  00200000-003def9e : Kernel code
  003def9f-0051f7d7 : Kernel data
7fe81400-7fffffff : reserved
88000000-89ffffff : PCI Bus #03
  88000000-89ffffff : PCI CardBus #04
8a000000-8bffffff : PCI CardBus #04
d0000000-dfffffff : PCI Bus #01
  d0000000-dfffffff : 0000:01:00.0
e0000000-e01fffff : PCI Bus #0d
ecb00000-ecbfffff : PCI Bus #03
  ecb00000-ecb00fff : 0000:03:01.0
    ecb00000-ecb00fff : yenta_socket
  ecbfe800-ecbfefff : 0000:03:01.4
  ecbff000-ecbfffff : 0000:03:01.4
    ecbff000-ecbff7ff : ohci1394
ecc00000-ecdfffff : PCI Bus #0d
ece00000-ecefffff : PCI Bus #09
  ecef0000-ecefffff : 0000:09:00.0
    ecef0000-ecefffff : tg3
ecf00000-ecffffff : PCI Bus #0c
  ecfff000-ecffffff : 0000:0c:00.0
    ecfff000-ecffffff : ipw3945
ed000000-efefffff : PCI Bus #01
  ed000000-edffffff : 0000:01:00.0
    ed000000-edffffff : nvidia
  ee000000-eeffffff : 0000:01:00.0
  ef000000-ef01ffff : 0000:01:00.0
efffc000-efffffff : 0000:00:1b.0
  efffc000-efffffff : ICH HD audio
f0000000-f4006fff : reserved
f4008000-f400bfff : reserved
fec00000-fec0ffff : reserved
fed20000-fed9ffff : reserved
fee00000-fee0ffff : reserved
ffa80000-ffa803ff : 0000:00:1d.7
  ffa80000-ffa803ff : ehci_hcd
ffb00000-ffffffff : reserved

[8.5.] PCI information ('lspci -vvv' as root)
00:00.0 Host bridge: Intel Corporation Mobile 945GM/PM/GMS/940GML and 945GT
Express Memory Controller Hub (rev 03)
        Subsystem: Dell Unknown device 01cc
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort+ >SERR- <PERR-
        Latency: 0
        Capabilities: [e0] Vendor Specific Information

00:01.0 PCI bridge: Intel Corporation Mobile 945GM/PM/GMS/940GML and 945GT
Express PCI Express Root Port (rev 03) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: ed000000-efefffff
        Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        Capabilities: [88] Subsystem: Dell Unknown device 01cc
        Capabilities: [80] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0
Enable+
                Address: fee00000  Data: 40d1
        Capabilities: [a0] Express Root Port (Slot+) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <64ns, L1 <1us
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 2
                Link: Latency L0s <256ns, L1 <4us
                Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x16
                Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
                Slot: Number 1, PowerLimit 75.000000
                Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
                Slot: AttnInd Off, PwrInd On, Power-
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [100] Virtual Channel
        Capabilities: [140] Unknown (5)

00:1b.0 Audio device: Intel Corporation 82801G (ICH7 Family) High Definition
Audio Controller (rev 01)
        Subsystem: Dell Unknown device 01cc
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 58
        Region 0: Memory at efffc000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [70] Express Unknown type IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <64ns, L1 <1us
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed unknown, Width x0, ASPM unknown, Port 0
                Link: Latency L0s <64ns, L1 <1us
                Link: ASPM Disabled CommClk- ExtSynch-
                Link: Speed unknown, Width x0
        Capabilities: [100] Virtual Channel
        Capabilities: [130] Unknown (5)

00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1
(rev 01) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=0b, subordinate=0b, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        Capabilities: [40] Express Root Port (Slot+) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 1
                Link: Latency L0s <1us, L1 <4us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x0
                Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
                Slot: Number 2, PowerLimit 6.500000
                Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq-
                Slot: AttnInd Unknown, PwrInd Unknown, Power-
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0
Enable+
                Address: fee00000  Data: 40d9
        Capabilities: [90] Subsystem: Dell Unknown device 01cc
        Capabilities: [a0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Unknown (5)

00:1c.1 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 2
(rev 01) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=0c, subordinate=0c, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: ecf00000-ecffffff
        Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        Capabilities: [40] Express Root Port (Slot+) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 2
                Link: Latency L0s <256ns, L1 <4us
                Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
                Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
                Slot: Number 3, PowerLimit 6.500000
                Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq-
                Slot: AttnInd Unknown, PwrInd Unknown, Power-
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0
Enable+
                Address: fee00000  Data: 40e1
        Capabilities: [90] Subsystem: Dell Unknown device 01cc
        Capabilities: [a0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Unknown (5)

00:1c.2 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 3
(rev 01) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: ece00000-ecefffff
        Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        Capabilities: [40] Express Root Port (Slot+) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 3
                Link: Latency L0s <256ns, L1 <4us
                Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
                Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
                Slot: Number 4, PowerLimit 6.500000
                Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq-
                Slot: AttnInd Unknown, PwrInd Unknown, Power-
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0
Enable+
                Address: fee00000  Data: 40e9
        Capabilities: [90] Subsystem: Dell Unknown device 01cc
        Capabilities: [a0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Unknown (5)

00:1c.3 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 4
(rev 01) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=0d, subordinate=0e, sec-latency=0
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: ecc00000-ecdfffff
        Prefetchable memory behind bridge: 00000000e0000000-00000000e01fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        Capabilities: [40] Express Root Port (Slot+) IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
                Link: Latency L0s <1us, L1 <4us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x0
                Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
                Slot: Number 5, PowerLimit 6.500000
                Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq-
                Slot: AttnInd Unknown, PwrInd Unknown, Power-
                Root: Correctable- Non-Fatal- Fatal- PME-
        Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0
Enable+
                Address: fee00000  Data: 4032
        Capabilities: [90] Subsystem: Dell Unknown device 01cc
        Capabilities: [a0] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Unknown (5)

00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #1 (rev
01) (prog-if 00 [UHCI])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 66
        Region 4: I/O ports at bf80 [size=32]

00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #2 (rev
01) (prog-if 00 [UHCI])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin B routed to IRQ 58
        Region 4: I/O ports at bf60 [size=32]

00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #3 (rev
01) (prog-if 00 [UHCI])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin C routed to IRQ 74
        Region 4: I/O ports at bf40 [size=32]

00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #4 (rev
01) (prog-if 00 [UHCI])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin D routed to IRQ 82
        Region 4: I/O ports at bf20 [size=32]

00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI
Controller (rev 01) (prog-if 20 [EHCI])
        Subsystem: Dell Unknown device 01cc
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 66
        Region 0: Memory at ffa80000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Debug port

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e1) (prog-if
01 [Subtractive decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0
        Bus: primary=00, secondary=03, subordinate=07, sec-latency=32
        I/O behind bridge: 00002000-00002fff
        Memory behind bridge: ecb00000-ecbfffff
        Prefetchable memory behind bridge: 0000000088000000-0000000089ffffff
        Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR+
        BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
        Capabilities: [50] Subsystem: Dell Unknown device 01cc

00:1f.0 ISA bridge: Intel Corporation 82801GBM (ICH7-M) LPC Interface Bridge
(rev 01)
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Capabilities: [e0] Vendor Specific Information

00:1f.2 IDE interface: Intel Corporation 82801GBM/GHM (ICH7 Family) Serial ATA
Storage Controller IDE (rev 01) (prog-if 80 [Master])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin B routed to IRQ 177
        Region 0: I/O ports at <ignored>
        Region 1: I/O ports at <ignored>
        Region 2: I/O ports at <ignored>
        Region 3: I/O ports at <ignored>
        Region 4: I/O ports at bfa0 [size=16]
        Capabilities: [70] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin B routed to IRQ 177
        Region 4: I/O ports at 10c0 [size=32]

01:00.0 VGA compatible controller: nVidia Corporation Quadro NVS 110M / GeForce
Go 7300 (rev a1) (prog-if 00 [VGA])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 169
        Region 0: Memory at ed000000 (32-bit, non-prefetchable) [size=16M]
        Region 1: Memory at d0000000 (64-bit, prefetchable) [size=256M]
        Region 3: Memory at ee000000 (64-bit, non-prefetchable) [size=16M]
        [virtual] Expansion ROM at ef000000 [disabled] [size=128K]
        Capabilities: [60] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [68] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [78] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <256ns, L1 <4us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
                Link: Latency L0s <256ns, L1 <4us
                Link: ASPM L1 Enabled RCB 128 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x16
        Capabilities: [100] Virtual Channel
        Capabilities: [128] Power Budgeting

03:01.0 CardBus bridge: O2 Micro, Inc. Cardbus bridge (rev 21)
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping+ SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 168
        Interrupt: pin A routed to IRQ 193
        Region 0: Memory at ecb00000 (32-bit, non-prefetchable) [size=4K]
        Bus: primary=03, secondary=04, subordinate=07, sec-latency=176
        Memory window 0: 88000000-89fff000 (prefetchable)
        Memory window 1: 8a000000-8bfff000
        I/O window 0: 00002000-000020ff
        I/O window 1: 00002400-000024ff
        BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ PostWrite+
        16-bit legacy interface ports at 0001

03:01.4 FireWire (IEEE 1394): O2 Micro, Inc. Firewire (IEEE 1394) (rev 02)
(prog-if 10 [OHCI])
        Subsystem: Dell Unknown device 01cc
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 193
        Region 0: Memory at ecbff000 (32-bit, non-prefetchable) [size=4K]
        Region 1: Memory at ecbfe800 (32-bit, non-prefetchable) [size=2K]
        Capabilities: [60] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME+

09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5752 Gigabit
Ethernet PCI Express (rev 02)
        Subsystem: Dell Unknown device 01cc
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 90
        Region 0: Memory at ecef0000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3
Enable+
                Address: 00000000fee00000  Data: 405a
        Capabilities: [d0] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 512 bytes, PhantFunc 0, ExtTag+
                Device: Latency L0s <4us, L1 unlimited
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
                Link: Latency L0s <2us, L1 <64us
                Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [13c] Virtual Channel

0c:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG Network
Connection (rev 02)
        Subsystem: Intel Corporation Unknown device 1021
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 177
        Region 0: Memory at ecfff000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express Legacy Endpoint IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <512ns, L1 unlimited
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
                Link: Latency L0s <128ns, L1 <64us
                Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 07-0e-7b-ff-ff-d2-19-00

[8.6.] SCSI information (from /proc/scsi/scsi)
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Hitachi HTS54161 Rev: SBDO
  Type:   Direct-Access                    ANSI SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: TSSTcorp Model: DVD+-RW TS-L632D Rev: DE03
  Type:   CD-ROM                           ANSI SCSI revision: 05

[8.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
I think that the problem is in do_mremap in mremap.c. if old_len >= new_len you
call do_munmap before you check the old_address with find_vma. do_munmap seems
to return 0 if the region it is asked to unmap isn't in the process's VM.
However something unexpected could happen if old_address isn't in the process's
VM but old_address+old_length is, since the region that you try to unmap is
from old_address+new_length to old_address+old_length. Maybe the process just
gets some memory unmapped that it didn't expect and SEGVs if it later tries to
access it.



      ___________________________________________________________
Support the World Aids Awareness campaign this month with Yahoo! For Good http://uk.promotions.yahoo.com/forgood/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
