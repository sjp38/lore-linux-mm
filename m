Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 98A556B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:53:55 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so148732919pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:53:55 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id sl6si8163297pac.192.2015.07.09.01.53.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 01:53:54 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] mm: RIP put_page_unless_one() as it has no callers
Date: Thu, 9 Jul 2015 14:23:30 +0530
Message-ID: <1436432010-3042-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 include/linux/mm.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7f471789781a..8d835cbe48fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -358,18 +358,6 @@ static inline int get_page_unless_zero(struct page *page)
 	return atomic_inc_not_zero(&page->_count);
 }
 
-/*
- * Try to drop a ref unless the page has a refcount of one, return false if
- * that is the case.
- * This is to make sure that the refcount won't become zero after this drop.
- * This can be called when MMU is off so it must not access
- * any of the virtual mappings.
- */
-static inline int put_page_unless_one(struct page *page)
-{
-	return atomic_add_unless(&page->_count, -1, 1);
-}
-
 extern int page_is_ram(unsigned long pfn);
 extern int region_is_ram(resource_size_t phys_addr, unsigned long size);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
