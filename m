Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C7D496B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:32:23 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so171389214pac.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 02:32:23 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id v13si49452510pas.84.2015.11.16.02.32.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 02:32:22 -0800 (PST)
Date: Mon, 16 Nov 2015 19:32:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151116103220.GA32578@bbox>
References: <20151103030258.GJ17906@bbox>
 <20151103071650.GA21553@node.shutemov.name>
 <20151103073329.GL17906@bbox>
 <20151103152019.GM17906@bbox>
 <20151104142135.GA13303@node.shutemov.name>
 <20151105001922.GD7357@bbox>
 <20151108225522.GA29600@node.shutemov.name>
 <20151112003614.GA5235@bbox>
 <20151116014521.GA7973@bbox>
 <20151116084522.GA9778@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20151116084522.GA9778@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Nov 16, 2015 at 10:45:22AM +0200, Kirill A. Shutemov wrote:
> On Mon, Nov 16, 2015 at 10:45:21AM +0900, Minchan Kim wrote:
> > During the test with MADV_FREE on kernel I applied your patches,
> > I couldn't see any problem.
> > 
> > However, in this round, I did another test which is same one
> > I attached but a liitle bit different because it doesn't do
> > (memcg things/kill/swapoff) for testing program long-live test.
> 
> Could you share updated test?

It's part of my testing suite so I should factor it out.
I will send it when I go to office tomorrow.

> 
> And could you try to reproduce it on clean mmotm-2015-11-10-15-53?

Befor leaving office, I queued it up and result is below.
It seems you fixed already but didn't apply it to mmotm yet. Right?
Anyway, please confirm and say to me what I should add more patches
into mmotm-2015-11-10-15-53 for follow up your recent many bug
fix patches.

Thanks.

page:ffffea0000553fc0 count:3 mapcount:1 mapping:ffff88007f717a01 index:0x6000002ff
flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
page->mem_cgroup:ffff880077cf0c00
------------[ cut here ]------------
kernel BUG at mm/migrate.c:889!
invalid opcode: 0000 [#1] SMP 
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 10 PID: 59 Comm: khugepaged Not tainted 4.3.0-mm1-kirill+ #7
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880073441a40 ti: ffff88007344c000 task.ti: ffff88007344c000
RIP: 0010:[<ffffffff81145466>]  [<ffffffff81145466>] migrate_pages+0x8e6/0x950
RSP: 0018:ffff88007344fa00  EFLAGS: 00010282
RAX: 0000000000000021 RBX: ffffea0001a0bbc0 RCX: 0000000000000000
RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffffff821df4d8
RBP: ffff88007344fa80 R08: 0000000000000000 R09: ffff8800000b9540
R10: ffffffff8163e2c0 R11: 00000000000002c2 R12: 0000000000000000
R13: ffffea0000553f80 R14: ffffea0000553fc0 R15: ffffffff8189db40
FS:  0000000000000000(0000) GS:ffff880078340000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f45cc0091d8 CR3: 000000007eba7000 CR4: 00000000000006a0
Stack:
 ffff880073441a40 0000000000000000 0000000000000000 0000000000000000
 ffffffff81114880 0000000000000000 ffffffff81116420 ffffea0000553fe0
 ffff88007344fb30 ffff88007344fb20 0000000000000000 ffff88007344fb20
Call Trace:
 [<ffffffff81114880>] ? trace_raw_output_mm_compaction_defer_template+0xc0/0xc0
 [<ffffffff81116420>] ? isolate_freepages_block+0x3d0/0x3d0
 [<ffffffff81116dfb>] compact_zone+0x2bb/0x720
 [<ffffffff8128793d>] ? list_del+0xd/0x30
 [<ffffffff811172cd>] compact_zone_order+0x6d/0xa0
 [<ffffffff8111751d>] try_to_compact_pages+0xed/0x200
 [<ffffffff81154143>] __alloc_pages_direct_compact+0x3b/0xd4
 [<ffffffff810f921b>] __alloc_pages_nodemask+0x3fb/0x920
 [<ffffffff81147465>] khugepaged+0x155/0x1b10
 [<ffffffff81073ca0>] ? prepare_to_wait_event+0xf0/0xf0
 [<ffffffff81147310>] ? __split_huge_pmd_locked+0x4e0/0x4e0
 [<ffffffff81057e49>] kthread+0xc9/0xe0
 [<ffffffff81057d80>] ? kthread_park+0x60/0x60
 [<ffffffff8142aa6f>] ret_from_fork+0x3f/0x70
 [<ffffffff81057d80>] ? kthread_park+0x60/0x60
Code: 44 c6 48 8b 40 08 83 e0 03 48 83 f8 03 0f 84 fd fa ff ff 4d 85 e4 0f 85 f4 fa ff ff 48 c7 c6 b8 f6 77 81 4c 89 f7 e8 fa 36 fd ff <0f> 0b 48 83 e8 01 e9 d0 fa ff ff f6 40 07 01 0f 84 5b fd ff ff 
RIP  [<ffffffff81145466>] migrate_pages+0x8e6/0x950
 RSP <ffff88007344fa00>
---[ end trace 337555313b7e45be ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
