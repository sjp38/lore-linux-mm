Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEACE6B025E
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 14:25:17 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b204so259500067qkc.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 11:25:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q131si11117406ywb.258.2016.09.19.11.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 11:25:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/2] mm: vma_adjust: remove superfluous check for next not NULL
Date: Mon, 19 Sep 2016 20:25:13 +0200
Message-Id: <1474309513-20313-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1474309513-20313-1-git-send-email-aarcange@redhat.com>
References: <20160918003654.GA25048@redhat.com>
 <1474309513-20313-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

If next would be NULL we couldn't reach such code path.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index eda3f07..4f512ca 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -702,7 +702,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * If next doesn't have anon_vma, import from vma after
 			 * next, if the vma overlaps with it.
 			 */
-			if (remove_next == 2 && next && !next->anon_vma)
+			if (remove_next == 2 && !next->anon_vma)
 				exporter = next->vm_next;
 
 		} else if (end > next->vm_start) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
