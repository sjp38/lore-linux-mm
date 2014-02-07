Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF916B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:03:17 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so3172535pbc.30
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:03:17 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id rx8si4802670pac.221.2014.02.07.04.03.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:03:15 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so3089287pad.36
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:03:15 -0800 (PST)
Date: Fri, 7 Feb 2014 17:33:10 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 2/9] mm: Mark functions as static in memory.c
Message-ID: <2bd9a806eae6958a75de452ba1d09f5cb6e2f7bc.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, josh@joshtriplett.org

Mark functions as static in memory.c because they are not used outside
this file.

This eliminates the following warnings in mm/memory.c:
mm/memory.c:3530:5: warning: no previous prototype for a??numa_migrate_prepa?? [-Wmissing-prototypes]
mm/memory.c:3545:5: warning: no previous prototype for a??do_numa_pagea?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5d9025f..982c1ad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3527,7 +3527,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
+static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 				unsigned long addr, int page_nid,
 				int *flags)
 {
@@ -3542,7 +3542,7 @@ int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
 	struct page *page = NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
