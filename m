Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9716B0038
	for <linux-mm@kvack.org>; Sun,  3 May 2015 22:31:12 -0400 (EDT)
Received: by ykeo186 with SMTP id o186so29842496yke.0
        for <linux-mm@kvack.org>; Sun, 03 May 2015 19:31:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 66si1263836yhi.109.2015.05.03.19.31.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 May 2015 19:31:11 -0700 (PDT)
Message-ID: <5546D9EB.4060602@oracle.com>
Date: Sun, 03 May 2015 22:31:07 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: VM_BUG on boot in set_pfnblock_flags_mask
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

Hi all,

I've decided to try and put more effort into testing on physical machines, but couldn't
even get the box to boot :(

[    0.000000] page:ffffea0000040000 count:0 mapcount:1 mapping:          (null) index:0x0
[    0.000000] flags: 0x0()
[    0.000000] page dumped because: VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn))
PANIC: early exception 06 rip 10:ffffffff8135d20f error 0 cr2 ffff88407ffff000
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.1.0-rc1-next-20150501+ #1
[    0.000000] Hardware name: Oracle Corporation OVCA X3-2             /ASSY,MOTHERBOARD,1U   , BIOS 17021300 06/19/2012
[    0.000000]  0000000000000000 115170652258be86 ffffffff82e077c0 ffffffff8267b3f8
[    0.000000]  0000000000000007 0000000000001000 ffffffff82e078b8 ffffffff831a11b0
[    0.000000]  29296e6670202c65 6e6f7a286e66705f 0000000000000000 6e6f7a2128454741
[    0.000000] Call Trace:
[    0.000000] dump_stack (lib/dump_stack.c:52)
[    0.000000] early_idt_handler (arch/x86/kernel/head_64.S:393)
[    0.000000] set_pageblock_migratetype (mm/page_alloc.c:317)
[    0.000000] memmap_init_zone (include/linux/mm.h:858 include/linux/mm.h:871 mm/page_alloc.c:862 mm/page_alloc.c:4553)
[    0.000000] free_area_init_node (mm/page_alloc.c:5300 mm/page_alloc.c:5374)
[    0.000000] free_area_init_nodes (mm/page_alloc.c:5765)
[    0.000000] zone_sizes_init (arch/x86/mm/init.c:716)
[    0.000000] paging_init (arch/x86/mm/init_64.c:665)
[    0.000000] setup_arch (arch/x86/kernel/setup.c:1183)
[    0.000000] start_kernel (include/linux/bitmap.h:187 include/linux/cpumask.h:342 include/linux/mm_types.h:476 init/main.c:524)
[    0.000000] x86_64_start_reservations (arch/x86/kernel/head64.c:198)
[    0.000000] x86_64_start_kernel (arch/x86/kernel/head64.c:187)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
