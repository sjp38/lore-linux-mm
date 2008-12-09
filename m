Received: by yx-out-1718.google.com with SMTP id 36so628153yxh.26
        for <linux-mm@kvack.org>; Tue, 09 Dec 2008 04:54:42 -0800 (PST)
Message-ID: <a4423d670812090454y72e2a0bdt8f6d53f0dc9b9ef2@mail.gmail.com>
Date: Tue, 9 Dec 2008 15:54:42 +0300
From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: next-20081209: pdflush: page allocation failure (xfs)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-next@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

I got the message during compiling of the kernel.
(tainted by previous warning)

x86_64, 2Gb of RAM

pdflush: page allocation failure. order:0, mode:0x4000
Pid: 30415, comm: pdflush Tainted: G        W  2.6.28-rc7-next-20081209 #3
Call Trace:
 [<ffffffff8027c292>] __alloc_pages_internal+0x469/0x488
 [<ffffffff802c170d>] ? bvec_alloc_bs+0xdc/0x11a
 [<ffffffff8029b3b7>] alloc_slab_page+0x20/0x26
 [<ffffffff8029b6b4>] __slab_alloc+0x26c/0x596
 [<ffffffff802c170d>] ? bvec_alloc_bs+0xdc/0x11a
 [<ffffffff802c170d>] ? bvec_alloc_bs+0xdc/0x11a
 [<ffffffff8029bdbb>] kmem_cache_alloc+0x7b/0xbe
 [<ffffffff802c170d>] bvec_alloc_bs+0xdc/0x11a
 [<ffffffff802c17f4>] bio_alloc_bioset+0xa9/0x101
 [<ffffffff802c18b6>] bio_alloc+0x10/0x1f
 [<ffffffff80354781>] xfs_alloc_ioend_bio+0x23/0x52
 [<ffffffff80354838>] xfs_submit_ioend+0x56/0xd4
 [<ffffffff80354e9f>] xfs_page_state_convert+0x5e9/0x642
 [<ffffffff803536bb>] ? xfs_count_page_state+0x97/0xb6
 [<ffffffff803551cf>] xfs_vm_writepage+0xbe/0xf7
 [<ffffffff8027c490>] __writepage+0x15/0x3b
 [<ffffffff8027ce0b>] write_cache_pages+0x1cd/0x331
 [<ffffffff8027c47b>] ? __writepage+0x0/0x3b
 [<ffffffff8027cf91>] generic_writepages+0x22/0x28
 [<ffffffff803550f3>] xfs_vm_writepages+0x45/0x4e
 [<ffffffff8027cfc2>] do_writepages+0x2b/0x3b
 [<ffffffff802b8e98>] __writeback_single_inode+0x186/0x2fa
 [<ffffffff802b94c3>] ? generic_sync_sb_inodes+0x2bc/0x30a
 [<ffffffff802b9433>] generic_sync_sb_inodes+0x22c/0x30a
 [<ffffffff802b972b>] writeback_inodes+0x9d/0xf4
 [<ffffffff8027d118>] wb_kupdate+0xa3/0x11e
 [<ffffffff8027db96>] pdflush+0x11d/0x1d0
 [<ffffffff8027d075>] ? wb_kupdate+0x0/0x11e
 [<ffffffff8027da79>] ? pdflush+0x0/0x1d0
 [<ffffffff80249cfd>] kthread+0x49/0x76
 [<ffffffff8020c8fa>] child_rip+0xa/0x20
 [<ffffffff802314de>] ? finish_task_switch+0x0/0xb9
 [<ffffffff8020c2c0>] ? restore_args+0x0/0x30
 [<ffffffff80249cb4>] ? kthread+0x0/0x76
 [<ffffffff8020c8f0>] ? child_rip+0x0/0x20
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 109
CPU    1: hi:  186, btch:  31 usd: 154
CPU    2: hi:  186, btch:  31 usd:  76
CPU    3: hi:  186, btch:  31 usd:  39
Active_anon:46892 active_file:71530 inactive_anon:10315
 inactive_file:243246 unevictable:0 dirty:15089 writeback:1402 unstable:0
 free:1877 slab:116494 mapped:672 pagetables:401 bounce:0
DMA free:1452kB min:40kB low:48kB high:60kB active_anon:0kB
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
present:15072kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 1975 1975 1975
DMA32 free:6056kB min:5664kB low:7080kB high:8496kB
active_anon:187568kB inactive_anon:41260kB active_file:286120kB
inactive_file:972984kB unevictable:0kB present:2023256kB
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 1*8kB 0*16kB 1*32kB 2*64kB 2*128kB 2*256kB 1*512kB 0*1024kB
0*2048kB 0*4096kB = 1452kB
DMA32: 204*4kB 59*8kB 6*16kB 4*32kB 1*64kB 1*128kB 1*256kB 0*512kB
0*1024kB 0*2048kB 1*4096kB = 6056kB
314797 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 3911788kB
Total swap = 3911788kB
523088 pages RAM
22877 pages reserved
224954 pages shared
276682 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
