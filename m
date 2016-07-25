Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AEA56B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 05:23:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so73225765wma.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 02:23:27 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id f27si23131236wmi.79.2016.07.25.02.23.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 02:23:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id EDA5A98DAA
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 09:23:25 +0000 (UTC)
Date: Mon, 25 Jul 2016 10:23:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, vmscan: remove highmem_file_pages -fix
Message-ID: <20160725092324.GM10438@techsingularity.net>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-3-git-send-email-mgorman@techsingularity.net>
 <20160725080911.GC1660@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160725080911.GC1660@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The wrong stat is being accumulatedin highmem_dirtyable_memory, fix it.

This is a fix to the mmotm patch mm-vmscan-remove-highmem_file_pages.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page-writeback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7e9061ec040b..f4cd7d8005c9 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -322,8 +322,8 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 			nr_pages = zone_page_state(z, NR_FREE_PAGES);
 			/* watch for underflows */
 			nr_pages -= min(nr_pages, high_wmark_pages(z));
-			nr_pages += zone_page_state(z, NR_INACTIVE_FILE);
-			nr_pages += zone_page_state(z, NR_ACTIVE_FILE);
+			nr_pages += zone_page_state(z, NR_ZONE_INACTIVE_FILE);
+			nr_pages += zone_page_state(z, NR_ZONE_ACTIVE_FILE);
 			x += nr_pages;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
