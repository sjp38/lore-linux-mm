Received: from anubis.ics.muni.cz (79.Red-79-145-228.staticIP.rima-tde.net [79.145.228.79])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id m54JYxIR012346
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 21:35:01 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.69)
	(envelope-from <xhejtman@anubis.ics.muni.cz>)
	id 1K3ylD-00051y-9t
	for linux-mm@kvack.org; Wed, 04 Jun 2008 21:35:03 +0200
Resent-Message-ID: <20080604193502.GT5012@ics.muni.cz>
Resent-To: linux-mm@kvack.org
Date: Wed, 4 Jun 2008 15:03:07 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Page allocation failure in 2.6.26-rc2 (iwl4965 driver)
Message-ID: <20080604130307.GN5012@ics.muni.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-wireless@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hello,

in the recent kernels I sometimes got the following allocation failure. It is
provoked by ifconfig wlan0 up. I have machine with 2GB RAM and 1.5GB of swap
(99% free). It happens if I start netbeans (which takes fair amount of memory)
and keep running netbeans whole night (so that updatedb and slocate are woken
up). 

My question is why this happens? According to Jiri Slaby, this should not
happen. I'm also attaching vmstat and slabinfo.

[14478990.059888] ifconfig: page allocation failure. order:4, mode:0x40d0
[14478990.059904] Pid: 27071, comm: ifconfig Not tainted 2.6.26-rc2-git5 #9
[14478990.059909] 
[14478990.059910] Call Trace:
[14478990.059932]  [<ffffffff80275a3d>] __alloc_pages_internal+0x3dd/0x4f0
[14478990.059945]  [<ffffffff80275bec>] __get_free_pages+0x1c/0x60
[14478990.059968]  [<ffffffffa00f51fa>]
:iwl4965:iwl4965_tx_queue_init+0x9a/0x1d0
[14478990.059992]  [<ffffffffa00fd873>]
:iwl4965:iwl4965_hw_nic_init+0x3f3/0x1cb0
[14478990.059999]  [<ffffffff8026a32e>] setup_irq+0x14e/0x290
[14478990.060018]  [<ffffffffa00e6ac4>] :iwl4965:__iwl4965_up+0xb4/0x590
[14478990.060035]  [<ffffffffa00e75c8>] :iwl4965:iwl4965_mac_start+0x5c8/0xfc0
[14478990.060043]  [<ffffffff802a451f>] __link_path_walk+0x53f/0x1040
[14478990.060069]  [<ffffffffa00b8dbc>] :mac80211:ieee80211_open+0x13c/0x5c0
[14478990.060075]  [<ffffffff802a50dc>] path_walk+0xbc/0xd0
[14478990.060086]  [<ffffffff804739f9>] dev_open+0x89/0xf0
[14478990.060093]  [<ffffffff80473292>] dev_change_flags+0x92/0x1b0
[14478990.060102]  [<ffffffff804b9bb4>] devinet_ioctl+0x7a4/0x7b0
[14478990.060108]  [<ffffffff802a6816>] do_filp_open+0xb6/0x990
[14478990.060121]  [<ffffffff80464496>] sock_ioctl+0x66/0x280
[14478990.060127]  [<ffffffff802a7f7f>] vfs_ioctl+0x2f/0xb0
[14478990.060133]  [<ffffffff802a8283>] do_vfs_ioctl+0x283/0x2f0
[14478990.060140]  [<ffffffff802a8339>] sys_ioctl+0x49/0x80
[14478990.060146]  [<ffffffff80297e99>] do_sys_open+0xe9/0x110
[14478990.060155]  [<ffffffff8020c32b>] system_call_after_swapgs+0x7b/0x80
[14478990.060163] 
[14478990.060166] Mem-info:
[14478990.060169] DMA per-cpu:
[14478990.060174] CPU    0: hi:    0, btch:   1 usd:   0
[14478990.060178] CPU    1: hi:    0, btch:   1 usd:   0
[14478990.060182] DMA32 per-cpu:
[14478990.060186] CPU    0: hi:  186, btch:  31 usd:   0
[14478990.060190] CPU    1: hi:  186, btch:  31 usd:   0
[14478990.060197] Active:353461 inactive:90156 dirty:3 writeback:0 unstable:0
[14478990.060199]  free:10504 slab:16638 mapped:24858 pagetables:3705 bounce:0
[14478990.060207] DMA free:7916kB min:28kB low:32kB high:40kB active:2536kB
inactive:0kB present:10032kB pages_scanned:0 all_unreclaimable? no
[14478990.060212] lowmem_reserve[]: 0 1963 1963 1963
[14478990.060223] DMA32 free:34100kB min:5652kB low:7064kB high:8476kB
active:1411308kB inactive:360624kB present:2010596kB pages_scanned:0
all_unreclaimable? no
[14478990.060229] lowmem_reserve[]: 0 0 0 0
[14478990.060237] DMA: 35*4kB 16*8kB 24*16kB 19*32kB 16*64kB 12*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 1*4096kB = 7916kB
[14478990.060256] DMA32: 4660*4kB 1361*8kB 231*16kB 15*32kB 1*64kB 1*128kB
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 34152kB
[14478990.060274] 174269 total pagecache pages
[14478990.060279] Swap cache: add 135, delete 86, find 31/36
[14478990.060283] Free swap  = 1534328kB
[14478990.060286] Total swap = 1534672kB
[14478990.076000] 513712 pages of RAM
[14478990.076008] 9367 reserved pages
[14478990.076012] 161337 pages shared
[14478990.076015] 49 pages swap cached
[14478990.076019] iwl4965: kmalloc for auxiliary BD structures failed
[14478990.076030] iwl4965: Tx 6 queue init failed
[14478990.076061] iwl4965: Unable to init nic

-- 
Luka1 Hejtmanek

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: attachment; filename="vmstat.nomem"

nr_free_pages 10562
nr_inactive 90191
nr_active 353444
nr_anon_pages 269349
nr_mapped 24853
nr_file_pages 174310
nr_dirty 34
nr_writeback 0
nr_slab_reclaimable 13345
nr_slab_unreclaimable 3293
nr_page_table_pages 3709
nr_unstable 0
nr_bounce 0
nr_vmscan_write 145
nr_writeback_temp 0
pgpgin 4465231
pgpgout 1690084
pswpin 19
pswpout 43
pgalloc_dma 336993
pgalloc_dma32 56207889
pgalloc_normal 0
pgalloc_movable 0
pgfree 56555683
pgactivate 1767842
pgdeactivate 232049
pgfault 51147492
pgmajfault 4074
pgrefill_dma 13774
pgrefill_dma32 1230295
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 11129
pgsteal_dma32 922798
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 11605
pgscan_direct_dma32 956420
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 112417
slabs_scanned 165120
kswapd_steal 0
kswapd_inodesteal 0
pageoutrun 4235909
allocstall 14350
pgrotated 76

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: attachment; filename="slabinfo.nomem"

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
fat_inode_cache       13     13    624   13    2 : tunables    0    0    0 : slabdata      1      1      0
fat_cache            204    204     40  102    1 : tunables    0    0    0 : slabdata      2      2      0
fuse_request           0      0    608   13    2 : tunables    0    0    0 : slabdata      0      0      0
fuse_inode             0      0    704   23    4 : tunables    0    0    0 : slabdata      0      0      0
kmalloc_dma-512        0     16    512   16    2 : tunables    0    0    0 : slabdata      1      1      0
cfq_queue            105    120    136   30    1 : tunables    0    0    0 : slabdata      4      4      0
bsg_cmd                0      0    312   13    1 : tunables    0    0    0 : slabdata      0      0      0
mqueue_inode_cache      1     19    832   19    4 : tunables    0    0    0 : slabdata      1      1      0
ext2_inode_cache       0      0    736   22    4 : tunables    0    0    0 : slabdata      0      0      0
journal_handle       340    340     24  170    1 : tunables    0    0    0 : slabdata      2      2      0
journal_head         126    126     96   42    1 : tunables    0    0    0 : slabdata      3      3      0
revoke_table         258    512     16  256    1 : tunables    0    0    0 : slabdata      2      2      0
revoke_record        256    256     32  128    1 : tunables    0    0    0 : slabdata      2      2      0
ext3_inode_cache   45184  45298    744   22    4 : tunables    0    0    0 : slabdata   2059   2059      0
ext3_xattr             0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
inotify_event_cache    204    204     40  102    1 : tunables    0    0    0 : slabdata      2      2      0
shmem_inode_cache   3021   3058    736   22    4 : tunables    0    0    0 : slabdata    139    139      0
pid_namespace          0      0   2104   15    8 : tunables    0    0    0 : slabdata      0      0      0
nsproxy               73    146     56   73    1 : tunables    0    0    0 : slabdata      2      2      0
xfrm_dst_cache         0      0    384   21    2 : tunables    0    0    0 : slabdata      0      0      0
ip_dst_cache          26     36    320   12    1 : tunables    0    0    0 : slabdata      3      3      0
UDP                   42     42    768   21    4 : tunables    0    0    0 : slabdata      2      2      0
TCP                   67     76   1664   19    8 : tunables    0    0    0 : slabdata      4      4      0
scsi_bidi_sdb        171    340     24  170    1 : tunables    0    0    0 : slabdata      2      2      0
scsi_io_context        0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
blkdev_queue          19     36   1792   18    8 : tunables    0    0    0 : slabdata      2      2      0
blkdev_requests       30     39    304   13    1 : tunables    0    0    0 : slabdata      3      3      0
sock_inode_cache     323    336    640   12    2 : tunables    0    0    0 : slabdata     28     28      0
skbuff_fclone_cache     36     36    448   18    2 : tunables    0    0    0 : slabdata      2      2      0
file_lock_cache       42     42    192   21    1 : tunables    0    0    0 : slabdata      2      2      0
Acpi-ParseExt       3413   3472     72   56    1 : tunables    0    0    0 : slabdata     62     62      0
Acpi-Parse           170    170     48   85    1 : tunables    0    0    0 : slabdata      2      2      0
proc_inode_cache     556    574    576   14    2 : tunables    0    0    0 : slabdata     41     41      0
sigqueue              50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
radix_tree_node    18235  18347    560   14    2 : tunables    0    0    0 : slabdata   1311   1311      0
bdev_cache            42     42    768   21    4 : tunables    0    0    0 : slabdata      2      2      0
sysfs_dir_cache    11779  11781     80   51    1 : tunables    0    0    0 : slabdata    231    231      0
inode_cache          261    435    544   15    2 : tunables    0    0    0 : slabdata     29     29      0
dentry              5784  11153    208   19    1 : tunables    0    0    0 : slabdata    587    587      0
buffer_head        59755  60624    112   36    1 : tunables    0    0    0 : slabdata   1684   1684      0
vm_area_struct     10323  10776    168   24    1 : tunables    0    0    0 : slabdata    449    449      0
files_cache          387    414    704   23    4 : tunables    0    0    0 : slabdata     18     18      0
signal_cache         236    266    832   19    4 : tunables    0    0    0 : slabdata     14     14      0
sighand_cache        153    180   2112   15    8 : tunables    0    0    0 : slabdata     12     12      0
task_struct          257    299   1424   23    8 : tunables    0    0    0 : slabdata     13     13      0
anon_vma            3302   3584     32  128    1 : tunables    0    0    0 : slabdata     28     28      0
idr_layer_cache      401    405    536   15    2 : tunables    0    0    0 : slabdata     27     27      0
kmalloc-4096          54     64   4096    8    8 : tunables    0    0    0 : slabdata      8      8      0
kmalloc-2048         373    432   2048   16    8 : tunables    0    0    0 : slabdata     27     27      0
kmalloc-1024        1019   1040   1024   16    4 : tunables    0    0    0 : slabdata     65     65      0
kmalloc-512          418    448    512   16    2 : tunables    0    0    0 : slabdata     28     28      0
kmalloc-256          599    608    256   16    1 : tunables    0    0    0 : slabdata     38     38      0
kmalloc-128          606    960    128   32    1 : tunables    0    0    0 : slabdata     30     30      0
kmalloc-64         28435  32320     64   64    1 : tunables    0    0    0 : slabdata    505    505      0
kmalloc-32          2619   2688     32  128    1 : tunables    0    0    0 : slabdata     21     21      0
kmalloc-16          2889   3584     16  256    1 : tunables    0    0    0 : slabdata     14     14      0
kmalloc-8           5020   5120      8  512    1 : tunables    0    0    0 : slabdata     10     10      0
kmalloc-192         5108   5292    192   21    1 : tunables    0    0    0 : slabdata    252    252      0
kmalloc-96          1188   1302     96   42    1 : tunables    0    0    0 : slabdata     31     31      0

--LZvS9be/3tNcYl/X--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
