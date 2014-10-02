Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 49FF86B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:57:25 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id fb4so73530wid.0
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:57:24 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id bp4si5851522wjc.41.2014.10.02.08.57.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:57:24 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id hi2so4549584wib.14
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:57:24 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: hugetlb braces not needed
Date: Thu,  2 Oct 2014 16:57:19 +0100
Message-Id: <1412265439-3654-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com, lcapitulino@redhat.com, iamjoonsoo.kim@lge.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

braces {} are not necessary for any arm of this statement

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/hugetlb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eeceeeb..565b403 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -106,11 +106,11 @@ static int hugepage_subpool_get_pages(struct hugepage_subpool *spool,
 		return 0;
 
 	spin_lock(&spool->lock);
-	if ((spool->used_hpages + delta) <= spool->max_hpages) {
+	if ((spool->used_hpages + delta) <= spool->max_hpages)
 		spool->used_hpages += delta;
-	} else {
+	else
 		ret = -ENOMEM;
-	}
+
 	spin_unlock(&spool->lock);
 
 	return ret;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
