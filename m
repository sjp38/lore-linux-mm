Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8768E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:50:34 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d41so34696291eda.12
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:50:34 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id y6si2193096edi.116.2019.01.04.04.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:50:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 6B74898837
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:50:32 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 01/25] mm, compaction: Shrink compact_control
Date: Fri,  4 Jan 2019 12:49:47 +0000
Message-Id: <20190104125011.16071-2-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The isolate and migrate scanners should never isolate more than a pageblock
of pages so unsigned int is sufficient saving 8 bytes on a 64-bit build.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/internal.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index f4a7bb02decf..5ddf5d3771a0 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -184,8 +184,8 @@ struct compact_control {
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
