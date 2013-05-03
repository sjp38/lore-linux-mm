Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9CC396B02CA
	for <linux-mm@kvack.org>; Fri,  3 May 2013 05:28:24 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id hz10so1279038vcb.10
        for <linux-mm@kvack.org>; Fri, 03 May 2013 02:28:23 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 3 May 2013 11:28:22 +0200
Message-ID: <CAEN0ZYDaHDhNZoJuRn3ZRUCYQyaP4DLwKheh2VFO00bo==0bLg@mail.gmail.com>
Subject: PROBLEM: kernel oops on page fault
From: Alexander H <1zeeky@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c231def3dbac04dbccf835
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11c231def3dbac04dbccf835
Content-Type: text/plain; charset=ISO-8859-1

[1.] One line summary of the problem:
    unable to handle kernel paging request
[2.] Full description of the problem/report:
    I was compiling something with gcc, when I received this kernel oops.
    I'm sorry if this is not specific enough, but I also couldn't
reproduce this oops.
[3.] Keywords (i.e., modules, networking, kernel):
    kernel, memory
[4.] Kernel version (from /proc/version):
    Linux version 3.8.11-1-ck (squishy@ease) (gcc version 4.8.0
20130425 (prerelease) (GCC) ) #1 SMP PREEMPT Thu May 2 09:53:00 EDT
2013
[5.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)
[ 2103.686565] BUG: unable to handle kernel paging request at 0000000051835ae3
[ 2103.686825] IP: [<ffffffff811440d0>] try_to_unmap_file+0x110/0x620
[ 2103.687021] PGD 3c0e7067 PUD 0
[ 2103.687129] Oops: 0000 [#1] PREEMPT SMP
[ 2103.687268] Modules linked in: brcmsmac cordic brcmutil bcma
mac80211 cfg80211 nfs lockd sunrpc fscache coretemp joydev iTCO_wdt
i915 iTCO_vendor_support gpio_ich snd
_hda_codec_realtek snd_hda_intel drm_kms_helper drm snd_hda_codec
microcode samsung_laptop psmouse serio_raw evdev pcspkr sky2 lpc_ich
snd_hwdep i2c_i801 snd_pcm thermal
 snd_page_alloc snd_timer battery snd soundcore intel_agp video
intel_gtt button ac arc4 i2c_algo_bit i2c_core rfkill
cpufreq_powersave acpi_cpufreq mperf processor btrf
s crc32c libcrc32c zlib_deflate ehci_pci ext4 crc16 jbd2 mbcache
uhci_hcd ehci_hcd usbcore usb_common sd_mod ahci libahci libata
scsi_mod [last unloaded: cordic]
[ 2103.689474] CPU 1
[ 2103.689560] Pid: 7640, comm: cc1plus Not tainted 3.8.11-1-ck #1
SAMSUNG ELECTRONICS CO., LTD. N150P/N210P/N220P
/N150P/N210P/N220P
[ 2103.689829] RIP: 0010:[<ffffffff811440d0>]  [<ffffffff811440d0>]
try_to_unmap_file+0x110/0x620
[ 2103.689829] RSP: 0000:ffff8800363ef960  EFLAGS: 00010282
[ 2103.689829] RAX: 0000000051835a3b RBX: fff6005d2d1d6f69 RCX: 696c20612d206f69
[ 2103.689829] RDX: 0000000051835a93 RSI: ffff880031665678 RDI: ffff880031665670
[ 2103.689829] RBP: ffff8800363ef9f8 R08: 0000000000000000 R09: 0000000000000000
[ 2103.689829] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000242
[ 2103.689829] R13: 0000000000000000 R14: ffff880031665650 R15: ffffea0000062c40
[ 2103.689829] FS:  00007f381a893800(0000) GS:ffff88003ef00000(0000)
knlGS:0000000000000000
[ 2103.689829] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2103.689829] CR2: 0000000051835ae3 CR3: 0000000026b67000 CR4: 00000000000007e0
[ 2103.689829] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2103.689829] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2103.689829] Process cc1plus (pid: 7640, threadinfo
ffff8800363ee000, task ffff88003780aed0)
[ 2103.689829] Stack:
[ 2103.689829]  0000000000000000 ffff8800363ef9c0 ffff880031665678
ffff8800363efaa0
[ 2103.689829]  ffff880031665650 0000000000000000 ffff880031665688
ffffea0000062c40
[ 2103.689829]  ffff8800363efa70 0000000000000001 ffffea0000fcef40
ffffffff8188b1c0
[ 2103.689829] Call Trace:
[ 2103.689829]  [<ffffffff8116a69f>] ? mem_cgroup_prepare_migration+0xbf/0x190
[ 2103.689829]  [<ffffffff8114539d>] try_to_unmap+0x2d/0x60
[ 2103.689829]  [<ffffffff8115e657>] migrate_pages+0x327/0x640
[ 2103.689829]  [<ffffffff811321d0>] ? isolate_freepages_block+0x3b0/0x3b0
[ 2103.689829]  [<ffffffff81133227>] compact_zone+0x2c7/0x490
[ 2103.689829]  [<ffffffff81133480>] compact_zone_order+0x90/0xd0
[ 2103.689829]  [<ffffffff81133712>] try_to_compact_pages+0xd2/0x100
[ 2103.689829]  [<ffffffff814a14a1>] __alloc_pages_direct_compact+0xad/0x1cf
[ 2103.689829]  [<ffffffff81118ec7>] __alloc_pages_nodemask+0x7b7/0x9f0
[ 2103.689829]  [<ffffffff81162ccb>] do_huge_pmd_anonymous_page+0x18b/0x4d0
[ 2103.689829]  [<ffffffff8113acff>] handle_mm_fault+0x29f/0x350
[ 2103.689829]  [<ffffffff814ac2d2>] __do_page_fault+0x1d2/0x5d0
[ 2103.689829]  [<ffffffff8112c170>] ? vm_mmap_pgoff+0x80/0xa0
[ 2103.689829]  [<ffffffff814ac6de>] do_page_fault+0xe/0x10
[ 2103.689829]  [<ffffffff814a9408>] page_fault+0x28/0x30
[ 2103.689829] Code: c1 48 89 85 78 ff ff ff 48 8b 46 28 48 39 c1 74
6a 80 fb 02 74 65 48 8d 40 a8 31 db 31 c9 48 8b b5 78 ff ff ff 66 0f
1f 44 00 00 <48> 8b 90 a8 00 00
 00 48 39 d1 48 0f 42 ca 48 8b 50 08 48 2b 10
[ 2103.689829] RIP  [<ffffffff811440d0>] try_to_unmap_file+0x110/0x620
[ 2103.689829]  RSP <ffff8800363ef960>
[ 2103.689829] CR2: 0000000051835ae3
[ 2103.796276] ---[ end trace 1756a48e83a7b663 ]---
[6.] A small shell script or example program which triggers the
     problem (if possible)
    I could not reproduce the oops.
[7.] Environment
    Err.. Arch Linux, gcc 4.8.0, Intel Atom N450, 1GB RAM, 1GB swap
[7.1.] Software (add the output of the ver_linux script here)
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux netblarch 3.8.11-1-ck #1 SMP PREEMPT Thu May 2 09:53:00 EDT 2013
x86_64 GNU/Linux

Gnu C                  4.8.0
Gnu make               3.82
binutils               2.23.2
util-linux             2.22.2
mount                  debug
module-init-tools      13
e2fsprogs              1.42.7
pcmciautils            018
PPP                    2.4.5
Linux C Library        2.17
Dynamic linker (ldd)   2.17
Linux C++ Library      6.0.18
Procps                 3.3.7
Net-tools              1.60
Kbd                    1.15.5
oprofile               0.9.8
Sh-utils               8.21
wireless-tools         29
Modules Loaded         brcmsmac cordic brcmutil bcma mac80211 cfg80211
nfs lockd sunrpc fscache coretemp joydev iTCO_wdt i915
iTCO_vendor_support gpio_ich snd_hda_codec_realtek snd_hda_intel
drm_kms_helper drm snd_hda_codec microcode samsung_laptop psmouse
serio_raw evdev pcspkr sky2 lpc_ich snd_hwdep i2c_i801 snd_pcm thermal
snd_page_alloc snd_timer battery snd soundcore intel_agp video
intel_gtt button ac arc4 i2c_algo_bit i2c_core rfkill
cpufreq_powersave acpi_cpufreq mperf processor btrfs crc32c libcrc32c
zlib_deflate ehci_pci ext4 crc16 jbd2 mbcache uhci_hcd ehci_hcd
usbcore usb_common sd_mod ahci libahci libata scsi_mod

[7.2.] Processor information (from /proc/cpuinfo):
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 28
model name	: Intel(R) Atom(TM) CPU N450   @ 1.66GHz
stepping	: 10
microcode	: 0x105
cpu MHz		: 1000.000
cache size	: 512 KB
physical id	: 0
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm
constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64
monitor ds_cpl est tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm
bogomips	: 3326.46
clflush size	: 64
cache_alignment	: 64
address sizes	: 32 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 28
model name	: Intel(R) Atom(TM) CPU N450   @ 1.66GHz
stepping	: 10
microcode	: 0x105
cpu MHz		: 1000.000
cache size	: 512 KB
physical id	: 0
siblings	: 1
core id		: 0
cpu cores	: 0
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm
constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64
monitor ds_cpl est tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm
bogomips	: 3326.46
clflush size	: 64
cache_alignment	: 64
address sizes	: 32 bits physical, 48 bits virtual
power management:

[7.3.] Module information (from /proc/modules):
brcmsmac 507576 0 - Live 0xffffffffa08e5000
cordic 1112 1 brcmsmac, Live 0xffffffffa01be000
brcmutil 3088 1 brcmsmac, Live 0xffffffffa01b5000
bcma 32574 1 brcmsmac, Live 0xffffffffa08d1000
mac80211 466081 1 brcmsmac, Live 0xffffffffa083f000
cfg80211 432785 2 brcmsmac,mac80211, Live 0xffffffffa07b3000
nfs 145340 0 - Live 0xffffffffa077c000
lockd 77125 1 nfs, Live 0xffffffffa0761000
sunrpc 220872 2 nfs,lockd, Live 0xffffffffa0712000
fscache 44798 1 nfs, Live 0xffffffffa06fe000
coretemp 6134 0 - Live 0xffffffffa0407000
joydev 9727 0 - Live 0xffffffffa04c9000
iTCO_wdt 5375 0 - Live 0xffffffffa03f9000
i915 552693 2 - Live 0xffffffffa05b1000
iTCO_vendor_support 1929 1 iTCO_wdt, Live 0xffffffffa00eb000
gpio_ich 4544 0 - Live 0xffffffffa0367000
snd_hda_codec_realtek 62215 1 - Live 0xffffffffa059a000
snd_hda_intel 34234 0 - Live 0xffffffffa0590000
drm_kms_helper 35346 1 i915, Live 0xffffffffa035d000
drm 224819 3 i915,drm_kms_helper, Live 0xffffffffa04e6000
snd_hda_codec 102242 2 snd_hda_codec_realtek,snd_hda_intel, Live
0xffffffffa03dd000
microcode 14324 0 - Live 0xffffffffa02bd000
samsung_laptop 8625 0 - Live 0xffffffffa02b1000
psmouse 77065 0 - Live 0xffffffffa0349000
serio_raw 5105 0 - Live 0xffffffffa00f5000
evdev 9976 12 - Live 0xffffffffa01ae000
pcspkr 1995 0 - Live 0xffffffffa0089000
sky2 49987 0 - Live 0xffffffffa028f000
lpc_ich 11633 0 - Live 0xffffffffa0112000
snd_hwdep 6364 1 snd_hda_codec, Live 0xffffffffa00d8000
i2c_i801 11237 0 - Live 0xffffffffa00d1000
snd_pcm 77084 2 snd_hda_intel,snd_hda_codec, Live 0xffffffffa0195000
thermal 8513 0 - Live 0xffffffffa0094000
snd_page_alloc 7298 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0071000
snd_timer 18911 1 snd_pcm, Live 0xffffffffa00c8000
battery 7002 0 - Live 0xffffffffa0030000
snd 59245 6 snd_hda_codec_realtek,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_timer,
Live 0xffffffffa005e000
soundcore 5450 1 snd, Live 0xffffffffa0021000
intel_agp 10968 1 i915, Live 0xffffffffa04df000
video 11170 2 i915,samsung_laptop, Live 0xffffffffa04d7000
intel_gtt 12744 3 i915,intel_agp, Live 0xffffffffa04cf000
button 4701 1 i915, Live 0xffffffffa04b7000
ac 2568 0 - Live 0xffffffffa04b3000
arc4 2032 2 - Live 0xffffffffa04af000
i2c_algo_bit 5423 1 i915, Live 0xffffffffa04aa000
i2c_core 22806 5 i915,drm_kms_helper,drm,i2c_i801,i2c_algo_bit, Live
0xffffffffa049d000
rfkill 15633 3 cfg80211,samsung_laptop, Live 0xffffffffa02d5000
cpufreq_powersave 1246 2 - Live 0xffffffffa02d1000
acpi_cpufreq 10502 1 - Live 0xffffffffa02c3000
mperf 1235 1 acpi_cpufreq, Live 0xffffffffa02bb000
processor 27271 1 acpi_cpufreq, Live 0xffffffffa02a1000
btrfs 766096 2 - Live 0xffffffffa01c8000
crc32c 1736 1 - Live 0xffffffffa01c4000
libcrc32c 1002 1 btrfs, Live 0xffffffffa01c0000
zlib_deflate 20828 1 btrfs, Live 0xffffffffa01b7000
ehci_pci 4120 0 - Live 0xffffffffa01b2000
ext4 475492 1 - Live 0xffffffffa011f000
crc16 1359 1 ext4, Live 0xffffffffa011b000
jbd2 77640 1 ext4, Live 0xffffffffa00fe000
mbcache 5962 1 ext4, Live 0xffffffffa00f8000
uhci_hcd 24659 0 - Live 0xffffffffa00ed000
ehci_hcd 47951 1 ehci_pci, Live 0xffffffffa00db000
usbcore 173551 3 ehci_pci,uhci_hcd,ehci_hcd, Live 0xffffffffa009c000
usb_common 954 1 usbcore, Live 0xffffffffa0098000
sd_mod 30946 5 - Live 0xffffffffa008b000
ahci 22096 4 - Live 0xffffffffa007f000
libahci 20599 1 ahci, Live 0xffffffffa0074000
libata 168677 2 ahci,libahci, Live 0xffffffffa0033000
scsi_mod 129647 2 sd_mod,libata, Live 0xffffffffa0000000

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
/proc/ioports:
0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0062-0062 : EC data
  0064-0064 : keyboard
  0066-0066 : EC cmd
  0070-0071 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  03c0-03df : vga+
  04d0-04d1 : pnp 00:00
  0800-080f : pnp 00:00
0cf8-0cff : PCI conf1
0d00-fdff : PCI Bus 0000:00
  1000-107f : pnp 00:00
    1000-1003 : ACPI PM1a_EVT_BLK
    1004-1005 : ACPI PM1a_CNT_BLK
    1008-100b : ACPI PM_TMR
    1010-1015 : ACPI CPU throttle
    1020-1020 : ACPI PM2_CNT_BLK
    1028-102f : ACPI GPE0_BLK
    1030-1033 : iTCO_wdt
      1030-1033 : iTCO_wdt
    1060-107f : iTCO_wdt
      1060-107f : iTCO_wdt
  1180-11bf : gpio_ich
    1180-11bf : pnp 00:00
  164e-174c : pnp 00:00
  1820-183f : 0000:00:1d.0
    1820-183f : uhci_hcd
  1840-185f : 0000:00:1d.1
    1840-185f : uhci_hcd
  1860-187f : 0000:00:1d.2
    1860-187f : uhci_hcd
  1880-189f : 0000:00:1d.3
    1880-189f : uhci_hcd
  18a0-18bf : 0000:00:1f.3
    18a0-18bf : i801_smbus
  18c0-18cf : 0000:00:1f.2
    18c0-18cf : ahci
  18d0-18d7 : 0000:00:02.0
  18d8-18db : 0000:00:1f.2
    18d8-18db : ahci
  18dc-18df : 0000:00:1f.2
    18dc-18df : ahci
  18e0-18e7 : 0000:00:1f.2
    18e0-18e7 : ahci
  18e8-18ef : 0000:00:1f.2
    18e8-18ef : ahci
  2000-2fff : PCI Bus 0000:09
    2000-20ff : 0000:09:00.0
      2000-20ff : sky2
  3000-3fff : PCI Bus 0000:05
  4000-4fff : PCI Bus 0000:07
  5000-5fff : PCI Bus 0000:0b
fe00-fe00 : pnp 00:00

/proc/iomem:
00000000-0000ffff : reserved
00010000-0009dbff : System RAM
0009dc00-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000ce000-000cffff : reserved
000d0000-000d3fff : PCI Bus 0000:00
000d4000-000d7fff : PCI Bus 0000:00
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000dffff : reserved
000e0000-000e3fff : PCI Bus 0000:00
000e4000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-3f5affff : System RAM
  01000000-014b4584 : Kernel code
  014b4585-018a70bf : Kernel data
  01972000-01aa2fff : Kernel bss
3f5b0000-3f5bffff : ACPI Tables
3f5c0000-3f5c2fff : ACPI Non-volatile Storage
3f5c3000-3fffffff : reserved
40000000-f7ffffff : PCI Bus 0000:00
  40000000-401fffff : PCI Bus 0000:05
  40200000-403fffff : PCI Bus 0000:07
  40400000-405fffff : PCI Bus 0000:07
  40600000-407fffff : PCI Bus 0000:09
  40800000-409fffff : PCI Bus 0000:0b
  40a00000-40bfffff : PCI Bus 0000:0b
  40c00000-40c00fff : Intel Flush Page
  40c04000-40c07fff : i915 MCHBAR
  d0000000-dfffffff : 0000:00:02.0
  e0000000-efffffff : reserved
    e0000000-efffffff : pnp 00:00
      e0000000-e10fffff : PCI MMCONFIG 0000 [bus 00-10]
  f0000000-f00fffff : 0000:00:02.0
  f0100000-f01fffff : PCI Bus 0000:05
    f0100000-f0103fff : 0000:05:00.0
      f0100000-f0103fff : bcma-pci-bridge
  f0200000-f02fffff : PCI Bus 0000:09
    f0200000-f0203fff : 0000:09:00.0
      f0200000-f0203fff : sky2
  f0300000-f037ffff : 0000:00:02.0
  f0380000-f03fffff : 0000:00:02.1
  f0400000-f0403fff : 0000:00:1b.0
    f0400000-f0403fff : ICH HD audio
  f0604000-f06043ff : 0000:00:1d.7
    f0604000-f06043ff : ehci_hcd
  f0604400-f06047ff : 0000:00:1f.2
    f0604400-f06047ff : ahci
f8000000-fbffffff : pnp 00:00
fec00000-fec0ffff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fed003ff : HPET 0
fed14000-fed17fff : pnp 00:00
fed1f410-fed1f414 : iTCO_wdt
  fed1f410-fed1f414 : iTCO_wdt
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
fef00000-feffffff : pnp 00:00
ff000000-ffffffff : reserved
00000000-0000ffff : reserved
00010000-0009dbff : System RAM
0009dc00-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000ce000-000cffff : reserved
000d0000-000d3fff : PCI Bus 0000:00
000d4000-000d7fff : PCI Bus 0000:00
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000dffff : reserved
000e0000-000e3fff : PCI Bus 0000:00
000e4000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-3f5affff : System RAM
  01000000-014b4584 : Kernel code
  014b4585-018a70bf : Kernel data
  01972000-01aa2fff : Kernel bss
3f5b0000-3f5bffff : ACPI Tables
3f5c0000-3f5c2fff : ACPI Non-volatile Storage
3f5c3000-3fffffff : reserved
40000000-f7ffffff : PCI Bus 0000:00
  40000000-401fffff : PCI Bus 0000:05
  40200000-403fffff : PCI Bus 0000:07
  40400000-405fffff : PCI Bus 0000:07
  40600000-407fffff : PCI Bus 0000:09
  40800000-409fffff : PCI Bus 0000:0b
  40a00000-40bfffff : PCI Bus 0000:0b
  40c00000-40c00fff : Intel Flush Page
  40c04000-40c07fff : i915 MCHBAR
  d0000000-dfffffff : 0000:00:02.0
  e0000000-efffffff : reserved
    e0000000-efffffff : pnp 00:00
      e0000000-e10fffff : PCI MMCONFIG 0000 [bus 00-10]
  f0000000-f00fffff : 0000:00:02.0
  f0100000-f01fffff : PCI Bus 0000:05
    f0100000-f0103fff : 0000:05:00.0
      f0100000-f0103fff : bcma-pci-bridge
  f0200000-f02fffff : PCI Bus 0000:09
    f0200000-f0203fff : 0000:09:00.0
      f0200000-f0203fff : sky2
  f0300000-f037ffff : 0000:00:02.0
  f0380000-f03fffff : 0000:00:02.1
  f0400000-f0403fff : 0000:00:1b.0
    f0400000-f0403fff : ICH HD audio
  f0604000-f06043ff : 0000:00:1d.7
    f0604000-f06043ff : ehci_hcd
  f0604400-f06047ff : 0000:00:1f.2
    f0604400-f06047ff : ahci
f8000000-fbffffff : pnp 00:00
fec00000-fec0ffff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fed003ff : HPET 0
fed14000-fed17fff : pnp 00:00
fed1f410-fed1f414 : iTCO_wdt
  fed1f410-fed1f414 : iTCO_wdt
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
fef00000-feffffff : pnp 00:00
ff000000-ffffffff : reserved

[7.5.] PCI information ('lspci -vvv' as root)
00:00.0 Host bridge: Intel Corporation Atom Processor
D4xx/D5xx/N4xx/N5xx DMI Bridge
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=08 <?>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation Atom Processor
D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller (prog-if 00 [VGA
controller])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 47
	Region 0: Memory at f0300000 (32-bit, non-prefetchable) [size=512K]
	Region 1: I/O ports at 18d0 [size=8]
	Region 2: Memory at d0000000 (32-bit, prefetchable) [size=256M]
	Region 3: Memory at f0000000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4152
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: i915

00:02.1 Display controller: Intel Corporation Atom Processor
D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at f0380000 (32-bit, non-prefetchable) [size=512K]
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:1b.0 Audio device: Intel Corporation NM10/ICH7 Family High
Definition Audio Controller (rev 02)
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 46
	Region 0: Memory at f0400000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4162
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0
<64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=1 ArbSelect=Fixed TC/VC=80
			Status:	NegoPending- InProgress-
	Capabilities: [130 v1] Root Complex Link
		Desc:	PortNumber=0f ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 1 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: f0100000-f01fffff
	Prefetchable memory behind bridge: 0000000040000000-00000000401fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #1, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4191
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=01 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 2 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: 40200000-403fffff
	Prefetchable memory behind bridge: 0000000040400000-00000000405fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41a1
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=02 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.2 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 3 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0200000-f02fffff
	Prefetchable memory behind bridge: 0000000040600000-00000000407fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #3, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41b1
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=03 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 4 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=0b, subordinate=0b, sec-latency=0
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: 40800000-409fffff
	Prefetchable memory behind bridge: 0000000040a00000-0000000040bfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41c1
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=04 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 1820 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 1840 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #3 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 1860 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.3 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #4 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at 1880 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB controller: Intel Corporation NM10/ICH7 Family USB2 EHCI
Controller (rev 02) (prog-if 20 [EHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at f0604000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci-pci

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e2)
(prog-if 01 [Subtractive decode])
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=11, subordinate=11, sec-latency=32
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Samsung Electronics Co Ltd Notebook N150P

00:1f.0 ISA bridge: Intel Corporation NM10 Family LPC Controller (rev 02)
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
	Kernel driver in use: lpc_ich

00:1f.2 SATA controller: Intel Corporation NM10/ICH7 Family SATA
Controller [AHCI mode] (rev 02) (prog-if 01 [AHCI 1.0])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 44
	Region 0: I/O ports at 18e8 [size=8]
	Region 1: I/O ports at 18dc [size=4]
	Region 2: I/O ports at 18e0 [size=8]
	Region 3: I/O ports at 18d8 [size=4]
	Region 4: I/O ports at 18c0 [size=16]
	Region 5: Memory at f0604400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0100c  Data: 41d1
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation NM10/ICH7 Family SMBus Controller (rev 02)
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 18a0 [size=32]
	Kernel driver in use: i801_smbus

05:00.0 Network controller: Broadcom Corporation BCM4313 802.11b/g/n
Wireless LAN Controller (rev 01)
	Subsystem: Wistron NeWeb Corp. Device 051a
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f0100000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Vendor Specific Information: Len=78 <?>
	Capabilities: [48] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<4us, L1 <64us
			ClockPM+ Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-00-b1-ff-ff-4c-00-1b
	Capabilities: [16c v1] Power Budgeting <?>
	Kernel driver in use: bcma-pci-bridge

09:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8040
PCI-E Fast Ethernet Controller
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 45
	Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 2000 [size=256]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41e1
	Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 unlimited
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 128 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-00:00.0 Host bridge:
Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx DMI Bridge
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=08 <?>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation Atom Processor
D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller (prog-if 00 [VGA
controller])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 47
	Region 0: Memory at f0300000 (32-bit, non-prefetchable) [size=512K]
	Region 1: I/O ports at 18d0 [size=8]
	Region 2: Memory at d0000000 (32-bit, prefetchable) [size=256M]
	Region 3: Memory at f0000000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4152
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: i915

00:02.1 Display controller: Intel Corporation Atom Processor
D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at f0380000 (32-bit, non-prefetchable) [size=512K]
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:1b.0 Audio device: Intel Corporation NM10/ICH7 Family High
Definition Audio Controller (rev 02)
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 46
	Region 0: Memory at f0400000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4162
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0
<64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=1 ArbSelect=Fixed TC/VC=80
			Status:	NegoPending- InProgress-
	Capabilities: [130 v1] Root Complex Link
		Desc:	PortNumber=0f ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 1 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: f0100000-f01fffff
	Prefetchable memory behind bridge: 0000000040000000-00000000401fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #1, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4191
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=01 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 2 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: 40200000-403fffff
	Prefetchable memory behind bridge: 0000000040400000-00000000405fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41a1
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=02 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.2 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 3 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0200000-f02fffff
	Prefetchable memory behind bridge: 0000000040600000-00000000407fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #3, PowerLimit 10.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41b1
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=03 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 4 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=0b, subordinate=0b, sec-latency=0
	I/O behind bridge: 00005000-00005fff
	Memory behind bridge: 40800000-409fffff
	Prefetchable memory behind bridge: 0000000040a00000-0000000040bfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal+ PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41c1
	Capabilities: [90] Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=04 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c001
	Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 1820 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 1840 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #3 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 1860 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.3 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #4 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at 1880 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB controller: Intel Corporation NM10/ICH7 Family USB2 EHCI
Controller (rev 02) (prog-if 20 [EHCI])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at f0604000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci-pci

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e2)
(prog-if 01 [Subtractive decode])
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=11, subordinate=11, sec-latency=32
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Samsung Electronics Co Ltd Notebook N150P

00:1f.0 ISA bridge: Intel Corporation NM10 Family LPC Controller (rev 02)
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
	Kernel driver in use: lpc_ich

00:1f.2 SATA controller: Intel Corporation NM10/ICH7 Family SATA
Controller [AHCI mode] (rev 02) (prog-if 01 [AHCI 1.0])
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 44
	Region 0: I/O ports at 18e8 [size=8]
	Region 1: I/O ports at 18dc [size=4]
	Region 2: I/O ports at 18e0 [size=8]
	Region 3: I/O ports at 18d8 [size=4]
	Region 4: I/O ports at 18c0 [size=16]
	Region 5: Memory at f0604400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0100c  Data: 41d1
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation NM10/ICH7 Family SMBus Controller (rev 02)
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 18a0 [size=32]
	Kernel driver in use: i801_smbus

05:00.0 Network controller: Broadcom Corporation BCM4313 802.11b/g/n
Wireless LAN Controller (rev 01)
	Subsystem: Wistron NeWeb Corp. Device 051a
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f0100000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Vendor Specific Information: Len=78 <?>
	Capabilities: [48] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<4us, L1 <64us
			ClockPM+ Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-00-b1-ff-ff-4c-00-1b
	Capabilities: [16c v1] Power Budgeting <?>
	Kernel driver in use: bcma-pci-bridge

09:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8040
PCI-E Fast Ethernet Controller
	Subsystem: Samsung Electronics Co Ltd Notebook N150P
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 45
	Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 2000 [size=256]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41e1
	Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 unlimited
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 128 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [130 v1] Device Serial Number d3-4c-cf-ff-ff-54-24-00
	Kernel driver in use: sky2

		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [130 v1] Device Serial Number d3-4c-cf-ff-ff-54-24-00
	Kernel driver in use: sky2

[7.6.] SCSI information (from /proc/scsi/scsi)
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Hitachi HTS54502 Rev: PB2O
  Type:   Direct-Access                    ANSI  SCSI revision: 05

[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
    Not sure. Let me know if I can do anything more!

Respectfully yours,
  Alexander Hirsch

--001a11c231def3dbac04dbccf835
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><pre>[1.] One line summary of the problem:<br>    unable t=
o handle kernel paging request<br>[2.] Full description of the problem/repo=
rt:<br>   =A0I was compiling something with gcc, when I received this kerne=
l oops.<br>
   =A0I&#39;m sorry if this is not specific enough, but I also couldn&#39;t=
 reproduce this oops.<br>[3.] Keywords (i.e., modules, networking, kernel):
    kernel, memory<br>[4.] Kernel version (from /proc/version):
    Linux version 3.8.11-1-ck (squishy@ease) (gcc version 4.8.0 20130425 (p=
rerelease) (GCC) ) #1 SMP PREEMPT Thu May 2 09:53:00 EDT 2013<br>[5.] Outpu=
t of Oops.. message (if applicable) with symbolic information=20
     resolved (see Documentation/oops-tracing.txt)
[ 2103.686565] BUG: unable to handle kernel paging request at 0000000051835=
ae3<br>[ 2103.686825] IP: [&lt;ffffffff811440d0&gt;] try_to_unmap_file+0x11=
0/0x620<br>[ 2103.687021] PGD 3c0e7067 PUD 0 <br>[ 2103.687129] Oops: 0000 =
[#1] PREEMPT SMP <br>
[ 2103.687268] Modules linked in: brcmsmac cordic brcmutil bcma mac80211 cf=
g80211 nfs lockd sunrpc fscache coretemp joydev iTCO_wdt i915 iTCO_vendor_s=
upport gpio_ich snd<br>_hda_codec_realtek snd_hda_intel drm_kms_helper drm =
snd_hda_codec microcode samsung_laptop psmouse serio_raw evdev pcspkr sky2 =
lpc_ich snd_hwdep i2c_i801 snd_pcm thermal<br>
 snd_page_alloc snd_timer battery snd soundcore intel_agp video intel_gtt b=
utton ac arc4 i2c_algo_bit i2c_core rfkill cpufreq_powersave acpi_cpufreq m=
perf processor btrf<br>s crc32c libcrc32c zlib_deflate ehci_pci ext4 crc16 =
jbd2 mbcache uhci_hcd ehci_hcd usbcore usb_common sd_mod ahci libahci libat=
a scsi_mod [last unloaded: cordic]<br>
[ 2103.689474] CPU 1 <br>[ 2103.689560] Pid: 7640, comm: cc1plus Not tainte=
d 3.8.11-1-ck #1 SAMSUNG ELECTRONICS CO., LTD. N150P/N210P/N220P          /=
N150P/N210P/N220P          <br>[ 2103.689829] RIP: 0010:[&lt;ffffffff811440=
d0&gt;]  [&lt;ffffffff811440d0&gt;] try_to_unmap_file+0x110/0x620<br>
[ 2103.689829] RSP: 0000:ffff8800363ef960  EFLAGS: 00010282<br>[ 2103.68982=
9] RAX: 0000000051835a3b RBX: fff6005d2d1d6f69 RCX: 696c20612d206f69<br>[ 2=
103.689829] RDX: 0000000051835a93 RSI: ffff880031665678 RDI: ffff8800316656=
70<br>
[ 2103.689829] RBP: ffff8800363ef9f8 R08: 0000000000000000 R09: 00000000000=
00000<br>[ 2103.689829] R10: 0000000000000000 R11: 0000000000000000 R12: 00=
00000000000242<br>[ 2103.689829] R13: 0000000000000000 R14: ffff88003166565=
0 R15: ffffea0000062c40<br>
[ 2103.689829] FS:  00007f381a893800(0000) GS:ffff88003ef00000(0000) knlGS:=
0000000000000000<br>[ 2103.689829] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000=
080050033<br>[ 2103.689829] CR2: 0000000051835ae3 CR3: 0000000026b67000 CR4=
: 00000000000007e0<br>
[ 2103.689829] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000<br>[ 2103.689829] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00=
00000000000400<br>[ 2103.689829] Process cc1plus (pid: 7640, threadinfo fff=
f8800363ee000, task ffff88003780aed0)<br>
[ 2103.689829] Stack:<br>[ 2103.689829]  0000000000000000 ffff8800363ef9c0 =
ffff880031665678 ffff8800363efaa0<br>[ 2103.689829]  ffff880031665650 00000=
00000000000 ffff880031665688 ffffea0000062c40<br>[ 2103.689829]  ffff880036=
3efa70 0000000000000001 ffffea0000fcef40 ffffffff8188b1c0<br>
[ 2103.689829] Call Trace:<br>[ 2103.689829]  [&lt;ffffffff8116a69f&gt;] ? =
mem_cgroup_prepare_migration+0xbf/0x190<br>[ 2103.689829]  [&lt;ffffffff811=
4539d&gt;] try_to_unmap+0x2d/0x60<br>[ 2103.689829]  [&lt;ffffffff8115e657&=
gt;] migrate_pages+0x327/0x640<br>
[ 2103.689829]  [&lt;ffffffff811321d0&gt;] ? isolate_freepages_block+0x3b0/=
0x3b0<br>[ 2103.689829]  [&lt;ffffffff81133227&gt;] compact_zone+0x2c7/0x49=
0<br>[ 2103.689829]  [&lt;ffffffff81133480&gt;] compact_zone_order+0x90/0xd=
0<br>
[ 2103.689829]  [&lt;ffffffff81133712&gt;] try_to_compact_pages+0xd2/0x100<=
br>[ 2103.689829]  [&lt;ffffffff814a14a1&gt;] __alloc_pages_direct_compact+=
0xad/0x1cf<br>[ 2103.689829]  [&lt;ffffffff81118ec7&gt;] __alloc_pages_node=
mask+0x7b7/0x9f0<br>
[ 2103.689829]  [&lt;ffffffff81162ccb&gt;] do_huge_pmd_anonymous_page+0x18b=
/0x4d0<br>[ 2103.689829]  [&lt;ffffffff8113acff&gt;] handle_mm_fault+0x29f/=
0x350<br>[ 2103.689829]  [&lt;ffffffff814ac2d2&gt;] __do_page_fault+0x1d2/0=
x5d0<br>
[ 2103.689829]  [&lt;ffffffff8112c170&gt;] ? vm_mmap_pgoff+0x80/0xa0<br>[ 2=
103.689829]  [&lt;ffffffff814ac6de&gt;] do_page_fault+0xe/0x10<br>[ 2103.68=
9829]  [&lt;ffffffff814a9408&gt;] page_fault+0x28/0x30<br>[ 2103.689829] Co=
de: c1 48 89 85 78 ff ff ff 48 8b 46 28 48 39 c1 74 6a 80 fb 02 74 65 48 8d=
 40 a8 31 db 31 c9 48 8b b5 78 ff ff ff 66 0f 1f 44 00 00 &lt;48&gt; 8b 90 =
a8 00 00<br>
 00 48 39 d1 48 0f 42 ca 48 8b 50 08 48 2b 10 <br>[ 2103.689829] RIP  [&lt;=
ffffffff811440d0&gt;] try_to_unmap_file+0x110/0x620<br>[ 2103.689829]  RSP =
&lt;ffff8800363ef960&gt;<br>[ 2103.689829] CR2: 0000000051835ae3<br>[ 2103.=
796276] ---[ end trace 1756a48e83a7b663 ]---<br>
[6.] A small shell script or example program which triggers the
     problem (if possible)
    I could not reproduce the oops.<br>[7.] Environment
    Err.. Arch Linux, gcc 4.8.0, Intel Atom N450, 1GB RAM, 1GB swap<br>[7.1=
.] Software (add the output of the ver_linux script here)
If some fields are empty or look unusual you may have an old version.<br>Co=
mpare to the current minimal requirements in Documentation/Changes.<br> <br=
>Linux netblarch 3.8.11-1-ck #1 SMP PREEMPT Thu May 2 09:53:00 EDT 2013 x86=
_64 GNU/Linux<br>
 <br>Gnu C                  4.8.0<br>Gnu make               3.82<br>binutil=
s               2.23.2<br>util-linux             2.22.2<br>mount           =
       debug<br>module-init-tools      13<br>e2fsprogs              1.42.7<=
br>
pcmciautils            018<br>PPP                    2.4.5<br>Linux C Libra=
ry        2.17<br>Dynamic linker (ldd)   2.17<br>Linux C++ Library      6.0=
.18<br>Procps                 3.3.7<br>Net-tools              1.60<br>Kbd  =
                  1.15.5<br>
oprofile               0.9.8<br>Sh-utils               8.21<br>wireless-too=
ls         29<br>Modules Loaded         brcmsmac cordic brcmutil bcma mac80=
211 cfg80211 nfs lockd sunrpc fscache coretemp joydev iTCO_wdt i915 iTCO_ve=
ndor_support gpio_ich snd_hda_codec_realtek snd_hda_intel drm_kms_helper dr=
m snd_hda_codec microcode samsung_laptop psmouse serio_raw evdev pcspkr sky=
2 lpc_ich snd_hwdep i2c_i801 snd_pcm thermal snd_page_alloc snd_timer batte=
ry snd soundcore intel_agp video intel_gtt button ac arc4 i2c_algo_bit i2c_=
core rfkill cpufreq_powersave acpi_cpufreq mperf processor btrfs crc32c lib=
crc32c zlib_deflate ehci_pci ext4 crc16 jbd2 mbcache uhci_hcd ehci_hcd usbc=
ore usb_common sd_mod ahci libahci libata scsi_mod<br>
<br>[7.2.] Processor information (from /proc/cpuinfo):
processor	: 0<br>vendor_id	: GenuineIntel<br>cpu family	: 6<br>model		: 28<=
br>model name	: Intel(R) Atom(TM) CPU N450   @ 1.66GHz<br>stepping	: 10<br>=
microcode	: 0x105<br>cpu MHz		: 1000.000<br>cache size	: 512 KB<br>physical=
 id	: 0<br>
siblings	: 1<br>core id		: 0<br>cpu cores	: 1<br>apicid		: 0<br>initial api=
cid	: 0<br>fpu		: yes<br>fpu_exception	: yes<br>cpuid level	: 10<br>wp		: y=
es<br>flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmo=
v pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constan=
t_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_=
cpl est tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm<br>
bogomips	: 3326.46<br>clflush size	: 64<br>cache_alignment	: 64<br>address =
sizes	: 32 bits physical, 48 bits virtual<br>power management:<br><br>proce=
ssor	: 1<br>vendor_id	: GenuineIntel<br>cpu family	: 6<br>model		: 28<br>
model name	: Intel(R) Atom(TM) CPU N450   @ 1.66GHz<br>stepping	: 10<br>mic=
rocode	: 0x105<br>cpu MHz		: 1000.000<br>cache size	: 512 KB<br>physical id=
	: 0<br>siblings	: 1<br>core id		: 0<br>cpu cores	: 0<br>apicid		: 1<br>
initial apicid	: 1<br>fpu		: yes<br>fpu_exception	: yes<br>cpuid level	: 10=
<br>wp		: yes<br>flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr =
pge mca cmov pat clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx=
 lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 =
monitor ds_cpl est tm2 ssse3 cx16 xtpr pdcm movbe lahf_lm dtherm<br>
bogomips	: 3326.46<br>clflush size	: 64<br>cache_alignment	: 64<br>address =
sizes	: 32 bits physical, 48 bits virtual<br>power management:<br><br>[7.3.=
] Module information (from /proc/modules):
brcmsmac 507576 0 - Live 0xffffffffa08e5000<br>cordic 1112 1 brcmsmac, Live=
 0xffffffffa01be000<br>brcmutil 3088 1 brcmsmac, Live 0xffffffffa01b5000<br=
>bcma 32574 1 brcmsmac, Live 0xffffffffa08d1000<br>mac80211 466081 1 brcmsm=
ac, Live 0xffffffffa083f000<br>
cfg80211 432785 2 brcmsmac,mac80211, Live 0xffffffffa07b3000<br>nfs 145340 =
0 - Live 0xffffffffa077c000<br>lockd 77125 1 nfs, Live 0xffffffffa0761000<b=
r>sunrpc 220872 2 nfs,lockd, Live 0xffffffffa0712000<br>fscache 44798 1 nfs=
, Live 0xffffffffa06fe000<br>
coretemp 6134 0 - Live 0xffffffffa0407000<br>joydev 9727 0 - Live 0xfffffff=
fa04c9000<br>iTCO_wdt 5375 0 - Live 0xffffffffa03f9000<br>i915 552693 2 - L=
ive 0xffffffffa05b1000<br>iTCO_vendor_support 1929 1 iTCO_wdt, Live 0xfffff=
fffa00eb000<br>
gpio_ich 4544 0 - Live 0xffffffffa0367000<br>snd_hda_codec_realtek 62215 1 =
- Live 0xffffffffa059a000<br>snd_hda_intel 34234 0 - Live 0xffffffffa059000=
0<br>drm_kms_helper 35346 1 i915, Live 0xffffffffa035d000<br>drm 224819 3 i=
915,drm_kms_helper, Live 0xffffffffa04e6000<br>
snd_hda_codec 102242 2 snd_hda_codec_realtek,snd_hda_intel, Live 0xffffffff=
a03dd000<br>microcode 14324 0 - Live 0xffffffffa02bd000<br>samsung_laptop 8=
625 0 - Live 0xffffffffa02b1000<br>psmouse 77065 0 - Live 0xffffffffa034900=
0<br>
serio_raw 5105 0 - Live 0xffffffffa00f5000<br>evdev 9976 12 - Live 0xffffff=
ffa01ae000<br>pcspkr 1995 0 - Live 0xffffffffa0089000<br>sky2 49987 0 - Liv=
e 0xffffffffa028f000<br>lpc_ich 11633 0 - Live 0xffffffffa0112000<br>snd_hw=
dep 6364 1 snd_hda_codec, Live 0xffffffffa00d8000<br>
i2c_i801 11237 0 - Live 0xffffffffa00d1000<br>snd_pcm 77084 2 snd_hda_intel=
,snd_hda_codec, Live 0xffffffffa0195000<br>thermal 8513 0 - Live 0xffffffff=
a0094000<br>snd_page_alloc 7298 2 snd_hda_intel,snd_pcm, Live 0xffffffffa00=
71000<br>
snd_timer 18911 1 snd_pcm, Live 0xffffffffa00c8000<br>battery 7002 0 - Live=
 0xffffffffa0030000<br>snd 59245 6 snd_hda_codec_realtek,snd_hda_intel,snd_=
hda_codec,snd_hwdep,snd_pcm,snd_timer, Live 0xffffffffa005e000<br>soundcore=
 5450 1 snd, Live 0xffffffffa0021000<br>
intel_agp 10968 1 i915, Live 0xffffffffa04df000<br>video 11170 2 i915,samsu=
ng_laptop, Live 0xffffffffa04d7000<br>intel_gtt 12744 3 i915,intel_agp, Liv=
e 0xffffffffa04cf000<br>button 4701 1 i915, Live 0xffffffffa04b7000<br>
ac 2568 0 - Live 0xffffffffa04b3000<br>arc4 2032 2 - Live 0xffffffffa04af00=
0<br>i2c_algo_bit 5423 1 i915, Live 0xffffffffa04aa000<br>i2c_core 22806 5 =
i915,drm_kms_helper,drm,i2c_i801,i2c_algo_bit, Live 0xffffffffa049d000<br>
rfkill 15633 3 cfg80211,samsung_laptop, Live 0xffffffffa02d5000<br>cpufreq_=
powersave 1246 2 - Live 0xffffffffa02d1000<br>acpi_cpufreq 10502 1 - Live 0=
xffffffffa02c3000<br>mperf 1235 1 acpi_cpufreq, Live 0xffffffffa02bb000<br>
processor 27271 1 acpi_cpufreq, Live 0xffffffffa02a1000<br>btrfs 766096 2 -=
 Live 0xffffffffa01c8000<br>crc32c 1736 1 - Live 0xffffffffa01c4000<br>libc=
rc32c 1002 1 btrfs, Live 0xffffffffa01c0000<br>zlib_deflate 20828 1 btrfs, =
Live 0xffffffffa01b7000<br>
ehci_pci 4120 0 - Live 0xffffffffa01b2000<br>ext4 475492 1 - Live 0xfffffff=
fa011f000<br>crc16 1359 1 ext4, Live 0xffffffffa011b000<br>jbd2 77640 1 ext=
4, Live 0xffffffffa00fe000<br>mbcache 5962 1 ext4, Live 0xffffffffa00f8000<=
br>
uhci_hcd 24659 0 - Live 0xffffffffa00ed000<br>ehci_hcd 47951 1 ehci_pci, Li=
ve 0xffffffffa00db000<br>usbcore 173551 3 ehci_pci,uhci_hcd,ehci_hcd, Live =
0xffffffffa009c000<br>usb_common 954 1 usbcore, Live 0xffffffffa0098000<br>
sd_mod 30946 5 - Live 0xffffffffa008b000<br>ahci 22096 4 - Live 0xffffffffa=
007f000<br>libahci 20599 1 ahci, Live 0xffffffffa0074000<br>libata 168677 2=
 ahci,libahci, Live 0xffffffffa0033000<br>scsi_mod 129647 2 sd_mod,libata, =
Live 0xffffffffa0000000<br>
<br>[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iom=
em)
/proc/ioports:<br>0000-0cf7 : PCI Bus 0000:00<br>  0000-001f : dma1<br>  00=
20-0021 : pic1<br>  0040-0043 : timer0<br>  0050-0053 : timer1<br>  0060-00=
60 : keyboard<br>  0062-0062 : EC data<br>  0064-0064 : keyboard<br>  0066-=
0066 : EC cmd<br>
  0070-0071 : rtc0<br>  0080-008f : dma page reg<br>  00a0-00a1 : pic2<br> =
 00c0-00df : dma2<br>  00f0-00ff : fpu<br>  03c0-03df : vga+<br>  04d0-04d1=
 : pnp 00:00<br>  0800-080f : pnp 00:00<br>0cf8-0cff : PCI conf1<br>0d00-fd=
ff : PCI Bus 0000:00<br>
  1000-107f : pnp 00:00<br>    1000-1003 : ACPI PM1a_EVT_BLK<br>    1004-10=
05 : ACPI PM1a_CNT_BLK<br>    1008-100b : ACPI PM_TMR<br>    1010-1015 : AC=
PI CPU throttle<br>    1020-1020 : ACPI PM2_CNT_BLK<br>    1028-102f : ACPI=
 GPE0_BLK<br>
    1030-1033 : iTCO_wdt<br>      1030-1033 : iTCO_wdt<br>    1060-107f : i=
TCO_wdt<br>      1060-107f : iTCO_wdt<br>  1180-11bf : gpio_ich<br>    1180=
-11bf : pnp 00:00<br>  164e-174c : pnp 00:00<br>  1820-183f : 0000:00:1d.0<=
br>
    1820-183f : uhci_hcd<br>  1840-185f : 0000:00:1d.1<br>    1840-185f : u=
hci_hcd<br>  1860-187f : 0000:00:1d.2<br>    1860-187f : uhci_hcd<br>  1880=
-189f : 0000:00:1d.3<br>    1880-189f : uhci_hcd<br>  18a0-18bf : 0000:00:1=
f.3<br>
    18a0-18bf : i801_smbus<br>  18c0-18cf : 0000:00:1f.2<br>    18c0-18cf :=
 ahci<br>  18d0-18d7 : 0000:00:02.0<br>  18d8-18db : 0000:00:1f.2<br>    18=
d8-18db : ahci<br>  18dc-18df : 0000:00:1f.2<br>    18dc-18df : ahci<br>
  18e0-18e7 : 0000:00:1f.2<br>    18e0-18e7 : ahci<br>  18e8-18ef : 0000:00=
:1f.2<br>    18e8-18ef : ahci<br>  2000-2fff : PCI Bus 0000:09<br>    2000-=
20ff : 0000:09:00.0<br>      2000-20ff : sky2<br>  3000-3fff : PCI Bus 0000=
:05<br>
  4000-4fff : PCI Bus 0000:07<br>  5000-5fff : PCI Bus 0000:0b<br>fe00-fe00=
 : pnp 00:00<br><br></pre><pre>/proc/iomem:<br>00000000-0000ffff : reserved
00010000-0009dbff : System RAM
0009dc00-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000ce000-000cffff : reserved
000d0000-000d3fff : PCI Bus 0000:00
000d4000-000d7fff : PCI Bus 0000:00
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000dffff : reserved
000e0000-000e3fff : PCI Bus 0000:00
000e4000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-3f5affff : System RAM
  01000000-014b4584 : Kernel code
  014b4585-018a70bf : Kernel data
  01972000-01aa2fff : Kernel bss
3f5b0000-3f5bffff : ACPI Tables
3f5c0000-3f5c2fff : ACPI Non-volatile Storage
3f5c3000-3fffffff : reserved
40000000-f7ffffff : PCI Bus 0000:00
  40000000-401fffff : PCI Bus 0000:05
  40200000-403fffff : PCI Bus 0000:07
  40400000-405fffff : PCI Bus 0000:07
  40600000-407fffff : PCI Bus 0000:09
  40800000-409fffff : PCI Bus 0000:0b
  40a00000-40bfffff : PCI Bus 0000:0b
  40c00000-40c00fff : Intel Flush Page
  40c04000-40c07fff : i915 MCHBAR
  d0000000-dfffffff : 0000:00:02.0
  e0000000-efffffff : reserved
    e0000000-efffffff : pnp 00:00
      e0000000-e10fffff : PCI MMCONFIG 0000 [bus 00-10]
  f0000000-f00fffff : 0000:00:02.0
  f0100000-f01fffff : PCI Bus 0000:05
    f0100000-f0103fff : 0000:05:00.0
      f0100000-f0103fff : bcma-pci-bridge
  f0200000-f02fffff : PCI Bus 0000:09
    f0200000-f0203fff : 0000:09:00.0
      f0200000-f0203fff : sky2
  f0300000-f037ffff : 0000:00:02.0
  f0380000-f03fffff : 0000:00:02.1
  f0400000-f0403fff : 0000:00:1b.0
    f0400000-f0403fff : ICH HD audio
  f0604000-f06043ff : 0000:00:1d.7
    f0604000-f06043ff : ehci_hcd
  f0604400-f06047ff : 0000:00:1f.2
    f0604400-f06047ff : ahci
f8000000-fbffffff : pnp 00:00
fec00000-fec0ffff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fed003ff : HPET 0
fed14000-fed17fff : pnp 00:00
fed1f410-fed1f414 : iTCO_wdt
  fed1f410-fed1f414 : iTCO_wdt
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
fef00000-feffffff : pnp 00:00
ff000000-ffffffff : reserved
00000000-0000ffff : reserved<br>00010000-0009dbff : System RAM<br>0009dc00-=
0009ffff : reserved<br>000a0000-000bffff : PCI Bus 0000:00<br>000c0000-000c=
7fff : Video ROM<br>000ce000-000cffff : reserved<br>000d0000-000d3fff : PCI=
 Bus 0000:00<br>
000d4000-000d7fff : PCI Bus 0000:00<br>000d8000-000dbfff : PCI Bus 0000:00<=
br>000dc000-000dffff : reserved<br>000e0000-000e3fff : PCI Bus 0000:00<br>0=
00e4000-000fffff : reserved<br>  000f0000-000fffff : System ROM<br>00100000=
-3f5affff : System RAM<br>
  01000000-014b4584 : Kernel code<br>  014b4585-018a70bf : Kernel data<br> =
 01972000-01aa2fff : Kernel bss<br>3f5b0000-3f5bffff : ACPI Tables<br>3f5c0=
000-3f5c2fff : ACPI Non-volatile Storage<br>3f5c3000-3fffffff : reserved<br=
>
40000000-f7ffffff : PCI Bus 0000:00<br>  40000000-401fffff : PCI Bus 0000:0=
5<br>  40200000-403fffff : PCI Bus 0000:07<br>  40400000-405fffff : PCI Bus=
 0000:07<br>  40600000-407fffff : PCI Bus 0000:09<br>  40800000-409fffff : =
PCI Bus 0000:0b<br>
  40a00000-40bfffff : PCI Bus 0000:0b<br>  40c00000-40c00fff : Intel Flush =
Page<br>  40c04000-40c07fff : i915 MCHBAR<br>  d0000000-dfffffff : 0000:00:=
02.0<br>  e0000000-efffffff : reserved<br>    e0000000-efffffff : pnp 00:00=
<br>
      e0000000-e10fffff : PCI MMCONFIG 0000 [bus 00-10]<br>  f0000000-f00ff=
fff : 0000:00:02.0<br>  f0100000-f01fffff : PCI Bus 0000:05<br>    f0100000=
-f0103fff : 0000:05:00.0<br>      f0100000-f0103fff : bcma-pci-bridge<br>
  f0200000-f02fffff : PCI Bus 0000:09<br>    f0200000-f0203fff : 0000:09:00=
.0<br>      f0200000-f0203fff : sky2<br>  f0300000-f037ffff : 0000:00:02.0<=
br>  f0380000-f03fffff : 0000:00:02.1<br>  f0400000-f0403fff : 0000:00:1b.0=
<br>
    f0400000-f0403fff : ICH HD audio<br>  f0604000-f06043ff : 0000:00:1d.7<=
br>    f0604000-f06043ff : ehci_hcd<br>  f0604400-f06047ff : 0000:00:1f.2<b=
r>    f0604400-f06047ff : ahci<br>f8000000-fbffffff : pnp 00:00<br>fec00000=
-fec0ffff : reserved<br>
  fec00000-fec003ff : IOAPIC 0<br>fed00000-fed003ff : HPET 0<br>fed14000-fe=
d17fff : pnp 00:00<br>fed1f410-fed1f414 : iTCO_wdt<br>  fed1f410-fed1f414 :=
 iTCO_wdt<br>fee00000-fee00fff : Local APIC<br>  fee00000-fee00fff : reserv=
ed<br>
fef00000-feffffff : pnp 00:00<br>ff000000-ffffffff : reserved<br><br>[7.5.]=
 PCI information (&#39;lspci -vvv&#39; as root)
00:00.0 Host bridge: Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx D=
MI Bridge<br>	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Cont=
rol: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- S=
ERR- FastB2B- DisINTx-<br>
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort+ &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0<br>	Capabilities=
: [e0] Vendor Specific Information: Len=3D08 &lt;?&gt;<br>	Kernel driver in=
 use: agpgart-intel<br>
<br>00:02.0 VGA compatible controller: Intel Corporation Atom Processor D4x=
x/D5xx/N4xx/N5xx Integrated Graphics Controller (prog-if 00 [VGA controller=
])<br>	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/=
O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- Fa=
stB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0<br>	Interrupt: p=
in A routed to IRQ 47<br>	Region 0: Memory at f0300000 (32-bit, non-prefetc=
hable) [size=3D512K]<br>
	Region 1: I/O ports at 18d0 [size=3D8]<br>	Region 2: Memory at d0000000 (3=
2-bit, prefetchable) [size=3D256M]<br>	Region 3: Memory at f0000000 (32-bit=
, non-prefetchable) [size=3D1M]<br>	Expansion ROM at &lt;unassigned&gt; [di=
sabled]<br>
	Capabilities: [90] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Address:=
 fee0300c  Data: 4152<br>	Capabilities: [d0] Power Management version 2<br>=
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)<br>
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Kernel dri=
ver in use: i915<br><br>00:02.1 Display controller: Intel Corporation Atom =
Processor D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller<br>	Subsystem:=
 Samsung Electronics Co Ltd Notebook N150P<br>
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- D=
EVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<=
br>
	Latency: 0<br>	Region 0: Memory at f0380000 (32-bit, non-prefetchable) [si=
ze=3D512K]<br>	Capabilities: [d0] Power Management version 2<br>		Flags: PM=
EClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)<br>		St=
atus: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>
<br>00:1b.0 Audio device: Intel Corporation NM10/ICH7 Family High Definitio=
n Audio Controller (rev 02)<br>	Subsystem: Samsung Electronics Co Ltd Noteb=
ook N150P<br>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- P=
arErr- Stepping- SERR+ FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Interrupt: pin A routed to IRQ 46<br>	Region 0: Memory at f0=
400000 (64-bit, non-prefetchable) [size=3D16K]<br>
	Capabilities: [50] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSo=
ftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [60] MSI: Ena=
ble+ Count=3D1/1 Maskable- 64bit+<br>
		Address: 00000000fee0300c  Data: 4162<br>	Capabilities: [70] Express (v1)=
 Root Complex Integrated Endpoint, MSI 00<br>		DevCap:	MaxPayload 128 bytes=
, PhantFunc 0, Latency L0s &lt;64ns, L1 &lt;1us<br>			ExtTag- RBE- FLReset-=
<br>
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-<br>			=
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+<br>			MaxPayload 128 bytes, Ma=
xReadReq 128 bytes<br>		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- Au=
xPwr+ TransPend-<br>
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 &lt;64=
ns, L1 &lt;1us<br>			ClockPM- Surprise- LLActRep- BwNot-<br>		LnkCtl:	ASPM =
Disabled; Disabled- Retrain- CommClk-<br>			ExtSynch- ClockPM- AutWidDis- B=
WInt- AutBWInt-<br>
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt-=
 ABWMgmt-<br>	Capabilities: [100 v1] Virtual Channel<br>		Caps:	LPEVC=3D0 R=
efClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed- WRR32- WRR64- WRR128-<br>		=
Ctrl:	ArbSelect=3DFixed<br>
		Status:	InProgress-<br>		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSn=
oopTrans-<br>			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ct=
rl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPending- =
InProgress-<br>
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixe=
d- WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	Enable+ ID=3D1 ArbSel=
ect=3DFixed TC/VC=3D80<br>			Status:	NegoPending- InProgress-<br>	Capabilit=
ies: [130 v1] Root Complex Link<br>
		Desc:	PortNumber=3D0f ComponentID=3D02 EltType=3DConfig<br>		Link0:	Desc:=
	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMapped LinkV=
alid+<br>			Addr:	00000000fed1c000<br>	Kernel driver in use: snd_hda_intel<=
br><br>00:1c.0 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express P=
ort 1 (rev 02) (prog-if 00 [Normal decode])<br>
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+<br>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- D=
EVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<=
br>
	Latency: 0, Cache Line Size: 32 bytes<br>	Bus: primary=3D00, secondary=3D0=
5, subordinate=3D05, sec-latency=3D0<br>	I/O behind bridge: 00003000-00003f=
ff<br>	Memory behind bridge: f0100000-f01fffff<br>	Prefetchable memory behi=
nd bridge: 0000000040000000-00000000401fffff<br>
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>	BridgeCtl: Parity- SERR- NoISA+ V=
GA- MAbort- &gt;Reset- FastB2B-<br>		PriDiscTmr- SecDiscTmr- DiscTmrStat- D=
iscTmrSERREn-<br>
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00<br>		DevCap:	Max=
Payload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited<br>			E=
xtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal- Fa=
tal+ Unsupported-<br>
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br>			MaxPayload 128 bytes,=
 MaxReadReq 128 bytes<br>		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq-=
 AuxPwr+ TransPend-<br>		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s=
 L1, Latency L0 &lt;256ns, L1 &lt;4us<br>
			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM L1 Enabled; RCB 64=
 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM- AutWidDis- BWIn=
t- AutBWInt-<br>		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ D=
LActive+ BWMgmt- ABWMgmt-<br>
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+<br>			=
Slot #1, PowerLimit 10.000W; Interlock- NoCompl-<br>		SltCtl:	Enable: AttnB=
tn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>			Control: AttnInd U=
nknown, PwrInd Unknown, Power- Interlock-<br>
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-<br>	=
		Changed: MRL- PresDet+ LinkState+<br>		RootCtl: ErrCorrectable- ErrNon-Fa=
tal- ErrFatal+ PMEIntEna- CRSVisible-<br>		RootCap: CRSVisible-<br>		RootSt=
a: PME ReqID 0000, PMEStatus- PMEPending-<br>
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Address:=
 fee0300c  Data: 4191<br>	Capabilities: [90] Subsystem: Samsung Electronics=
 Co Ltd Notebook N150P<br>	Capabilities: [a0] Power Management version 2<br=
>
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Cap=
abilities: [100 v1] Virtual Channel<br>		Caps:	LPEVC=3D0 RefClk=3D100ns PAT=
EntryBits=3D1<br>
		Arb:	Fixed+ WRR32- WRR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Statu=
s:	InProgress-<br>		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTran=
s-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	Ena=
ble+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>
			Status:	NegoPending- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeS=
lots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WR=
R256-<br>			Ctrl:	Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>			Status:=
	NegoPending- InProgress-<br>
	Capabilities: [180 v1] Root Complex Link<br>		Desc:	PortNumber=3D01 Compon=
entID=3D02 EltType=3DConfig<br>		Link0:	Desc:	TargetPort=3D00 TargetCompone=
nt=3D02 AssocRCRB- LinkType=3DMemMapped LinkValid+<br>			Addr:	00000000fed1=
c001<br>
	Kernel driver in use: pcieport<br><br>00:1c.1 PCI bridge: Intel Corporatio=
n NM10/ICH7 Family PCI Express Port 2 (rev 02) (prog-if 00 [Normal decode])=
<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Bus: primary=3D00, secondary=3D07, subordinate=3D07, sec-lat=
ency=3D0<br>
	I/O behind bridge: 00004000-00004fff<br>	Memory behind bridge: 40200000-40=
3fffff<br>	Prefetchable memory behind bridge: 0000000040400000-00000000405f=
ffff<br>	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort=
- &lt;TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- &gt;Reset- FastB2B-<br>		PriD=
iscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>	Capabilities: [40] Expr=
ess (v1) Root Port (Slot+), MSI 00<br>		DevCap:	MaxPayload 128 bytes, Phant=
Func 0, Latency L0s unlimited, L1 unlimited<br>
			ExtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal=
- Fatal+ Unsupported-<br>			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br=
>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br>		DevSta:	CorrErr- Uncorr=
Err- FatalErr- UnsuppReq- AuxPwr+ TransPend-<br>
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;256=
ns, L1 &lt;4us<br>			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM =
Disabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM-=
 AutWidDis- BWInt- AutBWInt-<br>
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-<br>		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Sur=
prise+<br>			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-<br>		SltCtl:	E=
nable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-<br>		SltSta:=
	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-<br>			Changed=
: MRL- PresDet- LinkState-<br>		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrF=
atal+ PMEIntEna- CRSVisible-<br>
		RootCap: CRSVisible-<br>		RootSta: PME ReqID 0000, PMEStatus- PMEPending-=
<br>	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Addr=
ess: fee0300c  Data: 41a1<br>	Capabilities: [90] Subsystem: Samsung Electro=
nics Co Ltd Notebook N150P<br>
	Capabilities: [a0] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [100 v1] Virtu=
al Channel<br>
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed+ WRR32- W=
RR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Status:	InProgress-<br>		VC=
0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ W=
RR32- WRR64- WRR128- TWRR128- WRR256-<br>
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPend=
ing- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	E=
nable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [180 v1] Root Complex=
 Link<br>		Desc:	PortNumber=3D02 ComponentID=3D02 EltType=3DConfig<br>		Lin=
k0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMap=
ped LinkValid+<br>
			Addr:	00000000fed1c001<br>	Kernel driver in use: pcieport<br><br>00:1c.2=
 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express Port 3 (rev 02)=
 (prog-if 00 [Normal decode])<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle- =
MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Bus: primary=3D00, secondary=3D09, subordinate=3D09, sec-lat=
ency=3D0<br>
	I/O behind bridge: 00002000-00002fff<br>	Memory behind bridge: f0200000-f0=
2fffff<br>	Prefetchable memory behind bridge: 0000000040600000-00000000407f=
ffff<br>	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort=
- &lt;TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- &gt;Reset- FastB2B-<br>		PriD=
iscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>	Capabilities: [40] Expr=
ess (v1) Root Port (Slot+), MSI 00<br>		DevCap:	MaxPayload 128 bytes, Phant=
Func 0, Latency L0s unlimited, L1 unlimited<br>
			ExtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal=
- Fatal+ Unsupported-<br>			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br=
>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br>		DevSta:	CorrErr- Uncorr=
Err- FatalErr- UnsuppReq- AuxPwr+ TransPend-<br>
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;256=
ns, L1 &lt;4us<br>			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM =
L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- Cl=
ockPM- AutWidDis- BWInt- AutBWInt-<br>
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt-=
 ABWMgmt-<br>		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Sur=
prise+<br>			Slot #3, PowerLimit 10.000W; Interlock- NoCompl-<br>		SltCtl:	=
Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-<br>		SltSta:=
	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-<br>			Changed=
: MRL- PresDet+ LinkState+<br>		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrF=
atal+ PMEIntEna- CRSVisible-<br>
		RootCap: CRSVisible-<br>		RootSta: PME ReqID 0000, PMEStatus- PMEPending-=
<br>	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Addr=
ess: fee0300c  Data: 41b1<br>	Capabilities: [90] Subsystem: Samsung Electro=
nics Co Ltd Notebook N150P<br>
	Capabilities: [a0] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [100 v1] Virtu=
al Channel<br>
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed+ WRR32- W=
RR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Status:	InProgress-<br>		VC=
0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ W=
RR32- WRR64- WRR128- TWRR128- WRR256-<br>
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPend=
ing- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	E=
nable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [180 v1] Root Complex=
 Link<br>		Desc:	PortNumber=3D03 ComponentID=3D02 EltType=3DConfig<br>		Lin=
k0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMap=
ped LinkValid+<br>
			Addr:	00000000fed1c001<br>	Kernel driver in use: pcieport<br><br>00:1c.3=
 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express Port 4 (rev 02)=
 (prog-if 00 [Normal decode])<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle- =
MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Bus: primary=3D00, secondary=3D0b, subordinate=3D0b, sec-lat=
ency=3D0<br>
	I/O behind bridge: 00005000-00005fff<br>	Memory behind bridge: 40800000-40=
9fffff<br>	Prefetchable memory behind bridge: 0000000040a00000-0000000040bf=
ffff<br>	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort=
- &lt;TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- &gt;Reset- FastB2B-<br>		PriD=
iscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>	Capabilities: [40] Expr=
ess (v1) Root Port (Slot+), MSI 00<br>		DevCap:	MaxPayload 128 bytes, Phant=
Func 0, Latency L0s unlimited, L1 unlimited<br>
			ExtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal=
- Fatal+ Unsupported-<br>			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br=
>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br>		DevSta:	CorrErr- Uncorr=
Err- FatalErr- UnsuppReq- AuxPwr+ TransPend-<br>
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;256=
ns, L1 &lt;4us<br>			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM =
Disabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM-=
 AutWidDis- BWInt- AutBWInt-<br>
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-<br>		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Sur=
prise+<br>			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-<br>		SltCtl:	E=
nable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-<br>		SltSta:=
	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-<br>			Changed=
: MRL- PresDet- LinkState-<br>		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrF=
atal+ PMEIntEna- CRSVisible-<br>
		RootCap: CRSVisible-<br>		RootSta: PME ReqID 0000, PMEStatus- PMEPending-=
<br>	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Addr=
ess: fee0300c  Data: 41c1<br>	Capabilities: [90] Subsystem: Samsung Electro=
nics Co Ltd Notebook N150P<br>
	Capabilities: [a0] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [100 v1] Virtu=
al Channel<br>
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed+ WRR32- W=
RR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Status:	InProgress-<br>		VC=
0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ W=
RR32- WRR64- WRR128- TWRR128- WRR256-<br>
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPend=
ing- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	E=
nable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [180 v1] Root Complex=
 Link<br>		Desc:	PortNumber=3D04 ComponentID=3D02 EltType=3DConfig<br>		Lin=
k0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMap=
ped LinkValid+<br>
			Addr:	00000000fed1c001<br>	Kernel driver in use: pcieport<br><br>00:1d.0=
 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #1 =
(rev 02) (prog-if 00 [UHCI])<br>	Subsystem: Samsung Electronics Co Ltd Note=
book N150P<br>
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- D=
EVSEL=3Dmedium &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx=
-<br>
	Latency: 0<br>	Interrupt: pin A routed to IRQ 23<br>	Region 4: I/O ports a=
t 1820 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.1 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #2 (rev 02=
) (prog-if 00 [UHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin B routed to IRQ 19<br>	Region 4: I/O ports a=
t 1840 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.2 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #3 (rev 02=
) (prog-if 00 [UHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin C routed to IRQ 18<br>	Region 4: I/O ports a=
t 1860 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.3 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #4 (rev 02=
) (prog-if 00 [UHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin D routed to IRQ 16<br>	Region 4: I/O ports a=
t 1880 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.7 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB2 EHCI Controller (rev 02) =
(prog-if 20 [EHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O- Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-=
 DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin A routed to IRQ 23<br>	Region 0: Memory at f=
0604000 (32-bit, non-prefetchable) [size=3D1K]<br>	Capabilities: [50] Power=
 Management version 2<br>		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA P=
ME(D0+,D1-,D2-,D3hot+,D3cold+)<br>
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabiliti=
es: [58] Debug port: BAR=3D1 offset=3D00a0<br>	Kernel driver in use: ehci-p=
ci<br><br>00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (re=
v e2) (prog-if 01 [Subtractive decode])<br>
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- D=
EVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<=
br>
	Latency: 0<br>	Bus: primary=3D00, secondary=3D11, subordinate=3D11, sec-la=
tency=3D32<br>	I/O behind bridge: 0000f000-00000fff<br>	Memory behind bridg=
e: fff00000-000fffff<br>	Prefetchable memory behind bridge: 00000000fff0000=
0-00000000000fffff<br>
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>	BridgeCtl: Parity- SERR- NoISA-=
 VGA- MAbort- &gt;Reset- FastB2B-<br>		PriDiscTmr- SecDiscTmr- DiscTmrStat-=
 DiscTmrSERREn-<br>
	Capabilities: [50] Subsystem: Samsung Electronics Co Ltd Notebook N150P<br=
><br>00:1f.0 ISA bridge: Intel Corporation NM10 Family LPC Controller (rev =
02)<br>	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I=
/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- F=
astB2B- DisINTx-<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0<br>	Capabiliti=
es: [e0] Vendor Specific Information: Len=3D0c &lt;?&gt;<br>	Kernel driver =
in use: lpc_ich<br>
<br>00:1f.2 SATA controller: Intel Corporation NM10/ICH7 Family SATA Contro=
ller [AHCI mode] (rev 02) (prog-if 01 [AHCI 1.0])<br>	Subsystem: Samsung El=
ectronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle=
- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0<br>	Interrupt:=
 pin B routed to IRQ 44<br>	Region 0: I/O ports at 18e8 [size=3D8]<br>	Regi=
on 1: I/O ports at 18dc [size=3D4]<br>
	Region 2: I/O ports at 18e0 [size=3D8]<br>	Region 3: I/O ports at 18d8 [si=
ze=3D4]<br>	Region 4: I/O ports at 18c0 [size=3D16]<br>	Region 5: Memory at=
 f0604400 (32-bit, non-prefetchable) [size=3D1K]<br>	Capabilities: [80] MSI=
: Enable+ Count=3D1/1 Maskable- 64bit-<br>
		Address: fee0100c  Data: 41d1<br>	Capabilities: [70] Power Management ver=
sion 2<br>		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3=
hot+,D3cold-)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PM=
E-<br>
	Kernel driver in use: ahci<br><br>00:1f.3 SMBus: Intel Corporation NM10/IC=
H7 Family SMBus Controller (rev 02)<br>	Subsystem: Samsung Electronics Co L=
td Notebook N150P<br>	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-<br>
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Interrupt: pin B routed t=
o IRQ 19<br>	Region 4: I/O ports at 18a0 [size=3D32]<br>	Kernel driver in u=
se: i801_smbus<br>
<br>05:00.0 Network controller: Broadcom Corporation BCM4313 802.11b/g/n Wi=
reless LAN Controller (rev 01)<br>	Subsystem: Wistron NeWeb Corp. Device 05=
1a<br>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- =
Stepping- SERR+ FastB2B- DisINTx-<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Interrupt: pin A routed to IRQ 16<br>	Region 0: Memory at f0=
100000 (64-bit, non-prefetchable) [size=3D16K]<br>
	Capabilities: [40] Power Management version 3<br>		Flags: PMEClk- DSI- D1+=
 D2+ AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst+ PME-Enable- DSel=3D0 DScale=3D2 PME-<br>	Capabilities: [58] Vendor Sp=
ecific Information: Len=3D78 &lt;?&gt;<br>
	Capabilities: [48] MSI: Enable- Count=3D1/1 Maskable- 64bit+<br>		Address:=
 0000000000000000  Data: 0000<br>	Capabilities: [d0] Express (v1) Endpoint,=
 MSI 00<br>		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s &lt;4us=
, L1 unlimited<br>
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-<br>		DevCtl:	Report erro=
rs: Correctable- Non-Fatal- Fatal- Unsupported-<br>			RlxdOrd- ExtTag+ Phan=
tFunc- AuxPwr- NoSnoop-<br>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br=
>
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-<br>		=
LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;4us, =
L1 &lt;64us<br>			ClockPM+ Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM L1 =
Enabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-<br>		LnkSta:	Speed 2.5GT/=
s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-<br>	Capabili=
ties: [100 v1] Advanced Error Reporting<br>		UESta:	DLP- SDES- TLP- FCP- Cm=
pltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-<br>
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- =
ECRC- UnsupReq- ACSViol-<br>		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAb=
rt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-<br>		CESta:	RxErr- Ba=
dTLP- BadDLLP- Rollover- Timeout- NonFatalErr+<br>
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+<br>		AERCa=
p:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-<br>	Capabilities=
: [13c v1] Virtual Channel<br>		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=
=3D1<br>
		Arb:	Fixed- WRR32- WRR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Statu=
s:	InProgress-<br>		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTran=
s-<br>			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	Ena=
ble+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [160 v1] Device Seria=
l Number 00-00-b1-ff-ff-4c-00-1b<br>	Capabilities: [16c v1] Power Budgeting=
 &lt;?&gt;<br>	Kernel driver in use: bcma-pci-bridge<br><br>09:00.0 Etherne=
t controller: Marvell Technology Group Ltd. 88E8040 PCI-E Fast Ethernet Con=
troller<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-=
 DisINTx+<br>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;T=
Abort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0, Cache Line Size: 32 bytes<br>	Interrupt: pin A routed to IRQ 4=
5<br>	Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=3D16K]<=
br>	Region 2: I/O ports at 2000 [size=3D256]<br>	Capabilities: [48] Power M=
anagement version 3<br>
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d+)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Cap=
abilities: [5c] MSI: Enable+ Count=3D1/1 Maskable- 64bit+<br>		Address: 000=
00000fee0300c  Data: 41e1<br>
	Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00<br>		DevCap:	MaxPa=
yload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited<br>			Ext=
Tag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-<br>		DevCtl:	Report errors: Co=
rrectable- Non-Fatal- Fatal- Unsupported-<br>
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br>			MaxPayload 128 bytes,=
 MaxReadReq 512 bytes<br>		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+=
 AuxPwr+ TransPend-<br>		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s=
 L1, Latency L0 &lt;256ns, L1 unlimited<br>
			ClockPM+ Surprise- LLActRep- BwNot-<br>		LnkCtl:	ASPM L0s L1 Enabled; RC=
B 128 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM- AutWidDis-=
 BWInt- AutBWInt-00:00.0 Host bridge: Intel Corporation Atom Processor D4xx=
/D5xx/N4xx/N5xx DMI Bridge<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O- Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast &gt;T=
Abort- &lt;TAbort- &lt;MAbort+ &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Capabilities: [e0] Vendor Specific Information: Len=3D08 &l=
t;?&gt;<br>	Kernel driver in use: agpgart-intel<br><br>00:02.0 VGA compatib=
le controller: Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx Integra=
ted Graphics Controller (prog-if 00 [VGA controller])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx+<br>	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast &gt;T=
Abort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin A routed to IRQ 47<br>	Region 0: Memory at f=
0300000 (32-bit, non-prefetchable) [size=3D512K]<br>	Region 1: I/O ports at=
 18d0 [size=3D8]<br>	Region 2: Memory at d0000000 (32-bit, prefetchable) [s=
ize=3D256M]<br>
	Region 3: Memory at f0000000 (32-bit, non-prefetchable) [size=3D1M]<br>	Ex=
pansion ROM at &lt;unassigned&gt; [disabled]<br>	Capabilities: [90] MSI: En=
able+ Count=3D1/1 Maskable- 64bit-<br>		Address: fee0300c  Data: 4152<br>	C=
apabilities: [d0] Power Management version 2<br>
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3col=
d-)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Ker=
nel driver in use: i915<br><br>00:02.1 Display controller: Intel Corporatio=
n Atom Processor D4xx/D5xx/N4xx/N5xx Integrated Graphics Controller<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast &gt;T=
Abort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Region 0: Memory at f0380000 (32-bit, non-prefetchable) [si=
ze=3D512K]<br>	Capabilities: [d0] Power Management version 2<br>		Flags: PM=
EClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)<br>		St=
atus: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>
<br>00:1b.0 Audio device: Intel Corporation NM10/ICH7 Family High Definitio=
n Audio Controller (rev 02)<br>	Subsystem: Samsung Electronics Co Ltd Noteb=
ook N150P<br>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- P=
arErr- Stepping- SERR+ FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Interrupt: pin A routed to IRQ 46<br>	Region 0: Memory at f0=
400000 (64-bit, non-prefetchable) [size=3D16K]<br>
	Capabilities: [50] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSo=
ftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [60] MSI: Ena=
ble+ Count=3D1/1 Maskable- 64bit+<br>
		Address: 00000000fee0300c  Data: 4162<br>	Capabilities: [70] Express (v1)=
 Root Complex Integrated Endpoint, MSI 00<br>		DevCap:	MaxPayload 128 bytes=
, PhantFunc 0, Latency L0s &lt;64ns, L1 &lt;1us<br>			ExtTag- RBE- FLReset-=
<br>
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-<br>			=
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+<br>			MaxPayload 128 bytes, Ma=
xReadReq 128 bytes<br>		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- Au=
xPwr+ TransPend-<br>
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 &lt;64=
ns, L1 &lt;1us<br>			ClockPM- Surprise- LLActRep- BwNot-<br>		LnkCtl:	ASPM =
Disabled; Disabled- Retrain- CommClk-<br>			ExtSynch- ClockPM- AutWidDis- B=
WInt- AutBWInt-<br>
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt-=
 ABWMgmt-<br>	Capabilities: [100 v1] Virtual Channel<br>		Caps:	LPEVC=3D0 R=
efClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed- WRR32- WRR64- WRR128-<br>		=
Ctrl:	ArbSelect=3DFixed<br>
		Status:	InProgress-<br>		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSn=
oopTrans-<br>			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ct=
rl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPending- =
InProgress-<br>
		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixe=
d- WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	Enable+ ID=3D1 ArbSel=
ect=3DFixed TC/VC=3D80<br>			Status:	NegoPending- InProgress-<br>	Capabilit=
ies: [130 v1] Root Complex Link<br>
		Desc:	PortNumber=3D0f ComponentID=3D02 EltType=3DConfig<br>		Link0:	Desc:=
	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMapped LinkV=
alid+<br>			Addr:	00000000fed1c000<br>	Kernel driver in use: snd_hda_intel<=
br><br>00:1c.0 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express P=
ort 1 (rev 02) (prog-if 00 [Normal decode])<br>
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+<br>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- D=
EVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<=
br>
	Latency: 0, Cache Line Size: 32 bytes<br>	Bus: primary=3D00, secondary=3D0=
5, subordinate=3D05, sec-latency=3D0<br>	I/O behind bridge: 00003000-00003f=
ff<br>	Memory behind bridge: f0100000-f01fffff<br>	Prefetchable memory behi=
nd bridge: 0000000040000000-00000000401fffff<br>
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>	BridgeCtl: Parity- SERR- NoISA+ V=
GA- MAbort- &gt;Reset- FastB2B-<br>		PriDiscTmr- SecDiscTmr- DiscTmrStat- D=
iscTmrSERREn-<br>
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00<br>		DevCap:	Max=
Payload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited<br>			E=
xtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal- Fa=
tal+ Unsupported-<br>
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br>			MaxPayload 128 bytes,=
 MaxReadReq 128 bytes<br>		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq-=
 AuxPwr+ TransPend-<br>		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s=
 L1, Latency L0 &lt;256ns, L1 &lt;4us<br>
			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM L1 Enabled; RCB 64=
 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM- AutWidDis- BWIn=
t- AutBWInt-<br>		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ D=
LActive+ BWMgmt- ABWMgmt-<br>
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+<br>			=
Slot #1, PowerLimit 10.000W; Interlock- NoCompl-<br>		SltCtl:	Enable: AttnB=
tn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>			Control: AttnInd U=
nknown, PwrInd Unknown, Power- Interlock-<br>
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-<br>	=
		Changed: MRL- PresDet+ LinkState+<br>		RootCtl: ErrCorrectable- ErrNon-Fa=
tal- ErrFatal+ PMEIntEna- CRSVisible-<br>		RootCap: CRSVisible-<br>		RootSt=
a: PME ReqID 0000, PMEStatus- PMEPending-<br>
	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Address:=
 fee0300c  Data: 4191<br>	Capabilities: [90] Subsystem: Samsung Electronics=
 Co Ltd Notebook N150P<br>	Capabilities: [a0] Power Management version 2<br=
>
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3col=
d+)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Cap=
abilities: [100 v1] Virtual Channel<br>		Caps:	LPEVC=3D0 RefClk=3D100ns PAT=
EntryBits=3D1<br>
		Arb:	Fixed+ WRR32- WRR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Statu=
s:	InProgress-<br>		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTran=
s-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	Ena=
ble+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>
			Status:	NegoPending- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeS=
lots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WR=
R256-<br>			Ctrl:	Enable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>			Status:=
	NegoPending- InProgress-<br>
	Capabilities: [180 v1] Root Complex Link<br>		Desc:	PortNumber=3D01 Compon=
entID=3D02 EltType=3DConfig<br>		Link0:	Desc:	TargetPort=3D00 TargetCompone=
nt=3D02 AssocRCRB- LinkType=3DMemMapped LinkValid+<br>			Addr:	00000000fed1=
c001<br>
	Kernel driver in use: pcieport<br><br>00:1c.1 PCI bridge: Intel Corporatio=
n NM10/ICH7 Family PCI Express Port 2 (rev 02) (prog-if 00 [Normal decode])=
<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Bus: primary=3D00, secondary=3D07, subordinate=3D07, sec-lat=
ency=3D0<br>
	I/O behind bridge: 00004000-00004fff<br>	Memory behind bridge: 40200000-40=
3fffff<br>	Prefetchable memory behind bridge: 0000000040400000-00000000405f=
ffff<br>	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort=
- &lt;TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- &gt;Reset- FastB2B-<br>		PriD=
iscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>	Capabilities: [40] Expr=
ess (v1) Root Port (Slot+), MSI 00<br>		DevCap:	MaxPayload 128 bytes, Phant=
Func 0, Latency L0s unlimited, L1 unlimited<br>
			ExtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal=
- Fatal+ Unsupported-<br>			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br=
>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br>		DevSta:	CorrErr- Uncorr=
Err- FatalErr- UnsuppReq- AuxPwr+ TransPend-<br>
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;256=
ns, L1 &lt;4us<br>			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM =
Disabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM-=
 AutWidDis- BWInt- AutBWInt-<br>
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-<br>		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Sur=
prise+<br>			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-<br>		SltCtl:	E=
nable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-<br>		SltSta:=
	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-<br>			Changed=
: MRL- PresDet- LinkState-<br>		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrF=
atal+ PMEIntEna- CRSVisible-<br>
		RootCap: CRSVisible-<br>		RootSta: PME ReqID 0000, PMEStatus- PMEPending-=
<br>	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Addr=
ess: fee0300c  Data: 41a1<br>	Capabilities: [90] Subsystem: Samsung Electro=
nics Co Ltd Notebook N150P<br>
	Capabilities: [a0] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [100 v1] Virtu=
al Channel<br>
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed+ WRR32- W=
RR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Status:	InProgress-<br>		VC=
0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ W=
RR32- WRR64- WRR128- TWRR128- WRR256-<br>
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPend=
ing- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	E=
nable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [180 v1] Root Complex=
 Link<br>		Desc:	PortNumber=3D02 ComponentID=3D02 EltType=3DConfig<br>		Lin=
k0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMap=
ped LinkValid+<br>
			Addr:	00000000fed1c001<br>	Kernel driver in use: pcieport<br><br>00:1c.2=
 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express Port 3 (rev 02)=
 (prog-if 00 [Normal decode])<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle- =
MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Bus: primary=3D00, secondary=3D09, subordinate=3D09, sec-lat=
ency=3D0<br>
	I/O behind bridge: 00002000-00002fff<br>	Memory behind bridge: f0200000-f0=
2fffff<br>	Prefetchable memory behind bridge: 0000000040600000-00000000407f=
ffff<br>	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort=
- &lt;TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- &gt;Reset- FastB2B-<br>		PriD=
iscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>	Capabilities: [40] Expr=
ess (v1) Root Port (Slot+), MSI 00<br>		DevCap:	MaxPayload 128 bytes, Phant=
Func 0, Latency L0s unlimited, L1 unlimited<br>
			ExtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal=
- Fatal+ Unsupported-<br>			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br=
>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br>		DevSta:	CorrErr- Uncorr=
Err- FatalErr- UnsuppReq- AuxPwr+ TransPend-<br>
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;256=
ns, L1 &lt;4us<br>			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM =
L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- Cl=
ockPM- AutWidDis- BWInt- AutBWInt-<br>
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt-=
 ABWMgmt-<br>		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Sur=
prise+<br>			Slot #3, PowerLimit 10.000W; Interlock- NoCompl-<br>		SltCtl:	=
Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-<br>		SltSta:=
	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-<br>			Changed=
: MRL- PresDet+ LinkState+<br>		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrF=
atal+ PMEIntEna- CRSVisible-<br>
		RootCap: CRSVisible-<br>		RootSta: PME ReqID 0000, PMEStatus- PMEPending-=
<br>	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Addr=
ess: fee0300c  Data: 41b1<br>	Capabilities: [90] Subsystem: Samsung Electro=
nics Co Ltd Notebook N150P<br>
	Capabilities: [a0] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [100 v1] Virtu=
al Channel<br>
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed+ WRR32- W=
RR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Status:	InProgress-<br>		VC=
0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ W=
RR32- WRR64- WRR128- TWRR128- WRR256-<br>
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPend=
ing- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	E=
nable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [180 v1] Root Complex=
 Link<br>		Desc:	PortNumber=3D03 ComponentID=3D02 EltType=3DConfig<br>		Lin=
k0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMap=
ped LinkValid+<br>
			Addr:	00000000fed1c001<br>	Kernel driver in use: pcieport<br><br>00:1c.3=
 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express Port 4 (rev 02)=
 (prog-if 00 [Normal decode])<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle- =
MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Bus: primary=3D00, secondary=3D0b, subordinate=3D0b, sec-lat=
ency=3D0<br>
	I/O behind bridge: 00005000-00005fff<br>	Memory behind bridge: 40800000-40=
9fffff<br>	Prefetchable memory behind bridge: 0000000040a00000-0000000040bf=
ffff<br>	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort=
- &lt;TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- &gt;Reset- FastB2B-<br>		PriD=
iscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-<br>	Capabilities: [40] Expr=
ess (v1) Root Port (Slot+), MSI 00<br>		DevCap:	MaxPayload 128 bytes, Phant=
Func 0, Latency L0s unlimited, L1 unlimited<br>
			ExtTag- RBE- FLReset-<br>		DevCtl:	Report errors: Correctable- Non-Fatal=
- Fatal+ Unsupported-<br>			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br=
>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br>		DevSta:	CorrErr- Uncorr=
Err- FatalErr- UnsuppReq- AuxPwr+ TransPend-<br>
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;256=
ns, L1 &lt;4us<br>			ClockPM- Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM =
Disabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM-=
 AutWidDis- BWInt- AutBWInt-<br>
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt-=
 ABWMgmt-<br>		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Sur=
prise+<br>			Slot #0, PowerLimit 0.000W; Interlock- NoCompl-<br>		SltCtl:	E=
nable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-<br>
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-<br>		SltSta:=
	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-<br>			Changed=
: MRL- PresDet- LinkState-<br>		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrF=
atal+ PMEIntEna- CRSVisible-<br>
		RootCap: CRSVisible-<br>		RootSta: PME ReqID 0000, PMEStatus- PMEPending-=
<br>	Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-<br>		Addr=
ess: fee0300c  Data: 41c1<br>	Capabilities: [90] Subsystem: Samsung Electro=
nics Co Ltd Notebook N150P<br>
	Capabilities: [a0] Power Management version 2<br>		Flags: PMEClk- DSI- D1-=
 D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabilities: [100 v1] Virtu=
al Channel<br>
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1<br>		Arb:	Fixed+ WRR32- W=
RR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Status:	InProgress-<br>		VC=
0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-<br>			Arb:	Fixed+ W=
RR32- WRR64- WRR128- TWRR128- WRR256-<br>
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>			Status:	NegoPend=
ing- InProgress-<br>		VC1:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTr=
ans-<br>			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	E=
nable- ID=3D0 ArbSelect=3DFixed TC/VC=3D00<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [180 v1] Root Complex=
 Link<br>		Desc:	PortNumber=3D04 ComponentID=3D02 EltType=3DConfig<br>		Lin=
k0:	Desc:	TargetPort=3D00 TargetComponent=3D02 AssocRCRB- LinkType=3DMemMap=
ped LinkValid+<br>
			Addr:	00000000fed1c001<br>	Kernel driver in use: pcieport<br><br>00:1d.0=
 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #1 =
(rev 02) (prog-if 00 [UHCI])<br>	Subsystem: Samsung Electronics Co Ltd Note=
book N150P<br>
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- D=
EVSEL=3Dmedium &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx=
-<br>
	Latency: 0<br>	Interrupt: pin A routed to IRQ 23<br>	Region 4: I/O ports a=
t 1820 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.1 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #2 (rev 02=
) (prog-if 00 [UHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin B routed to IRQ 19<br>	Region 4: I/O ports a=
t 1840 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.2 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #3 (rev 02=
) (prog-if 00 [UHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin C routed to IRQ 18<br>	Region 4: I/O ports a=
t 1860 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.3 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB UHCI Controller #4 (rev 02=
) (prog-if 00 [UHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-=
 DisINTx-<br>	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin D routed to IRQ 16<br>	Region 4: I/O ports a=
t 1880 [size=3D32]<br>	Kernel driver in use: uhci_hcd<br><br>00:1d.7 USB co=
ntroller: Intel Corporation NM10/ICH7 Family USB2 EHCI Controller (rev 02) =
(prog-if 20 [EHCI])<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O- Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-=
 DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt=
;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0<br>	Interrupt: pin A routed to IRQ 23<br>	Region 0: Memory at f=
0604000 (32-bit, non-prefetchable) [size=3D1K]<br>	Capabilities: [50] Power=
 Management version 2<br>		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D375mA P=
ME(D0+,D1-,D2-,D3hot+,D3cold+)<br>
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Capabiliti=
es: [58] Debug port: BAR=3D1 offset=3D00a0<br>	Kernel driver in use: ehci-p=
ci<br><br>00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (re=
v e2) (prog-if 01 [Subtractive decode])<br>
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-<br>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- D=
EVSEL=3Dfast &gt;TAbort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<=
br>
	Latency: 0<br>	Bus: primary=3D00, secondary=3D11, subordinate=3D11, sec-la=
tency=3D32<br>	I/O behind bridge: 0000f000-00000fff<br>	Memory behind bridg=
e: fff00000-000fffff<br>	Prefetchable memory behind bridge: 00000000fff0000=
0-00000000000fffff<br>
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort+ &lt;SERR- &lt;PERR-<br>	BridgeCtl: Parity- SERR- NoISA-=
 VGA- MAbort- &gt;Reset- FastB2B-<br>		PriDiscTmr- SecDiscTmr- DiscTmrStat-=
 DiscTmrSERREn-<br>
	Capabilities: [50] Subsystem: Samsung Electronics Co Ltd Notebook N150P<br=
><br>00:1f.0 ISA bridge: Intel Corporation NM10 Family LPC Controller (rev =
02)<br>	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I=
/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- F=
astB2B- DisINTx-<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0<br>	Capabiliti=
es: [e0] Vendor Specific Information: Len=3D0c &lt;?&gt;<br>	Kernel driver =
in use: lpc_ich<br>
<br>00:1f.2 SATA controller: Intel Corporation NM10/ICH7 Family SATA Contro=
ller [AHCI mode] (rev 02) (prog-if 01 [AHCI 1.0])<br>	Subsystem: Samsung El=
ectronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem+ BusMaster+ SpecCycle=
- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+<br>
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0<br>	Interrupt:=
 pin B routed to IRQ 44<br>	Region 0: I/O ports at 18e8 [size=3D8]<br>	Regi=
on 1: I/O ports at 18dc [size=3D4]<br>
	Region 2: I/O ports at 18e0 [size=3D8]<br>	Region 3: I/O ports at 18d8 [si=
ze=3D4]<br>	Region 4: I/O ports at 18c0 [size=3D16]<br>	Region 5: Memory at=
 f0604400 (32-bit, non-prefetchable) [size=3D1K]<br>	Capabilities: [80] MSI=
: Enable+ Count=3D1/1 Maskable- 64bit-<br>
		Address: fee0100c  Data: 41d1<br>	Capabilities: [70] Power Management ver=
sion 2<br>		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3=
hot+,D3cold-)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PM=
E-<br>
	Kernel driver in use: ahci<br><br>00:1f.3 SMBus: Intel Corporation NM10/IC=
H7 Family SMBus Controller (rev 02)<br>	Subsystem: Samsung Electronics Co L=
td Notebook N150P<br>	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGA=
Snoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-<br>
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium &gt;TAbort- &lt;=
TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Interrupt: pin B routed t=
o IRQ 19<br>	Region 4: I/O ports at 18a0 [size=3D32]<br>	Kernel driver in u=
se: i801_smbus<br>
<br>05:00.0 Network controller: Broadcom Corporation BCM4313 802.11b/g/n Wi=
reless LAN Controller (rev 01)<br>	Subsystem: Wistron NeWeb Corp. Device 05=
1a<br>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- =
Stepping- SERR+ FastB2B- DisINTx-<br>
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;TAbort- &lt;TA=
bort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>	Latency: 0, Cache Line Size=
: 32 bytes<br>	Interrupt: pin A routed to IRQ 16<br>	Region 0: Memory at f0=
100000 (64-bit, non-prefetchable) [size=3D16K]<br>
	Capabilities: [40] Power Management version 3<br>		Flags: PMEClk- DSI- D1+=
 D2+ AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)<br>		Status: D0 NoSof=
tRst+ PME-Enable- DSel=3D0 DScale=3D2 PME-<br>	Capabilities: [58] Vendor Sp=
ecific Information: Len=3D78 &lt;?&gt;<br>
	Capabilities: [48] MSI: Enable- Count=3D1/1 Maskable- 64bit+<br>		Address:=
 0000000000000000  Data: 0000<br>	Capabilities: [d0] Express (v1) Endpoint,=
 MSI 00<br>		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s &lt;4us=
, L1 unlimited<br>
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-<br>		DevCtl:	Report erro=
rs: Correctable- Non-Fatal- Fatal- Unsupported-<br>			RlxdOrd- ExtTag+ Phan=
tFunc- AuxPwr- NoSnoop-<br>			MaxPayload 128 bytes, MaxReadReq 128 bytes<br=
>
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-<br>		=
LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 &lt;4us, =
L1 &lt;64us<br>			ClockPM+ Surprise- LLActRep+ BwNot-<br>		LnkCtl:	ASPM L1 =
Enabled; RCB 64 bytes Disabled- Retrain- CommClk+<br>
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-<br>		LnkSta:	Speed 2.5GT/=
s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-<br>	Capabili=
ties: [100 v1] Advanced Error Reporting<br>		UESta:	DLP- SDES- TLP- FCP- Cm=
pltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-<br>
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- =
ECRC- UnsupReq- ACSViol-<br>		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAb=
rt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-<br>		CESta:	RxErr- Ba=
dTLP- BadDLLP- Rollover- Timeout- NonFatalErr+<br>
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+<br>		AERCa=
p:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-<br>	Capabilities=
: [13c v1] Virtual Channel<br>		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=
=3D1<br>
		Arb:	Fixed- WRR32- WRR64- WRR128-<br>		Ctrl:	ArbSelect=3DFixed<br>		Statu=
s:	InProgress-<br>		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTran=
s-<br>			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-<br>			Ctrl:	Ena=
ble+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01<br>
			Status:	NegoPending- InProgress-<br>	Capabilities: [160 v1] Device Seria=
l Number 00-00-b1-ff-ff-4c-00-1b<br>	Capabilities: [16c v1] Power Budgeting=
 &lt;?&gt;<br>	Kernel driver in use: bcma-pci-bridge<br><br>09:00.0 Etherne=
t controller: Marvell Technology Group Ltd. 88E8040 PCI-E Fast Ethernet Con=
troller<br>
	Subsystem: Samsung Electronics Co Ltd Notebook N150P<br>	Control: I/O+ Mem=
+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-=
 DisINTx+<br>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast &gt;T=
Abort- &lt;TAbort- &lt;MAbort- &gt;SERR- &lt;PERR- INTx-<br>
	Latency: 0, Cache Line Size: 32 bytes<br>	Interrupt: pin A routed to IRQ 4=
5<br>	Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=3D16K]<=
br>	Region 2: I/O ports at 2000 [size=3D256]<br>	Capabilities: [48] Power M=
anagement version 3<br>
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D3col=
d+)<br>		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-<br>	Cap=
abilities: [5c] MSI: Enable+ Count=3D1/1 Maskable- 64bit+<br>		Address: 000=
00000fee0300c  Data: 41e1<br>
	Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00<br>		DevCap:	MaxPa=
yload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited<br>			Ext=
Tag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-<br>		DevCtl:	Report errors: Co=
rrectable- Non-Fatal- Fatal- Unsupported-<br>
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-<br>			MaxPayload 128 bytes,=
 MaxReadReq 512 bytes<br>		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+=
 AuxPwr+ TransPend-<br>		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s=
 L1, Latency L0 &lt;256ns, L1 unlimited<br>
			ClockPM+ Surprise- LLActRep- BwNot-<br>		LnkCtl:	ASPM L0s L1 Enabled; RC=
B 128 bytes Disabled- Retrain- CommClk+<br>			ExtSynch- ClockPM- AutWidDis-=
 BWInt- AutBWInt-<br>		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotC=
lk+ DLActive- BWMgmt- ABWMgmt-<br>
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not S=
upported<br>		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-,=
 OBFF Disabled<br>		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-<br>
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- Compl=
ianceSOS-<br>			 Compliance De-emphasis: -6dB<br>		LnkSta2: Current De-emph=
asis Level: -6dB, EqualizationComplete-, EqualizationPhase1-<br>			 Equaliz=
ationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-<br>
	Capabilities: [100 v1] Advanced Error Reporting<br>		UESta:	DLP- SDES- TLP=
- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol=
-<br>		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- Malf=
TLP- ECRC- UnsupReq- ACSViol-<br>
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+=
 ECRC- UnsupReq- ACSViol-<br>		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Tim=
eout- NonFatalErr+<br>		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- N=
onFatalErr+<br>
		AERCap:	First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-<br>	Capab=
ilities: [130 v1] Device Serial Number d3-4c-cf-ff-ff-54-24-00<br>	Kernel d=
river in use: sky2<br><br>		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- =
SlotClk+ DLActive- BWMgmt- ABWMgmt-<br>
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not S=
upported<br>		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-,=
 OBFF Disabled<br>		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-<br>
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- Compl=
ianceSOS-<br>			 Compliance De-emphasis: -6dB<br>		LnkSta2: Current De-emph=
asis Level: -6dB, EqualizationComplete-, EqualizationPhase1-<br>			 Equaliz=
ationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-<br>
	Capabilities: [100 v1] Advanced Error Reporting<br>		UESta:	DLP- SDES- TLP=
- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol=
-<br>		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- Malf=
TLP- ECRC- UnsupReq- ACSViol-<br>
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+=
 ECRC- UnsupReq- ACSViol-<br>		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Tim=
eout- NonFatalErr+<br>		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- N=
onFatalErr+<br>
		AERCap:	First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-<br>	Capab=
ilities: [130 v1] Device Serial Number d3-4c-cf-ff-ff-54-24-00<br>	Kernel d=
river in use: sky2<br><br>[7.6.] SCSI information (from /proc/scsi/scsi)
Attached devices:<br>Host: scsi0 Channel: 00 Id: 00 Lun: 00<br>  Vendor: AT=
A      Model: Hitachi HTS54502 Rev: PB2O<br>  Type:   Direct-Access        =
            ANSI  SCSI revision: 05<br><br>[7.7.] Other information that mi=
ght be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
    Not sure. Let me know if I can do anything more!<br><br></pre><pre>Resp=
ectfully yours,<br>  Alexander Hirsch<br></pre></div>

--001a11c231def3dbac04dbccf835--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
