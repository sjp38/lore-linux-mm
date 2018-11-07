Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 979E76B04E3
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:18:48 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so15090593wrn.0
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:18:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y207-v6sor411667wmd.1.2018.11.07.02.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 02:18:47 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/5] mm, memory_hotplug: drop pointless block alignment checks from __offline_pages
Date: Wed,  7 Nov 2018 11:18:28 +0100
Message-Id: <20181107101830.17405-4-mhocko@kernel.org>
In-Reply-To: <20181107101830.17405-1-mhocko@kernel.org>
References: <20181107101830.17405-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
