Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 714456B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:06:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so64001545pfx.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:06:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iu4si5510808pac.93.2016.06.15.13.06.54
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:06:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 04/37]  mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix-2-fix
Date: Wed, 15 Jun 2016 23:06:09 +0300
Message-Id: <1466021202-61880-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

From: Andrew Morton <akpm@linux-foundation.org>

update comment to match new code

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/huge_memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1777b806de96..d7ccc8558187 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2502,9 +2502,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	}
 
 	/*
-	 * __collapse_huge_page_swapin always returns with mmap_sem
-	 * locked. If it fails, release mmap_sem and jump directly
-	 * label out. Continuing to collapse causes inconsistency.
+	 * __collapse_huge_page_swapin always returns with mmap_sem locked.
+	 * If it fails, release mmap_sem and jump directly out.
+	 * Continuing to collapse causes inconsistency.
 	 */
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
