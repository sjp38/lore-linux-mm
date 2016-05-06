Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2856B025F
	for <linux-mm@kvack.org>; Fri,  6 May 2016 11:04:09 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id y6so140864363ywe.0
        for <linux-mm@kvack.org>; Fri, 06 May 2016 08:04:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e66si9798035qgf.125.2016.05.06.08.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 08:04:04 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/3] mm: thp: split_huge_pmd_address() comment improvement
Date: Fri,  6 May 2016 17:04:00 +0200
Message-Id: <1462547040-1737-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
References: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alex Williamson <alex.williamson@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

Comment is partly wrong, this improves it by including the case of
split_huge_pmd_address() called by try_to_unmap_one if
TTU_SPLIT_HUGE_PMD is set.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9086793..1fbe13d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3031,8 +3031,10 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		return;
 
 	/*
-	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
-	 * materialize from under us.
+	 * Caller holds the mmap_sem write mode or the anon_vma lock,
+	 * so a huge pmd cannot materialize from under us (khugepaged
+	 * holds both the mmap_sem write mode and the anon_vma lock
+	 * write mode).
 	 */
 	__split_huge_pmd(vma, pmd, address, freeze);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
