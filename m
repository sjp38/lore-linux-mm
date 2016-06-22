Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41BD36B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:17:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so487819wme.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:17:35 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id a8si43552509wjv.84.2016.06.22.04.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:17:34 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id c82so212463wme.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:17:34 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH v2 3/3] mm, thp: fix comment inconsistency for swapin readahead functions
Date: Wed, 22 Jun 2016 14:17:15 +0300
Message-Id: <1466594235-3126-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, hillf.zj@alibaba-inc.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

After fixing swapin issues, comment lines stayed as in old version.
This patch updates the comments.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
Changes in v2:
 - Newly created in this version.

 mm/huge_memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ff96765..5cb0fd9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2441,8 +2441,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
 			down_read(&mm->mmap_sem);
-			/* vma is no longer available, don't continue to swapin */
 			if (hugepage_vma_revalidate(mm, address)) {
+				/* vma is no longer available, don't continue to swapin */
 				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 				return false;
 			}
@@ -2512,8 +2512,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	/*
 	 * __collapse_huge_page_swapin always returns with mmap_sem
-	 * locked.  If it fails, release mmap_sem and jump directly
-	 * out.  Continuing to collapse causes inconsistency.
+	 * locked. If it fails, we release mmap_sem and jump out_nolock.
+	 * Continuing to collapse causes inconsistency.
 	 */
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
