Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D19E18D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 18:03:41 -0400 (EDT)
Date: Wed, 16 Mar 2011 15:02:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-Id: <20110316150208.7407c375.akpm@linux-foundation.org>
In-Reply-To: <4D80D65C.5040504@fiec.espol.edu.ec>
References: <bug-31142-10286@https.bugzilla.kernel.org/>
	<20110315135334.36e29414.akpm@linux-foundation.org>
	<4D7FEDDC.3020607@fiec.espol.edu.ec>
	<20110315161926.595bdb65.akpm@linux-foundation.org>
	<4D80D65C.5040504@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?ISO-8859-1?Q?Villac=ED=ADs?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Wed, 16 Mar 2011 10:25:16 -0500
Alex Villac____s Lasso <avillaci@fiec.espol.edu.ec> wrote:

> El 15/03/11 18:19, Andrew Morton escribi__:
> > On Tue, 15 Mar 2011 17:53:16 -0500
> > Alex Villac____s Lasso<avillaci@fiec.espol.edu.ec>  wrote:
> >
> >> El 15/03/11 15:53, Andrew Morton escribi__:
> >>> rofl, will we ever fix this.
> >> Does this mean there is already a duplicate of this issue? If so, which one?
> > Nothing specific.  Nonsense like this has been happening for at least a
> > decade and it never seems to get a lot better.
> >
> >>> Please enable sysrq and do a sysrq-w when the tasks are blocked so we
> >>> can find where things are getting stuck.  Please avoid email client
> >>> wordwrapping when sending us the sysrq output.
> >>>
> Posted sysrq-w report into original bug report to avoid email word-wrap.

https://bugzilla.kernel.org/attachment.cgi?id=50952

Interesting bits:

[70874.969550] thunderbird-bin D 000000010434e04e     0 32283  32279 0x00000080
[70874.969553]  ffff88011ba91838 0000000000000086 ffff880100000000 0000000000013880
[70874.969557]  0000000000013880 ffff88010a231780 ffff88011ba91fd8 0000000000013880
[70874.969560]  0000000000013880 0000000000013880 0000000000013880 ffff88011ba91fd8
[70874.969564] Call Trace:
[70874.969567]  [<ffffffff810d7ed3>] ? sync_page+0x0/0x4d
[70874.969569]  [<ffffffff810d7ed3>] ? sync_page+0x0/0x4d
[70874.969572]  [<ffffffff8147cedb>] io_schedule+0x47/0x62
[70874.969575]  [<ffffffff810d7f1c>] sync_page+0x49/0x4d
[70874.969577]  [<ffffffff8147d36a>] __wait_on_bit+0x48/0x7b
[70874.969580]  [<ffffffff810d8100>] wait_on_page_bit+0x72/0x79
[70874.969583]  [<ffffffff8106cdb4>] ? wake_bit_function+0x0/0x31
[70874.969586]  [<ffffffff8111833c>] migrate_pages+0x1ac/0x38d
[70874.969589]  [<ffffffff8110d6d7>] ? compaction_alloc+0x0/0x2a4
[70874.969592]  [<ffffffff8110ddfd>] compact_zone+0x3f4/0x60e
[70874.969595]  [<ffffffff8110e1dc>] compact_zone_order+0xc2/0xd1
[70874.969599]  [<ffffffff8110e27f>] try_to_compact_pages+0x94/0xea
[70874.969602]  [<ffffffff810de916>] __alloc_pages_direct_compact+0xa9/0x1a5
[70874.969605]  [<ffffffff810ddbb8>] ? drain_local_pages+0x0/0x17
[70874.969607]  [<ffffffff810df0b0>] __alloc_pages_nodemask+0x69e/0x766
[70874.969610]  [<ffffffff81113701>] ? __slab_free+0x6d/0xf6
[70874.969614]  [<ffffffff8110c0de>] alloc_pages_vma+0xec/0xf1
[70874.969617]  [<ffffffff8111be1c>] do_huge_pmd_anonymous_page+0xbf/0x267
[70874.969620]  [<ffffffff810f2497>] ? pmd_offset+0x19/0x40
[70874.969623]  [<ffffffff810f5c70>] handle_mm_fault+0x15d/0x20f
[70874.969626]  [<ffffffff8100f26a>] ? arch_get_unmapped_area_topdown+0x195/0x28f
[70874.969629]  [<ffffffff8148178c>] do_page_fault+0x33b/0x35d
[70874.969632]  [<ffffffff810fb07d>] ? do_mmap_pgoff+0x29a/0x2f4
[70874.969635]  [<ffffffff8112dcee>] ? path_put+0x22/0x27
[70874.969638]  [<ffffffff8147f145>] page_fault+0x25/0x30


[70874.969731] gedit           D 000000010434dfb0     0 32356      1 0x00000080
[70874.969734]  ffff8800982ab558 0000000000000082 ffff880102400001 0000000000013880
[70874.969737]  0000000000013880 ffff880117408000 ffff8800982abfd8 0000000000013880
[70874.969741]  0000000000013880 0000000000013880 0000000000013880 ffff8800982abfd8
[70874.969744] Call Trace:
[70874.969747]  [<ffffffff8147cedb>] io_schedule+0x47/0x62
[70874.969750]  [<ffffffff8121c403>] get_request_wait+0x10a/0x197
[70874.969753]  [<ffffffff8106cd77>] ? autoremove_wake_function+0x0/0x3d
[70874.969756]  [<ffffffff8121ccc4>] __make_request+0x2c8/0x3e0
[70874.969759]  [<ffffffff8111487d>] ? kmem_cache_alloc+0x73/0xeb
[70874.969762]  [<ffffffff8121bb67>] generic_make_request+0x2bc/0x336
[70874.969765]  [<ffffffff811213a5>] ? lookup_page_cgroup+0x36/0x4c
[70874.969768]  [<ffffffff8121bcc1>] submit_bio+0xe0/0xff
[70874.969770]  [<ffffffff8114d72d>] ? bio_alloc_bioset+0x4d/0xc4
[70874.969773]  [<ffffffff810edf1f>] ? inc_zone_page_state+0x2d/0x2f
[70874.969776]  [<ffffffff81149274>] submit_bh+0xe8/0x10e
[70874.969779]  [<ffffffff8114b9fa>] __block_write_full_page+0x1ea/0x2da
[70874.969782]  [<ffffffffa0689202>] ? udf_get_block+0x0/0x115 [udf]
[70874.969785]  [<ffffffff8114a640>] ? end_buffer_async_write+0x0/0x12d
[70874.969788]  [<ffffffff8114a640>] ? end_buffer_async_write+0x0/0x12d
[70874.969791]  [<ffffffffa0689202>] ? udf_get_block+0x0/0x115 [udf]
[70874.969794]  [<ffffffff8114bb76>] block_write_full_page_endio+0x8c/0x98
[70874.969796]  [<ffffffff8114bb97>] block_write_full_page+0x15/0x17
[70874.969800]  [<ffffffffa0686027>] udf_writepage+0x18/0x1a [udf]
[70874.969803]  [<ffffffff81117fed>] move_to_new_page+0x106/0x195
[70874.969806]  [<ffffffff811183de>] migrate_pages+0x24e/0x38d
[70874.969809]  [<ffffffff8110d6d7>] ? compaction_alloc+0x0/0x2a4
[70874.969812]  [<ffffffff8110ddfd>] compact_zone+0x3f4/0x60e
[70874.969815]  [<ffffffff81049c78>] ? load_balance+0xcb/0x6b0
[70874.969818]  [<ffffffff8110e1dc>] compact_zone_order+0xc2/0xd1
[70874.969821]  [<ffffffff8110e27f>] try_to_compact_pages+0x94/0xea
[70874.969824]  [<ffffffff810de916>] __alloc_pages_direct_compact+0xa9/0x1a5
[70874.969827]  [<ffffffff810dee79>] __alloc_pages_nodemask+0x467/0x766
[70874.969830]  [<ffffffff810fcfd3>] ? anon_vma_alloc+0x1a/0x1c
[70874.969833]  [<ffffffff81048a30>] ? get_parent_ip+0x11/0x41
[70874.969833]  [<ffffffff8110c0de>] alloc_pages_vma+0xec/0xf1
[70874.969833]  [<ffffffff8123430e>] ? rb_insert_color+0x66/0xe1
[70874.969833]  [<ffffffff8111be1c>] do_huge_pmd_anonymous_page+0xbf/0x267
[70874.969833]  [<ffffffff810f2497>] ? pmd_offset+0x19/0x40
[70874.969833]  [<ffffffff810f5c70>] handle_mm_fault+0x15d/0x20f
[70874.969833]  [<ffffffff8100f298>] ? arch_get_unmapped_area_topdown+0x1c3/0x28f
[70874.969833]  [<ffffffff8148178c>] do_page_fault+0x33b/0x35d
[70874.969833]  [<ffffffff810fb07d>] ? do_mmap_pgoff+0x29a/0x2f4
[70874.969833]  [<ffffffff8112dcee>] ? path_put+0x22/0x27
[70874.969833]  [<ffffffff8147f145>] page_fault+0x25/0x30

So it appears that the system is full of dirty pages against a slow
device and your foreground processes have got stuck in direct reclaim
-> compaction -> migration.   That's Mel ;)

What happened to the plans to eliminate direct reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
