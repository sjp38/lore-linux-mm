Message-ID: <3D75CD24.AF9B769B@zip.com.au>
Date: Wed, 04 Sep 2002 02:06:44 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: 2.5.33-mm2
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

- Linus has merged ia32 NUMA discontigmem support

+ Added a little cleanup patch from various folks.


Threw in the kichen sink:

+writeback-control.patch

  Infrastructure for richer communication between the block layer
  and the VM.

+queue-congestion.patch

  Infrastructure for non-blocking writeout in the block layer.

+nonblocking-pdflush.patch

  Non-blocking background writeback

+nonblocking-vm.patch

  Non-blocking page reclaim.

This is all about reducing latency when the machine is performing heavy
writeback, which has been a significant performance problem for ever.
The code also happens to provide improved scalability in many-spindle
pagecache writeback.

The code is stable, but by no means complete.  Under some loads it will
chew tons of CPU in page reclaim.

But with mem=512m and four instances of `dbench 100' each against a
different disk the machine was 100% responsive and ran a `make -j6
bzImage' in three minutes.  Without these patches the kernel took over
five minutes just to unpack the kernel tarball.



linus.patch
  cset-1.575-to-1.600.txt.gz

scsi_hack.patch
  Fix block-highmem for scsi

ext3-htree.patch
  Indexed directories for ext3

zone-pages-reporting.patch
  Fix the boot-time reporting of each zone's available pages

enospc-recovery-fix.patch
  Fix the __block_write_full_page() error path.

fix-faults.patch
  Back out the initial work for atomic copy_*_user()

spin-lock-check.patch
  spinlock/rwlock checking infrastructure

refill-rate.patch
  refill the inactive list more quickly

copy_user_atomic.patch

kmap_atomic_reads.patch
  Use kmap_atomic() for generic_file_read()

kmap_atomic_writes.patch
  Use kmap_atomic() for generic_file_write()

throttling-fix.patch
  Fix throttling of heavy write()rs.

dirty-state-accounting.patch
  Make the global dirty memory accounting more accurate

rd-cleanup.patch
  Cleanup and fix the ramdisk driver (doesn't work right yet)

discontig-cleanup-1.patch
  i386 discontigmem coding cleanups

discontig-cleanup-2.patch
  i386 discontigmem cleanups

writeback-thresholds.patch
  Downward adjustments to the default dirtymemory thresholds

buffer-strip.patch
  Limit the consumption of ZONE_NORMAL by buffer_heads

rmap-speedup.patch
  rmap pte_chain space and CPU reductions

wli-highpte.patch
  Resurrect CONFIG_HIGHPTE - ia32 pagetables in highmem

readv-writev.patch
  O_DIRECT support for readv/writev

slablru.patch
  age slab pages on the LRU

slablru-speedup.patch
  slablru optimisations

llzpr.patch
  Reduce scheduling latency across zap_page_range

buffermem.patch
  Resurrect buffermem accounting

config-PAGE_OFFSET.patch
  Configurable kenrel/user memory split

lpp.patch
  ia32 huge tlb pages

ext3-sb.patch
  u.ext3_sb -> generic_sbp

oom-fix.patch
  Fix an OOM condition on big highmem machines

tlb-cleanup.patch
  Clean up the tlb gather code

dump-stack.patch
  arch-neutral dump_stack() function

wli-cleanup.patch
  random cleanups

madvise-move.patch
  move mdavise implementation into mm/madvise.c

split-vma.patch
  VMA splitting patch

buffer-ops-move.patch
  Move submit_bh() and ll_rw_block() into fs/buffer.c

writeback-control.patch
  Cleanup and extension of the writeback paths

queue-congestion.patch
  Infrastructure for communicating request queue congestion to the VM

nonblocking-pdflush.patch
  non-blocking writeback infrastructure, use it for pdflush

nonblocking-vm.patch
  Non-blocking page reclaim
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
