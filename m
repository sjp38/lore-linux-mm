Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 760FA6B0279
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:03:05 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l65so38038496wmf.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 09:03:05 -0800 (PST)
Received: from libero.it (smtp-16.italiaonline.it. [212.48.25.144])
        by mx.google.com with ESMTP id fs7si105295985wjb.7.2015.12.29.09.03.03
        for <linux-mm@kvack.org>;
        Tue, 29 Dec 2015 09:03:03 -0800 (PST)
Message-ID: <1451408582.2783.20.camel@libero.it>
Subject: Unrecoverable Out Of Memory kernel error
From: Guido Trentalancia <g.trentalancia@libero.it>
Date: Tue, 29 Dec 2015 18:03:02 +0100
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello.

I am getting an unrecoverable Out Of Memory error on kernel 4.3.1,
while compiling Firefox 43.0.3. The system becomes unresponsive, the
hard-disk is continuously busy and a hard-reboot must be forced.

Here is the report from the kernel:

Dec 29 12:28:24 vortex kernel: cc1plus invoked oom-killer:
gfp_mask=0x280da, order=0, oom_score_adj=0
Dec 29 12:28:25 vortex kernel: cc1plus cpuset=/ mems_allowed=0
Dec 29 12:28:25 vortex kernel: CPU: 1 PID: 10203 Comm: cc1plus Not
tainted 4.3.1 #1
Dec 29 12:28:25 vortex kernel: Hardware name: Acer Aspire
5745G/JV51_CP, BIOS V1.19 22/03/2011
Dec 29 12:28:25 vortex kernel: ffff8801184e3d50 ffff8801184e3b98
ffffffff812729cf ffff88003b301780
Dec 29 12:28:25 vortex kernel: ffff8801184e3be0 ffffffff8113b207
0000000000000015 0000000000000206
Dec 29 12:28:25 vortex kernel: ffff88001f1f2a08 ffff8801184e3d50
0000000000000000 ffff88001f1f2340
Dec 29 12:28:25 vortex kernel: Call Trace:
Dec 29 12:28:25 vortex kernel: [<ffffffff812729cf>]
dump_stack+0x44/0x55
Dec 29 12:28:25 vortex kernel: [<ffffffff8113b207>]
dump_header.isra.8+0x6c/0x1a9
Dec 29 12:28:25 vortex kernel: [<ffffffff810e9d7f>]
oom_kill_process+0x1af/0x370
Dec 29 12:28:25 vortex kernel: [<ffffffff8104e869>] ?
has_capability_noaudit+0x19/0x20
Dec 29 12:28:25 vortex kernel: [<ffffffff810ea3ed>]
out_of_memory+0x45d/0x480
Dec 29 12:28:25 vortex kernel: [<ffffffff810ef712>]
__alloc_pages_nodemask+0x7f2/0x900
Dec 29 12:28:25 vortex kernel: [<ffffffff811288dd>]
alloc_pages_vma+0xbd/0x220
Dec 29 12:28:25 vortex kernel: [<ffffffff8110d252>]
handle_mm_fault+0x1052/0x1250
Dec 29 12:28:25 vortex kernel: [<ffffffff8103bd8d>]
__do_page_fault+0x14d/0x350
Dec 29 12:28:25 vortex kernel: [<ffffffff8103bfcc>]
do_page_fault+0xc/0x10
Dec 29 12:28:25 vortex kernel: [<ffffffff8155d332>]
page_fault+0x22/0x30
Dec 29 12:28:25 vortex kernel: Mem-Info:
Dec 29 12:28:25 vortex kernel: active_anon:716916 inactive_anon:199483
isolated_anon:0
Dec 29 12:28:25 vortex kernel: active_file:3108 inactive_file:3160
isolated_file:32
Dec 29 12:28:25 vortex kernel: unevictable:4316 dirty:3173 writeback:55
unstable:0
Dec 29 12:28:25 vortex kernel: slab_reclaimable:16548
slab_unreclaimable:9058
Dec 29 12:28:25 vortex kernel: mapped:4037 shmem:13351 pagetables:6846
bounce:0
Dec 29 12:28:25 vortex kernel: free:7058 free_pcp:295 free_cma:0
Dec 29 12:28:25 vortex kernel: Node 0 DMA free:15220kB min:28kB
low:32kB high:40kB active_anon:80kB inactive_anon:268kB
active_file:20kB inactive_file:28kB unevictable:56kB isolated(anon):0kB
isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB
dirty:28kB writeback:0kB mapped:32kB shmem:0kB slab_reclaimable:68kB
slab_unreclaimable:76kB kernel_stack:16kB pagetables:0kB unstable:0kB
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB
pages_scanned:12588 all_unreclaimable? yes
Dec 29 12:28:25 vortex kernel: lowmem_reserve[]: 0 2458 3803 3803
Dec 29 12:28:25 vortex kernel: Node 0 DMA32 free:10344kB min:5024kB
low:6280kB high:7536kB active_anon:1902580kB inactive_anon:475920kB
active_file:8944kB inactive_file:8948kB unevictable:11244kB
isolated(anon):0kB isolated(file):0kB present:2595996kB
managed:2521148kB mlocked:16kB dirty:8888kB writeback:220kB
mapped:10444kB shmem:35636kB slab_reclaimable:42596kB
slab_unreclaimable:21252kB kernel_stack:4464kB pagetables:16528kB
unstable:0kB bounce:0kB free_pcp:340kB local_pcp:32kB free_cma:0kB
writeback_tmp:0kB pages_scanned:109524 all_unreclaimable? yes
Dec 29 12:28:25 vortex kernel: lowmem_reserve[]: 0 0 1344 1344
Dec 29 12:28:25 vortex kernel: Node 0 Normal free:2668kB min:2744kB
low:3428kB high:4116kB active_anon:965004kB inactive_anon:321744kB
active_file:3468kB inactive_file:3664kB unevictable:5964kB
isolated(anon):0kB isolated(file):0kB present:1441792kB
managed:1376548kB mlocked:0kB dirty:3776kB writeback:0kB mapped:5672kB
shmem:17768kB slab_reclaimable:23528kB slab_unreclaimable:14904kB
kernel_stack:3904kB pagetables:10856kB unstable:0kB bounce:0kB
free_pcp:840kB local_pcp:32kB free_cma:0kB writeback_tmp:0kB
pages_scanned:53692 all_unreclaimable? yes
Dec 29 12:28:25 vortex kernel: lowmem_reserve[]: 0 0 0 0
Dec 29 12:28:25 vortex kernel: Node 0 DMA: 6*4kB (UE) 3*8kB (EM) 4*16kB
(UE) 4*32kB (UEM) 2*64kB (UM) 2*128kB (UE) 1*256kB (E) 2*512kB (EM)
3*1024kB (UEM) 1*2048kB (E) 2*4096kB (M) = 15216kB
Dec 29 12:28:25 vortex kernel: Node 0 DMA32: 1452*4kB (UEM) 424*8kB
(UE) 56*16kB (UE) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
0*2048kB 0*4096kB = 10096kB
Dec 29 12:28:25 vortex kernel: Node 0 Normal: 644*4kB (UE) 0*8kB 0*16kB
0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
2576kB
Dec 29 12:28:25 vortex kernel: Node 0 hugepages_total=0
hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Dec 29 12:28:25 vortex kernel: 24576 total pagecache pages
Dec 29 12:28:25 vortex kernel: 291 pages in swap cache
Dec 29 12:28:25 vortex kernel: Swap cache stats: add 4095, delete 3804,
find 0/0
Dec 29 12:28:25 vortex kernel: Free swap  = 0kB
Dec 29 12:28:25 vortex kernel: Total swap = 16380kB
Dec 29 12:28:25 vortex kernel: 1013443 pages RAM
Dec 29 12:28:25 vortex kernel: 0 pages HighMem/MovableOnly
Dec 29 12:28:25 vortex kernel: 35044 pages reserved
Dec 29 12:28:25 vortex kernel: 0 pages hwpoisoned
Dec 29 12:28:25 vortex kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Dec 29 12:28:25 vortex kernel:
[  373]     0   373     6076      545      17       3        0         
    0 plymouthd
Dec 29 12:28:25 vortex kernel:
[  888]     0   888     7447      876      20       3        0         
-1000 udevd
Dec 29 12:28:25 vortex kernel: [
1199]     0  1199     1643       79       8       3        0           
  0 mcelog
Dec 29 12:28:25 vortex kernel: [
1604]     0  1604    11068      109      23       3        0         -
1000 auditd
Dec 29 12:28:25 vortex kernel: [
1626]     0  1626    11926     3125      26       3        0           
  0 restorecond
Dec 29 12:28:25 vortex kernel: [
1635]     0  1635    61245      155      22       3        0           
  0 rsyslogd
Dec 29 12:28:25 vortex kernel: [
1676]    81  1676     7759      303      16       3        0           
  0 dbus-daemon
Dec 29 12:28:25 vortex kernel: [
1687]     0  1687     1107      103       8       3        0           
  0 acpid
Dec 29 12:28:25 vortex kernel: [
1702]    38  1702     5769      161      16       3        0           
  0 ntpd
Dec 29 12:28:25 vortex kernel: [
1720]     0  1720    46177      425      48       3        0           
  0 cupsd
Dec 29 12:28:25 vortex kernel: [
1722]     0  1722    76178     8429      53       4        0           
  0 colord
Dec 29 12:28:25 vortex kernel: [
1728]     4  1728    17891      189      40       3        0           
  0 dbus
Dec 29 12:28:25 vortex kernel: [
1740]     0  1740    64524      318      61       4        0           
  0 cups-browsed
Dec 29 12:28:25 vortex kernel: [
1748]     0  1748    28900      216      15       3        0           
  0 crond
Dec 29 12:28:25 vortex kernel: [
1760]     0  1760     4279       35      12       3        0           
  0 atd
Dec 29 12:28:25 vortex kernel: [
1800]     0  1800     1090       59       8       3        0           
  0 mingetty
Dec 29 12:28:25 vortex kernel: [
1802]     0  1802     1090       74       8       3        0           
  0 mingetty
Dec 29 12:28:25 vortex kernel: [
1803]     0  1803     1090       63       8       3        0           
  0 mingetty
Dec 29 12:28:25 vortex kernel: [
1804]     0  1804     1090       62       8       3        0           
  0 mingetty
Dec 29 12:28:25 vortex kernel: [
1805]     0  1805     1090       61       8       3        0           
  0 mingetty
Dec 29 12:28:25 vortex kernel: [
1806]     0  1806    10176      164      25       3        0           
  0 xdm
Dec 29 12:28:25 vortex kernel: [
1813]     0  1813     7405      769      20       3        0         -
1000 udevd
Dec 29 12:28:25 vortex kernel: [
1814]     0  1814     7446      808      20       3        0         -
1000 udevd
Dec 29 12:28:25 vortex kernel: [
1816]     0  1816    61771     9345     123       3        0           
  0 X
Dec 29 12:28:25 vortex kernel: [
1819]     0  1819    23130      410      53       3        0           
  0 xdm
Dec 29 12:28:25 vortex kernel: [
3613]   500  3613   136397      767      92       3        0           
  0 gnome-session-b
Dec 29 12:28:25 vortex kernel: [
3625]   500  3625    14410      258      34       4        0           
  0 xscreensaver
Dec 29 12:28:25 vortex kernel: [
3633]   500  3633     7320       77      19       3        0           
  0 dbus-launch
Dec 29 12:28:25 vortex kernel: [
3634]   500  3634    24119      370      16       3        0           
  0 dbus-daemon
Dec 29 12:28:25 vortex kernel: [
3697]   500  3697    86058      163      36       3        0           
  0 at-spi-bus-laun
Dec 29 12:28:25 vortex kernel: [
3702]   500  3702    23965      185      16       4        0           
  0 dbus-daemon
Dec 29 12:28:25 vortex kernel: [
3705]   500  3705    51400      241      35       3        0           
  0 at-spi2-registr
Dec 29 12:28:25 vortex kernel: [
3717]   500  3717    75542      177      34       3        0           
  0 gnome-keyring-d
Dec 29 12:28:25 vortex kernel: [
3725]   500  3725   265501     1790     206       4        0           
  0 gnome-settings-
Dec 29 12:28:25 vortex kernel: [
3744]   500  3744    93347      231      39       3        0           
  0 gvfsd
Dec 29 12:28:25 vortex kernel: [
3750]   500  3750   135055      629      94       4        0           
  0 pulseaudio
Dec 29 12:28:25 vortex kernel: [
3752]   172  3752    40670      141      16       3        0           
  0 rtkit-daemon
Dec 29 12:28:25 vortex kernel: [
3756]   150  3756    93326     1090      44       4        0           
  0 polkitd
Dec 29 12:28:25 vortex kernel: [
3765]     0  3765    66639      797      33       3        0           
  0 upowerd
Dec 29 12:28:25 vortex kernel: [
3784]     0  3784   523058      359      59       5        0           
  0 console-kit-dae
Dec 29 12:28:25 vortex kernel: [
3858]   500  3858     6416      151      18       3        0           
  0 syndaemon
Dec 29 12:28:25 vortex kernel: [
3860]   500  3860   148540      943     105       3        0           
  0 gsd-printer
Dec 29 12:28:25 vortex kernel: [
3869]   500  3869    66984      308      64       4        0           
  0 gconf-helper
Dec 29 12:28:25 vortex kernel: [
3873]   500  3873    37554     1230      32       3        0           
  0 gconfd-2
Dec 29 12:28:25 vortex kernel: [
3882]   500  3882   523904    19664     321       5        4           
  0 gnome-shell
Dec 29 12:28:25 vortex kernel: [
3898]   500  3898   110850      352      39       3        0           
  0 ibus-daemon
Dec 29 12:28:25 vortex kernel: [
3903]   500  3903    91773      195      36       3        0           
  0 ibus-dconf
Dec 29 12:28:25 vortex kernel: [
3905]   500  3905   106852      524      98       4        0           
  0 ibus-x11
Dec 29 12:28:25 vortex kernel: [
3910]     0  3910    65170      242      32       3        0           
  0 accounts-daemon
Dec 29 12:28:25 vortex kernel: [
3920]   500  3920   116190      923      60       3        0           
  0 mission-control
Dec 29 12:28:25 vortex kernel: [
3928]   500  3928   166229     2331     173       4        0           
  0 goa-daemon
Dec 29 12:28:25 vortex kernel: [
3932]   500  3932    92115      102      39       3        0           
  0 gvfs-udisks2-vo
Dec 29 12:28:25 vortex kernel: [
3939]   500  3939    98032      273      49       3        0           
  0 gvfs-gdu-volume
Dec 29 12:28:25 vortex kernel: [
3948]   500  3948    89102      213      30       3        0           
  0 gvfs-goa-volume
Dec 29 12:28:25 vortex kernel: [
3956]   500  3956    93137      137      37       3        0           
  0 gvfs-gphoto2-vo
Dec 29 12:28:25 vortex kernel: [
3964]   500  3964   250470     2282     143       4        0           
  0 tracker-extract
Dec 29 12:28:25 vortex kernel: [
3966]   500  3966   249571     2312     204       4        0           
  0 evolution-alarm
Dec 29 12:28:25 vortex kernel: [
3973]   500  3973   142210     1444     132       4        0           
  0 krb5-auth-dialo
Dec 29 12:28:25 vortex kernel: [
3975]   500  3975   209147     1369      85       4        0           
  0 tracker-miner-f
Dec 29 12:28:25 vortex kernel: [
3990]   500  3990   146984     9739      76       3        0           
  0 tracker-store
Dec 29 12:28:25 vortex kernel: [
4002]   500  4002   114659      669      69       4        0           
  0 tracker-miner-u
Dec 29 12:28:25 vortex kernel: [
4005]   500  4005   168576      825      71       4        0           
  0 tracker-miner-a
Dec 29 12:28:25 vortex kernel: [
4016]   500  4016    74333      833      46       4        0           
  0 imsettings-daem
Dec 29 12:28:25 vortex kernel: [
4034]   500  4034   175460      832     142       4        0           
  0 evolution-sourc
Dec 29 12:28:25 vortex kernel: [
4047]   500  4047   219572     8820     158       4        0           
  0 evolution-calen
Dec 29 12:28:25 vortex kernel: [
4057]   500  4057   225629     9089     109       4        0           
  0 evolution-calen
Dec 29 12:28:25 vortex kernel: [
4067]   500  4067   183124     1294      99       4        0           
  0 evolution-addre
Dec 29 12:28:25 vortex kernel: [
4070]   500  4070   254600     8629     106       4        0           
  0 evolution-calen
Dec 29 12:28:25 vortex kernel: [
4092]   500  4092   215153     1207      96       4        0           
  0 evolution-addre
Dec 29 12:28:25 vortex kernel: [
4145]   500  4145    73311      207      33       3        0           
  0 ibus-engine-sim
Dec 29 12:28:25 vortex kernel: [
4169]   500  4169    71732      601      30       4        0           
  0 gvfsd-metadata
Dec 29 12:28:25 vortex kernel: [
4286]   500  4286   139079     2691     127       3        0           
  0 gnome-terminal-
Dec 29 12:28:25 vortex kernel: [
4290]   500  4290    29561      750      17       3        0           
  0 bash
Dec 29 12:28:25 vortex kernel: [12042]   500
12042   860695    22365     385       6        0             0
evolution
Dec 29 12:28:25 vortex kernel: [12498]   500
12498    44252      379      25       4        0             0 dconf-
service
Dec 29 12:28:25 vortex kernel: [31182]   500
31182   314138    45290     379       4        0             0 firefox
Dec 29 12:28:25 vortex kernel: [31309]     0
31309     1090       76       8       3        0             0 mingetty
Dec 29 12:28:25 vortex kernel: [31367]   500
31367    29522      711      17       4        0             0 bash
Dec 29 12:28:25 vortex kernel: [
5615]   500  5615    33683      635      21       3        0           
  0 make
Dec 29 12:28:25 vortex kernel: [
5676]   500  5676    26005       18      11       4        0           
  0 tail
Dec 29 12:28:25 vortex kernel: [10008]   500
10008    33683      631      21       3        0             0 make
Dec 29 12:28:25 vortex kernel: [10011]   500
10011    33683      633      24       3        0             0 make
Dec 29 12:28:25 vortex kernel: [10164]   500
10164    33317      278      22       4        0             0 make
Dec 29 12:28:25 vortex kernel: [10176]   500
10176    33317      270      23       3        0             0 make
Dec 29 12:28:25 vortex kernel: [10196]   500
10196    26996       89      11       3        0             0 c++
Dec 29 12:28:25 vortex kernel: [10197]   500
10197   242408   204623     421       4        0             0 cc1plus
Dec 29 12:28:25 vortex kernel: [10198]   500
10198    32608     5303      22       3        0             0 as
Dec 29 12:28:25 vortex kernel: [10199]   500
10199    26996       87      11       3        0             0 c++
Dec 29 12:28:25 vortex kernel: [10200]   500
10200   221648   182422     377       3        0             0 cc1plus
Dec 29 12:28:25 vortex kernel: [10201]   500
10201    31256     3908      18       3        0             0 as
Dec 29 12:28:25 vortex kernel: [10202]   500
10202    26996       87      11       3        0             0 c++
Dec 29 12:28:25 vortex kernel: [10203]   500
10203   216983   177702     371       4        0             0 cc1plus
Dec 29 12:28:25 vortex kernel: [10204]   500
10204    28383     1067      12       3        0             0 as
Dec 29 12:28:25 vortex kernel: [10207]   500
10207    26996       88      12       3        0             0 c++
Dec 29 12:28:25 vortex kernel: [10208]   500
10208   191267   152563     319       3        0             0 cc1plus
Dec 29 12:28:25 vortex kernel: [10209]   500
10209    30496     3183      18       4        0             0 as
Dec 29 12:28:25 vortex kernel: Out of memory: Kill process 10197
(cc1plus) score 208 or sacrifice child
Dec 29 12:28:25 vortex kernel: Killed process 10197 (cc1plus) total-
vm:969632kB, anon-rss:809184kB, file-rss:9308kB

Is there any way to prevent the system from becoming unresponsive ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
