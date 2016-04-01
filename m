Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C38856B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:06:57 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fe3so79129896pab.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:06:57 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id y65si17733581pfa.146.2016.03.31.19.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:06:56 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id e128so61468117pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:06:56 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 0/5] Add zone overlapping check
Date: Fri,  1 Apr 2016 11:06:41 +0900
Message-Id: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Change from v1
o drop patch 1 ("mm/page_alloc: fix same zone check in
__pageblock_pfn_to_page()") per Mel's comment

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

This is based on next-20160330.

Thanks.

[1]: https://lkml.org/lkml/2015/2/12/95

Joonsoo Kim (5):
  mm/hugetlb: add same zone check in pfn_range_valid_gigantic()
  mm/memory_hotplug: add comment to some functions related to memory
    hotplug
  mm/vmstat: add zone range overlapping check
  mm/page_owner: add zone range overlapping check
  power: add zone range overlapping check

 mm/hugetlb.c        | 9 ++++++---
 mm/page_alloc.c     | 7 ++++++-
 mm/page_isolation.c | 1 +
 mm/page_owner.c     | 3 +++
 mm/vmstat.c         | 7 +++++++
 5 files changed, 23 insertions(+), 4 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
