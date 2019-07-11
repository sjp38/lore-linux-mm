Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A90DC74A3F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93FBA20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 01:25:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X88ZBsD0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93FBA20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 479F88E00A2; Wed, 10 Jul 2019 21:25:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 450DE8E0032; Wed, 10 Jul 2019 21:25:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33F658E00A2; Wed, 10 Jul 2019 21:25:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDCBF8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 21:25:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x19so2580135pgx.1
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 18:25:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uH/2a1IWmhYEwlkkogiHSOMffDjr5cK1rp2VKH1sPp4=;
        b=ZchbaPyC6xbZENgnVapIsKgnlyjaK46layCgT/9ZePqP/q/l5H1AUBJvh/9MzuAV6+
         mJo/H+s6Kg1sJtHO8Hak+dIoS87oFkk0XmVlSYHwe8U03i3f6B2TDeaqenne53lPVfWN
         MMJswxz0//Cx5ey+CRonB2DNaDRRLGETREohqXXcPIkLVWtEDapGdikSaQ4AyQlDvNdT
         QEBFovYJIwAaU+E69NNiES9a6jxz7UjKrG81JVZEzec0rUM4nX/DW69YLUbj/Y0k+562
         FgTFmiwXjeesoW0bTp02wiI/l7RQpS/Hg9HguEQj9h0llgH7wbfx547L7wzcdSphgeub
         Tglg==
X-Gm-Message-State: APjAAAUUiX8PcNGAY+0Ru4R8s9dNo+R2BtSBuNBkuxqUSgVSnfC3QGO0
	isRdxtRXQreCACNXgJzkfzFkkO58jMxd86J4lVCW8yllpHLHIkKeAAnTMroSmvD196GQT6v4UTN
	7gu2b8kk1WWzsudZ9h0cJXDoDjtTEo+NIbLkB8M1vvaRKwRytx2fyKgTkkYXXnv8=
X-Received: by 2002:a63:6c7:: with SMTP id 190mr1351396pgg.7.1562808347212;
        Wed, 10 Jul 2019 18:25:47 -0700 (PDT)
X-Received: by 2002:a63:6c7:: with SMTP id 190mr1351280pgg.7.1562808345559;
        Wed, 10 Jul 2019 18:25:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562808345; cv=none;
        d=google.com; s=arc-20160816;
        b=GQ1JFdREvA5TaOysRn8NPhXAEi+tNq6+jh6XEzYvZoX9HCjncAqSAGFPV9Amvc0t9X
         cSDVfZEB8Aek9PiyJlBxN2bIcD/oervE2mhTAR9nmvOnlcKSc9kNwrWRcVSulUUIcF1Z
         rqSQSt2anqBFNT14NimDngzDC5Sl+70CP0e13CycKQ083SZTZaWebl3789y+Rjqq51nT
         Zdtxj7FTCcC9WfvHNmLHH6xzwcVLWue5cu8fGVMRSjuWlLdFwsJn5yfLfRjY6c6P6G9C
         Af47YrGMQr+Hx94P7PiSXyzVq0tiEo9OU7Mv4yzExxG9XnfwGGESyfNRKd3ZU6giJJcH
         brJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=uH/2a1IWmhYEwlkkogiHSOMffDjr5cK1rp2VKH1sPp4=;
        b=FuBFMWZjh00+JG7r8W3m9o8Mll1vcRPrhojnC4JqPpfDQXKIGNjRzwo0t7++XfIkSa
         S9Osjai1SxbC9biPBOlaFTpGF6dbEbn1yrskTOBBaVM383NBlCfRIAdPjyBttLdVAIqt
         esRiPX+Bu6zukrDbl+Q2u3ioFMnYyiewpctZ33+8XIUv9usdbohWJPMC6ZhGX2Vohe98
         U623nCR6vAzPWdMEiQg/XJF/Q35PAEmd/iAAXjJ5xOx0eIFO1xGPn1dcXeQDSfp/5Typ
         jvm+yqZFo3fyIhaKGpVqVPT5nM8ZbnU+bBCHaEIBg/dinqCSDIqiCwTzxBOsRBX+uviy
         3Ycg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X88ZBsD0;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r39sor4825284pld.65.2019.07.10.18.25.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 18:25:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X88ZBsD0;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uH/2a1IWmhYEwlkkogiHSOMffDjr5cK1rp2VKH1sPp4=;
        b=X88ZBsD0jq0bf1bYfcqSvVQ1p/zehAHMMcznAlBZE1SlzCtE/wQrzLL3zf5ZYTAMu6
         iBH0y0J3pzMF8+4ML0tjnck7WZtZkW+vJC4coQEbB2o4Zza8wcr6hmxmIndWypPFPrXT
         zxWKwtclbbPYTQyYRANAOuX41JjahnJdnnPFKXi7KNPlDJ7MOhIXSt+gJ5wXEhVXTUNr
         h01S23O2PUBufNhin26O/k3ZccM253hqDxXqPueVKHD0KKgKbpP5Opx61w0J5ZLZDZyb
         8WAlk0IjIxn8RiZOjXMWOoQqTsCZ34ErLRYBRHsNP/yRDd7OoCJUTQ3t7bsL05dwsW54
         iahQ==
X-Google-Smtp-Source: APXvYqx6N1FnZSIJRo4I9fW4v84QLEfJhNB9VYcHN6wMx8JA9f3ruXcxGHT8xKoQ0eayrFlDO9gI+Q==
X-Received: by 2002:a17:902:9f8e:: with SMTP id g14mr1430817plq.67.1562808345065;
        Wed, 10 Jul 2019 18:25:45 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id b37sm10031974pjc.15.2019.07.10.18.25.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 18:25:43 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 1/4] mm: introduce MADV_COLD
Date: Thu, 11 Jul 2019 10:25:25 +0900
Message-Id: <20190711012528.176050-2-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190711012528.176050-1-minchan@kernel.org>
References: <20190711012528.176050-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a process expects no accesses to a certain memory range, it could
give a hint to kernel that the pages can be reclaimed when memory pressure
happens but data should be preserved for future use.  This could reduce
workingset eviction so it ends up increasing performance.

This patch introduces the new MADV_COLD hint to madvise(2) syscall.
MADV_COLD can be used by a process to mark a memory range as not expected
to be used in the near future. The hint can help kernel in deciding which
pages to evict early during memory pressure.

It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves

	active file page -> inactive file LRU
	active anon page -> inacdtive anon LRU

Unlike MADV_FREE, it doesn't move active anonymous pages to inactive
file LRU's head because MADV_COLD is a little bit different symantic.
MADV_FREE means it's okay to discard when the memory pressure because
the content of the page is *garbage* so freeing such pages is almost zero
overhead since we don't need to swap out and access afterward causes just
minor fault. Thus, it would make sense to put those freeable pages in
inactive file LRU to compete other used-once pages. It makes sense for
implmentaion point of view, too because it's not swapbacked memory any
longer until it would be re-dirtied. Even, it could give a bonus to make
them be reclaimed on swapless system. However, MADV_COLD doesn't mean
garbage so reclaiming them requires swap-out/in in the end so it's bigger
cost. Since we have designed VM LRU aging based on cost-model, anonymous
cold pages would be better to position inactive anon's LRU list, not file
LRU. Furthermore, it would help to avoid unnecessary scanning if system
doesn't have a swap device. Let's start simpler way without adding
complexity at this moment. However, keep in mind, too that it's a caveat
that workloads with a lot of pages cache are likely to ignore MADV_COLD
on anonymous memory because we rarely age anonymous LRU lists.

* man-page material

MADV_COLD (since Linux x.x)

Pages in the specified regions will be treated as less-recently-accessed
compared to pages in the system with similar access frequencies.
In contrast to MADV_FREE, the contents of the region are preserved
regardless of subsequent writes to pages.

MADV_COLD cannot be applied to locked pages, Huge TLB pages, or VM_PFNMAP
pages.

* v2
 * add up the warn with lots of page cache workload - mhocko
 * add man page stuff - dave

* v1
 * remove page_mapcount filter - hannes, mhocko
 * remove idle page handling - joelaf

* RFCv2
 * add more description - mhocko

* RFCv1
 * renaming from MADV_COOL to MADV_COLD - hannes

* internal review
 * use clear_page_youn in deactivate_page - joelaf
 * Revise the description - surenb
 * Renaming from MADV_WARM to MADV_COOL - surenb

Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/internal.h                          |   2 +-
 mm/madvise.c                           | 180 ++++++++++++++++++++++++-
 mm/oom_kill.c                          |   2 +-
 mm/swap.c                              |  42 ++++++
 6 files changed, 224 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index de2c67a33b7e..0ce997edb8bb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -340,6 +340,7 @@ extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
+extern void deactivate_page(struct page *page);
 extern void mark_page_lazyfree(struct page *page);
 extern void swap_setup(void);
 
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 63b1f506ea67..ef8a56927b12 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -45,6 +45,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_COLD	5		/* deactivatie these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/internal.h b/mm/internal.h
index f53a14d67538..c61b215ff265 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -39,7 +39,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
-static inline bool can_madv_dontneed_vma(struct vm_area_struct *vma)
+static inline bool can_madv_lru_vma(struct vm_area_struct *vma)
 {
 	return !(vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP));
 }
diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..bae0055f9724 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -40,6 +40,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_COLD:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -307,6 +308,178 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	struct mmu_gather *tlb = walk->private;
+	struct mm_struct *mm = tlb->mm;
+	struct vm_area_struct *vma = walk->vma;
+	pte_t *orig_pte, *pte, ptent;
+	spinlock_t *ptl;
+	struct page *page;
+	unsigned long next;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd)) {
+		pmd_t orig_pmd;
+
+		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
+		ptl = pmd_trans_huge_lock(pmd, vma);
+		if (!ptl)
+			return 0;
+
+		orig_pmd = *pmd;
+		if (is_huge_zero_pmd(orig_pmd))
+			goto huge_unlock;
+
+		if (unlikely(!pmd_present(orig_pmd))) {
+			VM_BUG_ON(thp_migration_supported() &&
+					!is_pmd_migration_entry(orig_pmd));
+			goto huge_unlock;
+		}
+
+		page = pmd_page(orig_pmd);
+		if (next - addr != HPAGE_PMD_SIZE) {
+			int err;
+
+			if (page_mapcount(page) != 1)
+				goto huge_unlock;
+
+			get_page(page);
+			spin_unlock(ptl);
+			lock_page(page);
+			err = split_huge_page(page);
+			unlock_page(page);
+			put_page(page);
+			if (!err)
+				goto regular_page;
+			return 0;
+		}
+
+		if (pmd_young(orig_pmd)) {
+			pmdp_invalidate(vma, addr, pmd);
+			orig_pmd = pmd_mkold(orig_pmd);
+
+			set_pmd_at(mm, addr, pmd, orig_pmd);
+			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+		}
+
+		test_and_clear_page_young(page);
+		deactivate_page(page);
+huge_unlock:
+		spin_unlock(ptl);
+		return 0;
+	}
+
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+regular_page:
+	tlb_change_page_size(tlb, PAGE_SIZE);
+	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	flush_tlb_batched_pending(mm);
+	arch_enter_lazy_mmu_mode();
+	for (; addr < end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+
+		if (pte_none(ptent))
+			continue;
+
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		/*
+		 * Creating a THP page is expensive so split it only if we
+		 * are sure it's worth. Split it if we are only owner.
+		 */
+		if (PageTransCompound(page)) {
+			if (page_mapcount(page) != 1)
+				break;
+			get_page(page);
+			if (!trylock_page(page)) {
+				put_page(page);
+				break;
+			}
+			pte_unmap_unlock(orig_pte, ptl);
+			if (split_huge_page(page)) {
+				unlock_page(page);
+				put_page(page);
+				pte_offset_map_lock(mm, pmd, addr, &ptl);
+				break;
+			}
+			unlock_page(page);
+			put_page(page);
+			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+			pte--;
+			addr -= PAGE_SIZE;
+			continue;
+		}
+
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+
+		if (pte_young(ptent)) {
+			ptent = ptep_get_and_clear_full(mm, addr, pte,
+							tlb->fullmm);
+			ptent = pte_mkold(ptent);
+			set_pte_at(mm, addr, pte, ptent);
+			tlb_remove_tlb_entry(tlb, pte, addr);
+		}
+
+		/*
+		 * We are deactivating a page for accelerating reclaiming.
+		 * VM couldn't reclaim the page unless we clear PG_young.
+		 * As a side effect, it makes confuse idle-page tracking
+		 * because they will miss recent referenced history.
+		 */
+		test_and_clear_page_young(page);
+		deactivate_page(page);
+	}
+
+	arch_enter_lazy_mmu_mode();
+	pte_unmap_unlock(orig_pte, ptl);
+	cond_resched();
+
+	return 0;
+}
+
+static void madvise_cold_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk cold_walk = {
+		.pmd_entry = madvise_cold_pte_range,
+		.mm = vma->vm_mm,
+		.private = tlb,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &cold_walk);
+	tlb_end_vma(tlb, vma);
+}
+
+static long madvise_cold(struct vm_area_struct *vma,
+			struct vm_area_struct **prev,
+			unsigned long start_addr, unsigned long end_addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+
+	*prev = vma;
+	if (!can_madv_lru_vma(vma))
+		return -EINVAL;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
+	madvise_cold_page_range(&tlb, vma, start_addr, end_addr);
+	tlb_finish_mmu(&tlb, start_addr, end_addr);
+
+	return 0;
+}
+
 static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 
@@ -519,7 +692,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 				  int behavior)
 {
 	*prev = vma;
-	if (!can_madv_dontneed_vma(vma))
+	if (!can_madv_lru_vma(vma))
 		return -EINVAL;
 
 	if (!userfaultfd_remove(vma, start, end)) {
@@ -541,7 +714,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 			 */
 			return -ENOMEM;
 		}
-		if (!can_madv_dontneed_vma(vma))
+		if (!can_madv_lru_vma(vma))
 			return -EINVAL;
 		if (end > vma->vm_end) {
 			/*
@@ -695,6 +868,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_COLD:
+		return madvise_cold(vma, prev, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -716,6 +891,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_FREE:
+	case MADV_COLD:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 95872bdfec4e..c8f0ec6b0e80 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -523,7 +523,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
-		if (!can_madv_dontneed_vma(vma))
+		if (!can_madv_lru_vma(vma))
 			continue;
 
 		/*
diff --git a/mm/swap.c b/mm/swap.c
index 55899c1f54af..b501ad6eb091 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -47,6 +47,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
@@ -538,6 +539,22 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 	update_page_reclaim_stat(lruvec, file, 0);
 }
 
+static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+			    void *arg)
+{
+	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
+		int file = page_is_file_cache(page);
+		int lru = page_lru_base_type(page);
+
+		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
+		ClearPageActive(page);
+		ClearPageReferenced(page);
+		add_page_to_lru_list(page, lruvec, lru);
+
+		__count_vm_events(PGDEACTIVATE, hpage_nr_pages(page));
+		update_page_reclaim_stat(lruvec, file, 0);
+	}
+}
 
 static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
@@ -590,6 +607,10 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+
 	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
@@ -623,6 +644,26 @@ void deactivate_file_page(struct page *page)
 	}
 }
 
+/*
+ * deactivate_page - deactivate a page
+ * @page: page to deactivate
+ *
+ * deactivate_page() moves @page to the inactive list if @page was on the active
+ * list and was not an unevictable page.  This is done to accelerate the reclaim
+ * of @page.
+ */
+void deactivate_page(struct page *page)
+{
+	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+
+		get_page(page);
+		if (!pagevec_add(pvec, page) || PageCompound(page))
+			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		put_cpu_var(lru_deactivate_pvecs);
+	}
+}
+
 /**
  * mark_page_lazyfree - make an anon page lazyfree
  * @page: page to deactivate
@@ -687,6 +728,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
-- 
2.22.0.410.gd8fdbe21b5-goog

