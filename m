Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA24485
	for <linux-mm@kvack.org>; Tue, 8 Oct 2002 00:07:41 -0700 (PDT)
Message-ID: <3DA2843B.D33EEA08@digeo.com>
Date: Tue, 08 Oct 2002 00:07:39 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: 2.5.41-mm1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.41/2.5.41-mm1/

- Some new work on the swap control algorithms. Most notably some
  code to dynamically clamp down on memory dirtiers if it appears
  likely that their activity will cause paging activity.

- Added Bill Irwin's hugetlb filesytem.  It exposes the hugetlb code
  via a mmap() interface.  Also Bill has enhanced sysv shared memory
  to allow that to be backed by hugetlbfs files.

- Included Al Viro's Orlov block allocator for ext2.  It speeds up
  operations against many-small-files-in-many-directories by just heaps.


+misc.patch

 Tiny bugfix

+get_bios_geometry.patch

 Some more 64-bit sector_t work from Peter.

+orlov-allocator.patch

 The Orlov block allocator.  Needs to be done for ext3 as well...

+hugetlb-prefault.patch
+ramfs-aops.patch
+hugetlb-header-split.patch
+hugetlbfs.patch
+hugetlb-shm.patch

 hugetlbfs and hugetlbfs-for-shm.

+remove-radix_tree_reserve.patch

 Remove radix_tree_reserve() - we don't actually need it (Hugh)

+raw-use-o_direct.patch

 Convert the raw driver to simply subvert the passed file* into using
 O_DIRECT reads and writes against the backing blockdev.  This
 unbreaks the raw driver.

+mapped-start-active.patch

 Start mapped pages on the active list, not the inactive list.
 They're going to go there anyway, and adding great blobs of
 mapped pages to the inactive list upsets things.

+rename-dirty_async_ratio.patch

 Rename /proc/sys/vm/dirty_async_ratio to just dirty_ratio

+auto-dirty-memory.patch

 Dynamically decrease the writer throttling threshold if there's
 a lot of mapped memory around -> prevents heavy writers from
 forcing paging activity - make them clean their own pagecache
 earlier instead.





misc.patch
  mmisc fixes

discontig-setup-fix.patch
  discontigmem compile fix

discontig-no-contig_page_data.patch
  undefine contif_page_data for discontigmem

per-node-mem_map.patch
  ia32 NUMA: per-node ZONE_NORMAL

remove-get_free_page.patch
  remove get_free_page()

alloc_pages_node-cleanup.patch
  alloc_pages_node cleanup

free_area_init-cleanup.patch
  free_area_init_node cleanup

wli-libfs.patch
  Move dentry library functions from ramfs to libfs

ext3-dxdir.patch
  ext3 htree

lbd1.patch
  64-bit sector_t 1/5 - various driver changes

lbd2.patch
  64-bit sector_t 2/5 - printk changes and sector_t cleanup

lbd3.patch
  64-bit sector_t 3/5 - driver changes

lbd4.patch
  64-bit sector_t 4/5 - filesystems

lbd5.patch
  64-bit sector_t 5/5 - md fixes

lbd6.patch
  64-bit sector_t 6/5 - remove udivdi3, use sector_div()

get_bios_geometry.patch
  Fix xxx_get_biosgeometry --- avoid useless 64-bit division.

64-bit-sector_t.patch
  Hardwire CONFIG_LBD to "on"

orlov-allocator.patch

dio-fine-alignment.patch
  Allow O_DIRECT to use 512-byte alignment

lseek-ext2_readdir.patch
  remove lock_kernel() from ext2_readdir()

write-deadlock.patch
  Fix the generic_file_write-from-same-mmapped-page deadlock

batched-slab-asap.patch
  batched slab shrinking

swsusp-feature.patch
  add shrink_all_memory() for swsusp

rd-cleanup.patch
  Cleanup and fix the ramdisk driver (doesn't work right yet)

spin-lock-check.patch
  spinlock/rwlock checking infrastructure

hugetlb-prefault.patch
  hugetlbpages: factor out some code for hugetlbfs

ramfs-aops.patch

hugetlb-header-split.patch

hugetlbfs.patch

hugetlb-shm.patch

akpm-deadline.patch
  deadline scheduler tweaks

rmqueue_bulk.patch
  bulk page allocator

free_pages_bulk.patch
  Bulk page freeing function

hot_cold_pages.patch
  Hot/Cold pages and zone->lock amortisation

readahead-cold-pages.patch
  Use cache-cold pages for pagecache reads.

pagevec-hot-cold-hint.patch
  hot/cold hints for truncate and page reclaim

page-reservation.patch
  Page reservation API

remove-radix_tree_reserve.patch
  remove radix_tree_reserve()

raw-use-o_direct.patch

intel-user-copy.patch
  Faster copt_*_user for Intel ia32 CPUs

slab-split-01-rename.patch
  slab cleanup: rename static functions

slab-split-02-SMP.patch
  slab: enable the cpu arrays on uniprocessor

slab-split-03-tail.patch
  slab: reduced internal fragmentation

slab-split-04-drain.patch
  slab: take the spinlock in the drain function.

slab-split-05-name.patch
  slab: remove spaces from /proc identifiers

slab-split-06-mand-cpuarray.patch
  slab: cleanups and speedups

slab-split-07-inline.patch
  slab: uninline poisoning checks

slab-split-08-reap.patch
  slab: reap timers

cpucache_init-fix.patch
  cpucache_init fix

large-queue-throttle.patch
  Improve writer throttling for small machines

exit-page-referenced.patch
  Propagate pte referenced bit into pagecache during unmap

swappiness.patch
  swappiness control

mapped-start-active.patch

rename-dirty_async_ratio.patch
  rename dirty_async_ratio to dirty_ratio

auto-dirty-memory.patch
  adaptive dirty-memory thresholding

read_barrier_depends.patch
  extended barrier primitives

rcu_ltimer.patch
  RCU core

dcache_rcu.patch
  Use RCU for dcache
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
