Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37AD16B0253
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 16:00:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so19021575wma.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 13:00:34 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id as5si750787wjc.68.2016.07.08.13.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 13:00:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id BBD501C3257
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 21:00:31 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/3] Fix boot problem with deferred meminit on machine with no node 0
Date: Fri,  8 Jul 2016 21:00:28 +0100
Message-Id: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

A machine with only node 1 was observed to crash very early in boot with
the following message

[    0.000000] BUG: unable to handle kernel paging request at 000000000002a3c8
[    0.000000] PGD 0
[    0.000000] Modules linked in:
[    0.000000] Hardware name: Supermicro H8DSP-8/H8DSP-8, BIOS 080011  06/30/2006
[    0.000000] task: ffffffff81c0d500 ti: ffffffff81c00000 task.ti: ffffffff81c00000
[    0.000000] RIP: 0010:[<ffffffff816dbd63>]  [<ffffffff816dbd63>] reserve_bootmem_region+0x6a/0xef
[    0.000000] RSP: 0000:ffffffff81c03eb0  EFLAGS: 00010086
[    0.000000] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[    0.000000] RDX: ffffffff81c03ec0 RSI: ffffffff81d205c0 RDI: ffffffff8213ee60
[    0.000000] R13: ffffea0000000000 R14: ffffea0000000020 R15: ffffea0000000020
[    0.000000] FS:  0000000000000000(0000) GS:ffff8800fba00000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: 000000000002a3c8 CR3: 0000000001c06000 CR4: 00000000000006b0
[    0.000000] Stack:
[    0.000000]  ffffffff81c03f00 0000000000000400 ffff8800fbfc3200 ffffffff81e2a2c0
[    0.000000]  ffffffff81c03fb0 ffffffff81c03f20 ffffffff81dadf7d ffffea0002000040
[    0.000000]  ffffea0000000000 0000000000000000 000000000000ffff 0000000000000001
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81dadf7d>] free_all_bootmem+0x4b/0x12a
[    0.000000]  [<ffffffff81d97122>] mem_init+0x70/0xa3
[    0.000000]  [<ffffffff81d78f21>] start_kernel+0x25b/0x49b

This series is the lowest-risk solution to the problem.

 mm/page_alloc.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
