Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38D9D6B0881
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:30:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so2675268edc.9
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:30:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20-v6sor4747298ejt.1.2018.11.16.00.30.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 00:30:36 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/5] mm, memory_hotplug: drop pointless block alignment checks from __offline_pages
Date: Fri, 16 Nov 2018 09:30:18 +0100
Message-Id: <20181116083020.20260-4-mhocko@kernel.org>
In-Reply-To: <20181116083020.20260-1-mhocko@kernel.org>
References: <20181116083020.20260-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

This function is never called from a context which would provide
misaligned pfn range so drop the pointless check.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2b2b3ccbbfb5..a92b1b8f6218 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1554,12 +1554,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	struct zone *zone;
 	struct memory_notify arg;
 
-	/* at least, alignment against pageblock is necessary */
-	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
-		return -EINVAL;
-	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
-		return -EINVAL;
-
 	mem_hotplug_begin();
 
 	/* This makes hotplug much easier...and readable.
-- 
2.19.1
