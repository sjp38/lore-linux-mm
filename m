Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEC46B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:31:49 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id tt10so151731329pab.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:31:49 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id kg1si5492535pad.81.2016.03.14.00.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:31:48 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id x3so4189863pfb.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:31:48 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 0/6] Add zone overlapping check
Date: Mon, 14 Mar 2016 16:31:31 +0900
Message-Id: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello, all.

This patchset deals with some problematic sites that iterate pfn range.

There is a system that node's pfn are overlapped like as following.

-----pfn-------->
N0 N1 N2 N0 N1 N2

Therefore, we need to care this overlapping when iterating pfn range.

I audit many iterating sites that uses pfn_valid(), pfn_valid_within(),
zone_start_pfn and etc. and others looks safe for me. This is
a preparation step for new CMA implementation, ZONE_CMA [1], because
it would be easily overlapped with other zones. But, zone overlap
check is also needed for general case so I send it separately.

This is based on next-20160311.

Thanks.

[1]: https://lkml.org/lkml/2015/2/12/95

Joonsoo Kim (6):
  mm/page_alloc: fix same zone check in __pageblock_pfn_to_page()
  mm/hugetlb: add same zone check in pfn_range_valid_gigantic()
  mm/memory_hotplug: add comment to some functions related to memory
    hotplug
  mm/vmstat: add zone range overlapping check
  mm/page_owner: add zone range overlapping check
  power: add zone range overlapping check

 mm/hugetlb.c        |  9 ++++++---
 mm/page_alloc.c     | 10 +++++++---
 mm/page_isolation.c |  1 +
 mm/page_owner.c     |  3 +++
 mm/vmstat.c         |  7 +++++++
 5 files changed, 24 insertions(+), 6 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
