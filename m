Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD796B0069
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:02:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so55394531pfx.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:02:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i29si5669810pfa.172.2016.08.19.09.02.18
        for <linux-mm@kvack.org>;
        Fri, 19 Aug 2016 09:02:18 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH] mm: pagewalk: Fix the comment for test_walk
Date: Fri, 19 Aug 2016 17:01:58 +0100
Message-Id: <1471622518-21980-1-git-send-email-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Modify the comment describing struct mm_walk->test_walk()s behaviour
to match the comment on walk_page_test() and the behaviour of
walk_page_vma().

Fixes: fafaa4264eba4 "pagewalk: improve vma handling"
Signed-off-by: James Morse <james.morse@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53eeedd5..9a347068c0b3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1197,10 +1197,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * @pte_hole: if set, called for each hole at all levels
  * @hugetlb_entry: if set, called for each hugetlb entry
  * @test_walk: caller specific callback function to determine whether
- *             we walk over the current vma or not. A positive returned
+ *             we walk over the current vma or not. Returning 0
  *             value means "do page table walk over the current vma,"
  *             and a negative one means "abort current page table walk
- *             right now." 0 means "skip the current vma."
+ *             right now." 1 means "skip the current vma."
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked (NULL if walking outside vmas)
  * @private:   private data for callbacks' usage
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
