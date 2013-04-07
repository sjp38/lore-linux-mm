Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 16DC76B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 05:18:42 -0400 (EDT)
Received: by mail-pd0-f196.google.com with SMTP id 10so2136659pdc.11
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 02:18:41 -0700 (PDT)
From: k80c <k80ck80c@gmail.com>
Subject: [PATCH 1/1] mmap.c: find_vma: eliminate initial if(mm) check
Date: Sun,  7 Apr 2013 14:48:12 +0530
Message-Id: <1365326292-2761-1-git-send-email-k80ck80c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, k80c <k80ck80c@gmail.com>

As per commit 841e31e5cc6219d62054788faa289b6ed682d068,
we dont really need this if(mm) check anymore.

A WARN_ON_ONCE was added just for safety, but there have been no bug
reports about this so far.

Removing this if(mm) check.

Signed-off-by: k80c <k80ck80c@gmail.com>
---
 mm/mmap.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 0db0de1..b2c363f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1935,9 +1935,6 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct vm_area_struct *vma = NULL;
 
-	if (WARN_ON_ONCE(!mm))		/* Remove this in linux-3.6 */
-		return NULL;
-
 	/* Check the cache first. */
 	/* (Cache hit rate is typically around 35%.) */
 	vma = ACCESS_ONCE(mm->mmap_cache);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
