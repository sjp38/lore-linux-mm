Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id A22E56B0035
	for <linux-mm@kvack.org>; Sun, 25 May 2014 18:44:01 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id z60so10961362qgd.37
        for <linux-mm@kvack.org>; Sun, 25 May 2014 15:44:01 -0700 (PDT)
Received: from ikrg.com (ikrg.com. [2606:df00:2::fb1c:efb6])
        by mx.google.com with ESMTPS id n13si11441244qay.108.2014.05.25.15.43.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 25 May 2014 15:44:00 -0700 (PDT)
Date: Sun, 25 May 2014 17:42:37 -0500
From: Doug Morse <dm@dougmorse.org>
Subject: lshw sees 12GB RAM but system only using 8GB
Message-ID: <20140525224237.GA4869@ikrg.com>
Reply-To: Doug Morse <dm@dougmorse.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Dear Kernel Developer,

[1.] Summary

lshw sees 12GB RAM but system only using 8GB

[2.] Description

When I originally installed an additional 4GB RAM into my system a
year or two ago, the kernel recognized all 12GB just fine. Somewhere
along the line, however, the kernel stopped using all 12GB and started
using only 8GB (unfortunately, I have no idea when this occurred).

Specifically, "free" and cat /proc/meminfo only show 8GB of RAM, for
example:

    root@s3:~# free

                total       used       free     shared    buffers     cached
    Mem:       8152924    3530872    4622052          0     119240    1103024
    -/+ buffers/cache:    2308608    5844316
    Swap:      6143996          0    6143996
    root@s3:~# cat /proc/meminfo | head -5
    MemTotal:        8152924 kB
    MemFree:         4619976 kB
    MemAvailable:    5695244 kB
    Buffers:          119240 kB
    Cached:          1102912 kB

as do other reporting tools (e.g., nmon).  Dmesg also shows only 8GB
in use by the kernel at boot:

    root@s3:~# dmesg | grep -n Memory:

    203:[    0.000000] Memory: 8133320K/8364800K available (7665K kernel code, 1147K rwdata, 3624K rodata, 1356K init, 1432K bss, 231480K reserved)

However, lshw does see all 12GB:

    root@s3:~# lshw | grep -m 1 -A 50 "*-memory"

        *-memory
            description: System Memory
            physical id: 2c
            slot: System board or motherboard
            size: 12GiB
            *-bank:0
                description: DIMM DDR3 Synchronous 667 MHz (1.5 ns)
                product: F3-10666CL9-4
                vendor: Undefined
                physical id: 0
                serial: 00000000
                slot: Node0_Dimm0
                size: 4GiB
                width: 64 bits
                clock: 667MHz (1.5ns)
            *-bank:1
                description: DIMM DDR3 Synchronous 667 MHz (1.5 ns)
                product: F3-10666CL9-4
                vendor: Undefined
                physical id: 1
                serial: 00000000
                slot: Node0_Dimm1
                size: 4GiB
                width: 64 bits
                clock: 667MHz (1.5ns)
            *-bank:2
                description: DIMM DDR3 Synchronous 667 MHz (1.5 ns)
                product: F3-10666CL9-2
                vendor: Undefined
                physical id: 2
                serial: 00000000
                slot: Node0_Dimm2
                size: 2GiB
                width: 64 bits
                clock: 667MHz (1.5ns)
            *-bank:3
                description: DIMM DDR3 Synchronous 667 MHz (1.5 ns)
                product: F3-10666CL9-2
                vendor: Undefined
                physical id: 3
                serial: 00000000
                slot: Node0_Dimm3
                size: 2GiB
                width: 64 bits
                clock: 667MHz (1.5ns)

[3.] Keywords

<none>

{Per https://wiki.ubuntu.com/Bugs/Upstream/kernel}

[4.] Version

root@s3:~# cat /proc/version 

Linux version 3.15.0-031500rc6-generic (apw@gomeisa) (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201405211835 SMP Wed May 21 22:35:54 UTC 2014

[5.] Oops Output

NA

[6.] Shell Script Replicating Problem

NA

[7.] Environment

root@s3:~# lsb_release -rd

Description: Ubuntu 12.04.4 LTS
Release: 12.04

[7.1] Software

root@s3:~# /usr/src/linux-headers-3.2.0-63/scripts/ver_linux

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux s3.ikrg.com 3.15.0-031500rc6-generic #201405211835 SMP Wed May 21 22:35:54 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
 
Gnu C                  4.6
Gnu make               3.81
binutils               2.22
util-linux             2.20.1
mount                  support
module-init-tools      3.16
e2fsprogs              1.42
pcmciautils            018
PPP                    2.4.5
Linux C Library        2.15
Dynamic linker (ldd)   2.15
Procps                 3.2.8
Net-tools              1.60
Kbd                    1.15.2
Sh-utils               8.13
wireless-tools         30
Modules Loaded         hidp vmw_vsock_vmci_transport vsock vmw_vmci iptable_filter ip_tables x_tables joydev btusb snd_hda_codec_via snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep psmouse snd_seq_midi snd_pcm snd_rawmidi serio_raw rfcomm k10temp bnep parport_pc snd_seq_midi_event bluetooth edac_core edac_mce_amd 6lowpan_iphc ppdev snd_seq sp5100_tco snd_timer snd_seq_device i2c_piix4 binfmt_misc tpm_infineon snd soundcore mac_hid lp parport nls_utf8 isofs ses enclosure uas usb_storage hid_logitech ff_memless hid_logitech_dj usbhid hid firewire_ohci firewire_core crc_itu_t r8169 mii ahci libahci

[7.2] Processor Information

root@s3:~# cat /proc/cpuinfo

processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 16
model           : 5
model name      : AMD Athlon(tm) II X4 630 Processor
stepping        : 3
microcode       : 0x10000c8
cpu MHz         : 800.000
cache size      : 512 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 4
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt nodeid_msr hw_pstate npt lbrv svm_lock nrip_save
bogomips        : 5625.65
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

processor       : 1
vendor_id       : AuthenticAMD
cpu family      : 16
model           : 5
model name      : AMD Athlon(tm) II X4 630 Processor
stepping        : 3
microcode       : 0x10000c8
cpu MHz         : 800.000
cache size      : 512 KB
physical id     : 0
siblings        : 4
core id         : 1
cpu cores       : 4
apicid          : 1
initial apicid  : 1
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt nodeid_msr hw_pstate npt lbrv svm_lock nrip_save
bogomips        : 5625.65
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

processor       : 2
vendor_id       : AuthenticAMD
cpu family      : 16
model           : 5
model name      : AMD Athlon(tm) II X4 630 Processor
stepping        : 3
microcode       : 0x10000c8
cpu MHz         : 1600.000
cache size      : 512 KB
physical id     : 0
siblings        : 4
core id         : 2
cpu cores       : 4
apicid          : 2
initial apicid  : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt nodeid_msr hw_pstate npt lbrv svm_lock nrip_save
bogomips        : 5625.65
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

processor       : 3
vendor_id       : AuthenticAMD
cpu family      : 16
model           : 5
model name      : AMD Athlon(tm) II X4 630 Processor
stepping        : 3
microcode       : 0x10000c8
cpu MHz         : 800.000
cache size      : 512 KB
physical id     : 0
siblings        : 4
core id         : 3
cpu cores       : 4
apicid          : 3
initial apicid  : 3
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt nodeid_msr hw_pstate npt lbrv svm_lock nrip_save
bogomips        : 5625.65
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

[7.3] Module Information

root@s3:~# cat /proc/modules 

hidp 24317 0 - Live 0xffffffffa030c000
vmw_vsock_vmci_transport 30794 0 - Live 0xffffffffa031e000
vsock 35060 1 vmw_vsock_vmci_transport, Live 0xffffffffa0314000
vmw_vmci 68535 1 vmw_vsock_vmci_transport, Live 0xffffffffa02fa000
iptable_filter 12810 0 - Live 0xffffffffa02e0000
ip_tables 27718 1 iptable_filter, Live 0xffffffffa02c9000
x_tables 34194 2 iptable_filter,ip_tables, Live 0xffffffffa02f0000
joydev 17587 0 - Live 0xffffffffa02ea000
btusb 32555 0 - Live 0xffffffffa02d3000
snd_hda_codec_via 32006 1 - Live 0xffffffffa029a000
snd_hda_codec_generic 70087 1 snd_hda_codec_via, Live 0xffffffffa02b6000
snd_hda_codec_hdmi 48229 2 - Live 0xffffffffa028d000
snd_hda_intel 30608 6 - Live 0xffffffffa02a3000
snd_hda_controller 35518 1 snd_hda_intel, Live 0xffffffffa017f000
snd_hda_codec 144671 5 snd_hda_codec_via,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_controller, Live 0xffffffffa0268000
snd_hwdep 13613 1 snd_hda_codec, Live 0xffffffffa0263000
psmouse 113320 0 - Live 0xffffffffa0246000
snd_seq_midi 13564 0 - Live 0xffffffffa0220000
snd_pcm 113863 4 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_controller,snd_hda_codec, Live 0xffffffffa0225000
snd_rawmidi 30865 1 snd_seq_midi, Live 0xffffffffa0217000
serio_raw 13483 0 - Live 0xffffffffa017a000
rfcomm 75078 12 - Live 0xffffffffa0203000
k10temp 13191 0 - Live 0xffffffffa01fe000
bnep 19884 2 - Live 0xffffffffa015c000
parport_pc 32906 0 - Live 0xffffffffa02ac000
snd_seq_midi_event 14899 1 snd_seq_midi, Live 0xffffffffa012e000
bluetooth 461775 25 hidp,btusb,rfcomm,bnep, Live 0xffffffffa018c000
edac_core 63001 0 - Live 0xffffffffa0169000
edac_mce_amd 22792 0 - Live 0xffffffffa0162000
6lowpan_iphc 18968 1 bluetooth, Live 0xffffffffa014e000
ppdev 17711 0 - Live 0xffffffffa0156000
snd_seq 67636 2 snd_seq_midi,snd_seq_midi_event, Live 0xffffffffa013c000
sp5100_tco 14134 0 - Live 0xffffffffa0133000
snd_timer 30118 2 snd_pcm,snd_seq, Live 0xffffffffa0125000
snd_seq_device 14497 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0xffffffffa011c000
i2c_piix4 22310 0 - Live 0xffffffffa0111000
binfmt_misc 17508 1 - Live 0xffffffffa0101000
tpm_infineon 17169 0 - Live 0xffffffffa010b000
snd 74195 23 snd_hda_codec_via,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_rawmidi,snd_seq,snd_timer,snd_seq_device, Live 0xffffffffa00ed000
soundcore 12680 2 snd_hda_codec,snd, Live 0xffffffffa00e8000
mac_hid 13275 0 - Live 0xffffffffa00dc000
lp 17799 0 - Live 0xffffffffa00e2000
parport 42481 3 parport_pc,ppdev,lp, Live 0xffffffffa00d0000
nls_utf8 12557 1 - Live 0xffffffffa00b8000
isofs 40285 1 - Live 0xffffffffa00a9000
ses 13321 0 - Live 0xffffffffa008a000
enclosure 15465 1 ses, Live 0xffffffffa00a4000
uas 27672 0 - Live 0xffffffffa0082000
usb_storage 67009 2 uas, Live 0xffffffffa0092000
hid_logitech 26814 0 - Live 0xffffffffa0052000
ff_memless 13704 1 hid_logitech, Live 0xffffffffa0017000
hid_logitech_dj 18647 0 - Live 0xffffffffa0032000
usbhid 53121 0 - Live 0xffffffffa00bf000
hid 106436 4 hidp,hid_logitech,hid_logitech_dj,usbhid, Live 0xffffffffa0067000
firewire_ohci 45300 0 - Live 0xffffffffa005a000
firewire_core 69403 1 firewire_ohci, Live 0xffffffffa0040000
crc_itu_t 12707 1 firewire_core, Live 0xffffffffa0039000
r8169 73316 0 - Live 0xffffffffa001f000
mii 13981 1 r8169, Live 0xffffffffa0009000
ahci 30167 7 - Live 0xffffffffa000e000
libahci 32191 1 ahci, Live 0xffffffffa0000000
root@s3:~# cat /proc/modules | sed -e 's/\n/\r\n/'
hidp 24317 0 - Live 0xffffffffa030c000
vmw_vsock_vmci_transport 30794 0 - Live 0xffffffffa031e000
vsock 35060 1 vmw_vsock_vmci_transport, Live 0xffffffffa0314000
vmw_vmci 68535 1 vmw_vsock_vmci_transport, Live 0xffffffffa02fa000
iptable_filter 12810 0 - Live 0xffffffffa02e0000
ip_tables 27718 1 iptable_filter, Live 0xffffffffa02c9000
x_tables 34194 2 iptable_filter,ip_tables, Live 0xffffffffa02f0000
joydev 17587 0 - Live 0xffffffffa02ea000
btusb 32555 0 - Live 0xffffffffa02d3000
snd_hda_codec_via 32006 1 - Live 0xffffffffa029a000
snd_hda_codec_generic 70087 1 snd_hda_codec_via, Live 0xffffffffa02b6000
snd_hda_codec_hdmi 48229 2 - Live 0xffffffffa028d000
snd_hda_intel 30608 6 - Live 0xffffffffa02a3000
snd_hda_controller 35518 1 snd_hda_intel, Live 0xffffffffa017f000
snd_hda_codec 144671 5 snd_hda_codec_via,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_controller, Live 0xffffffffa0268000
snd_hwdep 13613 1 snd_hda_codec, Live 0xffffffffa0263000
psmouse 113320 0 - Live 0xffffffffa0246000
snd_seq_midi 13564 0 - Live 0xffffffffa0220000
snd_pcm 113863 4 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_controller,snd_hda_codec, Live 0xffffffffa0225000
snd_rawmidi 30865 1 snd_seq_midi, Live 0xffffffffa0217000
serio_raw 13483 0 - Live 0xffffffffa017a000
rfcomm 75078 12 - Live 0xffffffffa0203000
k10temp 13191 0 - Live 0xffffffffa01fe000
bnep 19884 2 - Live 0xffffffffa015c000
parport_pc 32906 0 - Live 0xffffffffa02ac000
snd_seq_midi_event 14899 1 snd_seq_midi, Live 0xffffffffa012e000
bluetooth 461775 25 hidp,btusb,rfcomm,bnep, Live 0xffffffffa018c000
edac_core 63001 0 - Live 0xffffffffa0169000
edac_mce_amd 22792 0 - Live 0xffffffffa0162000
6lowpan_iphc 18968 1 bluetooth, Live 0xffffffffa014e000
ppdev 17711 0 - Live 0xffffffffa0156000
snd_seq 67636 2 snd_seq_midi,snd_seq_midi_event, Live 0xffffffffa013c000
sp5100_tco 14134 0 - Live 0xffffffffa0133000
snd_timer 30118 2 snd_pcm,snd_seq, Live 0xffffffffa0125000
snd_seq_device 14497 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0xffffffffa011c000
i2c_piix4 22310 0 - Live 0xffffffffa0111000
binfmt_misc 17508 1 - Live 0xffffffffa0101000
tpm_infineon 17169 0 - Live 0xffffffffa010b000
snd 74195 23 snd_hda_codec_via,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_rawmidi,snd_seq,snd_timer,snd_seq_device, Live 0xffffffffa00ed000
soundcore 12680 2 snd_hda_codec,snd, Live 0xffffffffa00e8000
mac_hid 13275 0 - Live 0xffffffffa00dc000
lp 17799 0 - Live 0xffffffffa00e2000
parport 42481 3 parport_pc,ppdev,lp, Live 0xffffffffa00d0000
nls_utf8 12557 1 - Live 0xffffffffa00b8000
isofs 40285 1 - Live 0xffffffffa00a9000
ses 13321 0 - Live 0xffffffffa008a000
enclosure 15465 1 ses, Live 0xffffffffa00a4000
uas 27672 0 - Live 0xffffffffa0082000
usb_storage 67009 2 uas, Live 0xffffffffa0092000
hid_logitech 26814 0 - Live 0xffffffffa0052000
ff_memless 13704 1 hid_logitech, Live 0xffffffffa0017000
hid_logitech_dj 18647 0 - Live 0xffffffffa0032000
usbhid 53121 0 - Live 0xffffffffa00bf000
hid 106436 4 hidp,hid_logitech,hid_logitech_dj,usbhid, Live 0xffffffffa0067000
firewire_ohci 45300 0 - Live 0xffffffffa005a000
firewire_core 69403 1 firewire_ohci, Live 0xffffffffa0040000
crc_itu_t 12707 1 firewire_core, Live 0xffffffffa0039000
r8169 73316 0 - Live 0xffffffffa001f000
mii 13981 1 r8169, Live 0xffffffffa0009000
ahci 30167 7 - Live 0xffffffffa000e000
libahci 32191 1 ahci, Live 0xffffffffa0000000

[7.4] Loaded Driver and Hardware Information

root@s3:~# cat /proc/ioports 

0000-03af : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0064-0064 : keyboard
  0070-0071 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  0220-0227 : pnp 00:02
  0228-0237 : pnp 00:02
03b0-03df : PCI Bus 0000:00
  03c0-03df : vesafb
03e0-0cf7 : PCI Bus 0000:00
  03f8-03ff : serial
  040b-040b : pnp 00:01
  04d0-04d1 : pnp 00:07
  04d6-04d6 : pnp 00:01
  0800-0803 : ACPI PM1a_EVT_BLK
  0804-0805 : ACPI PM1a_CNT_BLK
  0808-080b : ACPI PM_TMR
  0810-0815 : ACPI CPU throttle
  0820-0827 : ACPI GPE0_BLK
  0900-090f : pnp 00:01
  0910-091f : pnp 00:01
  0a20-0a2f : pnp 00:02
  0b00-0b07 : piix4_smbus
  0b20-0b3f : pnp 00:01
    0b20-0b27 : piix4_smbus
  0c00-0c01 : pnp 00:01
  0c14-0c14 : pnp 00:01
  0c50-0c51 : pnp 00:01
  0c52-0c52 : pnp 00:01
  0c6c-0c6c : pnp 00:01
  0c6f-0c6f : pnp 00:01
  0cd0-0cd1 : pnp 00:01
  0cd2-0cd3 : pnp 00:01
  0cd4-0cd5 : pnp 00:01
  0cd6-0cd7 : pnp 00:01
    0cd6-0cd7 : SB800 TCO
  0cd8-0cdf : pnp 00:01
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  b000-bfff : PCI Bus 0000:06
    b000-b0ff : 0000:06:00.0
  c000-cfff : PCI Bus 0000:05
    c000-c07f : 0000:05:0e.0
  d000-dfff : PCI Bus 0000:03
    d000-d0ff : 0000:03:00.0
      d000-d0ff : r8169
  e000-efff : PCI Bus 0000:01
    e000-e0ff : 0000:01:00.0
  f000-f00f : 0000:00:11.0
    f000-f00f : ahci
  f010-f013 : 0000:00:11.0
    f010-f013 : ahci
  f020-f027 : 0000:00:11.0
    f020-f027 : ahci
  f030-f033 : 0000:00:11.0
    f030-f033 : ahci
  f040-f047 : 0000:00:11.0
    f040-f047 : ahci
  fe00-fefe : pnp 00:01

root@s3:~# cat /proc/iomem 

00000000-00000fff : reserved
00001000-0009e7ff : System RAM
0009e800-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000dffff : PCI Bus 0000:00
  000c0000-000cf1ff : Video ROM
000e0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-ae482fff : System RAM
  01000000-0177c658 : Kernel code
  0177c659-01d1efbf : Kernel data
  01e7b000-01fe0fff : Kernel bss
ae483000-aea40fff : reserved
aea41000-aee38fff : ACPI Non-volatile Storage
aee39000-af158fff : reserved
af159000-af159fff : System RAM
af15a000-af35ffff : ACPI Non-volatile Storage
af360000-af7fffff : System RAM
af800000-afffffff : RAM buffer
b0000000-ffffffff : PCI Bus 0000:00
  b0000000-bfffffff : PCI Bus 0000:06
    b0000000-bfffffff : 0000:06:00.0
  c0000000-cfffffff : PCI Bus 0000:01
    c0000000-cfffffff : 0000:01:00.0
      c0000000-c05affff : vesafb
  d0000000-d00fffff : PCI Bus 0000:03
    d0000000-d0003fff : 0000:03:00.0
      d0000000-d0003fff : r8169
    d0004000-d0004fff : 0000:03:00.0
      d0004000-d0004fff : r8169
  e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
    e0000000-efffffff : pnp 00:00
  f8000000-fbffffff : reserved
  fe600000-fe6fffff : PCI Bus 0000:06
    fe600000-fe61ffff : 0000:06:00.0
    fe620000-fe63ffff : 0000:06:00.0
    fe640000-fe643fff : 0000:06:00.1
      fe640000-fe643fff : ICH HD audio
  fe700000-fe7fffff : PCI Bus 0000:05
    fe700000-fe7007ff : 0000:05:0e.0
      fe700000-fe7007ff : firewire_ohci
  fe800000-fe8fffff : PCI Bus 0000:04
    fe800000-fe807fff : 0000:04:00.0
      fe800000-fe807fff : xhci_hcd
  fe900000-fe9fffff : PCI Bus 0000:02
    fe900000-fe907fff : 0000:02:00.0
      fe900000-fe907fff : xhci_hcd
  fea00000-feafffff : PCI Bus 0000:01
    fea00000-fea1ffff : 0000:01:00.0
    fea20000-fea3ffff : 0000:01:00.0
    fea40000-fea43fff : 0000:01:00.1
      fea40000-fea43fff : ICH HD audio
  feb00000-feb03fff : 0000:00:14.2
    feb00000-feb03fff : ICH HD audio
  feb04000-feb040ff : 0000:00:16.2
    feb04000-feb040ff : ehci_hcd
  feb05000-feb05fff : 0000:00:16.0
    feb05000-feb05fff : ohci_hcd
  feb06000-feb06fff : 0000:00:14.5
    feb06000-feb06fff : ohci_hcd
  feb07000-feb070ff : 0000:00:13.2
    feb07000-feb070ff : ehci_hcd
  feb08000-feb08fff : 0000:00:13.0
    feb08000-feb08fff : ohci_hcd
  feb09000-feb090ff : 0000:00:12.2
    feb09000-feb090ff : ehci_hcd
  feb0a000-feb0afff : 0000:00:12.0
    feb0a000-feb0afff : ohci_hcd
  feb0b000-feb0b3ff : 0000:00:11.0
    feb0b000-feb0b3ff : ahci
  feb20000-feb23fff : amd_iommu
  fec00000-fec00fff : reserved
    fec00000-fec003ff : IOAPIC 0
  fec10000-fec10fff : reserved
    fec10000-fec10fff : pnp 00:01
  fec20000-fec20fff : reserved
    fec20000-fec203ff : IOAPIC 1
  fed00000-fed00fff : reserved
    fed00000-fed00fff : pnp 00:01
      fed00000-fed003ff : HPET 0
  fed61000-fed70fff : reserved
    fed61000-fed70fff : pnp 00:01
  fed80000-fed8ffff : reserved
    fed80000-fed8ffff : pnp 00:01
      fed80b00-fed80b07 : SB800 TCO
  fee00000-fee00fff : Local APIC
    fee00000-fee00fff : pnp 00:01
  fef00000-ffffffff : reserved
    ffc00000-ffffffff : pnp 00:01
100001000-24fffffff : System RAM

[7.5] PCI Information

root@s3:~# lspci -vvv

00:00.0 Host bridge: Advanced Micro Devices, Inc. [AMD/ATI] RD890 PCI to PCI bridge (external gfx0 port B) (rev 02)
        Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] RD890 PCI to PCI bridge (external gfx0 port B)
        Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
        Capabilities: [f0] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [c4] HyperTransport: Slave or Primary Interface
                Command: BaseUnitID=0 UnitCnt=20 MastHost- DefDir- DUL-
                Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
                Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
                Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
                Link Config 1: MLWI=8bit DwFcIn- MLWO=8bit DwFcOut- LWI=8bit DwFcInEn- LWO=8bit DwFcOutEn-
                Revision ID: 3.00
                Link Frequency 0: [b]
                Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
                Link Frequency Capability 0: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
                Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ UIDRD-
                Link Frequency 1: 200MHz
                Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
                Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 600MHz- 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
                Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
                Prefetchable memory behind bridge Upper: 00-00
                Bus Number: 00
        Capabilities: [40] HyperTransport: Retry Mode
        Capabilities: [54] HyperTransport: UnitID Clumping
        Capabilities: [9c] HyperTransport: #1a
        Capabilities: [70] MSI: Enable- Count=1/4 Maskable- 64bit-
                Address: 00000000  Data: 0000

00:00.2 IOMMU: Advanced Micro Devices, Inc. [AMD/ATI] RD990 I/O Memory Management Unit (IOMMU)
        Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] RD990 I/O Memory Management Unit (IOMMU)
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 72
        Capabilities: [40] Secure device <?>
        Capabilities: [54] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0f00c  Data: 41b1
        Capabilities: [64] HyperTransport: MSI Mapping Enable+ Fixed+

00:02.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] RD890 PCI to PCI bridge (PCI express gpp port B) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: fea00000-feafffff
        Prefetchable memory behind bridge: 00000000c0000000-00000000cfffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x16, ASPM L0s L1, Latency L0 <1us, L1 <8us
                        ClockPM- Surprise- LLActRep+ BwNot+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
                        Slot #2, PowerLimit 75.000W; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
                DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -3.5dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device 5a14
        Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [190 v1] Access Control Services
                ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans+
                ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans-
        Kernel driver in use: pcieport

00:04.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] RD890 PCI to PCI bridge (PCI express gpp port D) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fe900000-fe9fffff
        Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x2, ASPM L0s L1, Latency L0 <1us, L1 <8us
                        ClockPM- Surprise- LLActRep+ BwNot+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt+
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
                        Slot #4, PowerLimit 75.000W; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
                DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -3.5dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device 5a14
        Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [190 v1] Access Control Services
                ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans+
                ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans-
        Kernel driver in use: pcieport

00:09.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] RD890 PCI to PCI bridge (PCI express gpp port H) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
        I/O behind bridge: 0000d000-0000dfff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: 00000000d0000000-00000000d00fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #4, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <8us
                        ClockPM- Surprise- LLActRep+ BwNot+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
                        Slot #9, PowerLimit 75.000W; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
                DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -3.5dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device 5a14
        Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [190 v1] Access Control Services
                ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans+
                ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans-
        Kernel driver in use: pcieport

00:0a.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] RD890 PCI to PCI bridge (external gfx1 port A) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fe800000-fe8fffff
        Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #5, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <8us
                        ClockPM- Surprise- LLActRep+ BwNot+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt+
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
                        Slot #10, PowerLimit 75.000W; Interlock- NoCompl+
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
                        Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                        Changed: MRL- PresDet- LinkState-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd+
                DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -3.5dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
                Address: 00000000  Data: 0000
        Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device 5a14
        Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [190 v1] Access Control Services
                ACSCap: SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans+
                ACSCtl: SrcValid+ TransBlk- ReqRedir+ CmpltRedir+ UpstreamFwd+ EgressCtrl- DirectTrans-
        Kernel driver in use: pcieport

00:11.0 SATA controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (rev 40) (prog-if 01 [AHCI 1.0])
        Subsystem: Gigabyte Technology Co., Ltd Device b002
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32
        Interrupt: pin A routed to IRQ 19
        Region 0: I/O ports at f040 [size=8]
        Region 1: I/O ports at f030 [size=4]
        Region 2: I/O ports at f020 [size=8]
        Region 3: I/O ports at f010 [size=4]
        Region 4: I/O ports at f000 [size=16]
        Region 5: Memory at feb0b000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [70] SATA HBA v1.0 InCfgSpace
        Capabilities: [a4] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: ahci

00:12.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at feb0a000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci-pci

00:12.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 17
        Region 0: Memory at feb09000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
                Bridge: PM- B3+
        Capabilities: [e4] Debug port: BAR=1 offset=00e0
        Kernel driver in use: ehci-pci

00:13.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at feb08000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci-pci

00:13.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 17
        Region 0: Memory at feb07000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
                Bridge: PM- B3+
        Capabilities: [e4] Debug port: BAR=1 offset=00e0
        Kernel driver in use: ehci-pci

00:14.0 SMBus: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 SMBus Controller (rev 42)
        Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 SMBus Controller
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Kernel driver in use: piix4_smbus

00:14.2 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 Azalia (Intel HDA) (rev 40)
        Subsystem: Gigabyte Technology Co., Ltd Device a014
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at feb00000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: snd_hda_intel

00:14.3 ISA bridge: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 LPC host controller (rev 40)
        Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 LPC host controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:14.4 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 PCI to PCI Bridge (rev 40) (prog-if 01 [Subtractive decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop+ ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Bus: primary=00, secondary=05, subordinate=05, sec-latency=64
        I/O behind bridge: 0000c000-0000cfff
        Memory behind bridge: fe700000-fe7fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:14.5 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI2 Controller (prog-if 10 [OHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin C routed to IRQ 18
        Region 0: Memory at feb06000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci-pci

00:15.0 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] SB700/SB800/SB900 PCI to PCI bridge (PCIE port 0) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
        I/O behind bridge: 0000b000-0000bfff
        Memory behind bridge: fe600000-fe6fffff
        Prefetchable memory behind bridge: 00000000b0000000-00000000bfffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Root Port (Slot-), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 128 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x4, ASPM L0s L1, Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep+ BwNot+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+ ARIFwd-
                DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- ARIFwd-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -3.5dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device 0000
        Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Kernel driver in use: pcieport

00:16.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at feb05000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci-pci

00:16.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5004
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 17
        Region 0: Memory at feb04000 (32-bit, non-prefetchable) [size=256]
        Capabilities: [c0] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
                Bridge: PM- B3+
        Capabilities: [e4] Debug port: BAR=1 offset=00e0
        Kernel driver in use: ehci-pci

00:18.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor HyperTransport Configuration
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: [80] HyperTransport: Host or Secondary Interface
                Command: WarmRst+ DblEnd- DevNum=0 ChainSide- HostHide+ Slave- <EOCErr- DUL-
                Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn- LSEn+ ExtCTL- 64b-
                Link Config: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
                Revision ID: 3.00
                Link Frequency: [b]
                Link Error: <Prot- <Ovfl- <EOC- CTLTm-
                Link Frequency Capability: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
                Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ UIDRD- ExtRS- UCnfE-

00:18.1 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor Address Map
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor DRAM Controller
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor Miscellaneous Control
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: [f0] Secure device <?>
        Kernel driver in use: k10temp

00:18.4 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor Link Control
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Redwood XT [Radeon HD 5670/5690/5730] (prog-if 00 [VGA controller])
        Subsystem: PC Partner Limited / Sapphire Technology Device e166
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at c0000000 (64-bit, prefetchable) [size=256M]
        Region 2: Memory at fea20000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at e000 [size=256]
        Expansion ROM at fea00000 [disabled] [size=128K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [150 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-

01:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Redwood HDMI Audio [Radeon HD 5000 Series]
        Subsystem: PC Partner Limited / Sapphire Technology Device aa60
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 76
        Region 0: Memory at fea40000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee00000  Data: 0000
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [150 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
        Kernel driver in use: snd_hda_intel

02:00.0 USB controller: Etron Technology, Inc. EJ168 USB 3.0 Host Controller (rev 01) (prog-if 30 [XHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5007
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 73
        Region 0: Memory at fe900000 (64-bit, non-prefetchable) [size=32K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] MSI: Enable+ Count=1/4 Maskable+ 64bit+
                Address: 00000000fee00000  Data: 0000
                Masking: 0000000e  Pending: 00000000
        Capabilities: [a0] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <64us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Not Supported, TimeoutDis-
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout+ NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
        Capabilities: [190 v1] Device Serial Number 01-01-01-01-01-01-01-01
        Kernel driver in use: xhci_hcd

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 06)
        Subsystem: Gigabyte Technology Co., Ltd Motherboard
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 75
        Region 0: I/O ports at d000 [size=256]
        Region 2: Memory at d0004000 (64-bit, prefetchable) [size=4K]
        Region 4: Memory at d0000000 (64-bit, prefetchable) [size=16K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee00000  Data: 0000
        Capabilities: [70] Express (v2) Endpoint, MSI 01
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 unlimited, L1 <64us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data
                Unknown small resource type 00, will not decode more.
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
        Capabilities: [140 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=01
                        Status: NegoPending- InProgress-
        Capabilities: [160 v1] Device Serial Number 01-00-00-00-68-4c-e0-00
        Kernel driver in use: r8169

04:00.0 USB controller: Etron Technology, Inc. EJ168 USB 3.0 Host Controller (rev 01) (prog-if 30 [XHCI])
        Subsystem: Gigabyte Technology Co., Ltd Device 5007
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 74
        Region 0: Memory at fe800000 (64-bit, non-prefetchable) [size=32K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [70] MSI: Enable+ Count=1/4 Maskable+ 64bit+
                Address: 00000000fee00000  Data: 0000
                Masking: 0000000e  Pending: 00000000
        Capabilities: [a0] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <64us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Not Supported, TimeoutDis-
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
        Capabilities: [190 v1] Device Serial Number 01-01-01-01-01-01-01-01
        Kernel driver in use: xhci_hcd

05:0e.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306/7/8 [Fire II(M)] IEEE 1394 OHCI Controller (rev c0) (prog-if 10 [OHCI])
        Subsystem: Gigabyte Technology Co., Ltd GA-7VT600-1394 Motherboard
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32 (8000ns max), Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 22
        Region 0: Memory at fe700000 (32-bit, non-prefetchable) [size=2K]
        Region 1: I/O ports at c000 [size=128]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2+ AuxCurrent=0mA PME(D0-,D1-,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: firewire_ohci

06:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Cedar [Radeon HD 5000/6000/7350/8350 Series] (prog-if 00 [VGA controller])
        Subsystem: PC Partner Limited / Sapphire Technology Device e164
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 10
        Region 0: Memory at b0000000 (64-bit, prefetchable) [size=256M]
        Region 2: Memory at fe620000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at b000 [size=256]
        Expansion ROM at fe600000 [disabled] [size=128K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [150 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-

06:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Cedar HDMI Audio [Radeon HD 5400/6300 Series]
        Subsystem: PC Partner Limited / Sapphire Technology Device aa68
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 77
        Region 0: Memory at fe640000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: [50] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <64ns, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee00000  Data: 0000
        Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [150 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
        Kernel driver in use: snd_hda_intel

[7.6] SCSI Information

root@s3:~# cat /proc/scsi/scsi 

Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: SAMSUNG SSD 830  Rev: CXM0
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: ST31000524AS     Rev: JC45
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi2 Channel: 00 Id: 00 Lun: 00
  Vendor: ATAPI    Model: iHAS124   B      Rev: AL0Q
  Type:   CD-ROM                           ANSI  SCSI revision: 05
Host: scsi6 Channel: 00 Id: 00 Lun: 00
  Vendor: WD       Model: My Passport 0748 Rev: 1010
  Type:   Direct-Access                    ANSI  SCSI revision: 06
Host: scsi6 Channel: 00 Id: 00 Lun: 01
  Vendor: WD       Model: SES Device       Rev: 1010
  Type:   Enclosure                        ANSI  SCSI revision: 06

[7.7] Other Information

root@s3:~# ls /proc

1     1747  2463  35    3762  4689  752          kcore
10    1754  2464  3502  3768  4694  754          key-users
1020  1757  248   3503  3776  47    755          kmsg
1038  1759  2499  3507  3783  4703  757          kpagecount
1048  1772  25    3509  38    4728  758          kpageflags
1050  1781  250   3518  3800  4738  760          latency_stats
1053  18    251   3527  3802  4763  761          loadavg
1077  1885  252   3532  3807  48    763          locks
11    1887  2554  3537  3812  4827  776          mdstat
1104  19    2582  3538  3815  4869  778          meminfo
1135  1915  2592  3550  3816  4896  8            misc
1138  1924  26    3551  3831  49    9            modules
1139  1991  263   3552  3868  5     914          mounts
1170  2     2638  3553  39    51    93           mtrr
1171  20    2640  3556  3915  52    94           net
12    21    2681  3560  3917  5225  969          pagetypeinfo
1295  2196  2732  3563  3954  5249  979          partitions
13    22    2736  3569  3956  5250  acpi         sched_debug
1300  2237  28    3570  3976  5283  asound       schedstat
1372  2248  285   3571  3992  5284  buddyinfo    scsi
1374  229   286   3578  3994  5292  bus          self
1379  2294  29    3579  40    53    cgroups      slabinfo
1381  2295  3     3589  4000  54    cmdline      softirqs
1389  2296  30    3598  4071  5417  consoles     stat
14    2297  31    36    4077  5418  cpuinfo      swaps
1409  2298  323   3603  4089  55    crypto       sys
1427  2299  329   3605  4090  5622  devices      sysrq-trigger
1434  23    33    3606  41    69    diskstats    sysvipc
1439  231   330   3607  42    7     dma          timer_list
15    2327  331   3608  4207  70    driver       timer_stats
16    2329  3380  3614  4224  71    execdomains  tty
1665  233   3384  3616  43    72    fb           uptime
1678  237   3397  3619  4330  73    filesystems  version
17    238   34    3621  4331  736   fs           vmallocinfo
1723  24    340   3625  4447  737   interrupts   vmstat
1729  242   341   3651  4458  74    iomem        zoneinfo
1741  243   3442  3683  45    745   ioports
1743  244   3453  37    46    746   irq
1746  2459  3499  3718  4682  751   kallsyms

[X.] Other Notes, Patches, Fixes, Workarounds

Ubuntu Launchpad Bug Report URL:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1321938

Thank you,
Doug


--

doug morse | dougmorse.org | +1 615 340 3400

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
