Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C0C4E6B0036
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 15:02:58 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so1424208wgh.27
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 12:02:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ga9si1270755wjb.116.2014.04.08.12.02.53
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 12:02:54 -0700 (PDT)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 1/5] hugetlb: prep_compound_gigantic_page(): drop __init marker
Date: Tue,  8 Apr 2014 15:02:16 -0400
Message-Id: <1396983740-26047-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com

This function is going to be used by non-init code in a future
commit.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 mm/hugetlb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7c02b9d..319db28 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -689,8 +689,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 	put_page(page); /* free it into the hugepage allocator */
 }
 
-static void __init prep_compound_gigantic_page(struct page *page,
-					       unsigned long order)
+static void prep_compound_gigantic_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
