Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17229C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C457320842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C457320842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 980048E001E; Wed, 27 Feb 2019 12:08:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 930E78E0001; Wed, 27 Feb 2019 12:08:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D3718E001E; Wed, 27 Feb 2019 12:08:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEE88E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:14 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o27so7250462edc.14
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zJK9tQmzH2wt8ZgtuBGoRD5SE3Dtp+m3gB1hPWai3es=;
        b=l6Dc50pb2pjBjY5SZb7C0blWN6lYT43dMUcEFbahC8QdB26FqxzVm3be+EPgZTEvH6
         IpuQVBBD5Q6+QAAwuKFF5HHFYDw7bAVi9OwQYw4q7NhZvveZuMProAKTjEc2nDcfNpkm
         g2doQlo0DGq/vPsWtY0rZS8HPyx/DuL3TBoS9dm+oM+gsYLgatHI2Fva9p1rXozoTAoq
         kuBddVVQIdHkdaFgtAvQfy7OBbBsYgPrw6LUJgZib09HrT4Dk754l41zjY5CeydyrtV/
         /jmmf3CdsM/HZhJP8LsnpZVeLrFFR78T4hiZ9LJEZ4PPd5sHbgqa8bvxegsTpWTGVqki
         Pd9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuY3KqHbKIFLhjq6VeawBokesYMU8O6V+whqnh7QIGBfMTEwJYBl
	Cc3AF92dKaBjD+BegH/y4/H5vhgucZDZ2+wsuDoqBHo6sPo4YoTnsY/Y6ggV3oDZdyj1/jF/+eb
	w3oKvUOnQeq/LuneY6ho0FI/k1EwgXNjd3FvRstaTEKtttlw2gmK0Z9WkxCggAaTiEA==
X-Received: by 2002:a50:d8ce:: with SMTP id y14mr3151508edj.101.1551287293594;
        Wed, 27 Feb 2019 09:08:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibo1ZP4W7oQpat5tGuWPV3bJdcgISbi/+a5GEUs3OgzUJ6YJq1ZqYsrkUWl1VmPpJoyfFUO
X-Received: by 2002:a50:d8ce:: with SMTP id y14mr3151425edj.101.1551287292164;
        Wed, 27 Feb 2019 09:08:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287292; cv=none;
        d=google.com; s=arc-20160816;
        b=iT+xdz04L7Ba44tUvOe1DXhbYJc6QLNIQyDfd6PLHSvbhnrzkA6h7xoLsNhwXfzVyA
         r9l37LZHOJ95HPc/nqRaNNjKroz20mBLcxicA0q5jMlMCdSamu5Xd+F0wthz2KVw9cC3
         OeB+Rp+U+jDWX15UoJfukmwRGsedlu2lW5NeD7/nBwOUjM8Xfm8St5mFZ35HmzBHP/lp
         DJTZl8CM108+0tHvSBNs07CPx9vSqXt/ysoE42Ft765Ie/eWC3QOf1quTdtIZa12TM3R
         Fp/fACbK9wWwtm+EXiHGyBMRCG5C+4FBq68OVaMMiS3YVcMK/JBvhOntWUtd3RYgdCb/
         RPkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zJK9tQmzH2wt8ZgtuBGoRD5SE3Dtp+m3gB1hPWai3es=;
        b=B7WEcZq7OE3499tCj1mncCuPZgd0S7TuEoL8AMSTfSEGfU1mTcmJ74vD+EuqewxQw4
         hFOVrquOSiWxCmRUk1YBqJ0dZQQMFNL0Cv4DQBMkZiD9DeMWYsO8/h+yMPpm9GGT1c/3
         J1GbVFQOgnCunKDamaV3LYjcijuJCQdMpOgEoyzARN2SRjGBjFQQh2MNHnKyQuamxqEa
         +9S4bdl2rTygJouT8Q5xEa7Y1LXd4NANXP4VOmygjMhIF2kfvzQORatRCvOMvkyYtF33
         ukXDIQbrBYGtnEQF1vbb++R5Y1+cOR1Vs725dbJBo+llAGrn3u8lNb4qQfVhBybBqUrp
         kIeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id bq9si621576ejb.212.2019.02.27.09.08.11
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:12 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1E223A78;
	Wed, 27 Feb 2019 09:08:11 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D78CF3F738;
	Wed, 27 Feb 2019 09:08:07 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v3 27/34] mm: pagewalk: Add 'depth' parameter to pte_hole
Date: Wed, 27 Feb 2019 17:06:01 +0000
Message-Id: <20190227170608.27963-28-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pte_hole() callback is called at multiple levels of the page tables.
Code dumping the kernel page tables needs to know what at what depth
the missing entry is. Add this is an extra parameter to pte_hole().
When the depth isn't know (e.g. processing a vma) then -1 is passed.

The depth that is reported is the actual level where the entry is
missing (ignoring any folding that is in place), i.e. any levels where
PTRS_PER_P?D is set to 1 are ignored.

Note that depth starts at 0 for a PGD so that PUD/PMD/PTE retain their
natural numbers as levels 2/3/4.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 fs/proc/task_mmu.c |  4 ++--
 include/linux/mm.h |  6 ++++--
 mm/hmm.c           |  2 +-
 mm/migrate.c       |  1 +
 mm/mincore.c       |  1 +
 mm/pagewalk.c      | 31 +++++++++++++++++++++++++------
 6 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f0ec9edab2f3..91131cd4e9e0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -474,7 +474,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 #ifdef CONFIG_SHMEM
 static int smaps_pte_hole(unsigned long addr, unsigned long end,
-		struct mm_walk *walk)
+			  __always_unused int depth, struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
 
@@ -1203,7 +1203,7 @@ static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
 }
 
 static int pagemap_pte_hole(unsigned long start, unsigned long end,
-				struct mm_walk *walk)
+			    __always_unused int depth, struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
 	unsigned long addr = start;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1a4b1615d012..4ae3634a9118 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1420,7 +1420,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *	       pmd_trans_huge() pmds.  They may simply choose to
  *	       split_huge_page() instead of handling it explicitly.
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
- * @pte_hole: if set, called for each hole at all levels
+ * @pte_hole: if set, called for each hole at all levels,
+ *            depth is -1 if not known, 0:PGD, 1:P4D, 2:PUD, 3:PMD, 4:PTE
+ *            any depths where PTRS_PER_P?D is equal to 1 are skipped
  * @hugetlb_entry: if set, called for each hugetlb entry
  * @test_walk: caller specific callback function to determine whether
  *             we walk over the current vma or not. Returning 0
@@ -1445,7 +1447,7 @@ struct mm_walk {
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_hole)(unsigned long addr, unsigned long next,
-			struct mm_walk *walk);
+			int depth, struct mm_walk *walk);
 	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
 			     unsigned long addr, unsigned long next,
 			     struct mm_walk *walk);
diff --git a/mm/hmm.c b/mm/hmm.c
index a04e4b810610..e3e6b8fda437 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -440,7 +440,7 @@ static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 }
 
 static int hmm_vma_walk_hole(unsigned long addr, unsigned long end,
-			     struct mm_walk *walk)
+			     __always_unused int depth, struct mm_walk *walk)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..8b62a9fecb5c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2121,6 +2121,7 @@ struct migrate_vma {
 
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
+				    __always_unused int depth,
 				    struct mm_walk *walk)
 {
 	struct migrate_vma *migrate = walk->private;
diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..c4edbc688241 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -104,6 +104,7 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 }
 
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
+				   __always_unused int depth,
 				   struct mm_walk *walk)
 {
 	walk->private += __mincore_unmapped_range(addr, end,
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index dac0c848b458..57946bcd810c 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -4,6 +4,22 @@
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
 
+/*
+ * We want to know the real level where a entry is located ignoring any
+ * folding of levels which may be happening. For example if p4d is folded then
+ * a missing entry found at level 1 (p4d) is actually at level 0 (pgd).
+ */
+static int real_depth(int depth)
+{
+	if (depth == 3 && PTRS_PER_PMD == 1)
+		depth = 2;
+	if (depth == 2 && PTRS_PER_PUD == 1)
+		depth = 1;
+	if (depth == 1 && PTRS_PER_P4D == 1)
+		depth = 0;
+	return depth;
+}
+
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
 {
@@ -31,6 +47,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	pmd_t *pmd;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(3);
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -38,7 +55,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -81,6 +98,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	pud_t *pud;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(2);
 
 	pud = pud_offset(p4d, addr);
 	do {
@@ -88,7 +106,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		next = pud_addr_end(addr, end);
 		if (pud_none(*pud)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -123,13 +141,14 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	p4d_t *p4d;
 	unsigned long next;
 	int err = 0;
+	int depth = real_depth(1);
 
 	p4d = p4d_offset(pgd, addr);
 	do {
 		next = p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, depth, walk);
 			if (err)
 				break;
 			continue;
@@ -160,7 +179,7 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
-				err = walk->pte_hole(addr, next, walk);
+				err = walk->pte_hole(addr, next, 0, walk);
 			if (err)
 				break;
 			continue;
@@ -206,7 +225,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		if (pte)
 			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		else if (walk->pte_hole)
-			err = walk->pte_hole(addr, next, walk);
+			err = walk->pte_hole(addr, next, -1, walk);
 
 		if (err)
 			break;
@@ -249,7 +268,7 @@ static int walk_page_test(unsigned long start, unsigned long end,
 	if (vma->vm_flags & VM_PFNMAP) {
 		int err = 1;
 		if (walk->pte_hole)
-			err = walk->pte_hole(start, end, walk);
+			err = walk->pte_hole(start, end, -1, walk);
 		return err ? err : 1;
 	}
 	return 0;
-- 
2.20.1

