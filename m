Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 499926B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:22:38 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id x84so36851881oix.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:22:38 -0800 (PST)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id j31si2459483otc.143.2017.01.11.08.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:22:33 -0800 (PST)
Received: by mail-oi0-x242.google.com with SMTP id j15so22605183oih.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:22:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz> <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Wed, 11 Jan 2017 21:52:29 +0530
Message-ID: <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

Hi Vlastimil ,

On Wed, Jan 11, 2017 at 6:08 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 01/11/2017 12:05 PM, Vlastimil Babka wrote:
>> On 01/11/2017 11:50 AM, Ganapatrao Kulkarni wrote:
>>> Hi,
>>>
>>> we are seeing OOM/stalls messages when we run ltp cpuset01(cpuset01 -I
>>> 360) test for few minutes, even through the numa system has adequate
>>> memory on both nodes.
>>>
>>> this we have observed same on both arm64/thunderx numa and on x86 numa system!
>>>
>>> using latest ltp from master branch version 20160920-197-gbc4d3db
>>> and linux kernel version 4.9
>>>
>>> is this known bug already?
>>
>> Probably not.
>>
>> Is it possible that cpuset limits the process to one node, and numa
>> mempolicy to the other node?
>
> Ah, so 4.9 has commit 82e7d3abec86 ("oom: print nodemask in the oom
> report"), so such state should be visible in the oom report. Can you
> post it whole instead of just the header line (i.e. the last line in
> your report)? Thanks.

pasting complete dmesg log.

[   80.880531] Bluetooth: HCI socket layer initialized
[   80.880533] Bluetooth: L2CAP socket layer initialized
[   80.880540] Bluetooth: SCO socket layer initialized
[   81.080898] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   81.080901] Bluetooth: BNEP filters: protocol multicast
[   81.080904] Bluetooth: BNEP socket layer initialized
[   81.278664] mgag200 0000:09:00.0: Video card doesn't support
cursors with partial transparency.
[   81.278668] mgag200 0000:09:00.0: Not enabling hardware cursor.
[  133.492439] usb 1-1.5: new low-speed USB device number 4 using ehci-pci
[  133.574627] usb 1-1.5: New USB device found, idVendor=0461, idProduct=4e22
[  133.574630] usb 1-1.5: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[  133.574633] usb 1-1.5: Product: USB Optical Mouse
[  133.574634] usb 1-1.5: Manufacturer: PixArt
[  133.577302] input: PixArt USB Optical Mouse as
/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.5/1-1.5:1.0/0003:0461:4E22.0003/input/input4
[  133.577523] hid-generic 0003:0461:4E22.0003: input,hidraw2: USB HID
v1.11 Mouse [PixArt USB Optical Mouse] on usb-0000:00:1a.0-1.5/input0
[ 1341.881889] loop: module loaded
[ 2280.275193] cgroup: new mount options do not match the existing
superblock, will be ignored
[ 2316.565940] cgroup: new mount options do not match the existing
superblock, will be ignored
[ 2393.388361] cpuset01: page allocation stalls for 10051ms, order:0,
mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[ 2393.388371] CPU: 9 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2393.388373] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2393.388374]  ffffc9000c1afba8 ffffffff813c771e ffffffff81a40be8
0000000000000001
[ 2393.388377]  ffffc9000c1afc30 ffffffff811b8c9a 024280ca00000202
ffffffff81a40be8
[ 2393.388380]  ffffc9000c1afbd0 0000000000000010 ffffc9000c1afc40
ffffc9000c1afbf0
[ 2393.388383] Call Trace:
[ 2393.388392]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2393.388397]  [<ffffffff811b8c9a>] warn_alloc+0x13a/0x170
[ 2393.388399]  [<ffffffff811b95c4>] __alloc_pages_slowpath+0x884/0xac0
[ 2393.388402]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2393.388405]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2393.388410]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2393.388413]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2393.388417]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2393.388422]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2393.388424]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2393.388429]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2393.388431] Mem-Info:
[ 2393.388437] active_anon:92316 inactive_anon:21059 isolated_anon:32
 active_file:202031 inactive_file:137088 isolated_file:0
 unevictable:16 dirty:20 writeback:5883 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21605
 mapped:26819 shmem:28393 pagetables:11375 bounce:0
 free:5494728 free_pcp:549 free_cma:0
[ 2393.388446] Node 0 active_anon:310368kB inactive_anon:25684kB
active_file:807836kB inactive_file:548592kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:101672kB dirty:80kB
writeback:148kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2393.388455] Node 1 active_anon:58896kB inactive_anon:58552kB
active_file:288kB inactive_file:0kB unevictable:4kB
isolated(anon):128kB isolated(file):0kB mapped:5604kB dirty:0kB
writeback:23384kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 87792kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2393.388457] Node 1 Normal free:11937124kB min:45532kB low:62044kB
high:78556kB active_anon:58896kB inactive_anon:58552kB
active_file:288kB inactive_file:0kB unevictable:4kB
writepending:23384kB present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:44812kB
kernel_stack:4264kB pagetables:27612kB bounce:0kB free_pcp:2240kB
local_pcp:0kB free_cma:0kB
[ 2393.388462] lowmem_reserve[]: 0 0 0 0
[ 2393.388465] Node 1 Normal: 1179*4kB (UME) 1396*8kB (UME) 1193*16kB
(UME) 910*32kB (UME) 721*64kB (UME) 568*128kB (UME) 444*256kB (UME)
328*512kB (ME) 223*1024kB (UM) 138*2048kB (ME) 2676*4096kB (M) =
11936412kB
[ 2393.388479] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2393.388481] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2393.388481] 374277 total pagecache pages
[ 2393.388483] 6667 pages in swap cache
[ 2393.388484] Swap cache stats: add 101786, delete 95119, find 393/682
[ 2393.388485] Free swap  = 15979384kB
[ 2393.388485] Total swap = 16383996kB
[ 2393.388486] 8331071 pages RAM
[ 2393.388486] 0 pages HighMem/MovableOnly
[ 2393.388487] 152036 pages reserved
[ 2393.388487] 0 pages hwpoisoned
[ 2397.331098] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2397.331100] cpuset01 cpuset=1 mems_allowed=1
[ 2397.331106] CPU: 7 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2397.331107] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2397.331108]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88085d596e00
[ 2397.331111]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2397.331114]  ffff88086c940000 ffffc9000c1afb60 ffffffff8120f582
ffffc9000c1afb80
[ 2397.331117] Call Trace:
[ 2397.331126]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2397.331131]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2397.331135]  [<ffffffff8120f582>] ? mempolicy_nodemask_intersects+0x52/0x80
[ 2397.331139]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2397.331145]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2397.331147]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2397.331150]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2397.331153]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2397.331155]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2397.331159]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2397.331162]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2397.331166]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2397.331171]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2397.331173]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2397.331178]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2397.331179] Mem-Info:
[ 2397.331186] active_anon:78898 inactive_anon:7674 isolated_anon:0
 active_file:202026 inactive_file:137665 isolated_file:0
 unevictable:16 dirty:0 writeback:1291 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21104
 mapped:26286 shmem:6851 pagetables:11375 bounce:0
 free:5521612 free_pcp:496 free_cma:0
[ 2397.331196] Node 0 active_anon:310432kB inactive_anon:25728kB
active_file:807844kB inactive_file:550708kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:103508kB dirty:0kB
writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2397.331206] Node 1 active_anon:5160kB inactive_anon:4968kB
active_file:260kB inactive_file:0kB unevictable:4kB isolated(anon):0kB
isolated(file):0kB mapped:1636kB dirty:0kB writeback:5164kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1624kB writeback_tmp:0kB
unstable:0kB pages_scanned:17440 all_unreclaimable? yes
[ 2397.331208] Node 1 Normal free:12046572kB min:45532kB low:62044kB
high:78556kB active_anon:5160kB inactive_anon:4968kB active_file:260kB
inactive_file:0kB unevictable:4kB writepending:5164kB
present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:42904kB
kernel_stack:4264kB pagetables:27612kB bounce:0kB free_pcp:1968kB
local_pcp:0kB free_cma:0kB
[ 2397.331213] lowmem_reserve[]: 0 0 0 0
[ 2397.331216] Node 1 Normal: 1199*4kB (UME) 1442*8kB (UME) 1165*16kB
(UME) 872*32kB (UME) 705*64kB (UME) 548*128kB (UME) 430*256kB (UME)
317*512kB (ME) 220*1024kB (UM) 136*2048kB (ME) 2708*4096kB (M) =
12046300kB
[ 2397.331230] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2397.331231] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2397.331233] 348299 total pagecache pages
[ 2397.331234] 1598 pages in swap cache
[ 2397.331235] Swap cache stats: add 123593, delete 121995, find 436/748
[ 2397.331236] Free swap  = 15892444kB
[ 2397.331236] Total swap = 16383996kB
[ 2397.331237] 8331071 pages RAM
[ 2397.331238] 0 pages HighMem/MovableOnly
[ 2397.331238] 152036 pages reserved
[ 2397.331239] 0 pages hwpoisoned
[ 2397.331240] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2397.331247] [ 1320]     0  1320    48262     7703      94       3
    54             0 systemd-journal
[ 2397.331249] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2397.331252] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2397.331255] [ 1546]     0  1546    12258      463      25       3
   109         -1000 auditd
[ 2397.331256] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2397.331258] [ 1558]     0  1558    95630      677      42       4
   498             0 accounts-daemon
[ 2397.331260] [ 1559]   172  1559    41156      423      17       4
    42             0 rtkit-daemon
[ 2397.331262] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2397.331264] [ 1561]    70  1561     7285      769      20       3
    36             0 avahi-daemon
[ 2397.331265] [ 1562]     0  1562     4322      530      14       3
    29             0 irqbalance
[ 2397.331267] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2397.331269] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2397.331271] [ 1567]     0  1567   176613     1288      58       4
  1320             0 rsyslogd
[ 2397.331273] [ 1570]    81  1570    12151      887      28       3
   110          -900 dbus-daemon
[ 2397.331275] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2397.331276] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2397.331278] [ 1590]     0  1590     6062      476      16       3
    85             0 systemd-logind
[ 2397.331280] [ 1598]     0  1598   134629      609      77       3
   537             0 NetworkManager
[ 2397.331282] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2397.331283] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2397.331285] [ 1605]     0  1605   148115      788      63       4
   419             0 abrt-dump-journ
[ 2397.331287] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2397.331289] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2397.331290] [ 1649]   995  1649   132342     1393      54       4
   868             0 polkitd
[ 2397.331292] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2397.331294] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2397.331296] [ 1710]     0  1710    31112      477      18       3
   149             0 crond
[ 2397.331297] [ 1719]  1000  1719     9562      872      24       3
   173             0 systemd
[ 2397.331299] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2397.331301] [ 1726]     0  1726    72807      611      47       3
   304             0 sddm
[ 2397.331303] [ 1762]  1000  1762   104348    23330     160       3
  1092             0 Xvnc
[ 2397.331305] [ 1765]     0  1765    97080    14901     145       3
  1895             0 Xorg.bin
[ 2397.331306] [ 1803]   989  1803     9562      872      23       3
   172             0 systemd
[ 2397.331308] [ 1804]   989  1804    18884      905      36       3
   204             0 (sd-pam)
[ 2397.331310] [ 1829]   989  1829     4015      251      13       3
     6             0 dbus-launch
[ 2397.331312] [ 1830]   989  1830    11712      268      27       3
    89             0 dbus-daemon
[ 2397.331313] [ 1834]  1000  1834    23696      812      49       4
     0             0 vncconfig
[ 2397.331315] [ 1836]  1000  1836    28369      430      11       3
     1             0 startkde
[ 2397.331317] [ 1845]  1000  1845     4015      216      13       3
    40             0 dbus-launch
[ 2397.331319] [ 1846]  1000  1846    11835      309      26       3
   167             0 dbus-daemon
[ 2397.331320] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2397.331322] [ 1903]  1000  1903    30532      218      15       3
    57             0 gpg-agent
[ 2397.331324] [ 1916]  1000  1916     1039       21       7       3
     0             0 start_kdeinit
[ 2397.331326] [ 1917]  1000  1917   138582     3030     187       4
   802             0 kdeinit4
[ 2397.331328] [ 1918]  1000  1918   139537     2039     174       4
   703             0 klauncher
[ 2397.331330] [ 1920]  1000  1920   736249     4516     356       6
  1991             0 kded4
[ 2397.331332] [ 1922]  1000  1922     2989      391      11       3
    50             0 gam_server
[ 2397.331333] [ 1926]  1000  1926   161611     2254     213       4
  1215             0 kglobalaccel
[ 2397.331335] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2397.331337] [ 1961]  1000  1961     1073      144       8       3
    22             0 kwrapper4
[ 2397.331339] [ 1962]  1000  1962   181547     2753     218       4
   687             0 ksmserver
[ 2397.331341] [ 1967]  1000  1967   207481     2152     162       4
   467             0 kactivitymanage
[ 2397.331342] [ 1968]     0  1968   108528      649      61       3
   308             0 upowerd
[ 2397.331344] [ 1989]     0  1989   107952      655      44       3
   194             0 udisksd
[ 2397.331346] [ 2021]  1000  2021   762607     5534     272       5
  1865             0 kwin
[ 2397.331348] [ 2049]  1000  2049   846858    13727     376       6
 11222             0 plasma-desktop
[ 2397.331349] [ 2050]  1000  2050   118825     4097     160       3
   542             0 baloo_file
[ 2397.331351] [ 2065]     0  2065   174636    12089     176       4
   418             0 packagekitd
[ 2397.331353] [ 2071]  1000  2071   109698     1427     147       4
   680             0 kuiserver
[ 2397.331355] [ 2073]  1000  2073    58632      586      49       3
   264             0 mission-control
[ 2397.331356] [ 2074]     0  2074     8083      458      20       3
    89             0 bluetoothd
[ 2397.331358] [ 2075]     0  2075    61086     1009      79       3
     8             0 sddm-helper
[ 2397.331360] [ 2109]  1001  2109     9563      890      24       3
   178             0 systemd
[ 2397.331362] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2397.331364] [ 2116]  1001  2116    28369      362      12       3
    62             0 startkde
[ 2397.331365] [ 2168]  1001  2168     4015      196      12       3
    66             0 dbus-launch
[ 2397.331367] [ 2169]  1001  2169    11805      473      27       3
    23             0 dbus-daemon
[ 2397.331369] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2397.331371] [ 2252]  1001  2252    30531      180      14       3
    47             0 gpg-agent
[ 2397.331373] [ 2265]  1001  2265   114260     1559     154       4
   747             0 kwalletd
[ 2397.331374] [ 2275]  1001  2275     2989      398      12       3
    48             0 gam_server
[ 2397.331376] [ 2283]  1000  2283   119072      484      93       3
   345             0 pulseaudio
[ 2397.331378] [ 2286]  1001  2286     1039        0       7       3
    21             0 start_kdeinit
[ 2397.331380] [ 2287]  1000  2287   233901     3637     287       4
  3554             0 krunner
[ 2397.331381] [ 2288]  1000  2288    29139      462      28       3
   122             0 xsettings-kde
[ 2397.331383] [ 2291]  1001  2291   138584     2381     186       4
  1460             0 kdeinit4
[ 2397.331385] [ 2303]  1001  2303   139539     1236     173       4
  1290             0 klauncher
[ 2397.331387] [ 2304]  1000  2304   222646     3577     231       4
  1903             0 kmix
[ 2397.331388] [ 2318]  1001  2318   737850     3343     356       6
  2869             0 kded4
[ 2397.331390] [ 2319]  1000  2319   124813     2105     177       4
  3879             0 krfb
[ 2397.331392] [ 2328]  1000  2328   188073     5718     232       4
  1920             0 konsole
[ 2397.331394] [ 2330]  1000  2330   165241     2912     220       4
  1261             0 kwalletd
[ 2397.331395] [ 2335]  1000  2335   133538     1078     164       4
  1244             0 polkit-kde-auth
[ 2397.331397] [ 2336]  1000  2336   163057     2127     217       4
  1427             0 klipper
[ 2397.331399] [ 2344]  1001  2344   161613     2154     212       4
  1338             0 kglobalaccel
[ 2397.331401] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2397.331402] [ 2372]  1000  2372    29461      380      13       3
   645             0 bash
[ 2397.331404] [ 2378]  1000  2378    29461      394      14       3
   645             0 bash
[ 2397.331406] [ 2384]  1000  2384    29461      394      15       3
   645             0 bash
[ 2397.331407] [ 2400]  1000  2400   143931     2516     179       3
   583             0 knotify4
[ 2397.331409] [ 2515]  1001  2515   244347     1216     169       4
  1330             0 kactivitymanage
[ 2397.331411] [ 2521]  1001  2521     1073      151       7       3
     0             0 kwrapper4
[ 2397.331413] [ 2522]  1001  2522   181563     1422     218       4
  2058             0 ksmserver
[ 2397.331415] [ 2538]  1001  2538   762667     6417     268       5
   636             0 kwin
[ 2397.331416] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2397.331418] [ 2569]  1001  2569   947139     7500     406       6
 16353             0 plasma-desktop
[ 2397.331420] [ 2570]  1001  2570   137027     3393     160       4
   790             0 baloo_file
[ 2397.331422] [ 2587]  1001  2587   109700     1396     150       3
   680             0 kuiserver
[ 2397.331424] [ 2589]  1001  2589    58631      844      49       4
    22             0 mission-control
[ 2397.331425] [ 2629]  1001  2629     2984      492      12       3
     0             0 ksysguardd
[ 2397.331427] [ 2644]  1001  2644   233841     2701     285       4
  4059             0 krunner
[ 2397.331429] [ 2645]  1001  2645    29139      567      28       3
     0             0 xsettings-kde
[ 2397.331431] [ 2650]  1001  2650   163058     1518     217       4
  2009             0 klipper
[ 2397.331433] [ 2652]  1001  2652   133536     2005     164       3
   317             0 polkit-kde-auth
[ 2397.331435] [ 2653]  1001  2653   222676     3217     230       4
  2288             0 kmix
[ 2397.331437] [ 2656]  1001  2656   119066      641      93       3
   224             0 pulseaudio
[ 2397.331438] [ 2675]  1001  2675   143932     1721     180       3
  1384             0 knotify4
[ 2397.331440] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2397.331442] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2397.331444] [ 3026]  1001  3026   209489     4366     243       4
  2015             0 dolphin
[ 2397.331446] [ 3043]  1001  3043   186923     4803     228       4
  1435             0 konsole
[ 2397.331447] [ 3049]  1001  3049    29490      611      14       3
   472             0 bash
[ 2397.331449] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2397.331451] [ 3678]     0  3678    30129      396      57       3
  3085             0 dhclient
[ 2397.331453] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2397.331455] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2397.331456] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2397.331459] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2397.331461] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2397.331462] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2397.331464] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2397.331466] [18174]     0 18174     2160        1      10       3
    32             0 cpuset01
[ 2397.331468] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2397.331469] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2397.331471] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2397.331473] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2397.331475] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2397.331476] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2397.331478] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2397.331480] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2397.331482] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2397.331483] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2397.331485] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2397.331487] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2397.331489] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2397.331490] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2397.331493] Out of memory: Kill process 2049 (plasma-desktop) score
3 or sacrifice child
[ 2397.331506] Killed process 2049 (plasma-desktop)
total-vm:3387432kB, anon-rss:23608kB, file-rss:22044kB,
shmem-rss:9256kB
[ 2397.340244] oom_reaper: reaped process 2049 (plasma-desktop), now
anon-rss:0kB, file-rss:124kB, shmem-rss:9256kB
[ 2398.146123] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2398.146124] cpuset01 cpuset=1 mems_allowed=1
[ 2398.146128] CPU: 7 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2398.146129] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2398.146130]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff8804691a8000
[ 2398.146133]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2398.146136]  ffff88086c940000 ffffc9000c1afb60 ffffffff8120f582
ffffc9000c1afb80
[ 2398.146138] Call Trace:
[ 2398.146145]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2398.146149]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2398.146152]  [<ffffffff8120f582>] ? mempolicy_nodemask_intersects+0x52/0x80
[ 2398.146156]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2398.146161]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2398.146163]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2398.146165]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2398.146167]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2398.146169]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2398.146173]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2398.146176]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2398.146179]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2398.146184]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2398.146186]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2398.146191]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2398.146192] Mem-Info:
[ 2398.146198] active_anon:73711 inactive_anon:7617 isolated_anon:0
 active_file:202873 inactive_file:138195 isolated_file:0
 unevictable:16 dirty:114 writeback:1403 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21092
 mapped:27003 shmem:6876 pagetables:11012 bounce:0
 free:5525440 free_pcp:461 free_cma:0
[ 2398.146207] Node 0 active_anon:290896kB inactive_anon:25732kB
active_file:810964kB inactive_file:552576kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:106464kB dirty:456kB
writeback:512kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2398.146217] Node 1 active_anon:3948kB inactive_anon:4736kB
active_file:528kB inactive_file:204kB unevictable:4kB
isolated(anon):0kB isolated(file):0kB mapped:1548kB dirty:0kB
writeback:5100kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 1724kB writeback_tmp:0kB unstable:0kB pages_scanned:16433
all_unreclaimable? yes
[ 2398.146220] Node 1 Normal free:12047352kB min:45532kB low:62044kB
high:78556kB active_anon:3948kB inactive_anon:4736kB active_file:528kB
inactive_file:204kB unevictable:4kB writepending:5100kB
present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:42856kB
kernel_stack:4248kB pagetables:26644kB bounce:0kB free_pcp:1900kB
local_pcp:120kB free_cma:0kB
[ 2398.146225] lowmem_reserve[]: 0 0 0 0
[ 2398.146227] Node 1 Normal: 1013*4kB (UME) 1308*8kB (UME) 1034*16kB
(UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) =
12047444kB
[ 2398.146241] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.146243] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.146243] 349544 total pagecache pages
[ 2398.146245] 1416 pages in swap cache
[ 2398.146245] Swap cache stats: add 123673, delete 122257, find 490/844
[ 2398.146246] Free swap  = 15935548kB
[ 2398.146247] Total swap = 16383996kB
[ 2398.146248] 8331071 pages RAM
[ 2398.146249] 0 pages HighMem/MovableOnly
[ 2398.146249] 152036 pages reserved
[ 2398.146250] 0 pages hwpoisoned
[ 2398.146250] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2398.146258] [ 1320]     0  1320    48262     8426      94       3
    54             0 systemd-journal
[ 2398.146260] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2398.146262] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2398.146264] [ 1546]     0  1546    12258      463      25       3
   109         -1000 auditd
[ 2398.146266] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2398.146268] [ 1558]     0  1558    95630      677      42       4
   498             0 accounts-daemon
[ 2398.146270] [ 1559]   172  1559    41156      423      17       4
    42             0 rtkit-daemon
[ 2398.146271] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2398.146273] [ 1561]    70  1561     7285      769      20       3
    36             0 avahi-daemon
[ 2398.146275] [ 1562]     0  1562     4322      530      14       3
    29             0 irqbalance
[ 2398.146277] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2398.146278] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2398.146280] [ 1567]     0  1567   176613     1288      58       4
  1320             0 rsyslogd
[ 2398.146282] [ 1570]    81  1570    12151      865      28       3
   110          -900 dbus-daemon
[ 2398.146284] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2398.146285] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2398.146287] [ 1590]     0  1590     6062      476      16       3
    85             0 systemd-logind
[ 2398.146289] [ 1598]     0  1598   134629      609      77       3
   537             0 NetworkManager
[ 2398.146291] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2398.146292] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2398.146294] [ 1605]     0  1605   148115      788      63       4
   419             0 abrt-dump-journ
[ 2398.146296] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2398.146298] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2398.146299] [ 1649]   995  1649   132342     1393      54       4
   868             0 polkitd
[ 2398.146301] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2398.146303] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2398.146304] [ 1710]     0  1710    31112      477      18       3
   149             0 crond
[ 2398.146306] [ 1719]  1000  1719     9562      872      24       3
   173             0 systemd
[ 2398.146308] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2398.146310] [ 1726]     0  1726    72807      611      47       3
   304             0 sddm
[ 2398.146312] [ 1762]  1000  1762   104309    23795     160       3
  1092             0 Xvnc
[ 2398.146314] [ 1765]     0  1765    97080    14901     145       3
  1895             0 Xorg.bin
[ 2398.146315] [ 1803]   989  1803     9562      872      23       3
   172             0 systemd
[ 2398.146317] [ 1804]   989  1804    18884      905      36       3
   204             0 (sd-pam)
[ 2398.146319] [ 1829]   989  1829     4015      251      13       3
     6             0 dbus-launch
[ 2398.146321] [ 1830]   989  1830    11712      268      27       3
    89             0 dbus-daemon
[ 2398.146322] [ 1834]  1000  1834    23696      812      49       4
     0             0 vncconfig
[ 2398.146324] [ 1836]  1000  1836    28369      430      11       3
     1             0 startkde
[ 2398.146326] [ 1845]  1000  1845     4015      216      13       3
    40             0 dbus-launch
[ 2398.146328] [ 1846]  1000  1846    11835      309      26       3
   167             0 dbus-daemon
[ 2398.146330] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2398.146331] [ 1903]  1000  1903    30532      218      15       3
    57             0 gpg-agent
[ 2398.146333] [ 1916]  1000  1916     1039       21       7       3
     0             0 start_kdeinit
[ 2398.146335] [ 1917]  1000  1917   138582     3030     187       4
   802             0 kdeinit4
[ 2398.146337] [ 1918]  1000  1918   139537     2039     174       4
   703             0 klauncher
[ 2398.146338] [ 1920]  1000  1920   736249     4516     356       6
  1991             0 kded4
[ 2398.146340] [ 1922]  1000  1922     2989      391      11       3
    50             0 gam_server
[ 2398.146342] [ 1926]  1000  1926   161611     2254     213       4
  1215             0 kglobalaccel
[ 2398.146344] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2398.146345] [ 1961]  1000  1961     1073      144       8       3
    22             0 kwrapper4
[ 2398.146348] [ 1962]  1000  1962   181547     2753     218       4
   687             0 ksmserver
[ 2398.146349] [ 1967]  1000  1967   207481     2152     162       4
   467             0 kactivitymanage
[ 2398.146351] [ 1968]     0  1968   108528      649      61       3
   308             0 upowerd
[ 2398.146353] [ 1989]     0  1989   107952      655      44       3
   194             0 udisksd
[ 2398.146354] [ 2021]  1000  2021   762607     5534     272       5
  1865             0 kwin
[ 2398.146356] [ 2050]  1000  2050   118825     4097     160       3
   542             0 baloo_file
[ 2398.146358] [ 2065]     0  2065   174636    12089     176       4
   418             0 packagekitd
[ 2398.146360] [ 2071]  1000  2071   109698     1427     147       4
   680             0 kuiserver
[ 2398.146362] [ 2073]  1000  2073    58632      586      49       3
   264             0 mission-control
[ 2398.146363] [ 2074]     0  2074     8083      458      20       3
    89             0 bluetoothd
[ 2398.146365] [ 2075]     0  2075    61086     1009      79       3
     8             0 sddm-helper
[ 2398.146367] [ 2109]  1001  2109     9563      890      24       3
   178             0 systemd
[ 2398.146368] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2398.146370] [ 2116]  1001  2116    28369      362      12       3
    62             0 startkde
[ 2398.146372] [ 2168]  1001  2168     4015      196      12       3
    66             0 dbus-launch
[ 2398.146373] [ 2169]  1001  2169    11805      473      27       3
    23             0 dbus-daemon
[ 2398.146375] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2398.146377] [ 2252]  1001  2252    30531      180      14       3
    47             0 gpg-agent
[ 2398.146379] [ 2265]  1001  2265   114260     1559     154       4
   747             0 kwalletd
[ 2398.146380] [ 2275]  1001  2275     2989      398      12       3
    48             0 gam_server
[ 2398.146382] [ 2283]  1000  2283   119072      484      93       3
   345             0 pulseaudio
[ 2398.146384] [ 2286]  1001  2286     1039        0       7       3
    21             0 start_kdeinit
[ 2398.146386] [ 2287]  1000  2287   233901     3637     287       4
  3554             0 krunner
[ 2398.146387] [ 2288]  1000  2288    29139      462      28       3
   122             0 xsettings-kde
[ 2398.146389] [ 2291]  1001  2291   138584     2381     186       4
  1460             0 kdeinit4
[ 2398.146391] [ 2303]  1001  2303   139539     1236     173       4
  1290             0 klauncher
[ 2398.146393] [ 2304]  1000  2304   222646     3577     231       4
  1903             0 kmix
[ 2398.146395] [ 2318]  1001  2318   737850     3343     356       6
  2869             0 kded4
[ 2398.146396] [ 2319]  1000  2319   124813     2105     177       4
  3879             0 krfb
[ 2398.146398] [ 2328]  1000  2328   188073     5718     232       4
  1920             0 konsole
[ 2398.146400] [ 2330]  1000  2330   165241     3028     220       4
  1261             0 kwalletd
[ 2398.146402] [ 2335]  1000  2335   133538     1078     164       4
  1244             0 polkit-kde-auth
[ 2398.146403] [ 2336]  1000  2336   163057     2127     217       4
  1427             0 klipper
[ 2398.146405] [ 2344]  1001  2344   161613     2154     212       4
  1338             0 kglobalaccel
[ 2398.146407] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2398.146408] [ 2372]  1000  2372    29461      380      13       3
   645             0 bash
[ 2398.146410] [ 2378]  1000  2378    29461      394      14       3
   645             0 bash
[ 2398.146412] [ 2384]  1000  2384    29461      394      15       3
   645             0 bash
[ 2398.146414] [ 2400]  1000  2400   143931     2516     179       3
   583             0 knotify4
[ 2398.146415] [ 2515]  1001  2515   244347     1216     169       4
  1330             0 kactivitymanage
[ 2398.146417] [ 2521]  1001  2521     1073      151       7       3
     0             0 kwrapper4
[ 2398.146419] [ 2522]  1001  2522   181563     1422     218       4
  2058             0 ksmserver
[ 2398.146420] [ 2538]  1001  2538   762667     6417     268       5
   636             0 kwin
[ 2398.146422] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2398.146424] [ 2569]  1001  2569   947139     7500     406       6
 16353             0 plasma-desktop
[ 2398.146426] [ 2570]  1001  2570   137027     3393     160       4
   790             0 baloo_file
[ 2398.146428] [ 2587]  1001  2587   109700     1396     150       3
   680             0 kuiserver
[ 2398.146429] [ 2589]  1001  2589    58631      844      49       4
    22             0 mission-control
[ 2398.146431] [ 2629]  1001  2629     2984      492      12       3
     0             0 ksysguardd
[ 2398.146433] [ 2644]  1001  2644   233841     2701     285       4
  4059             0 krunner
[ 2398.146435] [ 2645]  1001  2645    29139      567      28       3
     0             0 xsettings-kde
[ 2398.146436] [ 2650]  1001  2650   163058     1518     217       4
  2009             0 klipper
[ 2398.146438] [ 2652]  1001  2652   133536     2005     164       3
   317             0 polkit-kde-auth
[ 2398.146440] [ 2653]  1001  2653   222676     3217     230       4
  2288             0 kmix
[ 2398.146442] [ 2656]  1001  2656   119066      641      93       3
   224             0 pulseaudio
[ 2398.146443] [ 2675]  1001  2675   143932     1721     180       3
  1384             0 knotify4
[ 2398.146445] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2398.146447] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2398.146449] [ 3026]  1001  3026   209489     4366     243       4
  2015             0 dolphin
[ 2398.146451] [ 3043]  1001  3043   186923     4954     228       4
  1432             0 konsole
[ 2398.146453] [ 3049]  1001  3049    29490      611      14       3
   472             0 bash
[ 2398.146454] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2398.146456] [ 3678]     0  3678    30129      396      57       3
  3085             0 dhclient
[ 2398.146458] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2398.146459] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2398.146461] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2398.146463] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2398.146465] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2398.146467] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2398.146468] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2398.146470] [18174]     0 18174     2160        1      10       3
    32             0 cpuset01
[ 2398.146472] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2398.146474] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2398.146476] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2398.146478] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2398.146479] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2398.146481] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2398.146483] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2398.146484] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2398.146486] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2398.146488] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2398.146490] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2398.146492] [18186]     0 18186     2160      150      10       3
    25             0 cpuset01
[ 2398.146493] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2398.146495] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2398.146498] Out of memory: Kill process 1762 (Xvnc) score 3 or
sacrifice child
[ 2398.146537] Killed process 1762 (Xvnc) total-vm:417236kB,
anon-rss:68216kB, file-rss:8736kB, shmem-rss:18228kB
[ 2398.166242] oom_reaper: reaped process 1762 (Xvnc), now
anon-rss:0kB, file-rss:0kB, shmem-rss:18228kB
[ 2398.169306] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2398.169307] cpuset01 cpuset=1 mems_allowed=1
[ 2398.169310] CPU: 7 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2398.169311] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2398.169312]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88073f0b2940
[ 2398.169314]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2398.169317]  ffff88086c940000 ffffc9000c1afb60 ffffffff8120f582
ffffc9000c1afb80
[ 2398.169319] Call Trace:
[ 2398.169323]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2398.169325]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2398.169327]  [<ffffffff8120f582>] ? mempolicy_nodemask_intersects+0x52/0x80
[ 2398.169329]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2398.169332]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2398.169334]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2398.169336]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2398.169338]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2398.169340]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2398.169342]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2398.169345]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2398.169347]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2398.169350]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2398.169352]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2398.169355]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2398.169356] Mem-Info:
[ 2398.169362] active_anon:56701 inactive_anon:7617 isolated_anon:0
 active_file:202873 inactive_file:138195 isolated_file:0
 unevictable:16 dirty:114 writeback:1403 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21092
 mapped:26436 shmem:6876 pagetables:11012 bounce:0
 free:5542199 free_pcp:510 free_cma:0
[ 2398.169372] Node 0 active_anon:222856kB inactive_anon:25732kB
active_file:810964kB inactive_file:552576kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:104196kB dirty:456kB
writeback:512kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2398.169382] Node 1 active_anon:3948kB inactive_anon:4736kB
active_file:528kB inactive_file:204kB unevictable:4kB
isolated(anon):0kB isolated(file):0kB mapped:1548kB dirty:0kB
writeback:5100kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 1724kB writeback_tmp:0kB unstable:0kB pages_scanned:16433
all_unreclaimable? yes
[ 2398.169384] Node 1 Normal free:12046996kB min:45532kB low:62044kB
high:78556kB active_anon:3948kB inactive_anon:4736kB active_file:528kB
inactive_file:204kB unevictable:4kB writepending:5100kB
present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:42856kB
kernel_stack:4248kB pagetables:26644kB bounce:0kB free_pcp:2052kB
local_pcp:296kB free_cma:0kB
[ 2398.169388] lowmem_reserve[]: 0 0 0 0
[ 2398.169391] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB
(UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) =
12047196kB
[ 2398.169405] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.169406] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.169407] 349544 total pagecache pages
[ 2398.169407] 1429 pages in swap cache
[ 2398.169408] Swap cache stats: add 123689, delete 122260, find 494/863
[ 2398.169409] Free swap  = 15939856kB
[ 2398.169410] Total swap = 16383996kB
[ 2398.169411] 8331071 pages RAM
[ 2398.169411] 0 pages HighMem/MovableOnly
[ 2398.169412] 152036 pages reserved
[ 2398.169412] 0 pages hwpoisoned
[ 2398.169413] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2398.169421] [ 1320]     0  1320    48262     8426      94       3
    54             0 systemd-journal
[ 2398.169423] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2398.169425] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2398.169427] [ 1546]     0  1546    12258      463      25       3
   109         -1000 auditd
[ 2398.169429] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2398.169431] [ 1558]     0  1558    95630      677      42       4
   498             0 accounts-daemon
[ 2398.169432] [ 1559]   172  1559    41156      423      17       4
    42             0 rtkit-daemon
[ 2398.169434] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2398.169436] [ 1561]    70  1561     7285      769      20       3
    36             0 avahi-daemon
[ 2398.169437] [ 1562]     0  1562     4322      530      14       3
    29             0 irqbalance
[ 2398.169439] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2398.169441] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2398.169442] [ 1567]     0  1567   176613     1342      58       4
  1280             0 rsyslogd
[ 2398.169444] [ 1570]    81  1570    12151      865      28       3
   110          -900 dbus-daemon
[ 2398.169446] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2398.169448] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2398.169450] [ 1590]     0  1590     6062      476      16       3
    85             0 systemd-logind
[ 2398.169452] [ 1598]     0  1598   134629      609      77       3
   537             0 NetworkManager
[ 2398.169453] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2398.169455] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2398.169457] [ 1605]     0  1605   148115      788      63       4
   419             0 abrt-dump-journ
[ 2398.169458] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2398.169460] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2398.169462] [ 1649]   995  1649   132342     1393      54       4
   868             0 polkitd
[ 2398.169464] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2398.169465] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2398.169467] [ 1710]     0  1710    31112      477      18       3
   149             0 crond
[ 2398.169469] [ 1719]  1000  1719     9562      872      24       3
   173             0 systemd
[ 2398.169470] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2398.169472] [ 1726]     0  1726    72807      611      47       3
   304             0 sddm
[ 2398.169474] [ 1766]  1000  1762   104309     4557     160       3
     0             0 Xvnc
[ 2398.169476] [ 1765]     0  1765    97080    14901     145       3
  1895             0 Xorg.bin
[ 2398.169478] [ 1803]   989  1803     9562      872      23       3
   172             0 systemd
[ 2398.169479] [ 1804]   989  1804    18884      905      36       3
   204             0 (sd-pam)
[ 2398.169481] [ 1829]   989  1829     4015      251      13       3
     6             0 dbus-launch
[ 2398.169483] [ 1830]   989  1830    11712      268      27       3
    89             0 dbus-daemon
[ 2398.169484] [ 1834]  1000  1834    23696      812      49       4
     0             0 vncconfig
[ 2398.169486] [ 1836]  1000  1836    28369      430      11       3
     1             0 startkde
[ 2398.169488] [ 1845]  1000  1845     4015      216      13       3
    40             0 dbus-launch
[ 2398.169490] [ 1846]  1000  1846    11835      309      26       3
   167             0 dbus-daemon
[ 2398.169491] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2398.169493] [ 1903]  1000  1903    30532      218      15       3
    57             0 gpg-agent
[ 2398.169495] [ 1916]  1000  1916     1039       21       7       3
     0             0 start_kdeinit
[ 2398.169497] [ 1917]  1000  1917   138582     3030     187       4
   802             0 kdeinit4
[ 2398.169498] [ 1918]  1000  1918   139537     2039     174       4
   703             0 klauncher
[ 2398.169500] [ 1920]  1000  1920   736249     4516     356       6
  1991             0 kded4
[ 2398.169502] [ 1922]  1000  1922     2989      391      11       3
    50             0 gam_server
[ 2398.169503] [ 1926]  1000  1926   161611     2254     213       4
  1215             0 kglobalaccel
[ 2398.169505] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2398.169507] [ 1961]  1000  1961     1073      144       8       3
    22             0 kwrapper4
[ 2398.169509] [ 1962]  1000  1962   181547     2753     218       4
   687             0 ksmserver
[ 2398.169510] [ 1967]  1000  1967   207481     2152     162       4
   467             0 kactivitymanage
[ 2398.169512] [ 1968]     0  1968   108528      649      61       3
   308             0 upowerd
[ 2398.169514] [ 1989]     0  1989   107952      655      44       3
   194             0 udisksd
[ 2398.169516] [ 2021]  1000  2021   762607     5534     272       5
  1865             0 kwin
[ 2398.169517] [ 2050]  1000  2050   118825     4097     160       3
   542             0 baloo_file
[ 2398.169519] [ 2065]     0  2065   174636    12089     176       4
   418             0 packagekitd
[ 2398.169521] [ 2071]  1000  2071   109698     1427     147       4
   680             0 kuiserver
[ 2398.169523] [ 2073]  1000  2073    58632      586      49       3
   264             0 mission-control
[ 2398.169524] [ 2074]     0  2074     8083      458      20       3
    89             0 bluetoothd
[ 2398.169526] [ 2075]     0  2075    61086     1009      79       3
     8             0 sddm-helper
[ 2398.169528] [ 2109]  1001  2109     9563      890      24       3
   178             0 systemd
[ 2398.169529] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2398.169531] [ 2116]  1001  2116    28369      362      12       3
    62             0 startkde
[ 2398.169533] [ 2168]  1001  2168     4015      196      12       3
    66             0 dbus-launch
[ 2398.169535] [ 2169]  1001  2169    11805      473      27       3
    23             0 dbus-daemon
[ 2398.169537] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2398.169538] [ 2252]  1001  2252    30531      180      14       3
    47             0 gpg-agent
[ 2398.169540] [ 2265]  1001  2265   114260     1559     154       4
   747             0 kwalletd
[ 2398.169541] [ 2275]  1001  2275     2989      398      12       3
    48             0 gam_server
[ 2398.169543] [ 2283]  1000  2283   119072      484      93       3
   345             0 pulseaudio
[ 2398.169545] [ 2286]  1001  2286     1039        0       7       3
    21             0 start_kdeinit
[ 2398.169546] [ 2287]  1000  2287   233901     3637     287       4
  3554             0 krunner
[ 2398.169548] [ 2288]  1000  2288    29139      462      28       3
   122             0 xsettings-kde
[ 2398.169550] [ 2291]  1001  2291   138584     2381     186       4
  1460             0 kdeinit4
[ 2398.169552] [ 2303]  1001  2303   139539     1236     173       4
  1290             0 klauncher
[ 2398.169553] [ 2304]  1000  2304   222646     3577     231       4
  1903             0 kmix
[ 2398.169555] [ 2318]  1001  2318   737850     3343     356       6
  2869             0 kded4
[ 2398.169557] [ 2319]  1000  2319   124813     2105     177       4
  3879             0 krfb
[ 2398.169559] [ 2328]  1000  2328   188073     5718     232       4
  1920             0 konsole
[ 2398.169560] [ 2330]  1000  2330   165241     3028     220       4
  1261             0 kwalletd
[ 2398.169562] [ 2335]  1000  2335   133538     1078     164       4
  1244             0 polkit-kde-auth
[ 2398.169564] [ 2336]  1000  2336   163057     2127     217       4
  1427             0 klipper
[ 2398.169566] [ 2344]  1001  2344   161613     2154     212       4
  1338             0 kglobalaccel
[ 2398.169567] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2398.169569] [ 2372]  1000  2372    29461      380      13       3
   645             0 bash
[ 2398.169571] [ 2378]  1000  2378    29461      394      14       3
   645             0 bash
[ 2398.169572] [ 2384]  1000  2384    29461      394      15       3
   645             0 bash
[ 2398.169574] [ 2400]  1000  2400   143931     2516     179       3
   583             0 knotify4
[ 2398.169576] [ 2515]  1001  2515   244347     1216     169       4
  1330             0 kactivitymanage
[ 2398.169577] [ 2521]  1001  2521     1073      151       7       3
     0             0 kwrapper4
[ 2398.169579] [ 2522]  1001  2522   181563     1422     218       4
  2058             0 ksmserver
[ 2398.169581] [ 2538]  1001  2538   762667     6417     268       5
   636             0 kwin
[ 2398.169583] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2398.169584] [ 2569]  1001  2569   947139     7500     406       6
 16353             0 plasma-desktop
[ 2398.169586] [ 2570]  1001  2570   137027     3393     160       4
   790             0 baloo_file
[ 2398.169587] [ 2587]  1001  2587   109700     1396     150       3
   680             0 kuiserver
[ 2398.169589] [ 2589]  1001  2589    58631      844      49       4
    22             0 mission-control
[ 2398.169591] [ 2629]  1001  2629     2984      492      12       3
     0             0 ksysguardd
[ 2398.169593] [ 2644]  1001  2644   233841     2701     285       4
  4059             0 krunner
[ 2398.169595] [ 2645]  1001  2645    29139      567      28       3
     0             0 xsettings-kde
[ 2398.169596] [ 2650]  1001  2650   163058     1518     217       4
  2009             0 klipper
[ 2398.169598] [ 2652]  1001  2652   133536     2005     164       3
   317             0 polkit-kde-auth
[ 2398.169600] [ 2653]  1001  2653   222676     3217     230       4
  2288             0 kmix
[ 2398.169602] [ 2656]  1001  2656   119066      641      93       3
   224             0 pulseaudio
[ 2398.169603] [ 2675]  1001  2675   143932     1721     180       3
  1384             0 knotify4
[ 2398.169605] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2398.169607] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2398.169608] [ 3026]  1001  3026   209489     4366     243       4
  2015             0 dolphin
[ 2398.169610] [ 3043]  1001  3043   186923     4954     228       4
  1432             0 konsole
[ 2398.169612] [ 3049]  1001  3049    29490      611      14       3
   472             0 bash
[ 2398.169614] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2398.169615] [ 3678]     0  3678    30129      396      57       3
  3085             0 dhclient
[ 2398.169617] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2398.169619] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2398.169621] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2398.169623] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2398.169625] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2398.169627] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2398.169628] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2398.169630] [18174]     0 18174     2160        1      10       3
    32             0 cpuset01
[ 2398.169632] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2398.169634] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2398.169636] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2398.169637] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2398.169639] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2398.169641] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2398.169642] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2398.169644] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2398.169646] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2398.169648] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2398.169649] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2398.169651] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2398.169653] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2398.169654] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2398.169657] Out of memory: Kill process 2569 (plasma-desktop) score
2 or sacrifice child
[ 2398.169664] Killed process 2629 (ksysguardd) total-vm:11936kB,
anon-rss:424kB, file-rss:1544kB, shmem-rss:0kB
[ 2398.173987] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2398.173988] cpuset01 cpuset=1 mems_allowed=1
[ 2398.173991] CPU: 7 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2398.173992] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2398.173993]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88073f0b2940
[ 2398.173996]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2398.173998]  ffffc9000c1afbe0 ffffc9000c1afb60 ffffffff8120f582
ffffc9000c1afb80
[ 2398.174001] Call Trace:
[ 2398.174004]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2398.174007]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2398.174008]  [<ffffffff8120f582>] ? mempolicy_nodemask_intersects+0x52/0x80
[ 2398.174011]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2398.174014]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2398.174015]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2398.174017]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2398.174020]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2398.174022]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2398.174024]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2398.174027]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2398.174029]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2398.174032]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2398.174034]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2398.174037]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2398.174038] Mem-Info:
[ 2398.174043] active_anon:56620 inactive_anon:7617 isolated_anon:0
 active_file:202873 inactive_file:138195 isolated_file:0
 unevictable:16 dirty:114 writeback:1403 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21092
 mapped:26436 shmem:6876 pagetables:11012 bounce:0
 free:5542280 free_pcp:486 free_cma:0
[ 2398.174053] Node 0 active_anon:222532kB inactive_anon:25732kB
active_file:810964kB inactive_file:552576kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:104196kB dirty:456kB
writeback:512kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2398.174062] Node 1 active_anon:3948kB inactive_anon:4736kB
active_file:528kB inactive_file:204kB unevictable:4kB
isolated(anon):0kB isolated(file):0kB mapped:1548kB dirty:0kB
writeback:5100kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 1724kB writeback_tmp:0kB unstable:0kB pages_scanned:16433
all_unreclaimable? yes
[ 2398.174065] Node 1 Normal free:12046996kB min:45532kB low:62044kB
high:78556kB active_anon:3948kB inactive_anon:4736kB active_file:528kB
inactive_file:204kB unevictable:4kB writepending:5100kB
present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:42856kB
kernel_stack:4248kB pagetables:26644kB bounce:0kB free_pcp:1940kB
local_pcp:164kB free_cma:0kB
[ 2398.174069] lowmem_reserve[]: 0 0 0 0
[ 2398.174071] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB
(UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) =
12047196kB
[ 2398.174085] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.174086] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.174087] 349544 total pagecache pages
[ 2398.174088] 1437 pages in swap cache
[ 2398.174089] Swap cache stats: add 123697, delete 122260, find 494/864
[ 2398.174089] Free swap  = 15939856kB
[ 2398.174090] Total swap = 16383996kB
[ 2398.174091] 8331071 pages RAM
[ 2398.174091] 0 pages HighMem/MovableOnly
[ 2398.174092] 152036 pages reserved
[ 2398.174092] 0 pages hwpoisoned
[ 2398.174093] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2398.174100] [ 1320]     0  1320    48262     8426      94       3
    54             0 systemd-journal
[ 2398.174102] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2398.174104] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2398.174106] [ 1546]     0  1546    12258      463      25       3
   109         -1000 auditd
[ 2398.174108] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2398.174110] [ 1558]     0  1558    95630      677      42       4
   498             0 accounts-daemon
[ 2398.174112] [ 1559]   172  1559    41156      423      17       4
    42             0 rtkit-daemon
[ 2398.174113] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2398.174115] [ 1561]    70  1561     7285      769      20       3
    36             0 avahi-daemon
[ 2398.174117] [ 1562]     0  1562     4322      530      14       3
    29             0 irqbalance
[ 2398.174119] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2398.174120] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2398.174122] [ 1567]     0  1567   176613     1342      58       4
  1280             0 rsyslogd
[ 2398.174124] [ 1570]    81  1570    12151      865      28       3
   110          -900 dbus-daemon
[ 2398.174126] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2398.174127] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2398.174129] [ 1590]     0  1590     6062      476      16       3
    85             0 systemd-logind
[ 2398.174131] [ 1598]     0  1598   134629      609      77       3
   537             0 NetworkManager
[ 2398.174133] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2398.174134] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2398.174136] [ 1605]     0  1605   148115      788      63       4
   419             0 abrt-dump-journ
[ 2398.174138] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2398.174139] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2398.174141] [ 1649]   995  1649   132342     1393      54       4
   868             0 polkitd
[ 2398.174143] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2398.174144] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2398.174146] [ 1710]     0  1710    31112      477      18       3
   149             0 crond
[ 2398.174148] [ 1719]  1000  1719     9562      872      24       3
   173             0 systemd
[ 2398.174150] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2398.174151] [ 1726]     0  1726    72807      611      47       3
   304             0 sddm
[ 2398.174153] [ 1766]  1000  1762   104309     4557     160       3
     0             0 Xvnc
[ 2398.174155] [ 1765]     0  1765    97080    14901     145       3
  1895             0 Xorg.bin
[ 2398.174157] [ 1803]   989  1803     9562      872      23       3
   172             0 systemd
[ 2398.174158] [ 1804]   989  1804    18884      905      36       3
   204             0 (sd-pam)
[ 2398.174160] [ 1829]   989  1829     4015      251      13       3
     6             0 dbus-launch
[ 2398.174162] [ 1830]   989  1830    11712      268      27       3
    89             0 dbus-daemon
[ 2398.174164] [ 1834]  1000  1834    23696      812      49       4
     0             0 vncconfig
[ 2398.174165] [ 1836]  1000  1836    28369      430      11       3
     1             0 startkde
[ 2398.174167] [ 1845]  1000  1845     4015      216      13       3
    40             0 dbus-launch
[ 2398.174169] [ 1846]  1000  1846    11835      309      26       3
   167             0 dbus-daemon
[ 2398.174170] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2398.174172] [ 1903]  1000  1903    30532      218      15       3
    57             0 gpg-agent
[ 2398.174174] [ 1916]  1000  1916     1039       21       7       3
     0             0 start_kdeinit
[ 2398.174176] [ 1917]  1000  1917   138582     3030     187       4
   802             0 kdeinit4
[ 2398.174177] [ 1918]  1000  1918   139537     2039     174       4
   703             0 klauncher
[ 2398.174179] [ 1920]  1000  1920   736249     4516     356       6
  1991             0 kded4
[ 2398.174180] [ 1922]  1000  1922     2989      391      11       3
    50             0 gam_server
[ 2398.174182] [ 1926]  1000  1926   161611     2254     213       4
  1215             0 kglobalaccel
[ 2398.174184] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2398.174186] [ 1961]  1000  1961     1073      144       8       3
    22             0 kwrapper4
[ 2398.174188] [ 1962]  1000  1962   181547     2753     218       4
   687             0 ksmserver
[ 2398.174189] [ 1967]  1000  1967   207481     2152     162       4
   467             0 kactivitymanage
[ 2398.174191] [ 1968]     0  1968   108528      649      61       3
   308             0 upowerd
[ 2398.174193] [ 1989]     0  1989   107952      655      44       3
   194             0 udisksd
[ 2398.174195] [ 2021]  1000  2021   762607     5534     272       5
  1865             0 kwin
[ 2398.174196] [ 2050]  1000  2050   118825     4097     160       3
   542             0 baloo_file
[ 2398.174198] [ 2065]     0  2065   174636    12089     176       4
   418             0 packagekitd
[ 2398.174200] [ 2071]  1000  2071   109698     1427     147       4
   680             0 kuiserver
[ 2398.174202] [ 2073]  1000  2073    58632      586      49       3
   264             0 mission-control
[ 2398.174203] [ 2074]     0  2074     8083      458      20       3
    89             0 bluetoothd
[ 2398.174205] [ 2075]     0  2075    61086     1009      79       3
     8             0 sddm-helper
[ 2398.174207] [ 2109]  1001  2109     9563      890      24       3
   178             0 systemd
[ 2398.174209] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2398.174211] [ 2116]  1001  2116    28369      362      12       3
    62             0 startkde
[ 2398.174212] [ 2168]  1001  2168     4015      196      12       3
    66             0 dbus-launch
[ 2398.174214] [ 2169]  1001  2169    11805      473      27       3
    23             0 dbus-daemon
[ 2398.174216] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2398.174217] [ 2252]  1001  2252    30531      180      14       3
    47             0 gpg-agent
[ 2398.174219] [ 2265]  1001  2265   114260     1559     154       4
   747             0 kwalletd
[ 2398.174221] [ 2275]  1001  2275     2989      398      12       3
    48             0 gam_server
[ 2398.174223] [ 2283]  1000  2283   119072      484      93       3
   345             0 pulseaudio
[ 2398.174224] [ 2286]  1001  2286     1039        0       7       3
    21             0 start_kdeinit
[ 2398.174226] [ 2287]  1000  2287   233901     3637     287       4
  3554             0 krunner
[ 2398.174228] [ 2288]  1000  2288    29139      462      28       3
   122             0 xsettings-kde
[ 2398.174229] [ 2291]  1001  2291   138584     2381     186       4
  1460             0 kdeinit4
[ 2398.174231] [ 2303]  1001  2303   139539     1236     173       4
  1290             0 klauncher
[ 2398.174233] [ 2304]  1000  2304   222646     3577     231       4
  1903             0 kmix
[ 2398.174235] [ 2318]  1001  2318   737850     3343     356       6
  2869             0 kded4
[ 2398.174236] [ 2319]  1000  2319   124813     2105     177       4
  3879             0 krfb
[ 2398.174238] [ 2328]  1000  2328   188073     5718     232       4
  1920             0 konsole
[ 2398.174240] [ 2330]  1000  2330   165241     3028     220       4
  1261             0 kwalletd
[ 2398.174242] [ 2335]  1000  2335   133538     1078     164       4
  1244             0 polkit-kde-auth
[ 2398.174243] [ 2336]  1000  2336   163057     2127     217       4
  1427             0 klipper
[ 2398.174245] [ 2344]  1001  2344   161613     2154     212       4
  1338             0 kglobalaccel
[ 2398.174247] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2398.174248] [ 2372]  1000  2372    29461      380      13       3
   645             0 bash
[ 2398.174250] [ 2378]  1000  2378    29461      394      14       3
   645             0 bash
[ 2398.174252] [ 2384]  1000  2384    29461      394      15       3
   645             0 bash
[ 2398.174254] [ 2400]  1000  2400   143931     2516     179       3
   583             0 knotify4
[ 2398.174256] [ 2515]  1001  2515   244347     1216     169       4
  1330             0 kactivitymanage
[ 2398.174257] [ 2521]  1001  2521     1073      151       7       3
     0             0 kwrapper4
[ 2398.174259] [ 2522]  1001  2522   181563     1422     218       4
  2058             0 ksmserver
[ 2398.174261] [ 2538]  1001  2538   762667     6417     268       5
   636             0 kwin
[ 2398.174262] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2398.174264] [ 2569]  1001  2569   947139     7500     406       6
 16353             0 plasma-desktop
[ 2398.174266] [ 2570]  1001  2570   137027     3393     160       4
   790             0 baloo_file
[ 2398.174267] [ 2587]  1001  2587   109700     1396     150       3
   680             0 kuiserver
[ 2398.174269] [ 2589]  1001  2589    58631      844      49       4
    22             0 mission-control
[ 2398.174271] [ 2644]  1001  2644   233841     2701     285       4
  4059             0 krunner
[ 2398.174272] [ 2645]  1001  2645    29139      567      28       3
     0             0 xsettings-kde
[ 2398.174274] [ 2650]  1001  2650   163058     1518     217       4
  2009             0 klipper
[ 2398.174276] [ 2652]  1001  2652   133536     2005     164       3
   317             0 polkit-kde-auth
[ 2398.174278] [ 2653]  1001  2653   222676     3217     230       4
  2288             0 kmix
[ 2398.174279] [ 2656]  1001  2656   119066      641      93       3
   224             0 pulseaudio
[ 2398.174281] [ 2675]  1001  2675   143932     1721     180       3
  1384             0 knotify4
[ 2398.174283] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2398.174285] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2398.174287] [ 3026]  1001  3026   209489     4366     243       4
  2015             0 dolphin
[ 2398.174288] [ 3043]  1001  3043   186923     4954     228       4
  1432             0 konsole
[ 2398.174290] [ 3049]  1001  3049    29490      611      14       3
   472             0 bash
[ 2398.174292] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2398.174293] [ 3678]     0  3678    30129      396      57       3
  3085             0 dhclient
[ 2398.174295] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2398.174297] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2398.174299] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2398.174301] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2398.174303] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2398.174304] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2398.174306] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2398.174308] [18174]     0 18174     2160        1      10       3
    32             0 cpuset01
[ 2398.174310] [18175]     0 18175     2160      151      10       3
    27             0 cpuset01
[ 2398.174311] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2398.174313] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2398.174315] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2398.174316] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2398.174318] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2398.174320] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2398.174322] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2398.174323] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2398.174325] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2398.174327] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2398.174329] [18186]     0 18186     2160      150      10       3
    25             0 cpuset01
[ 2398.174331] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2398.174332] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2398.174335] Out of memory: Kill process 2569 (plasma-desktop) score
2 or sacrifice child
[ 2398.174353] Killed process 2569 (plasma-desktop)
total-vm:3788556kB, anon-rss:5748kB, file-rss:21796kB,
shmem-rss:2456kB
[ 2398.182059] oom_reaper: reaped process 2569 (plasma-desktop), now
anon-rss:0kB, file-rss:384kB, shmem-rss:2456kB
[ 2398.185127] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2398.185128] cpuset01 cpuset=1 mems_allowed=1
[ 2398.185131] CPU: 7 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2398.185132] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2398.185133]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff880868c5ee00
[ 2398.185136]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2398.185138]  ffff88086c940000 ffffc9000c1afb60 ffffffff8120f582
ffffc9000c1afb80
[ 2398.185140] Call Trace:
[ 2398.185144]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2398.185146]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2398.185148]  [<ffffffff8120f582>] ? mempolicy_nodemask_intersects+0x52/0x80
[ 2398.185150]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2398.185153]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2398.185154]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2398.185156]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2398.185159]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2398.185161]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2398.185163]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2398.185166]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2398.185168]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2398.185171]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2398.185173]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2398.185175]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2398.185176] Mem-Info:
[ 2398.185182] active_anon:55405 inactive_anon:7617 isolated_anon:0
 active_file:204898 inactive_file:136170 isolated_file:0
 unevictable:16 dirty:114 writeback:1403 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21092
 mapped:25059 shmem:6876 pagetables:11012 bounce:0
 free:5543657 free_pcp:503 free_cma:0
[ 2398.185191] Node 0 active_anon:217348kB inactive_anon:25732kB
active_file:819064kB inactive_file:544476kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:98688kB dirty:456kB
writeback:512kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2398.185200] Node 1 active_anon:4272kB inactive_anon:4736kB
active_file:528kB inactive_file:204kB unevictable:4kB
isolated(anon):0kB isolated(file):0kB mapped:1548kB dirty:0kB
writeback:5100kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 1724kB writeback_tmp:0kB unstable:0kB pages_scanned:16433
all_unreclaimable? yes
[ 2398.185203] Node 1 Normal free:12046996kB min:45532kB low:62044kB
high:78556kB active_anon:4272kB inactive_anon:4736kB active_file:528kB
inactive_file:204kB unevictable:4kB writepending:5100kB
present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:42856kB
kernel_stack:4248kB pagetables:26644kB bounce:0kB free_pcp:1944kB
local_pcp:252kB free_cma:0kB
[ 2398.185207] lowmem_reserve[]: 0 0 0 0
[ 2398.185210] Node 1 Normal: 889*4kB (UME) 1308*8kB (UME) 1034*16kB
(UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) =
12046948kB
[ 2398.185223] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.185224] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.185225] 349544 total pagecache pages
[ 2398.185226] 1448 pages in swap cache
[ 2398.185226] Swap cache stats: add 123708, delete 122260, find 494/871
[ 2398.185227] Free swap  = 16000184kB
[ 2398.185228] Total swap = 16383996kB
[ 2398.185229] 8331071 pages RAM
[ 2398.185230] 0 pages HighMem/MovableOnly
[ 2398.185230] 152036 pages reserved
[ 2398.185231] 0 pages hwpoisoned
[ 2398.185231] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2398.185239] [ 1320]     0  1320    48262     8426      94       3
    54             0 systemd-journal
[ 2398.185241] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2398.185243] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2398.185245] [ 1546]     0  1546    12258      463      25       3
   109         -1000 auditd
[ 2398.185247] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2398.185249] [ 1558]     0  1558    95630      677      42       4
   498             0 accounts-daemon
[ 2398.185250] [ 1559]   172  1559    41156      423      17       4
    42             0 rtkit-daemon
[ 2398.185252] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2398.185254] [ 1561]    70  1561     7285      769      20       3
    36             0 avahi-daemon
[ 2398.185256] [ 1562]     0  1562     4322      530      14       3
    29             0 irqbalance
[ 2398.185257] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2398.185259] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2398.185261] [ 1567]     0  1567   176613     1408      58       4
  1280             0 rsyslogd
[ 2398.185263] [ 1570]    81  1570    12151      865      28       3
   110          -900 dbus-daemon
[ 2398.185265] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2398.185266] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2398.185268] [ 1590]     0  1590     6062      476      16       3
    85             0 systemd-logind
[ 2398.185270] [ 1598]     0  1598   134629      609      77       3
   537             0 NetworkManager
[ 2398.185272] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2398.185273] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2398.185275] [ 1605]     0  1605   148115      788      63       4
   419             0 abrt-dump-journ
[ 2398.185277] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2398.185278] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2398.185280] [ 1649]   995  1649   132342     1393      54       4
   868             0 polkitd
[ 2398.185282] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2398.185284] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2398.185285] [ 1710]     0  1710    31112      477      18       3
   149             0 crond
[ 2398.185287] [ 1719]  1000  1719     9562      872      24       3
   173             0 systemd
[ 2398.185289] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2398.185290] [ 1726]     0  1726    72807      611      47       3
   304             0 sddm
[ 2398.185292] [ 1766]  1000  1762   104309     4557     160       3
     0             0 Xvnc
[ 2398.185294] [ 1765]     0  1765    97080    14901     145       3
  1895             0 Xorg.bin
[ 2398.185296] [ 1803]   989  1803     9562      872      23       3
   172             0 systemd
[ 2398.185297] [ 1804]   989  1804    18884      905      36       3
   204             0 (sd-pam)
[ 2398.185299] [ 1829]   989  1829     4015      251      13       3
     6             0 dbus-launch
[ 2398.185301] [ 1830]   989  1830    11712      268      27       3
    89             0 dbus-daemon
[ 2398.185303] [ 1834]  1000  1834    23696      812      49       4
     0             0 vncconfig
[ 2398.185304] [ 1836]  1000  1836    28369      430      11       3
     1             0 startkde
[ 2398.185306] [ 1845]  1000  1845     4015      216      13       3
    40             0 dbus-launch
[ 2398.185308] [ 1846]  1000  1846    11835      309      26       3
   167             0 dbus-daemon
[ 2398.185310] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2398.185311] [ 1903]  1000  1903    30532      218      15       3
    57             0 gpg-agent
[ 2398.185313] [ 1916]  1000  1916     1039       21       7       3
     0             0 start_kdeinit
[ 2398.185315] [ 1917]  1000  1917   138582     3030     187       4
   802             0 kdeinit4
[ 2398.185316] [ 1918]  1000  1918   139537     2039     174       4
   703             0 klauncher
[ 2398.185318] [ 1920]  1000  1920   736249     4516     356       6
  1991             0 kded4
[ 2398.185320] [ 1922]  1000  1922     2989      391      11       3
    50             0 gam_server
[ 2398.185322] [ 1926]  1000  1926   161611     2254     213       4
  1215             0 kglobalaccel
[ 2398.185323] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2398.185325] [ 1961]  1000  1961     1073      144       8       3
    22             0 kwrapper4
[ 2398.185327] [ 1962]  1000  1962   181547     2753     218       4
   687             0 ksmserver
[ 2398.185328] [ 1967]  1000  1967   207481     2152     162       4
   467             0 kactivitymanage
[ 2398.185330] [ 1968]     0  1968   108528      649      61       3
   308             0 upowerd
[ 2398.185332] [ 1989]     0  1989   107952      655      44       3
   194             0 udisksd
[ 2398.185334] [ 2021]  1000  2021   762607     5534     272       5
  1865             0 kwin
[ 2398.185335] [ 2050]  1000  2050   118825     4097     160       3
   542             0 baloo_file
[ 2398.185337] [ 2065]     0  2065   174636    12089     176       4
   418             0 packagekitd
[ 2398.185339] [ 2071]  1000  2071   109698     1427     147       4
   680             0 kuiserver
[ 2398.185341] [ 2073]  1000  2073    58632      586      49       3
   264             0 mission-control
[ 2398.185342] [ 2074]     0  2074     8083      458      20       3
    89             0 bluetoothd
[ 2398.185344] [ 2075]     0  2075    61086     1009      79       3
     8             0 sddm-helper
[ 2398.185346] [ 2109]  1001  2109     9563      890      24       3
   178             0 systemd
[ 2398.185348] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2398.185349] [ 2116]  1001  2116    28369      362      12       3
    62             0 startkde
[ 2398.185351] [ 2168]  1001  2168     4015      196      12       3
    66             0 dbus-launch
[ 2398.185353] [ 2169]  1001  2169    11805      473      27       3
    23             0 dbus-daemon
[ 2398.185354] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2398.185356] [ 2252]  1001  2252    30531      180      14       3
    47             0 gpg-agent
[ 2398.185358] [ 2265]  1001  2265   114260     1559     154       4
   747             0 kwalletd
[ 2398.185360] [ 2275]  1001  2275     2989      398      12       3
    48             0 gam_server
[ 2398.185361] [ 2283]  1000  2283   119072      484      93       3
   345             0 pulseaudio
[ 2398.185363] [ 2286]  1001  2286     1039        0       7       3
    21             0 start_kdeinit
[ 2398.185365] [ 2287]  1000  2287   233901     3637     287       4
  3554             0 krunner
[ 2398.185366] [ 2288]  1000  2288    29139      462      28       3
   122             0 xsettings-kde
[ 2398.185368] [ 2291]  1001  2291   138584     2381     186       4
  1460             0 kdeinit4
[ 2398.185370] [ 2303]  1001  2303   139539     1236     173       4
  1290             0 klauncher
[ 2398.185372] [ 2304]  1000  2304   222646     3577     231       4
  1903             0 kmix
[ 2398.185373] [ 2318]  1001  2318   737850     3343     356       6
  2869             0 kded4
[ 2398.185375] [ 2319]  1000  2319   124813     2105     177       4
  3879             0 krfb
[ 2398.185377] [ 2328]  1000  2328   188073     5718     232       4
  1920             0 konsole
[ 2398.185378] [ 2330]  1000  2330   165241     3028     220       4
  1261             0 kwalletd
[ 2398.185380] [ 2335]  1000  2335   133538     1078     164       4
  1244             0 polkit-kde-auth
[ 2398.185382] [ 2336]  1000  2336   163057     2127     217       4
  1427             0 klipper
[ 2398.185384] [ 2344]  1001  2344   161613     2154     212       4
  1338             0 kglobalaccel
[ 2398.185385] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2398.185387] [ 2372]  1000  2372    29461      380      13       3
   645             0 bash
[ 2398.185389] [ 2378]  1000  2378    29461      394      14       3
   645             0 bash
[ 2398.185390] [ 2384]  1000  2384    29461      394      15       3
   645             0 bash
[ 2398.185392] [ 2400]  1000  2400   143931     2516     179       3
   583             0 knotify4
[ 2398.185394] [ 2515]  1001  2515   244347     1216     169       4
  1330             0 kactivitymanage
[ 2398.185395] [ 2521]  1001  2521     1073      151       7       3
     0             0 kwrapper4
[ 2398.185397] [ 2522]  1001  2522   181563     1422     218       4
  2058             0 ksmserver
[ 2398.185399] [ 2538]  1001  2538   762667     6417     268       5
   636             0 kwin
[ 2398.185400] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2398.185403] [ 2569]  1001  2569   947139      710     406       6
     0             0 plasma-desktop
[ 2398.185404] [ 2570]  1001  2570   137027     3393     160       4
   790             0 baloo_file
[ 2398.185406] [ 2587]  1001  2587   109700     1396     150       3
   680             0 kuiserver
[ 2398.185408] [ 2589]  1001  2589    58631      844      49       4
    22             0 mission-control
[ 2398.185410] [ 2644]  1001  2644   233841     2701     285       4
  4059             0 krunner
[ 2398.185411] [ 2645]  1001  2645    29139      567      28       3
     0             0 xsettings-kde
[ 2398.185413] [ 2650]  1001  2650   163058     1518     217       4
  2009             0 klipper
[ 2398.185415] [ 2652]  1001  2652   133536     2005     164       3
   317             0 polkit-kde-auth
[ 2398.185416] [ 2653]  1001  2653   222676     3217     230       4
  2288             0 kmix
[ 2398.185418] [ 2656]  1001  2656   119066      641      93       3
   224             0 pulseaudio
[ 2398.185420] [ 2675]  1001  2675   143932     1721     180       3
  1384             0 knotify4
[ 2398.185421] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2398.185423] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2398.185425] [ 3026]  1001  3026   209489     4366     243       4
  2015             0 dolphin
[ 2398.185427] [ 3043]  1001  3043   186923     4954     228       4
  1432             0 konsole
[ 2398.185428] [ 3049]  1001  3049    29490      611      14       3
   472             0 bash
[ 2398.185430] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2398.185432] [ 3678]     0  3678    30129      396      57       3
  3085             0 dhclient
[ 2398.185434] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2398.185435] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2398.185437] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2398.185439] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2398.185441] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2398.185443] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2398.185445] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2398.185446] [18174]     0 18174     2160        1      10       3
    32             0 cpuset01
[ 2398.185448] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2398.185450] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2398.185452] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2398.185453] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2398.185455] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2398.185457] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2398.185459] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2398.185460] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2398.185462] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2398.185464] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2398.185465] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2398.185467] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2398.185469] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2398.185471] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2398.185474] Out of memory: Kill process 1765 (Xorg.bin) score 1 or
sacrifice child
[ 2398.185521] Killed process 1765 (Xorg.bin) total-vm:388320kB,
anon-rss:42844kB, file-rss:7988kB, shmem-rss:8772kB
[ 2398.191806] oom_reaper: reaped process 1765 (Xorg.bin), now
anon-rss:0kB, file-rss:0kB, shmem-rss:8772kB
[ 2398.194993] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2398.194994] cpuset01 cpuset=1 mems_allowed=1
[ 2398.194997] CPU: 7 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2398.194998] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2398.194999]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff880466fb0000
[ 2398.195002]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2398.195004]  ffffc9000c1afbe0 ffffc9000c1afb60 ffffffff8120f582
ffffc9000c1afb80
[ 2398.195006] Call Trace:
[ 2398.195010]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2398.195012]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2398.195014]  [<ffffffff8120f582>] ? mempolicy_nodemask_intersects+0x52/0x80
[ 2398.195017]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2398.195019]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2398.195021]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2398.195023]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2398.195025]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2398.195027]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2398.195030]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2398.195032]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2398.195035]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2398.195037]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2398.195039]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2398.195042]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2398.195043] Mem-Info:
[ 2398.195048] active_anon:44632 inactive_anon:7617 isolated_anon:0
 active_file:204979 inactive_file:136089 isolated_file:0
 unevictable:16 dirty:114 writeback:1403 unstable:0
 slab_reclaimable:40274 slab_unreclaimable:21092
 mapped:23763 shmem:6876 pagetables:11012 bounce:0
 free:5554254 free_pcp:484 free_cma:0
[ 2398.195058] Node 0 active_anon:174256kB inactive_anon:25732kB
active_file:819388kB inactive_file:544152kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:93504kB dirty:456kB
writeback:512kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2398.195068] Node 1 active_anon:4272kB inactive_anon:4736kB
active_file:528kB inactive_file:204kB unevictable:4kB
isolated(anon):0kB isolated(file):0kB mapped:1548kB dirty:0kB
writeback:5100kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 1724kB writeback_tmp:0kB unstable:0kB pages_scanned:16433
all_unreclaimable? yes
[ 2398.195070] Node 1 Normal free:12046616kB min:45532kB low:62044kB
high:78556kB active_anon:4272kB inactive_anon:4736kB active_file:528kB
inactive_file:204kB unevictable:4kB writepending:5100kB
present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37876kB slab_unreclaimable:42856kB
kernel_stack:4248kB pagetables:26644kB bounce:0kB free_pcp:1960kB
local_pcp:216kB free_cma:0kB
[ 2398.195074] lowmem_reserve[]: 0 0 0 0
[ 2398.195078] Node 1 Normal: 864*4kB (UE) 1304*8kB (UME) 1034*16kB
(UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME)
275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) =
12046816kB
[ 2398.195091] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.195092] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2398.195093] 349544 total pagecache pages
[ 2398.195094] 1464 pages in swap cache
[ 2398.195095] Swap cache stats: add 123724, delete 122260, find 494/887
[ 2398.195096] Free swap  = 16007700kB
[ 2398.195096] Total swap = 16383996kB
[ 2398.195097] 8331071 pages RAM
[ 2398.195098] 0 pages HighMem/MovableOnly
[ 2398.195098] 152036 pages reserved
[ 2398.195099] 0 pages hwpoisoned
[ 2398.195100] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2398.195107] [ 1320]     0  1320    48262     8426      94       3
    54             0 systemd-journal
[ 2398.195109] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2398.195111] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2398.195113] [ 1546]     0  1546    12258      463      25       3
   109         -1000 auditd
[ 2398.195115] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2398.195117] [ 1558]     0  1558    95630      677      42       4
   498             0 accounts-daemon
[ 2398.195118] [ 1559]   172  1559    41156      423      17       4
    42             0 rtkit-daemon
[ 2398.195120] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2398.195122] [ 1561]    70  1561     7285      769      20       3
    36             0 avahi-daemon
[ 2398.195123] [ 1562]     0  1562     4322      530      14       3
    29             0 irqbalance
[ 2398.195125] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2398.195127] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2398.195129] [ 1567]     0  1567   176613     1408      58       4
  1280             0 rsyslogd
[ 2398.195131] [ 1570]    81  1570    12151      865      28       3
   110          -900 dbus-daemon
[ 2398.195133] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2398.195134] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2398.195136] [ 1590]     0  1590     6062      476      16       3
    85             0 systemd-logind
[ 2398.195138] [ 1598]     0  1598   134629      609      77       3
   537             0 NetworkManager
[ 2398.195139] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2398.195141] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2398.195143] [ 1605]     0  1605   148115      788      63       4
   419             0 abrt-dump-journ
[ 2398.195144] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2398.195146] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2398.195148] [ 1649]   995  1649   132342     1393      54       4
   868             0 polkitd
[ 2398.195149] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2398.195151] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2398.195153] [ 1710]     0  1710    31112      477      18       3
   149             0 crond
[ 2398.195154] [ 1719]  1000  1719     9562      872      24       3
   173             0 systemd
[ 2398.195156] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2398.195158] [ 1726]     0  1726    72807      611      47       3
   304             0 sddm
[ 2398.195160] [ 1766]  1000  1762   104309     4557     160       3
     0             0 Xvnc
[ 2398.195162] [ 1767]     0  1765    97080     2193     145       3
     0             0 Xorg.bin
[ 2398.195163] [ 1803]   989  1803     9562      872      23       3
   172             0 systemd
[ 2398.195165] [ 1804]   989  1804    18884      905      36       3
   204             0 (sd-pam)
[ 2398.195167] [ 1829]   989  1829     4015      251      13       3
     6             0 dbus-launch
[ 2398.195169] [ 1830]   989  1830    11712      268      27       3
    89             0 dbus-daemon
[ 2398.195170] [ 1834]  1000  1834    23696      812      49       4
     0             0 vncconfig
[ 2398.195172] [ 1836]  1000  1836    28369      430      11       3
     1             0 startkde
[ 2398.195174] [ 1845]  1000  1845     4015      216      13       3
    40             0 dbus-launch
[ 2398.195175] [ 1846]  1000  1846    11835      309      26       3
   167             0 dbus-daemon
[ 2398.195177] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2398.195179] [ 1903]  1000  1903    30532      218      15       3
    57             0 gpg-agent
[ 2398.195180] [ 1916]  1000  1916     1039       21       7       3
     0             0 start_kdeinit
[ 2398.195182] [ 1917]  1000  1917   138582     3030     187       4
   802             0 kdeinit4
[ 2398.195184] [ 1918]  1000  1918   139537     2039     174       4
   703             0 klauncher
[ 2398.195186] [ 1920]  1000  1920   736249     4516     356       6
  1991             0 kded4
[ 2398.195187] [ 1922]  1000  1922     2989      391      11       3
    50             0 gam_server
[ 2398.195189] [ 1926]  1000  1926   161611     2254     213       4
  1215             0 kglobalaccel
[ 2398.195191] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2398.195193] [ 1961]  1000  1961     1073      144       8       3
    22             0 kwrapper4
[ 2398.195194] [ 1962]  1000  1962   181547     2753     218       4
   687             0 ksmserver
[ 2398.195196] [ 1967]  1000  1967   207481     2152     162       4
   467             0 kactivitymanage
[ 2398.195198] [ 1968]     0  1968   108528      649      61       3
   308             0 upowerd
[ 2398.195200] [ 1989]     0  1989   107952      655      44       3
   194             0 udisksd
[ 2398.195201] [ 2021]  1000  2021   762607     5534     272       5
  1865             0 kwin
[ 2398.195203] [ 2050]  1000  2050   118825     4097     160       3
   542             0 baloo_file
[ 2398.195205] [ 2065]     0  2065   174636    12089     176       4
   418             0 packagekitd
[ 2398.195206] [ 2071]  1000  2071   109698     1427     147       4
   680             0 kuiserver
[ 2398.195208] [ 2073]  1000  2073    58632      586      49       3
   264             0 mission-control
[ 2398.195210] [ 2074]     0  2074     8083      458      20       3
    89             0 bluetoothd
[ 2398.195211] [ 2075]     0  2075    61086     1009      79       3
     8             0 sddm-helper
[ 2398.195213] [ 2109]  1001  2109     9563      890      24       3
   178             0 systemd
[ 2398.195215] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2398.195217] [ 2116]  1001  2116    28369      362      12       3
    62             0 startkde
[ 2398.195219] [ 2168]  1001  2168     4015      196      12       3
    66             0 dbus-launch
[ 2398.195220] [ 2169]  1001  2169    11805      473      27       3
    23             0 dbus-daemon
[ 2398.195222] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2398.195224] [ 2252]  1001  2252    30531      180      14       3
    47             0 gpg-agent
[ 2398.195225] [ 2265]  1001  2265   114260     1559     154       4
   747             0 kwalletd
[ 2398.195227] [ 2275]  1001  2275     2989      398      12       3
    48             0 gam_server
[ 2398.195229] [ 2283]  1000  2283   119072      484      93       3
   345             0 pulseaudio
[ 2398.195230] [ 2286]  1001  2286     1039        0       7       3
    21             0 start_kdeinit
[ 2398.195232] [ 2287]  1000  2287   233901     3637     287       4
  3554             0 krunner
[ 2398.195234] [ 2288]  1000  2288    29139      462      28       3
   122             0 xsettings-kde
[ 2398.195236] [ 2291]  1001  2291   138584     2381     186       4
  1460             0 kdeinit4
[ 2398.195238] [ 2303]  1001  2303   139539     1236     173       4
  1290             0 klauncher
[ 2398.195239] [ 2304]  1000  2304   222646     3577     231       4
  1903             0 kmix
[ 2398.195241] [ 2318]  1001  2318   737850     3343     356       6
  2869             0 kded4
[ 2398.195242] [ 2319]  1000  2319   124813     2105     177       4
  3879             0 krfb
[ 2398.195244] [ 2328]  1000  2328   188073     5718     232       4
  1920             0 konsole
[ 2398.195246] [ 2330]  1000  2330   165241     3028     220       4
  1261             0 kwalletd
[ 2398.195248] [ 2335]  1000  2335   133538     1078     164       4
  1244             0 polkit-kde-auth
[ 2398.195249] [ 2336]  1000  2336   163057     2127     217       4
  1427             0 klipper
[ 2398.195251] [ 2344]  1001  2344   161613     2154     212       4
  1338             0 kglobalaccel
[ 2398.195253] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2398.195254] [ 2372]  1000  2372    29461      380      13       3
   645             0 bash
[ 2398.195256] [ 2378]  1000  2378    29461      394      14       3
   645             0 bash
[ 2398.195258] [ 2384]  1000  2384    29461      394      15       3
   645             0 bash
[ 2398.195260] [ 2400]  1000  2400   143931     2516     179       3
   583             0 knotify4
[ 2398.195261] [ 2515]  1001  2515   244347     1216     169       4
  1330             0 kactivitymanage
[ 2398.195263] [ 2521]  1001  2521     1073      151       7       3
     0             0 kwrapper4
[ 2398.195265] [ 2522]  1001  2522   181563     1422     218       4
  2058             0 ksmserver
[ 2398.195267] [ 2538]  1001  2538   762667     6417     268       5
   636             0 kwin
[ 2398.195268] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2398.195270] [ 2569]  1001  2569   947139      710     406       6
     0             0 plasma-desktop
[ 2398.195272] [ 2570]  1001  2570   137027     3393     160       4
   790             0 baloo_file
[ 2398.195273] [ 2587]  1001  2587   109700     1396     150       3
   680             0 kuiserver
[ 2398.195275] [ 2589]  1001  2589    58631      844      49       4
    22             0 mission-control
[ 2398.195277] [ 2644]  1001  2644   233841     2701     285       4
  4059             0 krunner
[ 2398.195279] [ 2645]  1001  2645    29139      567      28       3
     0             0 xsettings-kde
[ 2398.195280] [ 2650]  1001  2650   163058     1518     217       4
  2009             0 klipper
[ 2398.195282] [ 2652]  1001  2652   133536     2005     164       3
   317             0 polkit-kde-auth
[ 2398.195284] [ 2653]  1001  2653   222676     3217     230       4
  2288             0 kmix
[ 2398.195286] [ 2656]  1001  2656   119066      641      93       3
   224             0 pulseaudio
[ 2398.195288] [ 2675]  1001  2675   143932     1721     180       3
  1384             0 knotify4
[ 2398.195290] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2398.195292] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2398.195293] [ 3026]  1001  3026   209489     4366     243       4
  2015             0 dolphin
[ 2398.195295] [ 3043]  1001  3043   186923     4954     228       4
  1432             0 konsole
[ 2398.195297] [ 3049]  1001  3049    29490      611      14       3
   472             0 bash
[ 2398.195299] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2398.195300] [ 3678]     0  3678    30129      396      57       3
  3085             0 dhclient
[ 2398.195302] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2398.195304] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2398.195306] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2398.195308] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2398.195309] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2398.195311] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2398.195313] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2398.195315] [18174]     0 18174     2160        1      10       3
    32             0 cpuset01
[ 2398.195316] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2398.195318] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2398.195320] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2398.195322] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2398.195324] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2398.195325] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2398.195327] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2398.195329] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2398.195331] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2398.195333] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2398.195334] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2398.195336] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2398.195338] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2398.195340] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2398.195342] Out of memory: Kill process 2065 (packagekitd) score 1
or sacrifice child
[ 2398.195354] Killed process 2065 (packagekitd) total-vm:698544kB,
anon-rss:44136kB, file-rss:4220kB, shmem-rss:0kB
[ 2403.399444] cpuset01: page allocation stalls for 20062ms, order:0,
mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[ 2403.399451] CPU: 5 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2403.399452] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2403.399454]  ffffc9000c1afba8 ffffffff813c771e ffffffff81a40be8
0000000000000001
[ 2403.399457]  ffffc9000c1afc30 ffffffff811b8c9a 024280ca00000202
ffffffff81a40be8
[ 2403.399460]  ffffc9000c1afbd0 0000000000000010 ffffc9000c1afc40
ffffc9000c1afbf0
[ 2403.399463] Call Trace:
[ 2403.399470]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2403.399475]  [<ffffffff811b8c9a>] warn_alloc+0x13a/0x170
[ 2403.399477]  [<ffffffff811b95c4>] __alloc_pages_slowpath+0x884/0xac0
[ 2403.399479]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2403.399483]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2403.399487]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2403.399490]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2403.399494]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2403.399498]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2403.399500]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2403.399504]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2403.399506] Mem-Info:
[ 2403.399512] active_anon:34180 inactive_anon:5407 isolated_anon:0
 active_file:205370 inactive_file:139064 isolated_file:0
 unevictable:16 dirty:508 writeback:1276 unstable:0
 slab_reclaimable:40218 slab_unreclaimable:20951
 mapped:22890 shmem:3948 pagetables:10057 bounce:0
 free:5565198 free_pcp:413 free_cma:0
[ 2403.399521] Node 0 active_anon:131592kB inactive_anon:15992kB
active_file:818272kB inactive_file:552592kB unevictable:60kB
isolated(anon):0kB isolated(file):0kB mapped:87496kB dirty:2028kB
writeback:512kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 15788kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2403.399530] Node 1 active_anon:5128kB inactive_anon:5636kB
active_file:3208kB inactive_file:3664kB unevictable:4kB
isolated(anon):0kB isolated(file):0kB mapped:4064kB dirty:4kB
writeback:4592kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 4kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2403.399532] Node 1 Normal free:12042188kB min:45532kB low:62044kB
high:78556kB active_anon:5128kB inactive_anon:5636kB
active_file:3208kB inactive_file:3664kB unevictable:4kB
writepending:4596kB present:16777216kB managed:16512808kB mlocked:4kB
slab_reclaimable:37748kB slab_unreclaimable:42580kB
kernel_stack:3608kB pagetables:24576kB bounce:0kB free_pcp:1696kB
local_pcp:0kB free_cma:0kB
[ 2403.399537] lowmem_reserve[]: 0 0 0 0
[ 2403.399541] Node 1 Normal: 1199*4kB (UME) 886*8kB (UME) 772*16kB
(UME) 758*32kB (UME) 583*64kB (UME) 450*128kB (UME) 361*256kB (UME)
276*512kB (ME) 188*1024kB (UM) 118*2048kB (ME) 2742*4096kB (M) =
12042540kB
[ 2403.399555] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2403.399556] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2403.399557] 351010 total pagecache pages
[ 2403.399558] 2537 pages in swap cache
[ 2403.399559] Swap cache stats: add 125667, delete 123130, find 2546/4737
[ 2403.399560] Free swap  = 16012928kB
[ 2403.399561] Total swap = 16383996kB
[ 2403.399562] 8331071 pages RAM
[ 2403.399562] 0 pages HighMem/MovableOnly
[ 2403.399563] 152036 pages reserved
[ 2403.399564] 0 pages hwpoisoned
[ 2414.760549] cpuset01: page allocation stalls for 31422ms, order:0,
mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[ 2414.760559] CPU: 5 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2414.760560] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2414.760561]  ffffc9000c1afba8 ffffffff813c771e ffffffff81a40be8
0000000000000001
[ 2414.760565]  ffffc9000c1afc30 ffffffff811b8c9a 024280ca00000202
ffffffff81a40be8
[ 2414.760567]  ffffc9000c1afbd0 0000000000000010 ffffc9000c1afc40
ffffc9000c1afbf0
[ 2414.760570] Call Trace:
[ 2414.760579]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2414.760585]  [<ffffffff811b8c9a>] warn_alloc+0x13a/0x170
[ 2414.760587]  [<ffffffff811b95c4>] __alloc_pages_slowpath+0x884/0xac0
[ 2414.760590]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2414.760593]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2414.760598]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2414.760601]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2414.760606]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2414.760611]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2414.760613]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2414.760619]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2414.760620] Mem-Info:
[ 2414.760627] active_anon:20367 inactive_anon:2025 isolated_anon:0
 active_file:215029 inactive_file:143295 isolated_file:0
 unevictable:8 dirty:498 writeback:186 unstable:0
 slab_reclaimable:40054 slab_unreclaimable:18973
 mapped:23992 shmem:123 pagetables:3846 bounce:0
 free:5577260 free_pcp:533 free_cma:0
[ 2414.760637] Node 0 active_anon:66528kB inactive_anon:1116kB
active_file:831436kB inactive_file:547728kB unevictable:32kB
isolated(anon):0kB isolated(file):0kB mapped:71784kB dirty:1956kB
writeback:740kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 492kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2414.760646] Node 1 active_anon:14940kB inactive_anon:6984kB
active_file:28680kB inactive_file:25452kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:24184kB dirty:36kB
writeback:4kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
0kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable?
no
[ 2414.760649] Node 1 Normal free:12004368kB min:45532kB low:62044kB
high:78556kB active_anon:14940kB inactive_anon:6984kB
active_file:28680kB inactive_file:25452kB unevictable:0kB
writepending:40kB present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:37204kB slab_unreclaimable:39208kB
kernel_stack:2968kB pagetables:9268kB bounce:0kB free_pcp:2084kB
local_pcp:0kB free_cma:0kB
[ 2414.760654] lowmem_reserve[]: 0 0 0 0
[ 2414.760658] Node 1 Normal: 1566*4kB (UME) 1609*8kB (UME) 810*16kB
(UME) 330*32kB (UME) 90*64kB (UE) 447*128kB (UME) 363*256kB (UME)
276*512kB (ME) 188*1024kB (UM) 118*2048kB (ME) 2742*4096kB (M) =
12005280kB
[ 2414.760673] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2414.760674] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2414.760675] 361656 total pagecache pages
[ 2414.760676] 3201 pages in swap cache
[ 2414.760677] Swap cache stats: add 133003, delete 129802, find 10925/17917
[ 2414.760678] Free swap  = 16139464kB
[ 2414.760679] Total swap = 16383996kB
[ 2414.760680] 8331071 pages RAM
[ 2414.760680] 0 pages HighMem/MovableOnly
[ 2414.760681] 152036 pages reserved
[ 2414.760681] 0 pages hwpoisoned
[ 2423.343798] cpuset01: page allocation stalls for 40005ms, order:0,
mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[ 2423.343806] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2423.343807] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2423.343809]  ffffc9000c1afba8 ffffffff813c771e ffffffff81a40be8
0000000000000001
[ 2423.343811]  ffffc9000c1afc30 ffffffff811b8c9a 024280ca00000202
ffffffff81a40be8
[ 2423.343814]  ffffc9000c1afbd0 0000000000000010 ffffc9000c1afc40
ffffc9000c1afbf0
[ 2423.343817] Call Trace:
[ 2423.343823]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2423.343827]  [<ffffffff811b8c9a>] warn_alloc+0x13a/0x170
[ 2423.343830]  [<ffffffff811b95c4>] __alloc_pages_slowpath+0x884/0xac0
[ 2423.343832]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2423.343835]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2423.343838]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2423.343841]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2423.343844]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2423.343848]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2423.343850]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2423.343854]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2423.343855] Mem-Info:
[ 2423.343861] active_anon:9158 inactive_anon:2436 isolated_anon:0
 active_file:203141 inactive_file:134852 isolated_file:0
 unevictable:0 dirty:0 writeback:2057 unstable:0
 slab_reclaimable:39834 slab_unreclaimable:18139
 mapped:15678 shmem:220 pagetables:2404 bounce:0
 free:5611489 free_pcp:446 free_cma:0
[ 2423.343870] Node 0 active_anon:28696kB inactive_anon:1316kB
active_file:812348kB inactive_file:539388kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:62544kB dirty:0kB
writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2423.343879] Node 1 active_anon:7936kB inactive_anon:8428kB
active_file:216kB inactive_file:20kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:168kB dirty:0kB
writeback:8228kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 112kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2423.343881] Node 1 Normal free:12068748kB min:45532kB low:62044kB
high:78556kB active_anon:7936kB inactive_anon:8428kB active_file:216kB
inactive_file:20kB unevictable:0kB writepending:8228kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:36396kB slab_unreclaimable:37300kB
kernel_stack:3064kB pagetables:7008kB bounce:0kB free_pcp:1788kB
local_pcp:0kB free_cma:0kB
[ 2423.343886] lowmem_reserve[]: 0 0 0 0
[ 2423.343889] Node 1 Normal: 2223*4kB (UME) 2559*8kB (UME) 1748*16kB
(UME) 1079*32kB (UME) 476*64kB (UME) 302*128kB (UME) 343*256kB (UME)
266*512kB (UME) 183*1024kB (UM) 118*2048kB (ME) 2748*4096kB (M) =
12069844kB
[ 2423.343903] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2423.343904] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2423.343905] 341160 total pagecache pages
[ 2423.343906] 2836 pages in swap cache
[ 2423.343907] Swap cache stats: add 137368, delete 134532, find 12971/20921
[ 2423.343907] Free swap  = 16161232kB
[ 2423.343908] Total swap = 16383996kB
[ 2423.343909] 8331071 pages RAM
[ 2423.343909] 0 pages HighMem/MovableOnly
[ 2423.343910] 152036 pages reserved
[ 2423.343910] 0 pages hwpoisoned
[ 2423.456585] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2423.456586] cpuset01 cpuset=1 mems_allowed=1
[ 2423.456591] CPU: 12 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2423.456592] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2423.456593]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88046ca90000
[ 2423.456595]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2423.456598]  ffff88046d140000 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2423.456600] Call Trace:
[ 2423.456604]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2423.456608]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2423.456610]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2423.456614]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2423.456618]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2423.456620]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2423.456622]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2423.456624]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2423.456626]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2423.456629]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2423.456632]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2423.456634]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2423.456637]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2423.456639]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2423.456642]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2423.456643] Mem-Info:
[ 2423.456648] active_anon:8390 inactive_anon:1500 isolated_anon:0
 active_file:203169 inactive_file:134852 isolated_file:0
 unevictable:0 dirty:0 writeback:1210 unstable:0
 slab_reclaimable:38796 slab_unreclaimable:18139
 mapped:15692 shmem:220 pagetables:2404 bounce:0
 free:5614313 free_pcp:472 free_cma:0
[ 2423.456657] Node 0 active_anon:28696kB inactive_anon:1316kB
active_file:812348kB inactive_file:539388kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:62544kB dirty:0kB
writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2423.456665] Node 1 active_anon:4864kB inactive_anon:4684kB
active_file:328kB inactive_file:20kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:224kB dirty:0kB
writeback:4840kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 112kB writeback_tmp:0kB unstable:0kB pages_scanned:15980
all_unreclaimable? yes
[ 2423.456667] Node 1 Normal free:12080044kB min:45532kB low:62044kB
high:78556kB active_anon:4864kB inactive_anon:4684kB active_file:328kB
inactive_file:20kB unevictable:0kB writepending:4840kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32244kB slab_unreclaimable:37300kB
kernel_stack:3064kB pagetables:7008kB bounce:0kB free_pcp:1916kB
local_pcp:0kB free_cma:0kB
[ 2423.456672] lowmem_reserve[]: 0 0 0 0
[ 2423.456675] Node 1 Normal: 2044*4kB (UME) 2464*8kB (UME) 1677*16kB
(UME) 1055*32kB (UME) 497*64kB (UME) 365*128kB (UME) 345*256kB (UME)
265*512kB (UME) 182*1024kB (UM) 117*2048kB (ME) 2750*4096kB (M) =
12080992kB
[ 2423.456688] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2423.456689] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2423.456690] 340260 total pagecache pages
[ 2423.456691] 1940 pages in swap cache
[ 2423.456692] Swap cache stats: add 138292, delete 136352, find 12991/20953
[ 2423.456693] Free swap  = 16157728kB
[ 2423.456693] Total swap = 16383996kB
[ 2423.456694] 8331071 pages RAM
[ 2423.456695] 0 pages HighMem/MovableOnly
[ 2423.456695] 152036 pages reserved
[ 2423.456696] 0 pages hwpoisoned
[ 2423.456696] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2423.456704] [ 1320]     0  1320    48262    12036      94       3
    51             0 systemd-journal
[ 2423.456706] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2423.456708] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2423.456711] [ 1546]     0  1546    12258      495      25       3
    93         -1000 auditd
[ 2423.456712] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2423.456714] [ 1558]     0  1558    95630      700      42       4
   478             0 accounts-daemon
[ 2423.456716] [ 1559]   172  1559    41156      395      17       4
    42             0 rtkit-daemon
[ 2423.456718] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2423.456719] [ 1561]    70  1561     7285      685      20       3
    36             0 avahi-daemon
[ 2423.456721] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2423.456723] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2423.456725] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2423.456727] [ 1567]     0  1567   176613     1331      58       4
  1423             0 rsyslogd
[ 2423.456728] [ 1570]    81  1570    12151      900      28       3
    89          -900 dbus-daemon
[ 2423.456730] [ 1571]    70  1571     6990        8      18       3
    48             0 avahi-daemon
[ 2423.456732] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2423.456734] [ 1590]     0  1590     6062      674      16       3
    30             0 systemd-logind
[ 2423.456736] [ 1598]     0  1598   134629     1045      77       3
   354             0 NetworkManager
[ 2423.456737] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2423.456739] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2423.456741] [ 1605]     0  1605   148115      777      63       4
   430             0 abrt-dump-journ
[ 2423.456743] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2423.456744] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2423.456746] [ 1649]   995  1649   132342     2138      54       4
   730             0 polkitd
[ 2423.456748] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2423.456750] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2423.456751] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2423.456753] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2423.456755] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2423.456756] [ 1726]     0  1726    72807      681      47       3
   265             0 sddm
[ 2423.456758] [ 1874]  1000  1874    13333      143      28       4
     3             0 ssh-agent
[ 2423.456760] [ 1922]  1000  1922     2989      456      11       3
    36             0 gam_server
[ 2423.456762] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2423.456763] [ 1968]     0  1968   108528      575      61       3
   285             0 upowerd
[ 2423.456765] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2423.456767] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2423.456768] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2423.456770] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2423.456772] [ 2200]  1001  2200    13333      143      28       3
     4             0 ssh-agent
[ 2423.456774] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2423.456775] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2423.456777] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2423.456779] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2423.456781] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2423.456783] [ 3670]     0  3670    30129      574      60       3
  3094             0 dhclient
[ 2423.456785] [ 3678]     0  3678    30129      397      57       3
  3084             0 dhclient
[ 2423.456786] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2423.456788] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2423.456790] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2423.456792] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2423.456794] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2423.456796] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2423.456798] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2423.456799] [18174]     0 18174     2160      139      10       3
    30             0 cpuset01
[ 2423.456801] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2423.456803] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2423.456805] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2423.456807] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2423.456809] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2423.456810] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2423.456812] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2423.456814] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2423.456816] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2423.456817] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2423.456819] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2423.456821] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2423.456822] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2423.456824] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2423.456827] [18219]     0 18219    83575     2050     117       4
  2908             0 Xorg.bin
[ 2423.456829] [18307]     0 18307    33071      782      56       3
   260             0 sddm-helper
[ 2423.456831] [18308]   989 18308     9563     1084      23       3
     0             0 systemd
[ 2423.456832] [18309]   989 18309    39366     1104      40       3
    23             0 (sd-pam)
[ 2423.456834] Out of memory: Kill process 1320 (systemd-journal)
score 1 or sacrifice child
[ 2423.456840] Killed process 1320 (systemd-journal)
total-vm:193048kB, anon-rss:184kB, file-rss:47956kB, shmem-rss:4kB
[ 2423.467666] oom_reaper: reaped process 1320 (systemd-journal), now
anon-rss:0kB, file-rss:45828kB, shmem-rss:4kB
[ 2423.582461] systemd[1]: Unit systemd-journald.service entered failed state.
[ 2423.582549] systemd[1]: systemd-journald.service failed.
[ 2424.245227] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.245228] cpuset01 cpuset=1 mems_allowed=1
[ 2424.245232] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.245233] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.245234]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff8808685444c0
[ 2424.245237]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.245239]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.245242] Call Trace:
[ 2424.245247]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.245250]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.245252]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.245255]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.245258]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.245259]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.245262]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.245264]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.245266]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.245268]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.245271]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.245274]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.245276]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.245279]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.245282]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.245283] Mem-Info:
[ 2424.245288] active_anon:7741 inactive_anon:977 isolated_anon:0
 active_file:203926 inactive_file:134039 isolated_file:0
 unevictable:0 dirty:3 writeback:621 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18111
 mapped:5534 shmem:192 pagetables:2281 bounce:0
 free:5615773 free_pcp:403 free_cma:0
[ 2424.245296] Node 0 active_anon:28836kB inactive_anon:1348kB
active_file:815560kB inactive_file:536224kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:22416kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.245304] Node 1 active_anon:2128kB inactive_anon:2560kB
active_file:144kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:2440kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:9107 all_unreclaimable? yes
[ 2424.245306] Node 1 Normal free:12086724kB min:45532kB low:62044kB
high:78556kB active_anon:2128kB inactive_anon:2560kB active_file:144kB
inactive_file:0kB unevictable:0kB writepending:2444kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37272kB
kernel_stack:3048kB pagetables:6428kB bounce:0kB free_pcp:1612kB
local_pcp:0kB free_cma:0kB
[ 2424.245311] lowmem_reserve[]: 0 0 0 0
[ 2424.245314] Node 1 Normal: 1701*4kB (UME) 2253*8kB (UME) 1507*16kB
(UME) 948*32kB (UME) 501*64kB (UME) 377*128kB (UME) 317*256kB (UME)
242*512kB (UME) 173*1024kB (UM) 109*2048kB (ME) 2764*4096kB (M) =
12086380kB
[ 2424.245327] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.245329] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.245329] 339653 total pagecache pages
[ 2424.245330] 1324 pages in swap cache
[ 2424.245331] Swap cache stats: add 139120, delete 137796, find 13161/21143
[ 2424.245332] Free swap  = 16155120kB
[ 2424.245332] Total swap = 16383996kB
[ 2424.245333] 8331071 pages RAM
[ 2424.245334] 0 pages HighMem/MovableOnly
[ 2424.245334] 152036 pages reserved
[ 2424.245335] 0 pages hwpoisoned
[ 2424.245335] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.245343] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.245346] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.245348] [ 1546]     0  1546    12258      393      25       3
   115         -1000 auditd
[ 2424.245350] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.245351] [ 1558]     0  1558    95630      669      42       4
   509             0 accounts-daemon
[ 2424.245353] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.245355] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.245357] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.245358] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.245360] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.245361] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.245363] [ 1567]     0  1567   176613     1639      58       4
  1452             0 rsyslogd
[ 2424.245365] [ 1570]    81  1570    12151      675      28       3
   101          -900 dbus-daemon
[ 2424.245367] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.245369] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.245370] [ 1590]     0  1590     6062      662      16       3
    42             0 systemd-logind
[ 2424.245372] [ 1598]     0  1598   134629      943      77       3
   456             0 NetworkManager
[ 2424.245374] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.245376] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.245377] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.245379] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.245381] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.245382] [ 1649]   995  1649   132342     2124      54       4
   744             0 polkitd
[ 2424.245384] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.245386] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.245387] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.245389] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.245391] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.245392] [ 1726]     0  1726    72807      672      47       3
   274             0 sddm
[ 2424.245394] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.245396] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.245398] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.245399] [ 1968]     0  1968   108528      557      61       3
   303             0 upowerd
[ 2424.245401] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.245403] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.245404] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.245406] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.245408] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.245409] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.245411] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.245413] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.245414] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.245416] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.245418] [ 3670]     0  3670    30129      538      60       3
  3130             0 dhclient
[ 2424.245420] [ 3678]     0  3678    30129      378      57       3
  3103             0 dhclient
[ 2424.245421] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.245423] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.245424] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.245427] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.245428] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.245430] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.245432] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.245434] [18174]     0 18174     2160      104      10       3
    30             0 cpuset01
[ 2424.245435] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.245437] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.245439] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.245441] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.245443] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.245445] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.245446] [18181]     0 18181     2160      152      10       3
    26             0 cpuset01
[ 2424.245448] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.245450] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.245451] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.245453] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.245455] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.245456] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.245458] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.245461] [18219]     0 18219    83575     2050     117       4
  2908             0 Xorg.bin
[ 2424.245462] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.245464] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.245466] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.245468] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.245469] Out of memory: Kill process 18219 (Xorg.bin) score 0 or
sacrifice child
[ 2424.245515] Killed process 18219 (Xorg.bin) total-vm:334300kB,
anon-rss:0kB, file-rss:8200kB, shmem-rss:0kB
[ 2424.248326] oom_reaper: reaped process 18219 (Xorg.bin), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2424.250027] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.250028] cpuset01 cpuset=1 mems_allowed=1
[ 2424.250032] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.250033] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.250034]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff880469436e00
[ 2424.250036]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.250039]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.250041] Call Trace:
[ 2424.250044]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.250047]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.250049]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.250051]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.250054]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.250055]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.250058]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.250060]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.250062]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.250064]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.250067]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.250069]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.250071]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.250073]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.250076]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.250077] Mem-Info:
[ 2424.250082] active_anon:7712 inactive_anon:964 isolated_anon:0
 active_file:203952 inactive_file:134013 isolated_file:0
 unevictable:0 dirty:3 writeback:668 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18111
 mapped:4109 shmem:192 pagetables:2281 bounce:0
 free:5615867 free_pcp:468 free_cma:0
[ 2424.250091] Node 0 active_anon:28836kB inactive_anon:1348kB
active_file:815700kB inactive_file:536084kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:16716kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.250098] Node 1 active_anon:2012kB inactive_anon:2508kB
active_file:108kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:2628kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:9110 all_unreclaimable? yes
[ 2424.250100] Node 1 Normal free:12086852kB min:45532kB low:62044kB
high:78556kB active_anon:2012kB inactive_anon:2508kB active_file:108kB
inactive_file:0kB unevictable:0kB writepending:2632kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37272kB
kernel_stack:3048kB pagetables:6428kB bounce:0kB free_pcp:1864kB
local_pcp:0kB free_cma:0kB
[ 2424.250105] lowmem_reserve[]: 0 0 0 0
[ 2424.250107] Node 1 Normal: 1639*4kB (UME) 2253*8kB (UME) 1507*16kB
(UME) 948*32kB (UME) 501*64kB (UME) 377*128kB (UME) 317*256kB (UME)
242*512kB (UME) 173*1024kB (UM) 109*2048kB (ME) 2764*4096kB (M) =
12086132kB
[ 2424.250120] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.250121] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.250122] 339627 total pagecache pages
[ 2424.250123] 1369 pages in swap cache
[ 2424.250124] Swap cache stats: add 139165, delete 137796, find 13173/21167
[ 2424.250124] Free swap  = 16166588kB
[ 2424.250125] Total swap = 16383996kB
[ 2424.250126] 8331071 pages RAM
[ 2424.250126] 0 pages HighMem/MovableOnly
[ 2424.250127] 152036 pages reserved
[ 2424.250127] 0 pages hwpoisoned
[ 2424.250128] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.250136] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.250138] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.250140] [ 1546]     0  1546    12258      393      25       3
   115         -1000 auditd
[ 2424.250142] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.250144] [ 1558]     0  1558    95630      669      42       4
   509             0 accounts-daemon
[ 2424.250145] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.250147] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.250149] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.250150] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.250152] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.250154] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.250156] [ 1567]     0  1567   176613     1639      58       4
  1452             0 rsyslogd
[ 2424.250158] [ 1570]    81  1570    12151      675      28       3
   101          -900 dbus-daemon
[ 2424.250159] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.250161] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.250163] [ 1590]     0  1590     6062      662      16       3
    42             0 systemd-logind
[ 2424.250165] [ 1598]     0  1598   134629      943      77       3
   456             0 NetworkManager
[ 2424.250166] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.250168] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.250170] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.250171] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.250173] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.250174] [ 1649]   995  1649   132342     2124      54       4
   744             0 polkitd
[ 2424.250176] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.250178] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.250179] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.250181] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.250183] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.250185] [ 1726]     0  1726    72807      672      47       3
   274             0 sddm
[ 2424.250186] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.250188] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.250190] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.250192] [ 1968]     0  1968   108528      557      61       3
   303             0 upowerd
[ 2424.250193] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.250195] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.250197] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.250198] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.250200] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.250202] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.250203] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.250205] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.250206] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.250208] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.250210] [ 3670]     0  3670    30129      538      60       3
  3130             0 dhclient
[ 2424.250211] [ 3678]     0  3678    30129      378      57       3
  3103             0 dhclient
[ 2424.250213] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.250214] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.250216] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.250218] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.250220] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.250222] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.250223] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.250225] [18174]     0 18174     2160      104      10       3
    30             0 cpuset01
[ 2424.250227] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.250229] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.250231] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.250232] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.250234] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.250236] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.250238] [18181]     0 18181     2160      152      10       3
    26             0 cpuset01
[ 2424.250239] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.250241] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.250243] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.250244] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.250246] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.250248] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.250249] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.250252] [18219]     0 18219    83575        0     117       4
     0             0 Xorg.bin
[ 2424.250254] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.250256] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.250257] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.250259] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.250260] Out of memory: Kill process 3670 (dhclient) score 0 or
sacrifice child
[ 2424.250267] Killed process 3670 (dhclient) total-vm:120516kB,
anon-rss:28kB, file-rss:2124kB, shmem-rss:0kB
[ 2424.283252] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.283253] cpuset01 cpuset=1 mems_allowed=1
[ 2424.283256] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.283257] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.283258]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff880868543700
[ 2424.283261]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.283263]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.283266] Call Trace:
[ 2424.283269]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.283272]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.283274]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.283276]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.283279]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.283281]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.283283]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.283285]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.283287]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.283289]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.283292]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.283294]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.283297]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.283299]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.283302]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.283303] Mem-Info:
[ 2424.283308] active_anon:7514 inactive_anon:701 isolated_anon:0
 active_file:203980 inactive_file:134013 isolated_file:0
 unevictable:0 dirty:3 writeback:305 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18108
 mapped:4121 shmem:192 pagetables:2221 bounce:0
 free:5616374 free_pcp:386 free_cma:0
[ 2424.283317] Node 0 active_anon:28808kB inactive_anon:1348kB
active_file:815700kB inactive_file:536084kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:16708kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.283325] Node 1 active_anon:1248kB inactive_anon:1456kB
active_file:220kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:1176kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:5745 all_unreclaimable? yes
[ 2424.283327] Node 1 Normal free:12089004kB min:45532kB low:62044kB
high:78556kB active_anon:1248kB inactive_anon:1456kB active_file:220kB
inactive_file:0kB unevictable:0kB writepending:1180kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37264kB
kernel_stack:3048kB pagetables:6188kB bounce:0kB free_pcp:1528kB
local_pcp:0kB free_cma:0kB
[ 2424.283332] lowmem_reserve[]: 0 0 0 0
[ 2424.283334] Node 1 Normal: 1528*4kB (UME) 2062*8kB (UME) 1341*16kB
(UME) 829*32kB (UME) 460*64kB (UME) 333*128kB (UME) 269*256kB (UME)
214*512kB (UME) 158*1024kB (UM) 99*2048kB (ME) 2784*4096kB (M) =
12088896kB
[ 2424.283348] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.283349] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.283350] 339292 total pagecache pages
[ 2424.283351] 993 pages in swap cache
[ 2424.283352] Swap cache stats: add 139325, delete 138332, find 13175/21169
[ 2424.283352] Free swap  = 16178728kB
[ 2424.283353] Total swap = 16383996kB
[ 2424.283354] 8331071 pages RAM
[ 2424.283355] 0 pages HighMem/MovableOnly
[ 2424.283355] 152036 pages reserved
[ 2424.283356] 0 pages hwpoisoned
[ 2424.283356] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.283364] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.283366] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.283368] [ 1546]     0  1546    12258      393      25       3
   116         -1000 auditd
[ 2424.283370] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.283371] [ 1558]     0  1558    95630      596      42       4
   582             0 accounts-daemon
[ 2424.283373] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.283375] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.283376] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.283378] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.283380] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.283382] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.283383] [ 1567]     0  1567   176613     1619      58       4
  1472             0 rsyslogd
[ 2424.283385] [ 1570]    81  1570    12151      672      28       3
   104          -900 dbus-daemon
[ 2424.283387] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.283388] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.283390] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.283392] [ 1598]     0  1598   134629      887      77       3
   512             0 NetworkManager
[ 2424.283393] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.283395] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.283397] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.283398] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.283400] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.283402] [ 1649]   995  1649   132342     2088      54       4
   780             0 polkitd
[ 2424.283403] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.283405] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.283407] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.283409] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.283411] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.283412] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.283414] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.283416] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.283418] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.283419] [ 1968]     0  1968   108528      555      61       3
   305             0 upowerd
[ 2424.283421] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.283423] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.283424] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.283426] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.283427] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.283429] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.283431] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.283432] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.283434] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.283436] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.283438] [ 3678]     0  3678    30129      378      57       3
  3103             0 dhclient
[ 2424.283439] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.283441] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.283443] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.283445] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.283447] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.283449] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.283450] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.283452] [18174]     0 18174     2160       90      10       3
    30             0 cpuset01
[ 2424.283454] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.283456] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.283458] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.283459] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.283461] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.283463] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.283465] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.283467] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.283468] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.283470] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.283472] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.283473] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.283475] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.283477] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.283483] [18219]     0 18219    83575        0     117       4
     0             0 Xorg.bin
[ 2424.283485] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.283487] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.283489] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.283491] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.283492] Out of memory: Kill process 3678 (dhclient) score 0 or
sacrifice child
[ 2424.283499] Killed process 3678 (dhclient) total-vm:120516kB,
anon-rss:144kB, file-rss:1368kB, shmem-rss:0kB
[ 2424.294213] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.294214] cpuset01 cpuset=1 mems_allowed=1
[ 2424.294217] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.294218] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.294219]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88046abd0000
[ 2424.294222]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.294224]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.294226] Call Trace:
[ 2424.294230]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.294232]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.294234]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.294236]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.294239]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.294241]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.294243]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.294245]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.294247]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.294249]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.294252]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.294255]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.294257]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.294259]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.294262]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.294263] Mem-Info:
[ 2424.294268] active_anon:7441 inactive_anon:692 isolated_anon:0
 active_file:204033 inactive_file:133932 isolated_file:0
 unevictable:0 dirty:3 writeback:345 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18108
 mapped:3945 shmem:192 pagetables:2221 bounce:0
 free:5616475 free_pcp:511 free_cma:0
[ 2424.294277] Node 0 active_anon:28808kB inactive_anon:1348kB
active_file:816024kB inactive_file:535760kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:16060kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.294285] Node 1 active_anon:956kB inactive_anon:1420kB
active_file:108kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:1336kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:5751 all_unreclaimable? yes
[ 2424.294287] Node 1 Normal free:12089252kB min:45532kB low:62044kB
high:78556kB active_anon:956kB inactive_anon:1420kB active_file:108kB
inactive_file:0kB unevictable:0kB writepending:1340kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37264kB
kernel_stack:2880kB pagetables:6188kB bounce:0kB free_pcp:2088kB
local_pcp:0kB free_cma:0kB
[ 2424.294291] lowmem_reserve[]: 0 0 0 0
[ 2424.294294] Node 1 Normal: 1528*4kB (UME) 2061*8kB (UME) 1340*16kB
(UME) 830*32kB (UME) 460*64kB (UME) 333*128kB (UME) 269*256kB (UME)
214*512kB (UME) 158*1024kB (UM) 99*2048kB (ME) 2784*4096kB (M) =
12088904kB
[ 2424.294308] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.294309] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.294309] 339251 total pagecache pages
[ 2424.294310] 988 pages in swap cache
[ 2424.294311] Swap cache stats: add 139325, delete 138337, find 13175/21169
[ 2424.294312] Free swap  = 16191132kB
[ 2424.294312] Total swap = 16383996kB
[ 2424.294313] 8331071 pages RAM
[ 2424.294314] 0 pages HighMem/MovableOnly
[ 2424.294314] 152036 pages reserved
[ 2424.294315] 0 pages hwpoisoned
[ 2424.294315] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.294323] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.294325] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.294327] [ 1546]     0  1546    12258      393      25       3
   116         -1000 auditd
[ 2424.294329] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.294330] [ 1558]     0  1558    95630      596      42       4
   582             0 accounts-daemon
[ 2424.294332] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.294334] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.294336] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.294337] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.294339] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.294340] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.294342] [ 1567]     0  1567   176613     1619      58       4
  1472             0 rsyslogd
[ 2424.294344] [ 1570]    81  1570    12151      672      28       3
   104          -900 dbus-daemon
[ 2424.294345] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.294347] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.294349] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.294351] [ 1598]     0  1598   134629      887      77       3
   512             0 NetworkManager
[ 2424.294352] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.294354] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.294355] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.294357] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.294359] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.294361] [ 1649]   995  1649   132342     2088      54       4
   780             0 polkitd
[ 2424.294362] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.294364] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.294366] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.294367] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.294369] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.294371] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.294373] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.294374] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.294376] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.294378] [ 1968]     0  1968   108528      555      61       3
   305             0 upowerd
[ 2424.294379] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.294381] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.294383] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.294384] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.294386] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.294388] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.294389] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.294391] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.294393] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.294394] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.294396] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.294398] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.294400] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.294402] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.294404] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.294405] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.294407] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.294409] [18174]     0 18174     2160       90      10       3
    30             0 cpuset01
[ 2424.294411] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.294412] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.294414] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.294416] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.294418] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.294419] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.294421] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.294423] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.294425] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.294427] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.294428] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.294430] [18186]     0 18186     2160      150      10       3
    25             0 cpuset01
[ 2424.294432] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.294434] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.294437] [18219]     0 18219    83575       16     117       4
     0             0 Xorg.bin
[ 2424.294439] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.294440] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.294442] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.294444] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.294445] Out of memory: Kill process 1567 (rsyslogd) score 0 or
sacrifice child
[ 2424.294458] Killed process 1567 (rsyslogd) total-vm:706452kB,
anon-rss:268kB, file-rss:6208kB, shmem-rss:0kB
[ 2424.296717] oom_reaper: reaped process 1567 (rsyslogd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2424.298059] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.298060] cpuset01 cpuset=1 mems_allowed=1
[ 2424.298063] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.298063] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.298064]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff8804691ac4c0
[ 2424.298067]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.298069]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.298072] Call Trace:
[ 2424.298075]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.298077]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.298079]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.298082]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.298084]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.298086]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.298088]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.298090]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.298092]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.298095]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.298097]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.298099]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.298102]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.298104]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.298106]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.298107] Mem-Info:
[ 2424.298112] active_anon:7360 inactive_anon:692 isolated_anon:0
 active_file:204681 inactive_file:133284 isolated_file:0
 unevictable:0 dirty:3 writeback:345 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18108
 mapped:3297 shmem:192 pagetables:2221 bounce:0
 free:5616475 free_pcp:511 free_cma:0
[ 2424.298121] Node 0 active_anon:28484kB inactive_anon:1348kB
active_file:818616kB inactive_file:533168kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:13468kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.298129] Node 1 active_anon:956kB inactive_anon:1420kB
active_file:108kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:1336kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:5751 all_unreclaimable? yes
[ 2424.298131] Node 1 Normal free:12089252kB min:45532kB low:62044kB
high:78556kB active_anon:956kB inactive_anon:1420kB active_file:108kB
inactive_file:0kB unevictable:0kB writepending:1340kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37264kB
kernel_stack:2880kB pagetables:6188kB bounce:0kB free_pcp:2032kB
local_pcp:0kB free_cma:0kB
[ 2424.298135] lowmem_reserve[]: 0 0 0 0
[ 2424.298138] Node 1 Normal: 1528*4kB (UME) 2061*8kB (UME) 1340*16kB
(UME) 830*32kB (UME) 460*64kB (UME) 333*128kB (UME) 269*256kB (UME)
214*512kB (UME) 158*1024kB (UM) 99*2048kB (ME) 2784*4096kB (M) =
12088904kB
[ 2424.298151] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.298152] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.298152] 339251 total pagecache pages
[ 2424.298153] 953 pages in swap cache
[ 2424.298154] Swap cache stats: add 139330, delete 138377, find 13176/21172
[ 2424.298155] Free swap  = 16196684kB
[ 2424.298155] Total swap = 16383996kB
[ 2424.298156] 8331071 pages RAM
[ 2424.298157] 0 pages HighMem/MovableOnly
[ 2424.298157] 152036 pages reserved
[ 2424.298158] 0 pages hwpoisoned
[ 2424.298159] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.298166] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.298168] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.298170] [ 1546]     0  1546    12258      393      25       3
   116         -1000 auditd
[ 2424.298172] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.298173] [ 1558]     0  1558    95630      596      42       4
   582             0 accounts-daemon
[ 2424.298175] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.298177] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.298178] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.298180] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.298181] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.298183] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.298185] [ 1567]     0  1567   176613        0      58       4
     0             0 rsyslogd
[ 2424.298187] [ 1570]    81  1570    12151      672      28       3
   104          -900 dbus-daemon
[ 2424.298189] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.298190] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.298192] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.298193] [ 1598]     0  1598   134629      887      77       3
   512             0 NetworkManager
[ 2424.298195] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.298197] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.298198] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.298200] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.298202] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.298204] [ 1649]   995  1649   132342     2088      54       4
   780             0 polkitd
[ 2424.298205] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.298207] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.298208] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.298210] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.298211] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.298213] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.298215] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.298217] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.298219] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.298220] [ 1968]     0  1968   108528      555      61       3
   305             0 upowerd
[ 2424.298222] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.298224] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.298225] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.298227] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.298229] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.298230] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.298232] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.298234] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.298235] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.298237] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.298239] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.298241] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.298243] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.298245] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.298246] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.298248] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.298250] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.298252] [18174]     0 18174     2160       90      10       3
    30             0 cpuset01
[ 2424.298253] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.298255] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.298257] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.298259] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.298261] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.298263] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.298265] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.298266] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.298268] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.298270] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.298271] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.298273] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.298275] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.298276] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.298279] [18219]     0 18219    83575       16     117       4
     0             0 Xorg.bin
[ 2424.298281] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.298282] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.298284] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.298286] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.298287] Out of memory: Kill process 1649 (polkitd) score 0 or
sacrifice child
[ 2424.298299] Killed process 1649 (polkitd) total-vm:529368kB,
anon-rss:3768kB, file-rss:4584kB, shmem-rss:0kB
[ 2424.300652] oom_reaper: reaped process 1649 (polkitd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2424.317233] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.317234] cpuset01 cpuset=1 mems_allowed=1
[ 2424.317238] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.317238] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.317239]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88046abd44c0
[ 2424.317242]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.317245]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.317247] Call Trace:
[ 2424.317250]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.317253]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.317255]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.317257]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.317260]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.317262]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.317264]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.317266]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.317268]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.317271]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.317273]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.317276]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.317278]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.317280]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.317283]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.317284] Mem-Info:
[ 2424.317289] active_anon:6372 inactive_anon:692 isolated_anon:0
 active_file:204709 inactive_file:133284 isolated_file:0
 unevictable:0 dirty:3 writeback:345 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18087
 mapped:2987 shmem:192 pagetables:2104 bounce:0
 free:5617755 free_pcp:422 free_cma:0
[ 2424.317298] Node 0 active_anon:24532kB inactive_anon:1348kB
active_file:818616kB inactive_file:533168kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:12172kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.317307] Node 1 active_anon:956kB inactive_anon:1420kB
active_file:220kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:1336kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:5769 all_unreclaimable? yes
[ 2424.317309] Node 1 Normal free:12089820kB min:45532kB low:62044kB
high:78556kB active_anon:956kB inactive_anon:1420kB active_file:220kB
inactive_file:0kB unevictable:0kB writepending:1340kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37204kB
kernel_stack:2880kB pagetables:5732kB bounce:0kB free_pcp:1612kB
local_pcp:0kB free_cma:0kB
[ 2424.317313] lowmem_reserve[]: 0 0 0 0
[ 2424.317316] Node 1 Normal: 1518*4kB (UME) 2055*8kB (UME) 1327*16kB
(UME) 835*32kB (UME) 451*64kB (UME) 324*128kB (UME) 262*256kB (UME)
209*512kB (UME) 159*1024kB (UM) 102*2048kB (ME) 2784*4096kB (M) =
12089856kB
[ 2424.317329] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.317330] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.317331] 339158 total pagecache pages
[ 2424.317332] 873 pages in swap cache
[ 2424.317333] Swap cache stats: add 139352, delete 138479, find 13184/21191
[ 2424.317334] Free swap  = 16199856kB
[ 2424.317334] Total swap = 16383996kB
[ 2424.317335] 8331071 pages RAM
[ 2424.317336] 0 pages HighMem/MovableOnly
[ 2424.317336] 152036 pages reserved
[ 2424.317337] 0 pages hwpoisoned
[ 2424.317337] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.317345] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.317347] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.317349] [ 1546]     0  1546    12258      393      25       3
   116         -1000 auditd
[ 2424.317351] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.317353] [ 1558]     0  1558    95630      596      42       4
   582             0 accounts-daemon
[ 2424.317354] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.317356] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.317358] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.317360] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.317361] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.317363] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.317365] [ 1567]     0  1567   176613        0      58       4
     0             0 rsyslogd
[ 2424.317366] [ 1570]    81  1570    12151      672      28       3
   104          -900 dbus-daemon
[ 2424.317368] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.317370] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.317372] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.317374] [ 1598]     0  1598   134629      887      77       3
   512             0 NetworkManager
[ 2424.317375] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.317377] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.317379] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.317380] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.317382] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.317384] [ 1656]   995  1649   132342        1      54       4
     0             0 JS GC Helper
[ 2424.317385] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.317387] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.317389] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.317391] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.317392] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.317394] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.317396] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.317398] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.317399] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.317401] [ 1968]     0  1968   108528      555      61       3
   305             0 upowerd
[ 2424.317403] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.317404] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.317406] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.317408] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.317409] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.317411] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.317413] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.317414] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.317416] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.317418] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.317420] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.317421] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.317423] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.317425] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.317427] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.317429] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.317430] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.317432] [18174]     0 18174     2160       76      10       3
    30             0 cpuset01
[ 2424.317434] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.317436] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.317438] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.317440] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.317442] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.317444] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.317445] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.317447] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.317449] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.317451] [18184]     0 18184     2160      153      10       3
    25             0 cpuset01
[ 2424.317452] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.317454] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.317456] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.317457] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.317460] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.317462] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.317463] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.317465] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.317467] Out of memory: Kill process 1598 (NetworkManager) score
0 or sacrifice child
[ 2424.317480] Killed process 1598 (NetworkManager) total-vm:538516kB,
anon-rss:340kB, file-rss:3208kB, shmem-rss:0kB
[ 2424.320922] oom_reaper: reaped process 1598 (NetworkManager), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2424.323080] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.323081] cpuset01 cpuset=1 mems_allowed=1
[ 2424.323085] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.323085] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.323086]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff880868e36e00
[ 2424.323089]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.323091]  ffff88046d386040 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.323093] Call Trace:
[ 2424.323097]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.323099]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.323101]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.323103]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.323106]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.323108]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.323110]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.323112]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.323114]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.323116]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.323119]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.323121]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.323124]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.323126]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.323128]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.323130] Mem-Info:
[ 2424.323135] active_anon:6291 inactive_anon:692 isolated_anon:0
 active_file:204709 inactive_file:133284 isolated_file:0
 unevictable:0 dirty:3 writeback:345 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18087
 mapped:2906 shmem:192 pagetables:2104 bounce:0
 free:5617755 free_pcp:443 free_cma:0
[ 2424.323143] Node 0 active_anon:24208kB inactive_anon:1348kB
active_file:818616kB inactive_file:533168kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:11848kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.323151] Node 1 active_anon:956kB inactive_anon:1420kB
active_file:220kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:1336kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:5769 all_unreclaimable? yes
[ 2424.323153] Node 1 Normal free:12089820kB min:45532kB low:62044kB
high:78556kB active_anon:956kB inactive_anon:1420kB active_file:220kB
inactive_file:0kB unevictable:0kB writepending:1340kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37204kB
kernel_stack:2880kB pagetables:5732kB bounce:0kB free_pcp:1764kB
local_pcp:0kB free_cma:0kB
[ 2424.323157] lowmem_reserve[]: 0 0 0 0
[ 2424.323160] Node 1 Normal: 1487*4kB (UME) 2055*8kB (UME) 1327*16kB
(UME) 835*32kB (UME) 451*64kB (UME) 324*128kB (UME) 262*256kB (UME)
209*512kB (UME) 159*1024kB (UM) 102*2048kB (ME) 2784*4096kB (M) =
12089732kB
[ 2424.323173] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.323174] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.323175] 339158 total pagecache pages
[ 2424.323176] 853 pages in swap cache
[ 2424.323177] Swap cache stats: add 139355, delete 138502, find 13185/21195
[ 2424.323178] Free swap  = 16201436kB
[ 2424.323178] Total swap = 16383996kB
[ 2424.323179] 8331071 pages RAM
[ 2424.323180] 0 pages HighMem/MovableOnly
[ 2424.323180] 152036 pages reserved
[ 2424.323181] 0 pages hwpoisoned
[ 2424.323181] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.323189] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.323191] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.323193] [ 1546]     0  1546    12258      393      25       3
   116         -1000 auditd
[ 2424.323194] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.323196] [ 1558]     0  1558    95630      596      42       4
   582             0 accounts-daemon
[ 2424.323198] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.323199] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.323201] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.323203] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.323205] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.323206] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.323208] [ 1567]     0  1567   176613        0      58       4
     0             0 rsyslogd
[ 2424.323210] [ 1570]    81  1570    12151      672      28       3
   104          -900 dbus-daemon
[ 2424.323211] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.323213] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.323215] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.323217] [ 1650]     0  1598   134629        0      77       3
     0             0 NetworkManager
[ 2424.323219] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.323220] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.323222] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.323224] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.323225] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.323227] [ 1656]   995  1649   132342        1      54       4
     0             0 JS GC Helper
[ 2424.323229] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.323230] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.323232] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.323234] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.323235] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.323237] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.323239] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.323240] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.323242] [ 1958]   994  1958   100413     1256      48       3
   113             0 colord
[ 2424.323244] [ 1968]     0  1968   108528      555      61       3
   305             0 upowerd
[ 2424.323245] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.323247] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.323249] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.323251] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.323252] [ 2200]  1001  2200    13333      142      28       3
     5             0 ssh-agent
[ 2424.323254] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.323256] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.323258] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.323259] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.323261] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.323263] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.323265] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.323266] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.323268] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.323270] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.323272] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.323274] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.323275] [18174]     0 18174     2160       76      10       3
    30             0 cpuset01
[ 2424.323277] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.323279] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.323281] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.323282] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.323284] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.323286] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.323288] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.323290] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.323292] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.323293] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.323295] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.323296] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.323298] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.323300] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.323302] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.323304] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.323306] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.323308] [18313]     0 18313     7274      519      19       3
     0             0 systemd-journal
[ 2424.323309] Out of memory: Kill process 1958 (colord) score 0 or
sacrifice child
[ 2424.323319] Killed process 1958 (colord) total-vm:401652kB,
anon-rss:1784kB, file-rss:3240kB, shmem-rss:0kB
[ 2424.329431] systemd[1]: rsyslog.service: main process exited,
code=killed, status=9/KILL
[ 2424.329829] systemd[1]: Unit rsyslog.service entered failed state.
[ 2424.387255] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.387256] cpuset01 cpuset=1 mems_allowed=1
[ 2424.387259] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.387260] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.387261]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff880468c16040
[ 2424.387264]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.387267]  ffff880466c844c0 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.387269] Call Trace:
[ 2424.387273]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.387276]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.387277]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.387280]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.387283]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.387284]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.387286]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.387288]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.387290]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.387293]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.387295]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.387298]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.387300]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.387302]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.387305]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.387306] Mem-Info:
[ 2424.387311] active_anon:5719 inactive_anon:692 isolated_anon:0
 active_file:204737 inactive_file:132543 isolated_file:0
 unevictable:0 dirty:3 writeback:466 unstable:0
 slab_reclaimable:38712 slab_unreclaimable:18087
 mapped:2596 shmem:192 pagetables:2104 bounce:0
 free:5619026 free_pcp:577 free_cma:0
[ 2424.387320] Node 0 active_anon:22264kB inactive_anon:1348kB
active_file:818616kB inactive_file:530900kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:10876kB dirty:8kB
writeback:44kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
768kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.387330] Node 1 active_anon:612kB inactive_anon:1420kB
active_file:332kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:4kB writeback:1820kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:5432 all_unreclaimable? yes
[ 2424.387332] Node 1 Normal free:12089576kB min:45532kB low:62044kB
high:78556kB active_anon:612kB inactive_anon:1420kB active_file:332kB
inactive_file:0kB unevictable:0kB writepending:1824kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:32012kB slab_unreclaimable:37204kB
kernel_stack:2880kB pagetables:5732kB bounce:0kB free_pcp:2224kB
local_pcp:0kB free_cma:0kB
[ 2424.387337] lowmem_reserve[]: 0 0 0 0
[ 2424.387339] Node 1 Normal: 1330*4kB (UME) 2066*8kB (UME) 1307*16kB
(UME) 811*32kB (UME) 429*64kB (UME) 307*128kB (UME) 250*256kB (UME)
198*512kB (UME) 147*1024kB (UM) 97*2048kB (ME) 2793*4096kB (M) =
12090152kB
[ 2424.387353] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.387354] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.387355] 338619 total pagecache pages
[ 2424.387356] 898 pages in swap cache
[ 2424.387357] Swap cache stats: add 139482, delete 138584, find 13245/21262
[ 2424.387357] Free swap  = 16201736kB
[ 2424.387358] Total swap = 16383996kB
[ 2424.387359] 8331071 pages RAM
[ 2424.387359] 0 pages HighMem/MovableOnly
[ 2424.387360] 152036 pages reserved
[ 2424.387360] 0 pages hwpoisoned
[ 2424.387361] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.387369] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.387371] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.387373] [ 1546]     0  1546    12258      377      25       3
   116         -1000 auditd
[ 2424.387375] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.387377] [ 1558]     0  1558    95630      711      42       4
   549             0 accounts-daemon
[ 2424.387378] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.387380] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.387382] [ 1561]    70  1561     7285      679      20       3
    42             0 avahi-daemon
[ 2424.387384] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.387385] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.387387] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.387389] [ 1570]    81  1570    12151      643      28       3
   104          -900 dbus-daemon
[ 2424.387391] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.387393] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.387394] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.387396] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.387398] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.387400] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.387401] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.387403] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.387405] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.387407] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.387408] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.387410] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.387412] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.387414] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.387416] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.387417] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.387420] [ 1968]     0  1968   108528      555      61       3
   305             0 upowerd
[ 2424.387421] [ 1989]     0  1989   107952      906      44       3
   144             0 udisksd
[ 2424.387423] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.387425] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.387426] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.387428] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.387430] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.387431] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.387433] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.387435] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.387437] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.387439] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.387441] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.387443] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.387445] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.387447] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.387449] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.387450] [18174]     0 18174     2160       62      10       3
    30             0 cpuset01
[ 2424.387452] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.387454] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.387456] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.387458] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.387459] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.387461] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.387463] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.387465] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.387467] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.387468] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.387470] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.387472] [18186]     0 18186     2160      150      10       3
    25             0 cpuset01
[ 2424.387473] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.387475] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.387478] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.387480] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.387482] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.387483] [18313]     0 18313     7274      504      19       3
     0             0 systemd-journal
[ 2424.387485] [18314]     0 18314     2725      483      10       3
     0             0 systemd-cgroups
[ 2424.387490] [18316]     0 18316     2725      482      10       3
     0             0 systemd-cgroups
[ 2424.387492] [18318]     0 18318     2725      480      10       3
     0             0 systemd-cgroups
[ 2424.387493] Out of memory: Kill process 1558 (accounts-daemon)
score 0 or sacrifice child
[ 2424.387502] Killed process 1558 (accounts-daemon)
total-vm:382520kB, anon-rss:220kB, file-rss:2624kB, shmem-rss:0kB
[ 2424.390798] systemd[1]: rsyslog.service failed.
[ 2424.390915] systemd[1]: accounts-daemon.service: main process
exited, code=killed, status=9/KILL
[ 2424.391291] systemd[1]: Unit accounts-daemon.service entered failed state.
[ 2424.391334] systemd[1]: accounts-daemon.service failed.
[ 2424.391422] systemd[1]: NetworkManager.service: main process
exited, code=killed, status=9/KILL
[ 2424.391667] systemd[1]: Unit NetworkManager.service entered failed state.
[ 2424.929753] cpuset01 invoked oom-killer:
gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
order=0, oom_score_adj=0
[ 2424.929755] cpuset01 cpuset=1 mems_allowed=1
[ 2424.929758] CPU: 0 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
[ 2424.929759] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
1.0.4 08/29/2014
[ 2424.929760]  ffffc9000c1afb18 ffffffff813c771e ffffc9000c1afca0
ffff88046a233700
[ 2424.929763]  ffffc9000c1afb90 ffffffff8123aa94 0000000000000000
0000000000000000
[ 2424.929765]  ffff880466c844c0 ffffc9000c1afb60 ffffffff8120f553
ffffc9000c1afb80
[ 2424.929768] Call Trace:
[ 2424.929771]  [<ffffffff813c771e>] dump_stack+0x63/0x85
[ 2424.929774]  [<ffffffff8123aa94>] dump_header+0x7b/0x1f9
[ 2424.929776]  [<ffffffff8120f553>] ? mempolicy_nodemask_intersects+0x23/0x80
[ 2424.929779]  [<ffffffff8134b455>] ? security_capable_noaudit+0x45/0x60
[ 2424.929782]  [<ffffffff811b39c3>] oom_kill_process+0x213/0x3e0
[ 2424.929783]  [<ffffffff811b3eb0>] out_of_memory+0x140/0x4c0
[ 2424.929785]  [<ffffffff811b97df>] __alloc_pages_slowpath+0xa9f/0xac0
[ 2424.929788]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
[ 2424.929789]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
[ 2424.929793]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
[ 2424.929795]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
[ 2424.929798]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
[ 2424.929800]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
[ 2424.929802]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
[ 2424.929805]  [<ffffffff817ca588>] page_fault+0x28/0x30
[ 2424.929806] Mem-Info:
[ 2424.929811] active_anon:5505 inactive_anon:543 isolated_anon:0
 active_file:204595 inactive_file:132432 isolated_file:0
 unevictable:0 dirty:0 writeback:326 unstable:0
 slab_reclaimable:38639 slab_unreclaimable:17965
 mapped:2484 shmem:191 pagetables:1749 bounce:0
 free:5620179 free_pcp:564 free_cma:0
[ 2424.929821] Node 0 active_anon:21540kB inactive_anon:1388kB
active_file:818024kB inactive_file:530124kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB mapped:10292kB dirty:0kB
writeback:4kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp:
764kB writeback_tmp:0kB unstable:0kB pages_scanned:0
all_unreclaimable? no
[ 2424.929829] Node 1 active_anon:480kB inactive_anon:784kB
active_file:356kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB mapped:0kB dirty:0kB writeback:1300kB shmem:0kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
unstable:0kB pages_scanned:3494 all_unreclaimable? yes
[ 2424.929831] Node 1 Normal free:12092512kB min:45532kB low:62044kB
high:78556kB active_anon:480kB inactive_anon:784kB active_file:356kB
inactive_file:0kB unevictable:0kB writepending:1300kB
present:16777216kB managed:16512808kB mlocked:0kB
slab_reclaimable:31720kB slab_unreclaimable:36904kB
kernel_stack:2744kB pagetables:4820kB bounce:0kB free_pcp:2188kB
local_pcp:0kB free_cma:0kB
[ 2424.929835] lowmem_reserve[]: 0 0 0 0
[ 2424.929838] Node 1 Normal: 1330*4kB (UME) 1881*8kB (UME) 1208*16kB
(UME) 722*32kB (UME) 380*64kB (UME) 252*128kB (UME) 212*256kB (UME)
170*512kB (UME) 128*1024kB (UM) 95*2048kB (ME) 2809*4096kB (M) =
12091984kB
[ 2424.929852] Node 0 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.929853] Node 1 hugepages_total=4 hugepages_free=4
hugepages_surp=0 hugepages_size=1048576kB
[ 2424.929854] 338163 total pagecache pages
[ 2424.929854] 777 pages in swap cache
[ 2424.929856] Swap cache stats: add 139729, delete 138952, find 13487/21551
[ 2424.929856] Free swap  = 16204068kB
[ 2424.929857] Total swap = 16383996kB
[ 2424.929858] 8331071 pages RAM
[ 2424.929858] 0 pages HighMem/MovableOnly
[ 2424.929859] 152036 pages reserved
[ 2424.929859] 0 pages hwpoisoned
[ 2424.929860] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
swapents oom_score_adj name
[ 2424.929868] [ 1339]     0  1339    29859      366      26       3
    87             0 lvmetad
[ 2424.929870] [ 1366]     0  1366    10952      785      25       3
    86         -1000 systemd-udevd
[ 2424.929872] [ 1546]     0  1546    12258      307      25       3
   140         -1000 auditd
[ 2424.929874] [ 1557]     0  1557     4192      376      14       3
    44             0 alsactl
[ 2424.929876] [ 1559]   172  1559    41156      390      17       4
    47             0 rtkit-daemon
[ 2424.929877] [ 1560]     0  1560    82920      496      63       3
   304             0 ModemManager
[ 2424.929879] [ 1561]    70  1561     7285      537      20       3
    44             0 avahi-daemon
[ 2424.929881] [ 1562]     0  1562     4322      546      14       3
    29             0 irqbalance
[ 2424.929883] [ 1563]     0  1563     6104      505      18       3
   127             0 smartd
[ 2424.929884] [ 1566]     0  1566     1091      320       7       3
    37             0 rngd
[ 2424.929886] [ 1570]    81  1570    12151      859      28       3
   102          -900 dbus-daemon
[ 2424.929888] [ 1571]    70  1571     6990        3      18       3
    53             0 avahi-daemon
[ 2424.929890] [ 1574]   991  1574    28962      527      27       3
    56             0 chronyd
[ 2424.929892] [ 1590]     0  1590     6062      661      16       3
    43             0 systemd-logind
[ 2424.929893] [ 1602]     0  1602     1620      388       9       3
    32             0 mcelog
[ 2424.929895] [ 1604]     0  1604    52255      533      53       3
   392             0 abrtd
[ 2424.929897] [ 1605]     0  1605   148115      760      63       4
   451             0 abrt-dump-journ
[ 2424.929898] [ 1613]     0  1613    51691      859      51       3
     0             0 abrt-watch-log
[ 2424.929900] [ 1622]     0  1622    50497      398      40       3
    72             0 gssproxy
[ 2424.929902] [ 1690]     0  1690    20216      521      44       3
   200         -1000 sshd
[ 2424.929904] [ 1708]     0  1708     5945      453      17       3
    47             0 atd
[ 2424.929905] [ 1710]     0  1710    31112      500      18       3
   149             0 crond
[ 2424.929907] [ 1719]  1000  1719     9562      930      24       3
   120             0 systemd
[ 2424.929909] [ 1721]  1000  1721    18884      834      36       3
   275             0 (sd-pam)
[ 2424.929911] [ 1726]     0  1726    72807      654      47       3
   292             0 sddm
[ 2424.929912] [ 1874]  1000  1874    13333      142      28       4
     4             0 ssh-agent
[ 2424.929914] [ 1922]  1000  1922     2989      442      11       3
    61             0 gam_server
[ 2424.929916] [ 1968]     0  1968   108528      242      61       3
   302             0 upowerd
[ 2424.929918] [ 1989]     0  1989   107952      546      44       3
   127             0 udisksd
[ 2424.929919] [ 2074]     0  2074     8083      570      20       3
    69             0 bluetoothd
[ 2424.929921] [ 2109]  1001  2109     9563      945      24       3
   124             0 systemd
[ 2424.929923] [ 2110]  1001  2110    18884      788      36       3
   326             0 (sd-pam)
[ 2424.929924] [ 2275]  1001  2275     2989      493      12       3
    25             0 gam_server
[ 2424.929926] [ 2346]     0  2346    27577      416      10       3
     0             0 agetty
[ 2424.929928] [ 2560]     0  2560    27457      785      58       4
     0             0 login
[ 2424.929929] [ 2735]  1001  2735    29484      589      13       3
   448             0 bash
[ 2424.929931] [ 3006]     0  3006    26613      394      47       3
   260          -900 cagibid
[ 2424.929933] [ 3713]     0  3713    34031      909      70       3
     3             0 sshd
[ 2424.929935] [ 3836]  1001  3836    34031      625      68       3
    42             0 sshd
[ 2424.929936] [ 3838]  1001  3838    29519     1049      15       3
    56             0 bash
[ 2424.929939] [18056]     0 18056    57238      815      67       3
     0             0 sudo
[ 2424.929941] [18057]     0 18057    28534      385      14       3
   223             0 runltp
[ 2424.929942] [18171]     0 18171     1856      312       9       3
    29             0 ltp-pan
[ 2424.929944] [18172]     0 18172     2160      373      10       3
    33             0 cpuset01
[ 2424.929946] [18174]     0 18174     2160        2      10       3
    31             0 cpuset01
[ 2424.929948] [18175]     0 18175     2170      151      10       3
    27             0 cpuset01
[ 2424.929949] [18176]     0 18176     2170      152      10       3
    26             0 cpuset01
[ 2424.929951] [18177]     0 18177     2170      152      10       3
    26             0 cpuset01
[ 2424.929953] [18178]     0 18178     2170      148      10       3
    30             0 cpuset01
[ 2424.929955] [18179]     0 18179     2170      153      10       3
    25             0 cpuset01
[ 2424.929957] [18180]     0 18180     2170      152      10       3
    26             0 cpuset01
[ 2424.929959] [18181]     0 18181     2170      153      10       3
    25             0 cpuset01
[ 2424.929961] [18182]     0 18182     2170      150      10       3
    28             0 cpuset01
[ 2424.929962] [18183]     0 18183     2170      151      10       3
    27             0 cpuset01
[ 2424.929964] [18184]     0 18184     2170      153      10       3
    25             0 cpuset01
[ 2424.929966] [18185]     0 18185     2170      152      10       3
    26             0 cpuset01
[ 2424.929968] [18186]     0 18186     2170      150      10       3
    25             0 cpuset01
[ 2424.929969] [18187]     0 18187     2170      144      10       3
    30             0 cpuset01
[ 2424.929971] [18188]     0 18188     2170      144      10       3
    32             0 cpuset01
[ 2424.929974] [18307]     0 18307    33071      752      56       3
   290             0 sddm-helper
[ 2424.929976] [18308]   989 18308     9563      917      23       3
   170             0 systemd
[ 2424.929978] [18309]   989 18309    39366     1003      40       3
   124             0 (sd-pam)
[ 2424.929980] [18313]     0 18313     7274      419      19       3
    58             0 systemd-journal
[ 2424.929981] Out of memory: Kill process 1605 (abrt-dump-journ)
score 0 or sacrifice child
[ 2424.929989] Killed process 1605 (abrt-dump-journ)
total-vm:592460kB, anon-rss:0kB, file-rss:3040kB, shmem-rss:0kB
[ 2424.931892] oom_reaper: reaped process 1605 (abrt-dump-journ), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.089444] Out of memory: Kill process 18309 ((sd-pam)) score 0 or
sacrifice child
[ 2425.089450] Killed process 18309 ((sd-pam)) total-vm:157464kB,
anon-rss:4012kB, file-rss:0kB, shmem-rss:0kB
[ 2425.092147] Out of memory: Kill process 2110 ((sd-pam)) score 0 or
sacrifice child
[ 2425.092153] Killed process 2110 ((sd-pam)) total-vm:75536kB,
anon-rss:3152kB, file-rss:0kB, shmem-rss:0kB
[ 2425.134945] Out of memory: Kill process 1721 ((sd-pam)) score 0 or
sacrifice child
[ 2425.134953] Killed process 1721 ((sd-pam)) total-vm:75536kB,
anon-rss:3336kB, file-rss:0kB, shmem-rss:0kB
[ 2425.136952] oom_reaper: reaped process 1721 ((sd-pam)), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.139305] Out of memory: Kill process 3838 (bash) score 0 or
sacrifice child
[ 2425.139313] Killed process 18056 (sudo) total-vm:228952kB,
anon-rss:916kB, file-rss:2344kB, shmem-rss:0kB
[ 2425.145652] Out of memory: Kill process 3838 (bash) score 0 or
sacrifice child
[ 2425.145657] Killed process 3838 (bash) total-vm:118076kB,
anon-rss:2512kB, file-rss:1684kB, shmem-rss:0kB
[ 2425.150287] Out of memory: Kill process 18308 (systemd) score 0 or
sacrifice child
[ 2425.150294] Killed process 18308 (systemd) total-vm:38252kB,
anon-rss:0kB, file-rss:3668kB, shmem-rss:0kB
[ 2425.151701] oom_reaper: reaped process 18308 (systemd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.154305] Out of memory: Kill process 2109 (systemd) score 0 or
sacrifice child
[ 2425.154312] Killed process 2109 (systemd) total-vm:38252kB,
anon-rss:312kB, file-rss:3560kB, shmem-rss:0kB
[ 2425.160990] Out of memory: Kill process 1719 (systemd) score 0 or
sacrifice child
[ 2425.160996] Killed process 1719 (systemd) total-vm:38248kB,
anon-rss:312kB, file-rss:3488kB, shmem-rss:0kB
[ 2425.163970] Out of memory: Kill process 18307 (sddm-helper) score 0
or sacrifice child
[ 2425.163976] Killed process 18307 (sddm-helper) total-vm:132284kB,
anon-rss:4kB, file-rss:3004kB, shmem-rss:0kB
[ 2425.165787] oom_reaper: reaped process 18307 (sddm-helper), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.167018] Out of memory: Kill process 2735 (bash) score 0 or
sacrifice child
[ 2425.167022] Killed process 2735 (bash) total-vm:117936kB,
anon-rss:768kB, file-rss:1588kB, shmem-rss:0kB
[ 2425.169977] Out of memory: Kill process 1726 (sddm) score 0 or
sacrifice child
[ 2425.169982] Killed process 1726 (sddm) total-vm:291228kB,
anon-rss:184kB, file-rss:2432kB, shmem-rss:0kB
[ 2425.171797] oom_reaper: reaped process 1726 (sddm), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.173007] Out of memory: Kill process 3713 (sshd) score 0 or
sacrifice child
[ 2425.173010] Killed process 3836 (sshd) total-vm:136124kB,
anon-rss:1080kB, file-rss:1420kB, shmem-rss:0kB
[ 2425.174756] oom_reaper: reaped process 3836 (sshd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.176016] Out of memory: Kill process 3713 (sshd) score 0 or
sacrifice child
[ 2425.176020] Killed process 3713 (sshd) total-vm:136124kB,
anon-rss:1216kB, file-rss:2416kB, shmem-rss:4kB
[ 2425.180316] Out of memory: Kill process 1604 (abrtd) score 0 or
sacrifice child
[ 2425.180322] Killed process 1604 (abrtd) total-vm:209020kB,
anon-rss:0kB, file-rss:2132kB, shmem-rss:0kB
[ 2425.181764] oom_reaper: reaped process 1604 (abrtd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.183029] Out of memory: Kill process 1613 (abrt-watch-log) score
0 or sacrifice child
[ 2425.183033] Killed process 1613 (abrt-watch-log) total-vm:206764kB,
anon-rss:1320kB, file-rss:2116kB, shmem-rss:0kB
[ 2425.187331] Out of memory: Kill process 1560 (ModemManager) score 0
or sacrifice child
[ 2425.187341] Killed process 1560 (ModemManager) total-vm:331680kB,
anon-rss:0kB, file-rss:1984kB, shmem-rss:0kB
[ 2425.188787] oom_reaper: reaped process 1560 (ModemManager), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.190055] Out of memory: Kill process 2560 (login) score 0 or
sacrifice child
[ 2425.190062] Killed process 2560 (login) total-vm:109828kB,
anon-rss:796kB, file-rss:2344kB, shmem-rss:0kB
[ 2425.196508] Out of memory: Kill process 1590 (systemd-logind) score
0 or sacrifice child
[ 2425.196515] Killed process 1590 (systemd-logind) total-vm:24248kB,
anon-rss:180kB, file-rss:2464kB, shmem-rss:0kB
[ 2425.199021] Out of memory: Kill process 1989 (udisksd) score 0 or
sacrifice child
[ 2425.199031] Killed process 1989 (udisksd) total-vm:431808kB,
anon-rss:708kB, file-rss:1472kB, shmem-rss:0kB
[ 2425.201917] oom_reaper: reaped process 1989 (udisksd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.207752] Out of memory: Kill process 2074 (bluetoothd) score 0
or sacrifice child
[ 2425.207760] Killed process 2074 (bluetoothd) total-vm:32332kB,
anon-rss:80kB, file-rss:2200kB, shmem-rss:0kB
[ 2425.215492] Out of memory: Kill process 1710 (crond) score 0 or
sacrifice child
[ 2425.215500] Killed process 1710 (crond) total-vm:124448kB,
anon-rss:0kB, file-rss:2000kB, shmem-rss:0kB
[ 2425.217642] oom_reaper: reaped process 1710 (crond), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.220041] Out of memory: Kill process 1563 (smartd) score 0 or
sacrifice child
[ 2425.220048] Killed process 1563 (smartd) total-vm:24416kB,
anon-rss:120kB, file-rss:1900kB, shmem-rss:0kB
[ 2425.221639] oom_reaper: reaped process 1563 (smartd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.227763] Out of memory: Kill process 1574 (chronyd) score 0 or
sacrifice child
[ 2425.227769] Killed process 1574 (chronyd) total-vm:115848kB,
anon-rss:144kB, file-rss:1964kB, shmem-rss:0kB
[ 2425.229695] oom_reaper: reaped process 1574 (chronyd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.232108] Out of memory: Kill process 1561 (avahi-daemon) score 0
or sacrifice child
[ 2425.232115] Killed process 1571 (avahi-daemon) total-vm:27960kB,
anon-rss:12kB, file-rss:0kB, shmem-rss:0kB
[ 2425.233613] oom_reaper: reaped process 1571 (avahi-daemon), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.236221] Out of memory: Kill process 1561 (avahi-daemon) score 0
or sacrifice child
[ 2425.236226] Killed process 1561 (avahi-daemon) total-vm:29140kB,
anon-rss:1256kB, file-rss:876kB, shmem-rss:0kB
[ 2425.243309] Out of memory: Kill process 1562 (irqbalance) score 0
or sacrifice child
[ 2425.243315] Killed process 1562 (irqbalance) total-vm:17288kB,
anon-rss:280kB, file-rss:1904kB, shmem-rss:0kB
[ 2425.256527] Out of memory: Kill process 18057 (runltp) score 0 or
sacrifice child
[ 2425.256533] Killed process 18171 (ltp-pan) total-vm:7424kB,
anon-rss:0kB, file-rss:1220kB, shmem-rss:0kB
[ 2425.261267] Out of memory: Kill process 18057 (runltp) score 0 or
sacrifice child
[ 2425.261272] Killed process 18057 (runltp) total-vm:114136kB,
anon-rss:4kB, file-rss:1472kB, shmem-rss:0kB
[ 2425.274894] Out of memory: Kill process 1968 (upowerd) score 0 or
sacrifice child
[ 2425.274905] Killed process 1968 (upowerd) total-vm:434112kB,
anon-rss:296kB, file-rss:672kB, shmem-rss:0kB
[ 2425.298213] Out of memory: Kill process 2275 (gam_server) score 0
or sacrifice child
[ 2425.298220] Killed process 2275 (gam_server) total-vm:11956kB,
anon-rss:112kB, file-rss:1860kB, shmem-rss:0kB
[ 2425.325088] Out of memory: Kill process 1922 (gam_server) score 0
or sacrifice child
[ 2425.325096] Killed process 1922 (gam_server) total-vm:11956kB,
anon-rss:0kB, file-rss:1768kB, shmem-rss:0kB
[ 2425.458143] Out of memory: Kill process 1708 (atd) score 0 or sacrifice child
[ 2425.458151] Killed process 1708 (atd) total-vm:23780kB,
anon-rss:0kB, file-rss:1812kB, shmem-rss:0kB
[ 2425.459655] oom_reaper: reaped process 1708 (atd), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2425.462460] Out of memory: Kill process 18332 (systemd-cgroups)
score 0 or sacrifice child
[ 2425.462465] Killed process 18332 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1884kB, shmem-rss:0kB
[ 2425.466278] Out of memory: Kill process 1622 (gssproxy) score 0 or
sacrifice child
[ 2425.466298] Killed process 1622 (gssproxy) total-vm:201988kB,
anon-rss:168kB, file-rss:1424kB, shmem-rss:0kB
[ 2425.493031] systemd-journald[18313]: File
/var/log/journal/0ec92082f23d437aaa871981071c6a03/system.journal
corrupted or uncleanly shut down, renaming and replacing.
[ 2426.761109] Out of memory: Kill process 18348 (systemd-udevd) score
0 or sacrifice child
[ 2426.761118] Killed process 18348 (systemd-udevd) total-vm:43808kB,
anon-rss:696kB, file-rss:1368kB, shmem-rss:0kB
[ 2426.765604] Out of memory: Kill process 18349 (systemd-udevd) score
0 or sacrifice child
[ 2426.765611] Killed process 18349 (systemd-udevd) total-vm:43808kB,
anon-rss:672kB, file-rss:1368kB, shmem-rss:0kB
[ 2426.770579] Out of memory: Kill process 18329 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.770583] Killed process 18329 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1864kB, shmem-rss:0kB
[ 2426.775459] Out of memory: Kill process 18342 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.775463] Killed process 18342 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1860kB, shmem-rss:0kB
[ 2426.776700] oom_reaper: reaped process 18342 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.779504] Out of memory: Kill process 18350 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.779508] Killed process 18350 (systemd-cgroups)
total-vm:10900kB, anon-rss:124kB, file-rss:1864kB, shmem-rss:0kB
[ 2426.783417] Out of memory: Kill process 18337 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.783421] Killed process 18337 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1840kB, shmem-rss:0kB
[ 2426.785696] oom_reaper: reaped process 18337 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.788275] Out of memory: Kill process 18352 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.788279] Killed process 18352 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1832kB, shmem-rss:0kB
[ 2426.793299] Out of memory: Kill process 18327 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.793303] Killed process 18327 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1820kB, shmem-rss:0kB
[ 2426.794687] oom_reaper: reaped process 18327 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.797308] Out of memory: Kill process 18336 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.797312] Killed process 18336 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1820kB, shmem-rss:0kB
[ 2426.799685] oom_reaper: reaped process 18336 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.802315] Out of memory: Kill process 18340 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.802318] Killed process 18340 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1820kB, shmem-rss:0kB
[ 2426.806276] Out of memory: Kill process 18345 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.806279] Killed process 18345 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1820kB, shmem-rss:0kB
[ 2426.807695] oom_reaper: reaped process 18345 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.810362] Out of memory: Kill process 18339 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.810366] Killed process 18339 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1808kB, shmem-rss:0kB
[ 2426.811687] oom_reaper: reaped process 18339 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.814280] Out of memory: Kill process 18344 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.814283] Killed process 18344 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1804kB, shmem-rss:0kB
[ 2426.815684] oom_reaper: reaped process 18344 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.818281] Out of memory: Kill process 18333 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.818285] Killed process 18333 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1796kB, shmem-rss:0kB
[ 2426.822300] Out of memory: Kill process 18347 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.822304] Killed process 18347 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1796kB, shmem-rss:0kB
[ 2426.826293] Out of memory: Kill process 18330 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.826297] Killed process 18330 (systemd-cgroups)
total-vm:10900kB, anon-rss:124kB, file-rss:1796kB, shmem-rss:0kB
[ 2426.830266] Out of memory: Kill process 18331 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.830270] Killed process 18331 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1792kB, shmem-rss:0kB
[ 2426.831699] oom_reaper: reaped process 18331 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.834278] Out of memory: Kill process 18334 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.834282] Killed process 18334 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1792kB, shmem-rss:0kB
[ 2426.838279] Out of memory: Kill process 18343 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.838282] Killed process 18343 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1792kB, shmem-rss:0kB
[ 2426.839696] oom_reaper: reaped process 18343 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.842322] Out of memory: Kill process 18335 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.842325] Killed process 18335 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1784kB, shmem-rss:0kB
[ 2426.843687] oom_reaper: reaped process 18335 (systemd-cgroups), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.846305] Out of memory: Kill process 18346 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.846309] Killed process 18346 (systemd-cgroups)
total-vm:10900kB, anon-rss:0kB, file-rss:1784kB, shmem-rss:0kB
[ 2426.850350] Out of memory: Kill process 18354 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.850354] Killed process 18354 (systemd-cgroups)
total-vm:10900kB, anon-rss:124kB, file-rss:1772kB, shmem-rss:0kB
[ 2426.854300] Out of memory: Kill process 1339 (lvmetad) score 0 or
sacrifice child
[ 2426.854306] Killed process 1339 (lvmetad) total-vm:119436kB,
anon-rss:0kB, file-rss:1464kB, shmem-rss:0kB
[ 2426.855739] oom_reaper: reaped process 1339 (lvmetad), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.858318] Out of memory: Kill process 1559 (rtkit-daemon) score 0
or sacrifice child
[ 2426.858330] Killed process 1559 (rtkit-daemon) total-vm:164624kB,
anon-rss:0kB, file-rss:1500kB, shmem-rss:0kB
[ 2426.859734] oom_reaper: reaped process 1559 (rtkit-daemon), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.862292] Out of memory: Kill process 1557 (alsactl) score 0 or
sacrifice child
[ 2426.862297] Killed process 1557 (alsactl) total-vm:16768kB,
anon-rss:0kB, file-rss:1504kB, shmem-rss:0kB
[ 2426.864692] oom_reaper: reaped process 1557 (alsactl), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.867322] Out of memory: Kill process 1602 (mcelog) score 0 or
sacrifice child
[ 2426.867328] Killed process 1602 (mcelog) total-vm:6480kB,
anon-rss:0kB, file-rss:1552kB, shmem-rss:0kB
[ 2426.873526] Out of memory: Kill process 18355 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.873530] Killed process 18355 (systemd-cgroups)
total-vm:10900kB, anon-rss:132kB, file-rss:1868kB, shmem-rss:0kB
[ 2426.879641] Out of memory: Kill process 2346 (agetty) score 0 or
sacrifice child
[ 2426.879647] Killed process 2346 (agetty) total-vm:110308kB,
anon-rss:116kB, file-rss:1548kB, shmem-rss:0kB
[ 2426.885319] Out of memory: Kill process 18356 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.885323] Killed process 18356 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1860kB, shmem-rss:0kB
[ 2426.889307] Out of memory: Kill process 18172 (cpuset01) score 0 or
sacrifice child
[ 2426.889311] Killed process 18174 (cpuset01) total-vm:8640kB,
anon-rss:0kB, file-rss:860kB, shmem-rss:0kB
[ 2426.890676] oom_reaper: reaped process 18174 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.893260] Out of memory: Kill process 18172 (cpuset01) score 0 or
sacrifice child
[ 2426.893264] Killed process 18172 (cpuset01) total-vm:8640kB,
anon-rss:0kB, file-rss:1492kB, shmem-rss:0kB
[ 2426.894680] oom_reaper: reaped process 18172 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.897236] Out of memory: Kill process 18313 (systemd-journal)
score 0 or sacrifice child
[ 2426.897240] Killed process 18313 (systemd-journal)
total-vm:29096kB, anon-rss:0kB, file-rss:1296kB, shmem-rss:0kB
[ 2426.898714] oom_reaper: reaped process 18313 (systemd-journal), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.901292] Out of memory: Kill process 1566 (rngd) score 0 or
sacrifice child
[ 2426.901296] Killed process 1566 (rngd) total-vm:4364kB,
anon-rss:0kB, file-rss:1280kB, shmem-rss:0kB
[ 2426.905235] Out of memory: Kill process 18358 (systemd-cgroups)
score 0 or sacrifice child
[ 2426.905239] Killed process 18358 (systemd-cgroups)
total-vm:10900kB, anon-rss:128kB, file-rss:1864kB, shmem-rss:0kB
[ 2426.909242] Out of memory: Kill process 18175 (cpuset01) score 0 or
sacrifice child
[ 2426.909246] Killed process 18175 (cpuset01) total-vm:8680kB,
anon-rss:24kB, file-rss:580kB, shmem-rss:0kB
[ 2426.910679] oom_reaper: reaped process 18175 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.913171] Out of memory: Kill process 18176 (cpuset01) score 0 or
sacrifice child
[ 2426.913174] Killed process 18176 (cpuset01) total-vm:8680kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.915682] oom_reaper: reaped process 18176 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.917149] Out of memory: Kill process 18177 (cpuset01) score 0 or
sacrifice child
[ 2426.917152] Killed process 18177 (cpuset01) total-vm:8680kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.918689] oom_reaper: reaped process 18177 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.920224] Out of memory: Kill process 18178 (cpuset01) score 0 or
sacrifice child
[ 2426.920227] Killed process 18178 (cpuset01) total-vm:8680kB,
anon-rss:8kB, file-rss:580kB, shmem-rss:0kB
[ 2426.921679] oom_reaper: reaped process 18178 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.923221] Out of memory: Kill process 18179 (cpuset01) score 0 or
sacrifice child
[ 2426.923223] Killed process 18179 (cpuset01) total-vm:8680kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.926087] Out of memory: Kill process 18180 (cpuset01) score 0 or
sacrifice child
[ 2426.926090] Killed process 18180 (cpuset01) total-vm:8680kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.927694] oom_reaper: reaped process 18180 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.929104] Out of memory: Kill process 18181 (cpuset01) score 0 or
sacrifice child
[ 2426.929108] Killed process 18181 (cpuset01) total-vm:8680kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.933099] Out of memory: Kill process 18182 (cpuset01) score 0 or
sacrifice child
[ 2426.933101] Killed process 18182 (cpuset01) total-vm:8680kB,
anon-rss:20kB, file-rss:580kB, shmem-rss:0kB
[ 2426.935706] oom_reaper: reaped process 18182 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.936974] Out of memory: Kill process 18183 (cpuset01) score 0 or
sacrifice child
[ 2426.936977] Killed process 18183 (cpuset01) total-vm:8680kB,
anon-rss:24kB, file-rss:580kB, shmem-rss:0kB
[ 2426.939733] oom_reaper: reaped process 18183 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.940907] Out of memory: Kill process 18184 (cpuset01) score 0 or
sacrifice child
[ 2426.940909] Killed process 18184 (cpuset01) total-vm:8640kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.943763] Out of memory: Kill process 18185 (cpuset01) score 0 or
sacrifice child
[ 2426.943765] Killed process 18185 (cpuset01) total-vm:8680kB,
anon-rss:28kB, file-rss:580kB, shmem-rss:0kB
[ 2426.945711] oom_reaper: reaped process 18185 (cpuset01), now
anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 2426.946761] Out of memory: Kill process 18188 (cpuset01) score 0 or
sacrifice child
[ 2426.946763] Killed process 18188 (cpuset01) total-vm:8680kB,
anon-rss:4kB, file-rss:572kB, shmem-rss:0kB
[ 2428.567107] systemd-journald[18372]: File
/var/log/journal/0ec92082f23d437aaa871981071c6a03/system.journal
corrupted or uncleanly shut down, renaming and replacing.
[ 2430.100600] systemd-journald[18372]: Deleted empty journal
/var/log/journal/0ec92082f23d437aaa871981071c6a03/system@000545ce72268ae2-463c7cc3d0a8b6a5.journal~
(4096 bytes).
[ 3080.548770] perf: interrupt took too long (2631 > 2500), lowering
kernel.perf_event_max_sample_rate to 76000
[ 3282.302916] usb 1-1.5: USB disconnect, device number 4
[ 3283.699622] usb 1-1.5: new low-speed USB device number 5 using ehci-pci
[ 3283.783852] usb 1-1.5: New USB device found, idVendor=0461, idProduct=4e22
[ 3283.783853] usb 1-1.5: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[ 3283.783855] usb 1-1.5: Product: USB Optical Mouse
[ 3283.783856] usb 1-1.5: Manufacturer: PixArt
[ 3283.785925] input: PixArt USB Optical Mouse as
/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.5/1-1.5:1.0/0003:0461:4E22.0004/input/input5
[ 3283.786076] hid-generic 0003:0461:4E22.0004: input,hidraw2: USB HID
v1.11 Mouse [PixArt USB Optical Mouse] on usb-0000:00:1a.0-1.5/input0
>
>>> below is the oops log:
>>> [ 2280.275193] cgroup: new mount options do not match the existing
>>> superblock, will be ignored
>>> [ 2316.565940] cgroup: new mount options do not match the existing
>>> superblock, will be ignored
>>> [ 2393.388361] cpuset01: page allocation stalls for 10051ms, order:0,
>>> mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
>>> [ 2393.388371] CPU: 9 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
>>> [ 2393.388373] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
>>> 1.0.4 08/29/2014
>>> [ 2393.388374]  ffffc9000c1afba8 ffffffff813c771e ffffffff81a40be8
>>> 0000000000000001
>>> [ 2393.388377]  ffffc9000c1afc30 ffffffff811b8c9a 024280ca00000202
>>> ffffffff81a40be8
>>> [ 2393.388380]  ffffc9000c1afbd0 0000000000000010 ffffc9000c1afc40
>>> ffffc9000c1afbf0
>>> [ 2393.388383] Call Trace:
>>> [ 2393.388392]  [<ffffffff813c771e>] dump_stack+0x63/0x85
>>> [ 2393.388397]  [<ffffffff811b8c9a>] warn_alloc+0x13a/0x170
>>> [ 2393.388399]  [<ffffffff811b95c4>] __alloc_pages_slowpath+0x884/0xac0
>>> [ 2393.388402]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
>>> [ 2393.388405]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
>>> [ 2393.388410]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
>>> [ 2393.388413]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
>>> [ 2393.388417]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
>>> [ 2393.388422]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
>>> [ 2393.388424]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
>>> [ 2393.388429]  [<ffffffff817ca588>] page_fault+0x28/0x30
>>> [ 2393.388431] Mem-Info:
>>> [ 2393.388437] active_anon:92316 inactive_anon:21059 isolated_anon:32
>>>  active_file:202031 inactive_file:137088 isolated_file:0
>>>  unevictable:16 dirty:20 writeback:5883 unstable:0
>>>  slab_reclaimable:40274 slab_unreclaimable:21605
>>>  mapped:26819 shmem:28393 pagetables:11375 bounce:0
>>>  free:5494728 free_pcp:549 free_cma:0
>>> [ 2393.388446] Node 0 active_anon:310368kB inactive_anon:25684kB
>>> active_file:807836kB inactive_file:548592kB unevictable:60kB
>>> isolated(anon):0kB isolated(file):0kB mapped:101672kB dirty:80kB
>>> writeback:148kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
>>> anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
>>> all_unreclaimable? no
>>> [ 2393.388455] Node 1 active_anon:58896kB inactive_anon:58552kB
>>> active_file:288kB inactive_file:0kB unevictable:4kB
>>> isolated(anon):128kB isolated(file):0kB mapped:5604kB dirty:0kB
>>> writeback:23384kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
>>> anon_thp: 87792kB writeback_tmp:0kB unstable:0kB pages_scanned:0
>>> all_unreclaimable? no
>>> [ 2393.388457] Node 1 Normal free:11937124kB min:45532kB low:62044kB
>>> high:78556kB active_anon:58896kB inactive_anon:58552kB
>>> active_file:288kB inactive_file:0kB unevictable:4kB
>>> writepending:23384kB present:16777216kB managed:16512808kB mlocked:4kB
>>> slab_reclaimable:37876kB slab_unreclaimable:44812kB
>>> kernel_stack:4264kB pagetables:27612kB bounce:0kB free_pcp:2240kB
>>> local_pcp:0kB free_cma:0kB
>>> [ 2393.388462] lowmem_reserve[]: 0 0 0 0
>>> [ 2393.388465] Node 1 Normal: 1179*4kB (UME) 1396*8kB (UME) 1193*16kB
>>> (UME) 910*32kB (UME) 721*64kB (UME) 568*128kB (UME) 444*256kB (UME)
>>> 328*512kB (ME) 223*1024kB (UM) 138*2048kB (ME) 2676*4096kB (M) =
>>> 11936412kB
>>> [ 2393.388479] Node 0 hugepages_total=4 hugepages_free=4
>>> hugepages_surp=0 hugepages_size=1048576kB
>>> [ 2393.388481] Node 1 hugepages_total=4 hugepages_free=4
>>> hugepages_surp=0 hugepages_size=1048576kB
>>> [ 2393.388481] 374277 total pagecache pages
>>> [ 2393.388483] 6667 pages in swap cache
>>> [ 2393.388484] Swap cache stats: add 101786, delete 95119, find 393/682
>>> [ 2393.388485] Free swap  = 15979384kB
>>> [ 2393.388485] Total swap = 16383996kB
>>> [ 2393.388486] 8331071 pages RAM
>>> [ 2393.388486] 0 pages HighMem/MovableOnly
>>> [ 2393.388487] 152036 pages reserved
>>> [ 2393.388487] 0 pages hwpoisoned
>>> [ 2397.331098] cpuset01 invoked oom-killer:
>>> gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
>>> order=0, oom_score_adj=0
>>>
>>>
>>> [gkulkarni@xeon-numa ltp]$ numactl --hardware
>>> available: 2 nodes (0-1)
>>> node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22
>>> node 0 size: 15823 MB
>>> node 0 free: 10211 MB
>>> node 1 cpus: 1 3 5 7 9 11 13 15 17 19 21 23
>>> node 1 size: 16125 MB
>>> node 1 free: 11628 MB
>>> node distances:
>>> node   0   1
>>>   0:  10  21
>>>   1:  21  10
>>>
>>>
>>> thanks
>>> Ganapat
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
