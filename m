Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id D6A076B0036
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:59:17 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so4288088wes.39
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:59:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q4si4747845wix.57.2014.04.10.10.59.13
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 10:59:14 -0700 (PDT)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 1/5] hugetlb: prep_compound_gigantic_page(): drop __init marker
Date: Thu, 10 Apr 2014 13:58:41 -0400
Message-Id: <1397152725-20990-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

This function is going to be used by non-init code in a future
commit.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 mm/hugetlb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dd30f22..957231b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -690,8 +690,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
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
