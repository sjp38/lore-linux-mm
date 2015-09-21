Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 18DAF6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:23:34 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so123166822pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:23:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id vm6si38886838pab.128.2015.09.21.09.23.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:23:33 -0700 (PDT)
Date: Mon, 21 Sep 2015 19:23:14 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mm/huge_memory: add a missing tab
Message-ID: <20150921162314.GB5648@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

This line should be indented one more tab.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b057ab..61d2162 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2887,7 +2887,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		khugepaged_node_load[node]++;
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		if (!PageLRU(page)) {
-		result = SCAN_SCAN_ABORT;
+			result = SCAN_SCAN_ABORT;
 			goto out_unmap;
 		}
 		if (PageLocked(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
