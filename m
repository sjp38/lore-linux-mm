Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F1B646B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:23:53 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king@ubuntu.com>
In-Reply-To: <1303999415-sup-362@think>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <1303993705-sup-5213@think> <1303998140.2081.11.camel@lenovo>
	 <1303998300-sup-4941@think> <1303999282.2081.15.camel@lenovo>
	 <1303999415-sup-362@think>
Content-Type: multipart/mixed; boundary="=-aKxdBFoWi5ekVzCFqvOA"
Date: Thu, 28 Apr 2011 16:23:30 +0100
Message-ID: <1304004211.2081.23.camel@lenovo>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: James Bottomley <james.bottomley@suse.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>


--=-aKxdBFoWi5ekVzCFqvOA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Thu, 2011-04-28 at 10:04 -0400, Chris Mason wrote:
> Excerpts from Colin Ian King's message of 2011-04-28 10:01:22 -0400:
> > 
> > > Could you post the soft lockups you're seeing?
> > 
> > As requested, attached
> 
> These are not good, but they aren't the lockup James was seeing.  Were
> these messages with my patch?  If yes, please post the messages from
> without my patch.

Attached are the messages without your patch.

Colin
> 
> -chris


--=-aKxdBFoWi5ekVzCFqvOA
Content-Disposition: attachment; filename="kern.log"
Content-Type: text/x-log; name="kern.log"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Apr 28 15:47:41 ubuntu kernel: [  493.876427] INFO: task jbd2/sda1-8:290 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  493.876447] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  493.876455] jbd2/sda1-8     D 0000000000000000     0   290      2 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  493.876468]  ffff8800363e5c20 0000000000000046 ffff8800363e5fd8 ffff8800363e4000
Apr 28 15:49:04 ubuntu kernel: [  493.876481]  0000000000013d00 ffff8800720b3178 ffff8800363e5fd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  493.876507]  ffffffff81a0b020 ffff8800720b2dc0 ffff88001fffb1d0 ffff88001fc13d00
Apr 28 15:49:04 ubuntu kernel: [  493.876522] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  493.876542]  [<ffffffff81191db0>] ? sync_buffer+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.876557]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  493.876570]  [<ffffffff81191df0>] sync_buffer+0x40/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.876583]  [<ffffffff815c12ff>] __wait_on_bit+0x5f/0x90
Apr 28 15:49:04 ubuntu kernel: [  493.876596]  [<ffffffff81191db0>] ? sync_buffer+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.876609]  [<ffffffff815c13ac>] out_of_line_wait_on_bit+0x7c/0x90
Apr 28 15:49:04 ubuntu kernel: [  493.876623]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.876636]  [<ffffffff81191dae>] __wait_on_buffer+0x2e/0x30
Apr 28 15:49:04 ubuntu kernel: [  493.876649]  [<ffffffff81243c3e>] jbd2_journal_commit_transaction+0x10ae/0x1190
Apr 28 15:49:04 ubuntu kernel: [  493.876663]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.876677]  [<ffffffff81247e8b>] kjournald2+0xbb/0x220
Apr 28 15:49:04 ubuntu kernel: [  493.876688]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.876700]  [<ffffffff81247dd0>] ? kjournald2+0x0/0x220
Apr 28 15:49:04 ubuntu kernel: [  493.876711]  [<ffffffff810877e6>] kthread+0x96/0xa0
Apr 28 15:49:04 ubuntu kernel: [  493.876725]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
Apr 28 15:49:04 ubuntu kernel: [  493.876737]  [<ffffffff81087750>] ? kthread+0x0/0xa0
Apr 28 15:49:04 ubuntu kernel: [  493.876747]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
Apr 28 15:49:04 ubuntu kernel: [  493.876777] INFO: task flush-8:0:1137 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  493.876783] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  493.876792] flush-8:0       D 0000000000000002     0  1137      2 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  493.876806]  ffff88007495f420 0000000000000046 ffff88007495ffd8 ffff88007495e000
Apr 28 15:49:04 ubuntu kernel: [  493.876820]  0000000000013d00 ffff88007552b178 ffff88007495ffd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  493.876836]  ffff8801005e5b80 ffff88007552adc0 ffff88005dd9a840 ffff88001fc53d00
Apr 28 15:49:04 ubuntu kernel: [  493.876850] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  493.876863]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  493.876878]  [<ffffffff812c3499>] get_request_wait+0xc9/0x1a0
Apr 28 15:49:04 ubuntu kernel: [  493.876890]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.876902]  [<ffffffff812bc680>] ? elv_merge+0x50/0x120
Apr 28 15:49:04 ubuntu kernel: [  493.876915]  [<ffffffff812c3c56>] __make_request+0x76/0x4c0
Apr 28 15:49:04 ubuntu kernel: [  493.876929]  [<ffffffff812c1148>] generic_make_request+0x2d8/0x5c0
Apr 28 15:49:04 ubuntu kernel: [  493.876946]  [<ffffffff8110e725>] ? mempool_alloc_slab+0x15/0x20
Apr 28 15:49:04 ubuntu kernel: [  493.876957]  [<ffffffff8110ea69>] ? mempool_alloc+0x59/0x140
Apr 28 15:49:04 ubuntu kernel: [  493.876970]  [<ffffffff812c14b9>] submit_bio+0x89/0x120
Apr 28 15:49:04 ubuntu kernel: [  493.876982]  [<ffffffff811976fb>] ? bio_alloc_bioset+0x5b/0xf0
Apr 28 15:49:04 ubuntu kernel: [  493.876995]  [<ffffffff811918eb>] submit_bh+0xeb/0x120
Apr 28 15:49:04 ubuntu kernel: [  493.877007]  [<ffffffff81193630>] __block_write_full_page+0x210/0x3a0
Apr 28 15:49:04 ubuntu kernel: [  493.877018]  [<ffffffff81192720>] ? end_buffer_async_write+0x0/0x170
Apr 28 15:49:04 ubuntu kernel: [  493.877032]  [<ffffffff81206aa0>] ? noalloc_get_block_write+0x0/0x30
Apr 28 15:49:04 ubuntu kernel: [  493.877044]  [<ffffffff81206aa0>] ? noalloc_get_block_write+0x0/0x30
Apr 28 15:49:04 ubuntu kernel: [  493.877056]  [<ffffffff811944d3>] block_write_full_page_endio+0xe3/0x120
Apr 28 15:49:04 ubuntu kernel: [  493.877067]  [<ffffffff81194525>] block_write_full_page+0x15/0x20
Apr 28 15:49:04 ubuntu kernel: [  493.877079]  [<ffffffff81204e9a>] mpage_da_submit_io+0x43a/0x4c0
Apr 28 15:49:04 ubuntu kernel: [  493.877094]  [<ffffffff8122929b>] ? __ext4_handle_dirty_metadata+0x7b/0x120
Apr 28 15:49:04 ubuntu kernel: [  493.877110]  [<ffffffff81208c8e>] mpage_da_map_and_submit+0x1ae/0x440
Apr 28 15:49:04 ubuntu kernel: [  493.877122]  [<ffffffff812dfe2d>] ? radix_tree_gang_lookup_tag_slot+0x8d/0xd0
Apr 28 15:49:04 ubuntu kernel: [  493.877136]  [<ffffffff81208f8d>] mpage_add_bh_to_extent+0x6d/0xf0
Apr 28 15:49:04 ubuntu kernel: [  493.877149]  [<ffffffff81209102>] __mpage_da_writepage+0xf2/0x190
Apr 28 15:49:04 ubuntu kernel: [  493.877162]  [<ffffffff8120935b>] write_cache_pages_da+0x1bb/0x2d0
Apr 28 15:49:04 ubuntu kernel: [  493.877176]  [<ffffffff81209786>] ext4_da_writepages+0x316/0x630
Apr 28 15:49:04 ubuntu kernel: [  493.877191]  [<ffffffff81117151>] do_writepages+0x21/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.877202]  [<ffffffff8118b5df>] writeback_single_inode+0x9f/0x240
Apr 28 15:49:04 ubuntu kernel: [  493.877215]  [<ffffffff8118b9cb>] writeback_sb_inodes+0xcb/0x160
Apr 28 15:49:04 ubuntu kernel: [  493.877229]  [<ffffffff8118bc1b>] writeback_inodes_wb+0x10b/0x1c0
Apr 28 15:49:04 ubuntu kernel: [  493.877240]  [<ffffffff8118c04e>] wb_writeback+0x37e/0x490
Apr 28 15:49:04 ubuntu kernel: [  493.877254]  [<ffffffff815c2e6f>] ? _raw_spin_lock_irqsave+0x2f/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.877269]  [<ffffffff81074fdb>] ? lock_timer_base.clone.20+0x3b/0x70
Apr 28 15:49:04 ubuntu kernel: [  493.877283]  [<ffffffff811166aa>] ? determine_dirtyable_memory+0x1a/0x30
Apr 28 15:49:04 ubuntu kernel: [  493.877296]  [<ffffffff8118c2ef>] wb_do_writeback+0x18f/0x230
Apr 28 15:49:04 ubuntu kernel: [  493.877309]  [<ffffffff8118c412>] bdi_writeback_thread+0x82/0x260
Apr 28 15:49:04 ubuntu kernel: [  493.877321]  [<ffffffff8118c390>] ? bdi_writeback_thread+0x0/0x260
Apr 28 15:49:04 ubuntu kernel: [  493.877333]  [<ffffffff810877e6>] kthread+0x96/0xa0
Apr 28 15:49:04 ubuntu kernel: [  493.877345]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
Apr 28 15:49:04 ubuntu kernel: [  493.877357]  [<ffffffff81087750>] ? kthread+0x0/0xa0
Apr 28 15:49:04 ubuntu kernel: [  493.877368]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
Apr 28 15:49:04 ubuntu kernel: [  493.877386] INFO: task unity-panel-ser:1548 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  493.877393] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  493.877400] unity-panel-ser D 0000000000000002     0  1548      1 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  493.877414]  ffff88006837fb68 0000000000000086 ffff88006837ffd8 ffff88006837e000
Apr 28 15:49:04 ubuntu kernel: [  493.877429]  0000000000013d00 ffff8800723ac858 ffff88006837ffd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  493.877444]  ffff8801005e5b80 ffff8800723ac4a0 ffff88001fff41c8 ffff88001fc53d00
Apr 28 15:49:04 ubuntu kernel: [  493.877459] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  493.877473]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.877484]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  493.877497]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.877509]  [<ffffffff815c12ff>] __wait_on_bit+0x5f/0x90
Apr 28 15:49:04 ubuntu kernel: [  493.877522]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
Apr 28 15:49:04 ubuntu kernel: [  493.877534]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  493.877548]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
Apr 28 15:49:04 ubuntu kernel: [  493.877561]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
Apr 28 15:49:04 ubuntu kernel: [  493.877573]  [<ffffffff8112d134>] __do_fault+0x54/0x520
Apr 28 15:49:04 ubuntu kernel: [  493.877585]  [<ffffffff811309ca>] handle_pte_fault+0xfa/0x210
Apr 28 15:49:04 ubuntu kernel: [  493.877597]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.877608]  [<ffffffff8112de3f>] ? __pte_alloc+0xdf/0x100
Apr 28 15:49:04 ubuntu kernel: [  493.877619]  [<ffffffff81131d4d>] handle_mm_fault+0x16d/0x250
Apr 28 15:49:04 ubuntu kernel: [  493.877632]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
Apr 28 15:49:04 ubuntu kernel: [  493.877644]  [<ffffffff81136f75>] ? do_mmap_pgoff+0x335/0x370
Apr 28 15:49:04 ubuntu kernel: [  493.877656]  [<ffffffff815c34d5>] page_fault+0x25/0x30
Apr 28 15:49:04 ubuntu kernel: [  493.877672] INFO: task jbd2/sda4-8:2990 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  493.877678] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  493.877686] jbd2/sda4-8     D 0000000000000000     0  2990      2 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  493.877699]  ffff880074f4fd20 0000000000000046 ffff880074f4ffd8 ffff880074f4e000
Apr 28 15:49:04 ubuntu kernel: [  493.877714]  0000000000013d00 ffff88005c2103b8 ffff880074f4ffd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  493.877729]  ffffffff81a0b020 ffff88005c210000 0000000000000002 ffff8800755ae5a0
Apr 28 15:49:04 ubuntu kernel: [  493.877744] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  493.877756]  [<ffffffff81242d40>] jbd2_journal_commit_transaction+0x1b0/0x1190
Apr 28 15:49:04 ubuntu kernel: [  493.877772]  [<ffffffff8100a6e0>] ? __switch_to+0xc0/0x2f0
Apr 28 15:49:04 ubuntu kernel: [  493.877786]  [<ffffffff815c2cbe>] ? _raw_spin_lock+0xe/0x20
Apr 28 15:49:04 ubuntu kernel: [  493.877799]  [<ffffffff81074fdb>] ? lock_timer_base.clone.20+0x3b/0x70
Apr 28 15:49:04 ubuntu kernel: [  493.877812]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.877824]  [<ffffffff81247e8b>] kjournald2+0xbb/0x220
Apr 28 15:49:04 ubuntu kernel: [  493.877836]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  493.877847]  [<ffffffff81247dd0>] ? kjournald2+0x0/0x220
Apr 28 15:49:04 ubuntu kernel: [  493.877858]  [<ffffffff810877e6>] kthread+0x96/0xa0
Apr 28 15:49:04 ubuntu kernel: [  493.877869]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
Apr 28 15:49:04 ubuntu kernel: [  493.877882]  [<ffffffff81087750>] ? kthread+0x0/0xa0
Apr 28 15:49:04 ubuntu kernel: [  493.877892]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
Apr 28 15:49:04 ubuntu kernel: [  553.778917] INFO: task jbd2/sda1-8:290 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  553.778936] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  553.778944] jbd2/sda1-8     D 0000000000000002     0   290      2 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  553.778956]  ffff8800363e5c20 0000000000000046 ffff8800363e5fd8 ffff8800363e4000
Apr 28 15:49:04 ubuntu kernel: [  553.778969]  0000000000013d00 ffff8800720b3178 ffff8800363e5fd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  553.778981]  ffff8801005e2dc0 ffff8800720b2dc0 ffff88001ffec230 ffff88001fc53d00
Apr 28 15:49:04 ubuntu kernel: [  553.779007] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  553.779027]  [<ffffffff81191db0>] ? sync_buffer+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779043]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  553.779055]  [<ffffffff81191df0>] sync_buffer+0x40/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779067]  [<ffffffff815c12ff>] __wait_on_bit+0x5f/0x90
Apr 28 15:49:04 ubuntu kernel: [  553.779080]  [<ffffffff81191db0>] ? sync_buffer+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779093]  [<ffffffff815c13ac>] out_of_line_wait_on_bit+0x7c/0x90
Apr 28 15:49:04 ubuntu kernel: [  553.779107]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779121]  [<ffffffff81191dae>] __wait_on_buffer+0x2e/0x30
Apr 28 15:49:04 ubuntu kernel: [  553.779134]  [<ffffffff812432ef>] jbd2_journal_commit_transaction+0x75f/0x1190
Apr 28 15:49:04 ubuntu kernel: [  553.779148]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  553.779162]  [<ffffffff81247e8b>] kjournald2+0xbb/0x220
Apr 28 15:49:04 ubuntu kernel: [  553.779174]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  553.779185]  [<ffffffff81247dd0>] ? kjournald2+0x0/0x220
Apr 28 15:49:04 ubuntu kernel: [  553.779196]  [<ffffffff810877e6>] kthread+0x96/0xa0
Apr 28 15:49:04 ubuntu kernel: [  553.779210]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
Apr 28 15:49:04 ubuntu kernel: [  553.779222]  [<ffffffff81087750>] ? kthread+0x0/0xa0
Apr 28 15:49:04 ubuntu kernel: [  553.779233]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
Apr 28 15:49:04 ubuntu kernel: [  553.779245] INFO: task rs:main Q:Reg:775 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  553.779252] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  553.779260] rs:main Q:Reg   D 0000000000000000     0   775      1 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  553.779274]  ffff880036317b98 0000000000000086 ffff880036317fd8 ffff880036316000
Apr 28 15:49:04 ubuntu kernel: [  553.779289]  0000000000013d00 ffff8800759983b8 ffff880036317fd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  553.779304]  ffff88003632adc0 ffff880075998000 ffff88001ffe6f68 ffff88001fc13d00
Apr 28 15:49:04 ubuntu kernel: [  553.779318] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  553.779333]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779345]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  553.779357]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779369]  [<ffffffff815c12ff>] __wait_on_bit+0x5f/0x90
Apr 28 15:49:04 ubuntu kernel: [  553.779381]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
Apr 28 15:49:04 ubuntu kernel: [  553.779393]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779405]  [<ffffffff812df74e>] ? radix_tree_lookup_slot+0xe/0x10
Apr 28 15:49:04 ubuntu kernel: [  553.779418]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
Apr 28 15:49:04 ubuntu kernel: [  553.779431]  [<ffffffff8112f090>] do_swap_page.clone.50+0x5e0/0x640
Apr 28 15:49:04 ubuntu kernel: [  553.779446]  [<ffffffff8108bb90>] ? lock_hrtimer_base.clone.25+0x30/0x60
Apr 28 15:49:04 ubuntu kernel: [  553.779459]  [<ffffffff8108bc5c>] ? hrtimer_try_to_cancel+0x4c/0xe0
Apr 28 15:49:04 ubuntu kernel: [  553.779472]  [<ffffffff81130a89>] handle_pte_fault+0x1b9/0x210
Apr 28 15:49:04 ubuntu kernel: [  553.779484]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
Apr 28 15:49:04 ubuntu kernel: [  553.779494]  [<ffffffff8112de3f>] ? __pte_alloc+0xdf/0x100
Apr 28 15:49:04 ubuntu kernel: [  553.779505]  [<ffffffff81131d4d>] handle_mm_fault+0x16d/0x250
Apr 28 15:49:04 ubuntu kernel: [  553.779518]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
Apr 28 15:49:04 ubuntu kernel: [  553.779531]  [<ffffffff8109ce7b>] ? do_futex+0xbb/0x210
Apr 28 15:49:04 ubuntu kernel: [  553.779543]  [<ffffffff8109d04b>] ? sys_futex+0x7b/0x180
Apr 28 15:49:04 ubuntu kernel: [  553.779555]  [<ffffffff8116f985>] ? putname+0x35/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779567]  [<ffffffff81164200>] ? do_sys_open+0x10/0x150
Apr 28 15:49:04 ubuntu kernel: [  553.779579]  [<ffffffff815c34d5>] page_fault+0x25/0x30
Apr 28 15:49:04 ubuntu kernel: [  553.779589] INFO: task rsyslogd:795 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  553.779595] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  553.779603] rsyslogd        D 0000000000000000     0   795      1 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  553.779616]  ffff880075c0db98 0000000000000086 ffff880075c0dfd8 ffff880075c0c000
Apr 28 15:49:04 ubuntu kernel: [  553.779631]  0000000000013d00 ffff88003623b178 ffff880075c0dfd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  553.779646]  ffff880075998000 ffff88003623adc0 ffff88001ffe6f68 ffff88001fc13d00
Apr 28 15:49:04 ubuntu kernel: [  553.779660] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  553.779672]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779684]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  553.779696]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779709]  [<ffffffff815c12ff>] __wait_on_bit+0x5f/0x90
Apr 28 15:49:04 ubuntu kernel: [  553.779720]  [<ffffffff8114077f>] ? read_swap_cache_async+0x4f/0x160
Apr 28 15:49:04 ubuntu kernel: [  553.779734]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
Apr 28 15:49:04 ubuntu kernel: [  553.779746]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.779759]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
Apr 28 15:49:04 ubuntu kernel: [  553.779770]  [<ffffffff8112f090>] do_swap_page.clone.50+0x5e0/0x640
Apr 28 15:49:04 ubuntu kernel: [  553.779783]  [<ffffffff81130a89>] handle_pte_fault+0x1b9/0x210
Apr 28 15:49:04 ubuntu kernel: [  553.779794]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
Apr 28 15:49:04 ubuntu kernel: [  553.779805]  [<ffffffff8112de3f>] ? __pte_alloc+0xdf/0x100
Apr 28 15:49:04 ubuntu kernel: [  553.779816]  [<ffffffff81131d4d>] handle_mm_fault+0x16d/0x250
Apr 28 15:49:04 ubuntu kernel: [  553.779828]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
Apr 28 15:49:04 ubuntu kernel: [  553.779841]  [<ffffffff81164fd0>] ? vfs_read+0x120/0x180
Apr 28 15:49:04 ubuntu kernel: [  553.779851]  [<ffffffff815c34d5>] page_fault+0x25/0x30
Apr 28 15:49:04 ubuntu kernel: [  553.779894] INFO: task tee:2977 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  553.779900] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  553.779908] tee             D 0000000000000002     0  2977   2875 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  553.779921]  ffff88005c1e39e8 0000000000000082 ffff88005c1e3fd8 ffff88005c1e2000
Apr 28 15:49:04 ubuntu kernel: [  553.779935]  0000000000013d00 ffff8800755283b8 ffff88005c1e3fd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  553.779950]  ffff8801005e5b80 ffff880075528000 ffff88005c1e39d8 ffff88005c1e3a38
Apr 28 15:49:04 ubuntu kernel: [  553.779965] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  553.779980]  [<ffffffff81241db5>] do_get_write_access+0x255/0x490
Apr 28 15:49:04 ubuntu kernel: [  553.779992]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.780006]  [<ffffffff81209e2d>] ? ext4_dirty_inode+0x3d/0x60
Apr 28 15:49:04 ubuntu kernel: [  553.780019]  [<ffffffff81242131>] jbd2_journal_get_write_access+0x31/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.780034]  [<ffffffff81228f9e>] __ext4_journal_get_write_access+0x3e/0x80
Apr 28 15:49:04 ubuntu kernel: [  553.780047]  [<ffffffff81205268>] ext4_reserve_inode_write+0x78/0xa0
Apr 28 15:49:04 ubuntu kernel: [  553.780059]  [<ffffffff812052df>] ext4_mark_inode_dirty+0x4f/0x220
Apr 28 15:49:04 ubuntu kernel: [  553.780072]  [<ffffffff8121dc03>] ? ext4_journal_start_sb+0xb3/0x140
Apr 28 15:49:04 ubuntu kernel: [  553.780084]  [<ffffffff81209e2d>] ext4_dirty_inode+0x3d/0x60
Apr 28 15:49:04 ubuntu kernel: [  553.780096]  [<ffffffff8118b31f>] __mark_inode_dirty+0x3f/0x260
Apr 28 15:49:04 ubuntu kernel: [  553.780109]  [<ffffffff8117f0b5>] file_update_time+0xf5/0x170
Apr 28 15:49:04 ubuntu kernel: [  553.780124]  [<ffffffff8110d928>] __generic_file_aio_write+0x1f8/0x440
Apr 28 15:49:04 ubuntu kernel: [  553.780137]  [<ffffffff8105f652>] ? default_wake_function+0x12/0x20
Apr 28 15:49:04 ubuntu kernel: [  553.780150]  [<ffffffff8110dbd6>] generic_file_aio_write+0x66/0xd0
Apr 28 15:49:04 ubuntu kernel: [  553.780162]  [<ffffffff811fe2a9>] ext4_file_write+0x69/0x280
Apr 28 15:49:04 ubuntu kernel: [  553.780176]  [<ffffffff8138b0c3>] ? pty_write+0x73/0x80
Apr 28 15:49:04 ubuntu kernel: [  553.780188]  [<ffffffff81038c79>] ? default_spin_lock_flags+0x9/0x10
Apr 28 15:49:04 ubuntu kernel: [  553.780201]  [<ffffffff81164682>] do_sync_write+0xd2/0x110
Apr 28 15:49:04 ubuntu kernel: [  553.780217]  [<ffffffff812ae7e8>] ? apparmor_file_permission+0x18/0x20
Apr 28 15:49:04 ubuntu kernel: [  553.780231]  [<ffffffff81279bac>] ? security_file_permission+0x2c/0xb0
Apr 28 15:49:04 ubuntu kernel: [  553.780244]  [<ffffffff81384d70>] ? n_tty_write+0x0/0x280
Apr 28 15:49:04 ubuntu kernel: [  553.780256]  [<ffffffff81164ab1>] ? rw_verify_area+0x61/0xf0
Apr 28 15:49:04 ubuntu kernel: [  553.780268]  [<ffffffff81164df6>] vfs_write+0xc6/0x180
Apr 28 15:49:04 ubuntu kernel: [  553.780278]  [<ffffffff81165111>] sys_write+0x51/0x90
Apr 28 15:49:04 ubuntu kernel: [  553.780290]  [<ffffffff8100c002>] system_call_fastpath+0x16/0x1b
Apr 28 15:49:04 ubuntu kernel: [  553.780299] INFO: task jbd2/sda4-8:2990 blocked for more than 30 seconds.
Apr 28 15:49:04 ubuntu kernel: [  553.780307] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 28 15:49:04 ubuntu kernel: [  553.780314] jbd2/sda4-8     D 0000000000000000     0  2990      2 0x00000000
Apr 28 15:49:04 ubuntu kernel: [  553.780327]  ffff880074f4faf0 0000000000000046 ffff880074f4ffd8 ffff880074f4e000
Apr 28 15:49:04 ubuntu kernel: [  553.780342]  0000000000013d00 ffff88005c2103b8 ffff880074f4ffd8 0000000000013d00
Apr 28 15:49:04 ubuntu kernel: [  553.780357]  ffffffff81a0b020 ffff88005c210000 ffff88001ffee048 ffff88001fc13d00
Apr 28 15:49:04 ubuntu kernel: [  553.780372] Call Trace:
Apr 28 15:49:04 ubuntu kernel: [  553.780384]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.780396]  [<ffffffff815c0980>] io_schedule+0x70/0xc0
Apr 28 15:49:04 ubuntu kernel: [  553.780407]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.780419]  [<ffffffff815c12ff>] __wait_on_bit+0x5f/0x90
Apr 28 15:49:04 ubuntu kernel: [  553.780432]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
Apr 28 15:49:04 ubuntu kernel: [  553.780444]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
Apr 28 15:49:04 ubuntu kernel: [  553.780457]  [<ffffffff8110c41d>] filemap_fdatawait_range+0xfd/0x190
Apr 28 15:49:04 ubuntu kernel: [  553.780472]  [<ffffffff8110c4db>] filemap_fdatawait+0x2b/0x30
Apr 28 15:49:04 ubuntu kernel: [  553.780484]  [<ffffffff81242a83>] journal_finish_inode_data_buffers+0x63/0x170
Apr 28 15:49:04 ubuntu kernel: [  553.780496]  [<ffffffff81243274>] jbd2_journal_commit_transaction+0x6e4/0x1190
Apr 28 15:49:04 ubuntu kernel: [  553.780510]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  553.780522]  [<ffffffff81247e8b>] kjournald2+0xbb/0x220
Apr 28 15:49:04 ubuntu kernel: [  553.780534]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
Apr 28 15:49:04 ubuntu kernel: [  553.780546]  [<ffffffff81247dd0>] ? kjournald2+0x0/0x220
Apr 28 15:49:04 ubuntu kernel: [  553.780556]  [<ffffffff810877e6>] kthread+0x96/0xa0
Apr 28 15:49:04 ubuntu kernel: [  553.780568]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
Apr 28 15:49:04 ubuntu kernel: [  553.780580]  [<ffffffff81087750>] ? kthread+0x0/0xa0
Apr 28 15:49:04 ubuntu kernel: [  553.780591]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10

--=-aKxdBFoWi5ekVzCFqvOA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
