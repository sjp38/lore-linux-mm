Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2752D8E0217
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:03:13 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d41so3361101eda.12
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:03:13 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id w44si1092158edb.74.2018.12.14.15.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:03:11 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.10])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 1C37B1C1FBE
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:03:11 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/14] mm, compaction: Shrink compact_control
Date: Fri, 14 Dec 2018 23:02:57 +0000
Message-Id: <20181214230310.572-2-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The isolate and migrate scanners should never isolate more than a pageblock
of pages so unsigned int is sufficient saving 8 bytes on a 64-bit build.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/internal.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 536bc2a839b9..5564841fce36 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -185,8 +185,8 @@ struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
 	struct list_head migratepages;	/* List of pages being migrated */
 	struct zone *zone;
-	unsigned long nr_freepages;	/* Number of isolated free pages */
-	unsigned long nr_migratepages;	/* Number of pages to migrate */
+	unsigned int nr_freepages;	/* Number of isolated free pages */
+	unsigned int nr_migratepages;	/* Number of pages to migrate */
 	unsigned long total_migrate_scanned;
 	unsigned long total_free_scanned;
 	unsigned long free_pfn;		/* isolate_freepages search base */
-- 
2.16.4
