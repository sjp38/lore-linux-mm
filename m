Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D14C6B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 08:52:27 -0400 (EDT)
Received: by wyi40 with SMTP id 40so2377902wyi.14
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 05:52:23 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 13 Oct 2011 20:52:22 +0800
Message-ID: <CAJd=RBALaNJ680JzCP8KUaDO80dM+9_AK5yW9SSVoUD0G1Cxzw@mail.gmail.com>
Subject: [PATCH] mm/huge_memory: Clean up typo when updating mmu cache
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrea

There are three cases of update_mmu_cache() in the file, and the case in
function collapse_huge_page() has a typo, namely the last parameter used,
which is corrected based on the other two cases.

Due to the define of update_mmu_cache by X86, the only arch that implements
THP currently, the change here has no really crystal point, but one or two
minutes of efforts could be saved for those archs that are likely to support
THP in future.

Thanks

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/huge_memory.c	Sat Aug 13 11:45:14 2011
+++ b/mm/huge_memory.c	Thu Oct 13 20:07:29 2011
@@ -1906,7 +1906,7 @@ static void collapse_huge_page(struct mm
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
 	set_pmd_at(mm, address, pmd, _pmd);
-	update_mmu_cache(vma, address, entry);
+	update_mmu_cache(vma, address, _pmd);
 	prepare_pmd_huge_pte(pgtable, mm);
 	mm->nr_ptes--;
 	spin_unlock(&mm->page_table_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
