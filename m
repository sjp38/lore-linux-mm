Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8C526B0253
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:11:48 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id di3so85250754pab.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 23:11:48 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id p4si11545457pfp.199.2016.06.09.23.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 23:11:45 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id di3so4374699pab.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 23:11:44 -0700 (PDT)
Date: Fri, 10 Jun 2016 15:11:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [mmots-2016-06-09-16-49] kernel BUG at mm/slub.c:1616
Message-ID: <20160610061139.GA374@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

[  429.191962] gfp: 2
[  429.192634] ------------[ cut here ]------------
[  429.193281] kernel BUG at mm/slub.c:1616!
[  429.193920] invalid opcode: 0000 [#1] PREEMPT SMP
[  429.194556] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_pcm snd_timer snd soundcore coretemp hwmon mousedev r8169 i2c_i801 crc32c_intel mii lpc_ich mfd_core acpi_cpufreq processor sch_fq_codel uas usb_storage hid_generi
c usbhid hid sd_mod ahci libahci libata scsi_mod ehci_pci ehci_hcd usbcore usb_common
[  429.196008] CPU: 0 PID: 562 Comm: gzip Not tainted 4.7.0-rc2-mm1-dbg-00231-g201dcbd-dirty #141
[  429.197385] task: ffff8800bf8e3a80 ti: ffff88009434c000 task.ti: ffff88009434c000
[  429.198082] RIP: 0010:[<ffffffff811036a5>]  [<ffffffff811036a5>] new_slab+0x25/0x2be
[  429.198782] RSP: 0018:ffff88009434f820  EFLAGS: 00010082
[  429.199475] RAX: 0000000000000006 RBX: 0000000000000000 RCX: 0000000000000001
[  429.200173] RDX: ffff880137c10401 RSI: ffffffff81796bf9 RDI: 00000000ffffffff
[  429.200871] RBP: ffff88009434f850 R08: 0000000000000001 R09: 0000000000000000
[  429.201568] R10: ffff88009434f860 R11: 00000000ffffffff R12: 000000000203138a
[  429.202272] R13: ffff880133001800 R14: 0000000000000000 R15: 0000000000000000
[  429.202969] FS:  00007fa79ea77700(0000) GS:ffff880137c00000(0000) knlGS:0000000000000000
[  429.203665] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  429.204363] CR2: 00000000015ec1c0 CR3: 00000000940a6000 CR4: 00000000000006f0
[  429.205063] Stack:
[  429.205760]  000000000203138a 0000000000000000 ffff880137c17e50 ffff880133001800
[  429.206474]  0000000000000000 0000000000000000 ffff88009434f930 ffffffff81105467
[  429.207197]  ffffffff8105993f ffffffff810c7582 0000000100150015 0203138a00000001
[  429.207914] Call Trace:
[  429.208618]  [<ffffffff81105467>] ___slab_alloc.constprop.23+0x2f8/0x387
[  429.209328]  [<ffffffff8105993f>] ? __might_sleep+0x70/0x77
[  429.210034]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.210739]  [<ffffffff810767fa>] ? lock_acquire+0x46/0x60
[  429.211423]  [<ffffffffa01ba17d>] ? fat_cache_add.part.1+0x135/0x140 [fat]
[  429.212102]  [<ffffffff8110553b>] __slab_alloc.isra.18.constprop.22+0x45/0x6d
[  429.212781]  [<ffffffff8110553b>] ? __slab_alloc.isra.18.constprop.22+0x45/0x6d
[  429.213446]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.214110]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.214771]  [<ffffffff811055d9>] kmem_cache_alloc+0x76/0xc7
[  429.215426]  [<ffffffff810c7582>] mempool_alloc_slab+0x10/0x12
[  429.216078]  [<ffffffff810c7636>] mempool_alloc+0x7e/0x147
[  429.216724]  [<ffffffffa01ba53f>] ? fat_get_mapped_cluster+0x5a/0xeb [fat]
[  429.217369]  [<ffffffff811ca221>] bio_alloc_bioset+0xbd/0x1b1
[  429.218013]  [<ffffffff81148078>] mpage_alloc+0x28/0x7b
[  429.218650]  [<ffffffff8114856a>] do_mpage_readpage+0x43d/0x545
[  429.219282]  [<ffffffff81148767>] mpage_readpages+0xf5/0x152
[  429.219914]  [<ffffffffa01c0d1a>] ? fat_add_cluster+0x48/0x48 [fat]
[  429.220544]  [<ffffffffa01c0d1a>] ? fat_add_cluster+0x48/0x48 [fat]
[  429.221170]  [<ffffffff811ea19f>] ? __radix_tree_lookup+0x70/0xa3
[  429.221825]  [<ffffffffa01befc6>] fat_readpages+0x18/0x1a [fat]
[  429.222456]  [<ffffffff810d0477>] __do_page_cache_readahead+0x215/0x2d6
[  429.223087]  [<ffffffff810d0883>] ondemand_readahead+0x34b/0x360
[  429.223718]  [<ffffffff810d0883>] ? ondemand_readahead+0x34b/0x360
[  429.224349]  [<ffffffff810d0a3a>] page_cache_async_readahead+0xae/0xb9
[  429.224979]  [<ffffffff810c546d>] generic_file_read_iter+0x1d1/0x6cf
[  429.225614]  [<ffffffff81071351>] ? update_fast_ctr+0x49/0x63
[  429.226236]  [<ffffffff8111b183>] ? pipe_write+0x3c7/0x3d9
[  429.226852]  [<ffffffff81114418>] __vfs_read+0xc4/0xe8
[  429.227464]  [<ffffffff811144da>] vfs_read+0x9e/0x109
[  429.228093]  [<ffffffff81114892>] SyS_read+0x4c/0x89
[  429.228699]  [<ffffffff814a4ba5>] entry_SYSCALL_64_fastpath+0x18/0xa8
[  429.229308] Code: 5a 5b 41 5c 5d c3 55 48 89 e5 41 57 41 56 41 55 41 54 41 89 f4 81 e6 06 00 00 fc 53 51 74 0e 48 c7 c7 66 9a 75 81 e8 39 fe fb ff <0f> 0b 44 23 25 56 39 78 00 49 89 ff 4c 8b 6f 28 41 81 e4 e0 3e 
[  429.230077] RIP  [<ffffffff811036a5>] new_slab+0x25/0x2be
[  429.230739]  RSP <ffff88009434f820>
[  429.231392] ---[ end trace ddce043dc10fc3d2 ]---
[  429.232059] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
[  429.232719] in_atomic(): 0, irqs_disabled(): 1, pid: 562, name: gzip
[  429.233376] INFO: lockdep is turned off.
[  429.234034] irq event stamp: 1994762
[  429.234697] hardirqs last  enabled at (1994761): [<ffffffff8113f360>] __find_get_block+0xd9/0x117
[  429.235360] hardirqs last disabled at (1994762): [<ffffffff81105516>] __slab_alloc.isra.18.constprop.22+0x20/0x6d
[  429.236026] softirqs last  enabled at (1994554): [<ffffffff81040285>] __do_softirq+0x1bc/0x217
[  429.236694] softirqs last disabled at (1994535): [<ffffffff810404ba>] irq_exit+0x3b/0x8f
[  429.237360] CPU: 0 PID: 562 Comm: gzip Tainted: G      D         4.7.0-rc2-mm1-dbg-00231-g201dcbd-dirty #141
[  429.238708]  0000000000000000 ffff88009434f520 ffffffff811e632c 0000000000000000
[  429.239397]  ffff8800bf8e3a80 ffff88009434f548 ffffffff810598c8 ffffffff8174b8c3
[  429.240077]  0000000000000b90 0000000000000000 ffff88009434f570 ffffffff8105993f
[  429.240757] Call Trace:
[  429.241433]  [<ffffffff811e632c>] dump_stack+0x68/0x92
[  429.242113]  [<ffffffff810598c8>] ___might_sleep+0x1fb/0x202
[  429.242816]  [<ffffffff8105993f>] __might_sleep+0x70/0x77
[  429.243493]  [<ffffffff810487a0>] exit_signals+0x1e/0x119
[  429.244168]  [<ffffffff8103eec3>] do_exit+0x111/0x8f8
[  429.244844]  [<ffffffff8107da75>] ? kmsg_dump+0x149/0x154
[  429.245525]  [<ffffffff81014a03>] oops_end+0x9d/0xa4
[  429.246200]  [<ffffffff81014b27>] die+0x55/0x5e
[  429.246868]  [<ffffffff81012450>] do_trap+0x67/0x11d
[  429.247538]  [<ffffffff8101272d>] do_error_trap+0x100/0x10f
[  429.248212]  [<ffffffff811036a5>] ? new_slab+0x25/0x2be
[  429.248878]  [<ffffffff8107c870>] ? wake_up_klogd+0x4e/0x61
[  429.249544]  [<ffffffff8107ccda>] ? console_unlock+0x457/0x4a2
[  429.250202]  [<ffffffff81001036>] ? trace_hardirqs_off_thunk+0x1a/0x1c
[  429.250856]  [<ffffffff81012889>] do_invalid_op+0x1b/0x1d
[  429.251508]  [<ffffffff814a5e25>] invalid_op+0x15/0x20
[  429.252158]  [<ffffffff811036a5>] ? new_slab+0x25/0x2be
[  429.252803]  [<ffffffff81105467>] ___slab_alloc.constprop.23+0x2f8/0x387
[  429.253451]  [<ffffffff8105993f>] ? __might_sleep+0x70/0x77
[  429.254102]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.254740]  [<ffffffff810767fa>] ? lock_acquire+0x46/0x60
[  429.255376]  [<ffffffffa01ba17d>] ? fat_cache_add.part.1+0x135/0x140 [fat]
[  429.256012]  [<ffffffff8110553b>] __slab_alloc.isra.18.constprop.22+0x45/0x6d
[  429.256657]  [<ffffffff8110553b>] ? __slab_alloc.isra.18.constprop.22+0x45/0x6d
[  429.257292]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.257959]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.258592]  [<ffffffff811055d9>] kmem_cache_alloc+0x76/0xc7
[  429.259226]  [<ffffffff810c7582>] mempool_alloc_slab+0x10/0x12
[  429.259849]  [<ffffffff810c7636>] mempool_alloc+0x7e/0x147
[  429.260432]  [<ffffffffa01ba53f>] ? fat_get_mapped_cluster+0x5a/0xeb [fat]
[  429.261024]  [<ffffffff811ca221>] bio_alloc_bioset+0xbd/0x1b1
[  429.261614]  [<ffffffff81148078>] mpage_alloc+0x28/0x7b
[  429.262185]  [<ffffffff8114856a>] do_mpage_readpage+0x43d/0x545
[  429.262753]  [<ffffffff81148767>] mpage_readpages+0xf5/0x152
[  429.263320]  [<ffffffffa01c0d1a>] ? fat_add_cluster+0x48/0x48 [fat]
[  429.263887]  [<ffffffffa01c0d1a>] ? fat_add_cluster+0x48/0x48 [fat]
[  429.264447]  [<ffffffff811ea19f>] ? __radix_tree_lookup+0x70/0xa3
[  429.265017]  [<ffffffffa01befc6>] fat_readpages+0x18/0x1a [fat]
[  429.265575]  [<ffffffff810d0477>] __do_page_cache_readahead+0x215/0x2d6
[  429.266135]  [<ffffffff810d0883>] ondemand_readahead+0x34b/0x360
[  429.266691]  [<ffffffff810d0883>] ? ondemand_readahead+0x34b/0x360
[  429.267240]  [<ffffffff810d0a3a>] page_cache_async_readahead+0xae/0xb9
[  429.267798]  [<ffffffff810c546d>] generic_file_read_iter+0x1d1/0x6cf
[  429.268345]  [<ffffffff81071351>] ? update_fast_ctr+0x49/0x63
[  429.268896]  [<ffffffff8111b183>] ? pipe_write+0x3c7/0x3d9
[  429.269438]  [<ffffffff81114418>] __vfs_read+0xc4/0xe8
[  429.269976]  [<ffffffff811144da>] vfs_read+0x9e/0x109
[  429.270518]  [<ffffffff81114892>] SyS_read+0x4c/0x89
[  429.271057]  [<ffffffff814a4ba5>] entry_SYSCALL_64_fastpath+0x18/0xa8

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
