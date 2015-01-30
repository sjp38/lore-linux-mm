Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 731CA6B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 05:55:54 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so51059660pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:55:54 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id ch5si4492541pdb.158.2015.01.30.02.55.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 02:55:53 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so51059414pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:55:52 -0800 (PST)
Date: Fri, 30 Jan 2015 19:53:02 +0900
From: Daeseok Youn <daeseok.youn@gmail.com>
Subject: [PATCH] mincore: remove unneeded variable 'err'
Message-ID: <20150130105302.GA24970@devel.8.8.4.4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, n-horiguchi@ah.jp.nec.com, riel@redhat.com, minchan@kernel.org, daeseok.youn@gmail.com, kirill.shutemov@linux.intel.com, weijie.yang@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mincore_hugetlb() returns always '0'

Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
---
 mm/mincore.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 8d6db5c..be25efd 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -22,7 +22,6 @@
 static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 			unsigned long end, struct mm_walk *walk)
 {
-	int err = 0;
 #ifdef CONFIG_HUGETLB_PAGE
 	unsigned char present;
 	unsigned char *vec = walk->private;
@@ -38,7 +37,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 #else
 	BUG();
 #endif
-	return err;
+	return 0;
 }
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
