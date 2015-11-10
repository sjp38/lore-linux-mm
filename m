Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE026B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 19:22:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so93035016wme.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 16:22:51 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id m78si1774131wma.3.2015.11.09.16.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 16:22:51 -0800 (PST)
Received: by wmeo63 with SMTP id o63so10544047wme.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 16:22:51 -0800 (PST)
From: Alexey Klimov <klimov.linux@gmail.com>
Subject: [PATCH] mm/mlock.c: drop unneeded initialization in munlock_vma_pages_range()
Date: Tue, 10 Nov 2015 00:22:42 +0000
Message-Id: <1447114962-31834-1-git-send-email-klimov.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, klimov.linux@gmail.com, emunson@akamai.com

Before usage page pointer initialized by NULL is reinitialized by
follow_page_mask(). Drop useless init of page pointer in the beginning
of loop.

Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>
---
 mm/mlock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 339d9e0..9cb87cb 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -425,7 +425,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
 
 	while (start < end) {
-		struct page *page = NULL;
+		struct page *page;
 		unsigned int page_mask;
 		unsigned long page_increm;
 		struct pagevec pvec;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
