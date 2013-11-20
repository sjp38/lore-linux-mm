Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id DF0C76B003C
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:51:39 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id e53so2327298eek.23
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:51:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 42si18119137eea.209.2013.11.20.09.51.38
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:51:39 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 8/8] mm/hugetlb.c: defer PageHeadHuge() symbol export
Date: Wed, 20 Nov 2013 18:51:16 +0100
Message-Id: <1384969876-6374-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
References: <1384969876-6374-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

No actual need of it. So keep it internal.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/hugetlb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9b8a14b..133ea72 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -743,7 +743,6 @@ int PageHeadHuge(struct page *page_head)
 
 	return get_compound_page_dtor(page_head) == free_huge_page;
 }
-EXPORT_SYMBOL_GPL(PageHeadHuge);
 
 pgoff_t __basepage_index(struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
