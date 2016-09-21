Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4156B0264
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:15:26 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 16so129142437qtn.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:15:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s194si15095341ywg.418.2016.09.21.14.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 14:15:25 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/4] mm: vma_adjust: minor comment correction
Date: Wed, 21 Sep 2016 23:15:20 +0200
Message-Id: <1474492522-2261-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
References: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>

The cases are three not two.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 4f512ca..1b88754 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -663,7 +663,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			/*
 			 * vma expands, overlapping all the next, and
 			 * perhaps the one after too (mprotect case 6).
-			 * The only two other cases that gets here are
+			 * The only other cases that gets here are
 			 * case 1, case 7 and case 8.
 			 */
 			if (next == expand) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
