Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 88D7A6B0037
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 07:49:58 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id z60so3429467qgd.41
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 04:49:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u7si9256136qcu.13.2014.07.31.04.49.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 04:49:57 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 1/2] mm, vmscan: fix an outdated comment still mentioning get_scan_ratio
Date: Thu, 31 Jul 2014 13:49:44 +0200
Message-Id: <1406807385-5168-2-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1406807385-5168-1-git-send-email-jmarchan@redhat.com>
References: <1406807385-5168-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>

Quite a while  ago, get_scan_ratio() has been renamed get_scan_count(),
however a comment in shrink_active_list() still mention it. This patch
fixes the outdated comment.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d698f4f..079918d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1759,7 +1759,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
 	 * helps balance scan pressure between file and anonymous pages in
-	 * get_scan_ratio.
+	 * get_scan_count.
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
