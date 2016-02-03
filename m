Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F3166828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:38:25 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id cy9so15329684pac.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:38:25 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id y9si9933326pas.124.2016.02.03.07.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 07:38:25 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id yy13so15182176pab.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:38:24 -0800 (PST)
Date: Thu, 4 Feb 2016 00:36:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [mm -next] mapping->tree_lock inconsistent lock state
Message-ID: <20160203153633.GA32219@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

next-20160203

[ 3587.997451] =================================
[ 3587.997453] [ INFO: inconsistent lock state ]
[ 3587.997456] 4.5.0-rc2-next-20160203-dbg-00007-g37a0a9d-dirty #377 Not tainted
[ 3587.997457] ---------------------------------
[ 3587.997459] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[ 3587.997462] cc1plus/22766 [HC0[0]:SC0[0]:HE1:SE1] takes:
[ 3587.997464]  (&(&mapping->tree_lock)->rlock){+.?...}, at: [<ffffffff8113aaee>] migrate_page_move_mapping+0xbd/0x33f
[ 3587.997474] {IN-SOFTIRQ-W} state was registered at:
[ 3587.997476]   [<ffffffff81082515>] __lock_acquire+0x973/0x18fc
[ 3587.997481]   [<ffffffff81083c77>] lock_acquire+0x10d/0x1a8
[ 3587.997484]   [<ffffffff813c3486>] _raw_spin_lock_irqsave+0x3d/0x51
[ 3587.997489]   [<ffffffff81100552>] test_clear_page_writeback+0x75/0x1b4
[ 3587.997493]   [<ffffffff810f53cb>] end_page_writeback+0x29/0x4a
[ 3587.997497]   [<ffffffff8117ffd5>] end_buffer_async_write+0xfb/0x176
[ 3587.997501]   [<ffffffff8117fb53>] end_bio_bh_io_sync+0x2c/0x37
[ 3587.997503]   [<ffffffff811d0a43>] bio_endio+0x53/0x5b
[ 3587.997508]   [<ffffffff811d8548>] blk_update_request+0x1fb/0x34d
[ 3587.997512]   [<ffffffffa00ed512>] scsi_end_request+0x31/0x182 [scsi_mod]
[ 3587.997522]   [<ffffffffa00eec2d>] scsi_io_completion+0x186/0x46e [scsi_mod]
[ 3587.997530]   [<ffffffffa00e7aa2>] scsi_finish_command+0xd4/0xdd [scsi_mod]
[ 3587.997537]   [<ffffffffa00ee51c>] scsi_softirq_done+0xe0/0xe7 [scsi_mod]
[ 3587.997544]   [<ffffffff811df3ef>] blk_done_softirq+0x84/0x8b
[ 3587.997548]   [<ffffffff8104625c>] __do_softirq+0x196/0x3f5
[ 3587.997552]   [<ffffffff810466aa>] irq_exit+0x40/0x94
[ 3587.997554]   [<ffffffff813c6041>] do_IRQ+0x101/0x119
[ 3587.997558]   [<ffffffff813c4689>] ret_from_intr+0x0/0x19
[ 3587.997561]   [<ffffffff812d9906>] cpuidle_enter+0x17/0x19
[ 3587.997565]   [<ffffffff8107c32a>] call_cpuidle+0x3e/0x40
[ 3587.997569]   [<ffffffff8107c65b>] cpu_startup_entry+0x242/0x35e
[ 3587.997572]   [<ffffffff813bd4fa>] rest_init+0x131/0x137
[ 3587.997575]   [<ffffffff816d4ec1>] start_kernel+0x3dd/0x3ea
[ 3587.997579]   [<ffffffff816d42f1>] x86_64_start_reservations+0x2a/0x2c
[ 3587.997582]   [<ffffffff816d445d>] x86_64_start_kernel+0x16a/0x178
[ 3587.997586] irq event stamp: 191930
[ 3587.997587] hardirqs last  enabled at (191929): [<ffffffff810fb0da>] free_hot_cold_page+0x166/0x179
[ 3587.997591] hardirqs last disabled at (191930): [<ffffffff813c34ad>] _raw_spin_lock_irq+0x13/0x47
[ 3587.997594] softirqs last  enabled at (191758): [<ffffffff810463a5>] __do_softirq+0x2df/0x3f5
[ 3587.997597] softirqs last disabled at (191741): [<ffffffff810466aa>] irq_exit+0x40/0x94
[ 3587.997600] 
               other info that might help us debug this:
[ 3587.997602]  Possible unsafe locking scenario:

[ 3587.997604]        CPU0
[ 3587.997605]        ----
[ 3587.997607]   lock(&(&mapping->tree_lock)->rlock);
[ 3587.997610]   <Interrupt>
[ 3587.997611]     lock(&(&mapping->tree_lock)->rlock);
[ 3587.997614] 
                *** DEADLOCK ***

[ 3587.997617] 2 locks held by cc1plus/22766:
[ 3587.997618]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81036ee0>] __do_page_fault+0x140/0x35a
[ 3587.997626]  #1:  (&(&mapping->tree_lock)->rlock){+.?...}, at: [<ffffffff8113aaee>] migrate_page_move_mapping+0xbd/0x33f
[ 3587.997633] 
               stack backtrace:
[ 3587.997636] CPU: 7 PID: 22766 Comm: cc1plus Not tainted 4.5.0-rc2-next-20160203-dbg-00007-g37a0a9d-dirty #377
[ 3587.997638]  0000000000000000 ffff88010f73f818 ffffffff811f1b02 ffffffff81f35160
[ 3587.997643]  ffff88013813e900 ffff88010f73f850 ffffffff810f3000 0000000000000006
[ 3587.997647]  ffff88013813f058 ffff88013813e900 ffffffff8107f99d 0000000000000006
[ 3587.997651] Call Trace:
[ 3587.997656]  [<ffffffff811f1b02>] dump_stack+0x67/0x90
[ 3587.997660]  [<ffffffff810f3000>] print_usage_bug.part.24+0x259/0x268
[ 3587.997663]  [<ffffffff8107f99d>] ? check_usage_forwards+0x11c/0x11c
[ 3587.997666]  [<ffffffff81080579>] mark_lock+0x381/0x567
[ 3587.997670]  [<ffffffff810807bd>] mark_held_locks+0x5e/0x74
[ 3587.997673]  [<ffffffff813c363f>] ? _raw_spin_unlock_irq+0x2c/0x4a
[ 3587.997676]  [<ffffffff8108093f>] trace_hardirqs_on_caller+0x16c/0x188
[ 3587.997679]  [<ffffffff81080968>] trace_hardirqs_on+0xd/0xf
[ 3587.997682]  [<ffffffff813c363f>] _raw_spin_unlock_irq+0x2c/0x4a
[ 3587.997686]  [<ffffffff81148bef>] unlock_page_lru+0x11f/0x12a
[ 3587.997689]  [<ffffffff8114a90f>] mem_cgroup_migrate+0x196/0x1d9
[ 3587.997692]  [<ffffffff8113abf3>] migrate_page_move_mapping+0x1c2/0x33f
[ 3587.997696]  [<ffffffff8113b669>] buffer_migrate_page+0x47/0x102
[ 3587.997699]  [<ffffffff8113b4e4>] move_to_new_page+0x56/0x194
[ 3587.997702]  [<ffffffff8113bb6b>] migrate_pages+0x447/0x978
[ 3587.997705]  [<ffffffff811171f0>] ? isolate_freepages_block+0x353/0x353
[ 3587.997708]  [<ffffffff81115cd6>] ? pageblock_pfn_to_page+0xbf/0xbf
[ 3587.997711]  [<ffffffff81118834>] compact_zone+0x690/0x92e
[ 3587.997714]  [<ffffffff81118b40>] compact_zone_order+0x6e/0x8a
[ 3587.997717]  [<ffffffff81118dc3>] try_to_compact_pages+0x151/0x28f
[ 3587.997720]  [<ffffffff81118dc3>] ? try_to_compact_pages+0x151/0x28f
[ 3587.997723]  [<ffffffff8108111a>] ? __lock_is_held+0x3c/0x57
[ 3587.997726]  [<ffffffff810fc471>] __alloc_pages_direct_compact+0x3e/0xeb
[ 3587.997729]  [<ffffffff810fc965>] __alloc_pages_nodemask+0x447/0xb8b
[ 3587.997732]  [<ffffffff81120a18>] ? handle_mm_fault+0x8b4/0x16bf
[ 3587.997737]  [<ffffffff8106409f>] ? __might_sleep+0x75/0x7c
[ 3587.997740]  [<ffffffff81140704>] do_huge_pmd_anonymous_page+0x1d1/0x3fc
[ 3587.997744]  [<ffffffff811202ae>] ? handle_mm_fault+0x14a/0x16bf
[ 3587.997747]  [<ffffffff81120623>] handle_mm_fault+0x4bf/0x16bf
[ 3587.997750]  [<ffffffff8108111a>] ? __lock_is_held+0x3c/0x57
[ 3587.997754]  [<ffffffff81036f7f>] __do_page_fault+0x1df/0x35a
[ 3587.997757]  [<ffffffff8103712c>] do_page_fault+0xc/0xe
[ 3587.997760]  [<ffffffff813c5892>] page_fault+0x22/0x30

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
