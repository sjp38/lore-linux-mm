Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id A14FD6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:51:11 -0400 (EDT)
Received: by iecvh10 with SMTP id vh10so75990490iec.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:51:11 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id 2si1550937igt.56.2015.06.26.06.51.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 06:51:11 -0700 (PDT)
Received: by iebrt9 with SMTP id rt9so75992827ieb.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:51:11 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Make the function madvise_behaviour_valid bool
Date: Fri, 26 Jun 2015 09:51:05 -0400
Message-Id: <1435326665-20525-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jack@suse.cz, kirill.shutemov@linux.intel.com, axboe@fb.com, tj@kernel.org, Anna.Schumaker@netapp.com, hch@lst.de, shhuiw@gmail.com, matthew.r.wilcox@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This makes the function madvise_bahaviour_valid bool now due to
this particular function always returning the value of either one
or zero as its return value.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/madvise.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 64bb8a2..069e22d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -385,7 +385,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	}
 }
 
-static int
+static bool
 madvise_behavior_valid(int behavior)
 {
 	switch (behavior) {
@@ -407,10 +407,10 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
-		return 1;
+		return true;
 
 	default:
-		return 0;
+		return false;
 	}
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
