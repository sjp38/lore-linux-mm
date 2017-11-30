Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDE36B026E
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:56 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v8so92256wmh.2
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m19si3943763wrf.445.2017.11.30.14.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:54 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:52 -0800
From: akpm@linux-foundation.org
Subject: [patch 13/15] mm/page_owner: align with pageblock_nr pages
Message-ID: <5a208318./AHclpWAWggUsQYT%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, zhongjiang@huawei.com, mhocko@kernel.org

From: zhong jiang <zhongjiang@huawei.com>
Subject: mm/page_owner: align with pageblock_nr pages

When pfn_valid(pfn) returns false, pfn should be aligned with
pageblock_nr_pages other than MAX_ORDER_NR_PAGES in init_pages_in_zone,
because the skipped 2M may be valid pfn, as a result, early allocated
count will not be accurate.

Link: http://lkml.kernel.org/r/1468938136-24228-1-git-send-email-zhongjiang@huawei.com
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_owner.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages mm/page_owner.c
--- a/mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages
+++ a/mm/page_owner.c
@@ -544,7 +544,7 @@ static void init_pages_in_zone(pg_data_t
 	 */
 	for (; pfn < end_pfn; ) {
 		if (!pfn_valid(pfn)) {
-			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
+			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 			continue;
 		}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
