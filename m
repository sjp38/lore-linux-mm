Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 31B8F6B00C5
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:40:57 -0400 (EDT)
Date: Mon, 9 Mar 2009 08:40:45 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090309084045.2c652fbf@mjolnir.ossman.eu>
In-Reply-To: <20090309020701.GA381@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-2410-1236584450-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-2410-1236584450-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 9 Mar 2009 10:07:01 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Mon, Mar 09, 2009 at 09:37:42AM +0800, Wu Fengguang wrote:
> >=20
> > The "free" pages in sysrq mem-info report should be equal to "MemFree"
> > in /proc/meminfo. So I'd expect meminfo numbers to be different in
> > .26/.27 as well.
> >=20
> > Maybe the memory is taken by some user space program, so it would be
> > helpful to know the numbers in /proc/meminfo, /proc/vmstat and
> > /proc/zoneinfo.
>=20
> And maybe piggyback /proc/slabinfo in case it is a kernel bug :-)
>=20

Big dump of relevant /proc files:

[root@builder ~]# free
             total       used       free     shared    buffers     cached
Mem:        509108     236988     272120          0        228      14760
-/+ buffers/cache:     222000     287108
Swap:       524280        228     524052

[root@builder ~]# cat /proc/meminfo=20
MemTotal:       509108 kB
MemFree:        272172 kB
Buffers:           240 kB
Cached:          14788 kB
SwapCached:         64 kB
Active:          32544 kB
Inactive:         5900 kB
SwapTotal:      524280 kB
SwapFree:       524052 kB
Dirty:            5980 kB
Writeback:           0 kB
AnonPages:       23404 kB
Mapped:           8648 kB
Slab:            23148 kB
SReclaimable:     5420 kB
SUnreclaim:      17728 kB
PageTables:       3324 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
WritebackTmp:        0 kB
CommitLimit:    778832 kB
Committed_AS:    85196 kB
VmallocTotal: 34359738367 kB
VmallocUsed:      1740 kB
VmallocChunk: 34359736619 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:     2048 kB
DirectMap4k:      2032
DirectMap2M:  18446744073709551613
DirectMap1G:         0

[root@builder ~]# cat /proc/vmstat=20
nr_free_pages 68035
nr_inactive 1479
nr_active 8137
nr_anon_pages 5851
nr_mapped 2162
nr_file_pages 3777
nr_dirty 132
nr_writeback 0
nr_slab_reclaimable 1354
nr_slab_unreclaimable 4440
nr_page_table_pages 831
nr_unstable 0
nr_bounce 0
nr_vmscan_write 324
nr_writeback_temp 0
numa_hit 18985527
numa_miss 0
numa_foreign 0
numa_interleave 44220
numa_local 18985527
numa_other 0
pgpgin 379025
pgpgout 820238
pswpin 16
pswpout 57
pgalloc_dma 295454
pgalloc_dma32 18721928
pgalloc_normal 0
pgalloc_movable 0
pgfree 19085491
pgactivate 60797
pgdeactivate 47199
pgfault 25624481
pgmajfault 2490
pgrefill_dma 8144
pgrefill_dma32 103508
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 4503
pgsteal_dma32 179395
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 4999
pgscan_kswapd_dma32 180546
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 384
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 153856
kswapd_steal 183628
kswapd_inodesteal 35303
pageoutrun 3794
allocstall 3
pgrotated 72
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0

[root@builder ~]# cat /proc/zoneinfo=20
Node 0, zone      DMA
  pages free     2524
        min      12
        low      15
        high     18
        scanned  0 (a: 27 i: 24)
        spanned  4096
        present  2180
    nr_free_pages 2524
    nr_inactive  0
    nr_active    8
    nr_anon_pages 8
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 16
    nr_slab_unreclaimable 7
    nr_page_table_pages 15
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 292
    nr_writeback_temp 0
    numa_hit     295370
    numa_miss    0
    numa_foreign 0
    numa_interleave 0
    numa_local   295370
    numa_other   0
        protection: (0, 489, 489, 489)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 2
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         0
Node 0, zone    DMA32
  pages free     65515
        min      700
        low      875
        high     1050
        scanned  0 (a: 0 i: 0)
        spanned  126960
        present  125224
    nr_free_pages 65515
    nr_inactive  1482
    nr_active    8137
    nr_anon_pages 5843
    nr_mapped    2162
    nr_file_pages 3789
    nr_dirty     128
    nr_writeback 0
    nr_slab_reclaimable 1331
    nr_slab_unreclaimable 4429
    nr_page_table_pages 816
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 32
    nr_writeback_temp 0
    numa_hit     18690260
    numa_miss    0
    numa_foreign 0
    numa_interleave 44220
    numa_local   18690260
    numa_other   0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 69
              high:  186
              batch: 31
  vm stats threshold: 6
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         4096

[root@builder ~]# cat /proc/slabinfo=20
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesper=
slab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_sla=
bs> <num_slabs> <sharedavail>
rpc_inode_cache       39     39    832   39    8 : tunables    0    0    0 =
: slabdata      1      1      0
nf_conntrack_expect      0      0    240   34    2 : tunables    0    0    =
0 : slabdata      0      0      0
UDPv6                 34     34    960   34    8 : tunables    0    0    0 =
: slabdata      1      1      0
TCPv6                 18     18   1792   18    8 : tunables    0    0    0 =
: slabdata      1      1      0
kmalloc_dma-512       32     32    512   32    4 : tunables    0    0    0 =
: slabdata      1      1      0
dm_snap_pending_exception    144    144    112   36    1 : tunables    0   =
 0    0 : slabdata      4      4      0
kcopyd_job             0      0    360   45    4 : tunables    0    0    0 =
: slabdata      0      0      0
dm_uevent              0      0   2608   12    8 : tunables    0    0    0 =
: slabdata      0      0      0
ext3_inode_cache     387   1554    768   42    8 : tunables    0    0    0 =
: slabdata     37     37      0
ext3_xattr            46     46     88   46    1 : tunables    0    0    0 =
: slabdata      1      1      0
journal_handle       170    170     24  170    1 : tunables    0    0    0 =
: slabdata      1      1      0
journal_head          42     42     96   42    1 : tunables    0    0    0 =
: slabdata      1      1      0
revoke_table         256    256     16  256    1 : tunables    0    0    0 =
: slabdata      1      1      0
revoke_record        128    128     32  128    1 : tunables    0    0    0 =
: slabdata      1      1      0
cfq_io_context        44     48    168   24    1 : tunables    0    0    0 =
: slabdata      2      2      0
mqueue_inode_cache     36     36    896   36    8 : tunables    0    0    0=
 : slabdata      1      1      0
isofs_inode_cache      0      0    616   26    4 : tunables    0    0    0 =
: slabdata      0      0      0
hugetlbfs_inode_cache     28     28    584   28    4 : tunables    0    0  =
  0 : slabdata      1      1      0
dquot                  0      0    256   32    2 : tunables    0    0    0 =
: slabdata      0      0      0
inotify_event_cache    612    612     40  102    1 : tunables    0    0    =
0 : slabdata      6      6      0
fasync_cache      313798 313820     24  170    1 : tunables    0    0    0 =
: slabdata   1846   1846      0
shmem_inode_cache    735    738    792   41    8 : tunables    0    0    0 =
: slabdata     18     18      0
pid_namespace          0      0   2104   15    8 : tunables    0    0    0 =
: slabdata      0      0      0
nsproxy                0      0     56   73    1 : tunables    0    0    0 =
: slabdata      0      0      0
UNIX                  92     92    704   46    8 : tunables    0    0    0 =
: slabdata      2      2      0
xfrm_dst_cache         0      0    384   42    4 : tunables    0    0    0 =
: slabdata      0      0      0
ip_dst_cache          51     75    320   25    2 : tunables    0    0    0 =
: slabdata      3      3      0
TCP                   19     19   1664   19    8 : tunables    0    0    0 =
: slabdata      1      1      0
blkdev_integrity       0      0    120   34    1 : tunables    0    0    0 =
: slabdata      0      0      0
blkdev_queue          34     34   1824   17    8 : tunables    0    0    0 =
: slabdata      2      2      0
blkdev_requests       38     52    304   26    2 : tunables    0    0    0 =
: slabdata      2      2      0
sock_inode_cache     138    138    704   46    8 : tunables    0    0    0 =
: slabdata      3      3      0
file_lock_cache       42     42    192   42    2 : tunables    0    0    0 =
: slabdata      1      1      0
taskstats             26     26    312   26    2 : tunables    0    0    0 =
: slabdata      1      1      0
proc_inode_cache      90    162    600   27    4 : tunables    0    0    0 =
: slabdata      6      6      0
sigqueue              25     25    160   25    1 : tunables    0    0    0 =
: slabdata      1      1      0
radix_tree_node      623   2581    560   29    4 : tunables    0    0    0 =
: slabdata     89     89      0
bdev_cache            42     42    768   42    8 : tunables    0    0    0 =
: slabdata      1      1      0
sysfs_dir_cache     7084   7089     80   51    1 : tunables    0    0    0 =
: slabdata    139    139      0
inode_cache         1505   1708    568   28    4 : tunables    0    0    0 =
: slabdata     61     61      0
dentry              2555   4485    208   39    2 : tunables    0    0    0 =
: slabdata    115    115      0
avc_node            1735   2128     72   56    1 : tunables    0    0    0 =
: slabdata     38     38      0
buffer_head         1583   5472    112   36    1 : tunables    0    0    0 =
: slabdata    152    152      0
mm_struct             75     78    832   39    8 : tunables    0    0    0 =
: slabdata      2      2      0
vm_area_struct      2223   2438    176   46    2 : tunables    0    0    0 =
: slabdata     53     53      0
files_cache           78     84    768   42    8 : tunables    0    0    0 =
: slabdata      2      2      0
signal_cache         105    108    896   36    8 : tunables    0    0    0 =
: slabdata      3      3      0
sighand_cache         85     90   2112   15    8 : tunables    0    0    0 =
: slabdata      6      6      0
task_struct          141    145   5840    5    8 : tunables    0    0    0 =
: slabdata     29     29      0
anon_vma             741    768     32  128    1 : tunables    0    0    0 =
: slabdata      6      6      0
shared_policy_node     85     85     48   85    1 : tunables    0    0    0=
 : slabdata      1      1      0
numa_policy           56     60    136   30    1 : tunables    0    0    0 =
: slabdata      2      2      0
idr_layer_cache      269    270    536   30    4 : tunables    0    0    0 =
: slabdata      9      9      0
kmalloc-4096         247    248   4096    8    8 : tunables    0    0    0 =
: slabdata     31     31      0
kmalloc-2048         345    352   2048   16    8 : tunables    0    0    0 =
: slabdata     22     22      0
kmalloc-1024         396    416   1024   32    8 : tunables    0    0    0 =
: slabdata     13     13      0
kmalloc-512          297    320    512   32    4 : tunables    0    0    0 =
: slabdata     10     10      0
kmalloc-256          985    992    256   32    2 : tunables    0    0    0 =
: slabdata     31     31      0
kmalloc-128         1899   2016    128   32    1 : tunables    0    0    0 =
: slabdata     63     63      0
kmalloc-64          6795   9600     64   64    1 : tunables    0    0    0 =
: slabdata    150    150      0
kmalloc-32         20735  20736     32  128    1 : tunables    0    0    0 =
: slabdata    162    162      0
kmalloc-16        138778 139264     16  256    1 : tunables    0    0    0 =
: slabdata    544    544      0
kmalloc-8           8190   8192      8  512    1 : tunables    0    0    0 =
: slabdata     16     16      0
kmalloc-192          972   1050    192   42    2 : tunables    0    0    0 =
: slabdata     25     25      0
kmalloc-96          2815   2856     96   42    1 : tunables    0    0    0 =
: slabdata     68     68      0
kmem_cache_node        0      0     64   64    1 : tunables    0    0    0 =
: slabdata      0      0      0

--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-2410-1236584450-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm0yAAACgkQ7b8eESbyJLit4gCg4jYSl7BO99wmhFj1O5CigKcX
NJ0Anj7Pfx0fnZn06SgaY94cFATTBjLg
=9f7A
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-2410-1236584450-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
