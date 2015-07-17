Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 01D45280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:53:36 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so60259122pac.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:53:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ns8si18307621pdb.234.2015.07.17.04.53.25
        for <linux-mm@kvack.org>;
        Fri, 17 Jul 2015 04:53:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 6/6] mm, madvise: use vma_is_anonymous() to check for anon VMA
Date: Fri, 17 Jul 2015 14:53:13 +0300
Message-Id: <1437133993-91885-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

!vma->vm_file is not reliable to detect anon VMA, because not all
drivers bother set it. Let's use vma_is_anonymous() instead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 67d5fe74ffdf..00fb14ff98dd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -393,7 +393,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	/* MADV_FREE works for only anon vma at the moment */
-	if (vma->vm_file)
+	if (!vma_is_anonymous(vma))
 		return -EINVAL;
 
 	start = max(vma->vm_start, start_addr);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
