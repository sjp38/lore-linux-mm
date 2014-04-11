Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id B58B36B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 05:25:08 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id pv20so3253113lab.37
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 02:25:06 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id rd2si5068258lac.177.2014.04.11.02.25.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 02:25:05 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1WYXhn-0003ZU-QG
	for linux-mm@kvack.org; Fri, 11 Apr 2014 11:25:04 +0200
Received: from 217.64.254.218.mactelecom.net ([217.64.254.218])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 11:25:03 +0200
Received: from rblists by 217.64.254.218.mactelecom.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 11:25:03 +0200
From: =?ISO-8859-1?Q?Rapha=EBl_Bauduin?= <rblists@gmail.com>
Subject: PROBLEM:  unable to handle kernel paging request
Date: Fri, 11 Apr 2014 10:41:17 +0200
Message-ID: <li89rd$vjd$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I'm getting regular kernel paging request errors on a server running a 
vanilla kernel 2.6.32.61. Since 7 march, there have been 10 such errors.

We have not been able to identify circumstances in which this bug happens.

Here is the last one:

BUG: unable to handle kernel paging request at ffff8804c001fb39
IP: [<ffffffff810bdbf3>] page_evictable+0x25/0x81
PGD 1002063 PUD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu15/topology/thread_siblings
CPU 6
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 
nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT xt_tcpudp kvm_amd 
kvm ip6table_filter ip6_tables iptable_filter ip_tables x_tables tun 
nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc bridge stp 
bonding dm_round_robin dm_multipath scsi_dh loop snd_pcm snd_timer snd 
soundcore snd_page_alloc serio_raw evdev tpm_tis tpm tpm_bios psmouse 
pcspkr button amd64_edac_mod edac_core edac_mce_amd container i2c_piix4 
shpchp pci_hotplug i2c_core processor ext3 jbd mbcache dm_mirror 
dm_region_hash dm_log dm_snapshot dm_mod sd_mod crc_t10dif lpfc mptsas 
scsi_transport_fc mptscsih mptbase scsi_tgt ehci_hcd scsi_transport_sas 
tg3 ohci_hcd libphy scsi_mod usbcore nls_base thermal fan thermal_sys 
[last unloaded: scsi_wait_scan]
Pid: 185, comm: kswapd0 Not tainted 2.6.32.61vanilla #1 PRIMERGY BX630 
S2
RIP: 0010:[<ffffffff810bdbf3>]  [<ffffffff810bdbf3>] 
page_evictable+0x25/0x81
RSP: 0018:ffff880416a3ba80  EFLAGS: 00010282
RAX: ffff8804c001fad6 RBX: ffffea000ba17088 RCX: 0000000000000020
RDX: 020000000002004c RSI: 0000000000000000 RDI: ffffea000ba17088
RBP: ffff880000015c80 R08: ffff880426458f00 R09: ffff880000015c80
R10: 0000000000000002 R11: ffff8800451e9850 R12: ffffea000ba170b0
R13: 0000000000000000 R14: 0000000000000001 R15: 0000000000000020
FS:  00007f9e11b07820(0000) GS:ffff88000fcc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffff8804c001fb39 CR3: 00000001ac27d000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kswapd0 (pid: 185, threadinfo ffff880416a3a000, task 
ffff8804150f4600)
Stack:
  0000000000000020 ffffffff810bec01 0000000000000000 ffffea0000000001
<0> ffffea0000000001 ffffea0005cdd6f8 0000000000000009 ffff880416a3bb00
<0> ffff880416a3be10 ffff8800000170c0 0000001500000000 ffff8800000170c0
Call Trace:
  [<ffffffff810bec01>] ? shrink_active_list+0x19e/0x2d9
  [<ffffffff810bedfb>] ? shrink_list+0xbf/0x767
  [<ffffffff810bb3c9>] ? determine_dirtyable_memory+0xd/0x1d
  [<ffffffff810bb441>] ? get_dirty_limits+0x1d/0x259
  [<ffffffff810bf723>] ? shrink_zone+0x280/0x342
  [<ffffffff810c0148>] ? kswapd+0x4b9/0x683
  [<ffffffff810bd7df>] ? isolate_pages_global+0x0/0x20f
  [<ffffffff810651de>] ? autoremove_wake_function+0x0/0x2e
  [<ffffffff810bfc8f>] ? kswapd+0x0/0x683
  [<ffffffff81064f11>] ? kthread+0x79/0x81
  [<ffffffff81011baa>] ? child_rip+0xa/0x20
  [<ffffffff81064e98>] ? kthread+0x0/0x81
  [<ffffffff81011ba0>] ? child_rip+0x0/0x20
Code: 81 e9 83 2a 16 00 48 83 ec 08 48 8b 17 48 8b 47 18 f7 c2 00 00 01 
00 74 09 48 c7 c0 80 9f 46 81 eb 09 a8 01 75 0b 48 85 c0 74 06 <f6> 40 
63 02 75 4b f7 c2 00 00 40 00 75 43 48 85 f6 74 42 48 8b
RIP  [<ffffffff810bdbf3>] page_evictable+0x25/0x81
  RSP <ffff880416a3ba80>
CR2: ffff8804c001fb39
---[ end trace 41d830aa2ac6f872 ]---

Addresses reported in these 10 occurences are:
00000000c001fade
ffff8804c001fade
ffff8804c001fb2e
ffff8804c001fb39

I can send all 10 bug traces if that can help. (Is an attachment of 10K 
ok for the list?)

The server has 16Gb of RAM, 32Gb of swap. Total memory configured for 
KVM instance is 13.5Gb.

I can send you all further information you might need, just let me know.


Here are further details:

~# cat /proc/version
Linux version 2.6.32.61vanilla (root@sSlave01) (gcc version 4.3.2 
(Debian 4.3.2-1.1) ) #1 SMP Fri Mar 7 13:29:11 CET 2014

# ./ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux sMaster01 2.6.32.61vanilla #1 SMP Fri Mar 7 13:29:11 CET 2014 
x86_64 GNU/Linux

Gnu C                  4.3.2
Gnu make               3.81
binutils               2.18.0.20080103
util-linux             2.13.1.1
mount                  2.13.1.1
module-init-tools      3.4
e2fsprogs              1.41.3
Linux C Library        2.7
Dynamic linker (ldd)   2.7
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               6.10
udev                   125
Modules Loaded         ipt_MASQUERADE iptable_nat nf_nat 
nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT 
xt_tcpudp kvm_amd kvm ip6table_filter ip6_tables iptable_filter 
ip_tables x_tables tun nfsd exportfs nfs lockd fscache nfs_acl 
auth_rpcgss sunrpc bridge stp bonding dm_round_robin dm_multipath 
scsi_dh loop snd_pcm snd_timer snd soundcore serio_raw snd_page_alloc 
tpm_tis psmouse tpm tpm_bios pcspkr evdev amd64_edac_mod edac_core 
edac_mce_amd button container i2c_piix4 processor shpchp pci_hotplug 
i2c_core ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot 
dm_mod sd_mod crc_t10dif mptsas lpfc mptscsih scsi_transport_fc ehci_hcd 
mptbase scsi_tgt scsi_transport_sas tg3 ohci_hcd libphy scsi_mod usbcore 
nls_base thermal fan thermal_sys

There are 16 cores, here's an extract:
# cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 16
model           : 4
model name      : Quad-Core AMD Opteron(tm) Processor 8380
stepping        : 2
cpu MHz         : 2500.037
cache size      : 512 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 4
apicid          : 4
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext 
fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good 
nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm 
extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt
bogomips        : 5000.06
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

# cat /proc/modules
ipt_MASQUERADE 1554 0 - Live 0xffffffffa01d2000
iptable_nat 4203 0 - Live 0xffffffffa0185000
nf_nat 13100 2 ipt_MASQUERADE,iptable_nat, Live 0xffffffffa01b3000
nf_conntrack_ipv4 9849 3 iptable_nat,nf_nat, Live 0xffffffffa0171000
nf_defrag_ipv4 1139 1 nf_conntrack_ipv4, Live 0xffffffffa0160000
xt_conntrack 2407 0 - Live 0xffffffffa0095000
nf_conntrack 45959 5 
ipt_MASQUERADE,iptable_nat,nf_nat,nf_conntrack_ipv4,xt_conntrack, Live 
0xffffffffa029e000
ipt_REJECT 1953 0 - Live 0xffffffffa007b000
xt_tcpudp 2319 0 - Live 0xffffffffa001c000
kvm_amd 31620 36 - Live 0xffffffffa014f000
kvm 214143 1 kvm_amd, Live 0xffffffffa045a000
ip6table_filter 2384 0 - Live 0xffffffffa0457000
ip6_tables 15091 1 ip6table_filter, Live 0xffffffffa044d000
iptable_filter 2258 0 - Live 0xffffffffa0447000
ip_tables 13915 2 iptable_nat,iptable_filter, Live 0xffffffffa043d000
x_tables 12845 7 
ipt_MASQUERADE,iptable_nat,xt_conntrack,ipt_REJECT,xt_tcpudp,ip6_tables,ip_tables, 
Live 0xffffffffa0431000
tun 10748 22 - Live 0xffffffffa0428000
nfsd 252542 13 - Live 0xffffffffa03db000
exportfs 3074 1 nfsd, Live 0xffffffffa03d5000
nfs 239354 0 - Live 0xffffffffa0386000
lockd 57267 2 nfsd,nfs, Live 0xffffffffa036f000
fscache 29162 1 nfs, Live 0xffffffffa035d000
nfs_acl 2031 2 nfsd,nfs, Live 0xffffffffa0357000
auth_rpcgss 33316 2 nfsd,nfs, Live 0xffffffffa0346000
sunrpc 160476 21 nfsd,nfs,lockd,nfs_acl,auth_rpcgss, Live 0xffffffffa0307000
bridge 39278 0 - Live 0xffffffffa02f4000
stp 1440 1 bridge, Live 0xffffffffa02ee000
bonding 73895 0 - Live 0xffffffffa02d1000
dm_round_robin 2228 12 - Live 0xffffffffa02cb000
dm_multipath 13088 7 dm_round_robin, Live 0xffffffffa02c1000
scsi_dh 4640 1 dm_multipath, Live 0xffffffffa02b9000
loop 11703 0 - Live 0xffffffffa02b0000
snd_pcm 60487 0 - Live 0xffffffffa028d000
snd_timer 15534 1 snd_pcm, Live 0xffffffffa0282000
snd 46430 2 snd_pcm,snd_timer, Live 0xffffffffa026a000
soundcore 4598 1 snd, Live 0xffffffffa0262000
serio_raw 3752 0 - Live 0xffffffffa025c000
snd_page_alloc 6089 1 snd_pcm, Live 0xffffffffa0254000
tpm_tis 7448 0 - Live 0xffffffffa024c000
psmouse 49681 0 - Live 0xffffffffa0237000
tpm 10023 1 tpm_tis, Live 0xffffffffa022d000
tpm_bios 4521 1 tpm, Live 0xffffffffa0226000
pcspkr 1699 0 - Live 0xffffffffa0220000
evdev 7352 2 - Live 0xffffffffa0218000
amd64_edac_mod 13710 0 - Live 0xffffffffa020d000
edac_core 29261 6 amd64_edac_mod, Live 0xffffffffa01fb000
edac_mce_amd 6337 1 amd64_edac_mod, Live 0xffffffffa01f4000
button 4650 0 - Live 0xffffffffa01ec000
container 2389 0 - Live 0xffffffffa0080000
i2c_piix4 8328 0 - Live 0xffffffffa01e4000
processor 29727 0 - Live 0xffffffffa01d4000
shpchp 26248 0 - Live 0xffffffffa01c6000
pci_hotplug 21587 1 shpchp, Live 0xffffffffa01b9000
i2c_core 15739 1 i2c_piix4, Live 0xffffffffa01ad000
ext3 105686 3 - Live 0xffffffffa0188000
jbd 36877 1 ext3, Live 0xffffffffa0175000
mbcache 5050 1 ext3, Live 0xffffffffa016d000
dm_mirror 10827 0 - Live 0xffffffffa0164000
dm_region_hash 6584 1 dm_mirror, Live 0xffffffffa015c000
dm_log 7381 2 dm_mirror,dm_region_hash, Live 0xffffffffa00cb000
dm_snapshot 18289 0 - Live 0xffffffffa003f000
dm_mod 53338 35 dm_multipath,dm_mirror,dm_log,dm_snapshot, Live 
0xffffffffa012b000
sd_mod 29657 15 - Live 0xffffffffa0145000
crc_t10dif 1276 1 sd_mod, Live 0xffffffffa000c000
mptsas 28916 2 - Live 0xffffffffa013b000
lpfc 360864 24 - Live 0xffffffffa00d0000
mptscsih 16360 1 mptsas, Live 0xffffffffa0088000
scsi_transport_fc 35131 1 lpfc, Live 0xffffffffa0070000
ehci_hcd 31457 0 - Live 0xffffffffa00c1000
mptbase 48190 2 mptsas,mptscsih, Live 0xffffffffa00b3000
scsi_tgt 8466 1 scsi_transport_fc, Live 0xffffffffa0005000
scsi_transport_sas 19673 1 mptsas, Live 0xffffffffa0046000
tg3 95311 0 - Live 0xffffffffa0099000
ohci_hcd 19071 0 - Live 0xffffffffa008e000
libphy 13446 1 tg3, Live 0xffffffffa0082000
scsi_mod 126117 8 
scsi_dh,sd_mod,mptsas,lpfc,mptscsih,scsi_transport_fc,scsi_tgt,scsi_transport_sas, 
Live 0xffffffffa004f000
usbcore 122727 3 ehci_hcd,ohci_hcd, Live 0xffffffffa001f000
nls_base 6457 1 usbcore, Live 0xffffffffa0018000
thermal 11674 0 - Live 0xffffffffa000f000
fan 3346 0 - Live 0xffffffffa0009000
thermal_sys 11942 3 processor,thermal,fan, Live 0xffffffffa0000000

# cat /proc/ioports
0000-3fff : PCI Bus #00
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
   0100-0101 : pnp 00:09
   0200-020f : pnp 00:09
   02f8-02ff : serial
   03c0-03df : vga+
   03f8-03ff : serial
   040b-040b : pnp 00:09
   04d0-04d1 : pnp 00:09
   04d6-04d6 : pnp 00:09
   0500-0560 : pnp 00:09
     0500-0503 : ACPI PM1a_EVT_BLK
     0504-0505 : ACPI PM1a_CNT_BLK
     0508-050b : ACPI PM_TMR
     050c-0511 : ACPI CPU throttle
     0514-051b : ACPI GPE1_BLK
     0540-0543 : ACPI PM1b_EVT_BLK
     0544-0545 : ACPI PM1b_CNT_BLK
     0550-0557 : ACPI GPE0_BLK
     0558-055b : pnp 00:09
   0580-058f : pnp 00:09
     0580-0587 : piix4_smbus
   0590-0593 : pnp 00:09
   0600-061f : pnp 00:09
   0620-0623 : pnp 00:09
   0624-067f : pnp 00:09
   06c0-06c0 : pnp 00:09
   0700-0703 : pnp 00:09
   0c00-0c01 : pnp 00:09
   0c06-0c08 : pnp 00:09
   0c14-0c14 : pnp 00:09
   0c49-0c4a : pnp 00:09
   0c50-0c53 : pnp 00:09
   0c6c-0c6c : pnp 00:09
   0c6f-0c6f : pnp 00:09
   0ca4-0ca5 : pnp 00:09
   0cd6-0cd7 : pnp 00:09
   0cf8-0cff : PCI conf1
   0e00-0e7f : pnp 00:09
   0f00-0f7f : pnp 00:09
     0f50-0f58 : pnp 00:09
   1000-10ff : 0000:00:03.0
   1400-14ff : 0000:00:03.1
   1800-18ff : 0000:00:03.2
   2000-2fff : PCI Bus 0000:03
     2000-20ff : 0000:03:00.0
   3000-3fff : PCI Bus 0000:04
     3000-30ff : 0000:04:00.0
     3400-34ff : 0000:04:00.1
4000-5fff : PCI Bus #10
   4000-4fff : PCI Bus 0000:11
     4000-40ff : 0000:11:00.0
   5000-5fff : PCI Bus 0000:12
     5000-50ff : 0000:12:00.0
     5400-54ff : 0000:12:00.1
6000-ffff : PCI Bus #00

# cat /proc/iomem
00000000-0000ffff : reserved
00010000-0009c7ff : System RAM
0009c800-0009ffff : reserved
000a0000-000bffff : PCI Bus #00
000d0000-000fffff : reserved
00100000-d7f3ffff : System RAM
   01000000-01303b04 : Kernel code
   01303b05-014d0d8f : Kernel data
   0156f000-01680403 : Kernel bss
   20000000-23ffffff : GART
d7f40000-d7f53fff : ACPI Tables
d7f54000-d7f7ffff : ACPI Non-volatile Storage
d7f80000-d7ffffff : reserved
d8000000-df0fffff : PCI Bus #00
   d8000000-d81fffff : PCI Bus 0000:03
     d8000000-d81fffff : 0000:03:00.0
   d8200000-d82fffff : PCI Bus 0000:04
     d8200000-d823ffff : 0000:04:00.0
     d8240000-d827ffff : 0000:04:00.1
   dd000000-ddffffff : 0000:00:05.0
   de000000-de7fffff : 0000:00:05.0
   dea00000-decfffff : PCI Bus 0000:03
     dec00000-dec0ffff : 0000:03:00.0
       dec00000-dec0ffff : mpt
     dec10000-dec13fff : 0000:03:00.0
       dec10000-dec13fff : mpt
   ded00000-dedfffff : PCI Bus 0000:04
     ded80000-ded80fff : 0000:04:00.0
       ded80000-ded80fff : lpfc
     ded81000-ded81fff : 0000:04:00.1
       ded81000-ded81fff : lpfc
     ded82000-ded820ff : 0000:04:00.0
       ded82000-ded820ff : lpfc
     ded82400-ded824ff : 0000:04:00.1
       ded82400-ded824ff : lpfc
   dee00000-deefffff : PCI Bus 0000:08
     dee00000-deefffff : PCI Bus 0000:09
       dee00000-dee0ffff : 0000:09:04.0
         dee00000-dee0ffff : tg3
       dee10000-dee1ffff : 0000:09:04.0
         dee10000-dee1ffff : tg3
       dee20000-dee2ffff : 0000:09:04.1
         dee20000-dee2ffff : tg3
       dee30000-dee3ffff : 0000:09:04.1
         dee30000-dee3ffff : tg3
   def00000-deffffff : PCI Bus 0000:0a
     def00000-deffffff : PCI Bus 0000:0b
       def00000-def0ffff : 0000:0b:04.0
         def00000-def0ffff : tg3
       def10000-def1ffff : 0000:0b:04.0
         def10000-def1ffff : tg3
       def20000-def2ffff : 0000:0b:04.1
         def20000-def2ffff : tg3
       def30000-def3ffff : 0000:0b:04.1
         def30000-def3ffff : tg3
   df000000-df003fff : 0000:00:05.0
   df005000-df005fff : 0000:00:03.0
     df005000-df005fff : ohci_hcd
   df006000-df006fff : 0000:00:03.1
     df006000-df006fff : ohci_hcd
   df007000-df007fff : 0000:00:03.2
     df007000-df007fff : ehci_hcd
df100000-df8fffff : PCI Bus #10
   df100000-df1fffff : PCI Bus 0000:12
     df100000-df13ffff : 0000:12:00.0
     df140000-df17ffff : 0000:12:00.1
     df180000-df180fff : 0000:12:00.0
       df180000-df180fff : lpfc
     df181000-df181fff : 0000:12:00.1
       df181000-df181fff : lpfc
     df182000-df1820ff : 0000:12:00.0
       df182000-df1820ff : lpfc
     df182400-df1824ff : 0000:12:00.1
       df182400-df1824ff : lpfc
   df200000-df3fffff : PCI Bus 0000:11
     df200000-df3fffff : 0000:11:00.0
   df400000-df6fffff : PCI Bus 0000:11
     df600000-df60ffff : 0000:11:00.0
       df600000-df60ffff : mpt
     df610000-df613fff : 0000:11:00.0
       df610000-df613fff : mpt
   df700000-df7fffff : PCI Bus 0000:16
     df700000-df7fffff : PCI Bus 0000:17
       df700000-df70ffff : 0000:17:04.0
         df700000-df70ffff : tg3
       df710000-df71ffff : 0000:17:04.0
         df710000-df71ffff : tg3
       df720000-df72ffff : 0000:17:04.1
         df720000-df72ffff : tg3
       df730000-df73ffff : 0000:17:04.1
         df730000-df73ffff : tg3
   df800000-df8fffff : PCI Bus 0000:18
     df800000-df8fffff : PCI Bus 0000:19
       df800000-df80ffff : 0000:19:04.0
         df800000-df80ffff : tg3
       df810000-df81ffff : 0000:19:04.0
         df810000-df81ffff : tg3
       df820000-df82ffff : 0000:19:04.1
         df820000-df82ffff : tg3
       df830000-df83ffff : 0000:19:04.1
         df830000-df83ffff : tg3
df900000-dfffffff : PCI Bus #00
e0000000-efffffff : reserved
   e0000000-efffffff : pnp 00:09
     e0000000-e18fffff : PCI MMCONFIG 0 [00-18]
f0000000-fecfffff : PCI Bus #00
   fec00000-fec01fff : reserved
     fec00000-fec00fff : IOAPIC 0
     fec01000-fec01fff : IOAPIC 1
fed00000-ffffffff : PCI Bus #00
   fed00000-fed003ff : HPET 0
     fed00000-fed003ff : reserved
   fee00000-fee00fff : Local APIC
     fee00000-fee00fff : reserved
   fff80000-ffffffff : reserved
100000000-427ffffff : System RAM
428000000-fcffffffff : PCI Bus #00






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
