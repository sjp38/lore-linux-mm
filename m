Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D28198D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 23:56:35 -0500 (EST)
Date: Thu, 24 Feb 2011 05:56:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 7/8] Use GFP_OTHER_NODE for transparent huge pages
Message-ID: <20110224045625.GH31195@random.random>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
 <1298425922-23630-8-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298425922-23630-8-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

This fixes build with CONFIG_NUMA=n for patch 7 (noticed on my
laptop which isn't NUMA yet ;).

===
Subject: thp: add extra_gfp in alloc_hugepage non NUMA

From: Andrea Arcangeli <aarcange@redhat.com>

Add extra_gfp to avoid build failure with CONFIG_NUMA=n.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -660,7 +660,7 @@ static inline struct page *alloc_hugepag
 #ifndef CONFIG_NUMA
 static inline struct page *alloc_hugepage(int defrag)
 {
-	return alloc_pages(alloc_hugepage_gfpmask(defrag),
+	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
 			   HPAGE_PMD_ORDER);
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
