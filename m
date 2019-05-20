Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D62C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0519420449
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FjGICkkN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0519420449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1696B0006; Sun, 19 May 2019 23:53:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 892C26B0007; Sun, 19 May 2019 23:53:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75AAA6B0008; Sun, 19 May 2019 23:53:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38D156B0006
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u7so9013551pfh.17
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZGdumR7MSzBXsKYy6968BKcjiPMsnk7KDc5fqeBNwkM=;
        b=aV0dDdH/7ixP2clnVXk+TmlrA6EhIVLsLVQAl2z4ybyWBof582ZW/e9wtu+Q0J4z0b
         EiGzvTfzOp99xA1Pri8XFtQBDBF4JIkUFrTjGP/lnomYlmcGbMGx077nbKvCTzIbF/VX
         OH7RYbFDyDJAY5TXfRz3+9WeWmbKEO5InZEdkf7v1Eqi3MOyMIBjkhS0rlxWS5GYnat3
         6I3kKfYf1GF4QXyIq38g2iftJ1cz8C6+xdX11dGvADmQV5eFUDAcGxpMWt5paEeqCGOP
         g9bx3b7LXX/JKh4y3ZuY8p8cVNo4CoZ6oz10y7V0E0WnCeVf2csGcgB303IqUlUd0QA8
         xFfA==
X-Gm-Message-State: APjAAAXDl/f42p02YlG0pTLPpFlNU1ATp9Z6cmrhp1wiy+ZnK4tp6L7/
	QYA04o3FTLPS2ElPfcqX9PJa95r2iCuIkdiLSTovTJ4S8IK5Kxtftc7ds239qynZC4N6z3gykL3
	sb+tTipTLAHik+NN3nekooYhc1+ksVgfsW5MadmTZoUJjGiC1LYxEeavhlmNfYoY=
X-Received: by 2002:a62:ea04:: with SMTP id t4mr76318622pfh.47.1558324390773;
        Sun, 19 May 2019 20:53:10 -0700 (PDT)
X-Received: by 2002:a62:ea04:: with SMTP id t4mr76318516pfh.47.1558324389206;
        Sun, 19 May 2019 20:53:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324389; cv=none;
        d=google.com; s=arc-20160816;
        b=UdpklDB5VTM1Vc6grDHXK9Lwz/O6X1xY/7/g6hqKg+2VdEfYgPC3HsTeZLAXCx1kZn
         QIz2xBVWaXW+CreXQL42+pdDGfWE51MZUSNa9p6Ge9u+66nGi6j7fsBUIlARH+FMThk/
         3hw6lql1NSyTFJKOHs7X+DWTyheCRl1D7AlrXFzzTkMGKog8AkAgBLRD6uNb9Q5Kl1OQ
         CCkppmedpEhGE3ix9c/AIJ94hNvRcDDeGy1kuIwhvnCDVxA7zzno8NZAQcoEzewnxSqF
         c+xNhiZIEltqcjv+Z1foPFsGY5DsGXf/h3DJBLjuDaR4/4T6bDnRzNqMebvLpj8YDAmv
         A3Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=ZGdumR7MSzBXsKYy6968BKcjiPMsnk7KDc5fqeBNwkM=;
        b=CBcmCFO25BQZi/Sv0T18IHTZFitYQSjBOZSbRLdPmWcO/DLSAnZWEFK69qNoZ/5+gC
         Z3OxvT1GIxZ3JV2U4mZPlpqMRJk5B2o2JJDlFkJzSMrK5+l40kuk4cdEXT35iLrrxwWE
         W3IkXwKbM7CChw0/HSGEvut/nEd3hf8n7Y6ZqahjXNi09tgBg00J398/zcJ5eBREqouE
         QT6txHWKomO2x8EVZum0ImVzxJSocB/98+2OSBpBZhvStiLk9nt3ryksVxgzVATR8x5l
         2ye87WexPuuigDRUp3TaSzmXEiWWw5axK/80OXcQA2VIFKfTdkW5A6glFwrPwou77wDW
         dUfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FjGICkkN;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x11sor16313660pgx.46.2019.05.19.20.53.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FjGICkkN;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZGdumR7MSzBXsKYy6968BKcjiPMsnk7KDc5fqeBNwkM=;
        b=FjGICkkNAHPAt7KjG1vLE/V+sSXuxy882WftAOALleqtB/dYOU3CMCjIDgDwZYKgFU
         3sy/1I4Tp75glkroR9BwdxtajZxchrAJmNiQDzCIfBRONzD4Sk5A69HqaGIWkwYLTmDp
         4oNo3B6H9DMHdm5kk9sBlnxkIVCEkg41Xd95eUqKZB3s+zeI5iNSKMsjDZdzNO0/StUR
         r7zwG5UvA/9HfwRp7liBHENYgIFBJYPNdfGsk11RsencgCo9ZNFguk4rW67gKnMyjna/
         MPZwC1Mz5npPbiBs95cBHlk9Em9tqej29GDMZwX5u7S31Lee7ALKwxWK3cY3Tg5rlSzh
         V1AQ==
X-Google-Smtp-Source: APXvYqyqDckbd7dbntrF36htEawLZuZ75EEeBqGqTy7menXc3X+zgsp9IMF5ITbm+AhBQk09A6XOsA==
X-Received: by 2002:a63:7b1e:: with SMTP id w30mr67834911pgc.406.1558324388822;
        Sun, 19 May 2019 20:53:08 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.53.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:07 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/7] mm: introduce MADV_COOL
Date: Mon, 20 May 2019 12:52:48 +0900
Message-Id: <20190520035254.57579-2-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a process expects no accesses to a certain memory range
it could hint kernel that the pages can be reclaimed
when memory pressure happens but data should be preserved
for future use.  This could reduce workingset eviction so it
ends up increasing performance.

This patch introduces the new MADV_COOL hint to madvise(2)
syscall. MADV_COOL can be used by a process to mark a memory range
as not expected to be used in the near future. The hint can help
kernel in deciding which pages to evict early during memory
pressure.

Internally, it works via deactivating memory from active list to
inactive's head so when the memory pressure happens, they will be
reclaimed earlier than other active pages unless there is no
access until the time.

* v1r2
 * use clear_page_young in deactivate_page - joelaf

* v1r1
 * Revise the description - surenb
 * Renaming from MADV_WARM to MADV_COOL - surenb

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/page-flags.h             |   1 +
 include/linux/page_idle.h              |  15 ++++
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           | 112 +++++++++++++++++++++++++
 mm/swap.c                              |  43 ++++++++++
 6 files changed, 173 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..58b06654c8dd 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -424,6 +424,7 @@ static inline bool set_hwpoison_free_buddy_page(struct page *page)
 TESTPAGEFLAG(Young, young, PF_ANY)
 SETPAGEFLAG(Young, young, PF_ANY)
 TESTCLEARFLAG(Young, young, PF_ANY)
+CLEARPAGEFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
index 1e894d34bdce..f3f43b317150 100644
--- a/include/linux/page_idle.h
+++ b/include/linux/page_idle.h
@@ -19,6 +19,11 @@ static inline void set_page_young(struct page *page)
 	SetPageYoung(page);
 }
 
+static inline void clear_page_young(struct page *page)
+{
+	ClearPageYoung(page);
+}
+
 static inline bool test_and_clear_page_young(struct page *page)
 {
 	return TestClearPageYoung(page);
@@ -65,6 +70,16 @@ static inline void set_page_young(struct page *page)
 	set_bit(PAGE_EXT_YOUNG, &page_ext->flags);
 }
 
+static void clear_page_young(struct page *page)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+
+	if (unlikely(!page_ext))
+		return;
+
+	clear_bit(PAGE_EXT_YOUNG, &page_ext->flags);
+}
+
 static inline bool test_and_clear_page_young(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..64795abea003 100644
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
index abd238d0f7a4..f7a4a5d4b642 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -42,6 +42,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_COOL	5		/* deactivatie these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..c05817fb570d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -8,6 +8,7 @@
 
 #include <linux/mman.h>
 #include <linux/pagemap.h>
+#include <linux/page_idle.h>
 #include <linux/syscalls.h>
 #include <linux/mempolicy.h>
 #include <linux/page-isolation.h>
@@ -40,6 +41,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_COOL:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -307,6 +309,113 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	pte_t *orig_pte, *pte, ptent;
+	spinlock_t *ptl;
+	struct page *page;
+	struct vm_area_struct *vma = walk->vma;
+	unsigned long next;
+
+	next = pmd_addr_end(addr, end);
+	if (pmd_trans_huge(*pmd)) {
+		spinlock_t *ptl;
+
+		ptl = pmd_trans_huge_lock(pmd, vma);
+		if (!ptl)
+			return 0;
+
+		if (is_huge_zero_pmd(*pmd))
+			goto huge_unlock;
+
+		page = pmd_page(*pmd);
+		if (page_mapcount(page) > 1)
+			goto huge_unlock;
+
+		if (next - addr != HPAGE_PMD_SIZE) {
+			int err;
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
+		pmdp_test_and_clear_young(vma, addr, pmd);
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
+	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
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
+		if (page_mapcount(page) > 1)
+			continue;
+
+		ptep_test_and_clear_young(vma, addr, pte);
+		deactivate_page(page);
+	}
+
+	pte_unmap_unlock(orig_pte, ptl);
+	cond_resched();
+
+	return 0;
+}
+
+static void madvise_cool_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk cool_walk = {
+		.pmd_entry = madvise_cool_pte_range,
+		.mm = vma->vm_mm,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &cool_walk);
+	tlb_end_vma(tlb, vma);
+}
+
+static long madvise_cool(struct vm_area_struct *vma,
+			unsigned long start_addr, unsigned long end_addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+
+	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+		return -EINVAL;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
+	madvise_cool_page_range(&tlb, vma, start_addr, end_addr);
+	tlb_finish_mmu(&tlb, start_addr, end_addr);
+
+	return 0;
+}
+
 static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 
@@ -695,6 +804,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_COOL:
+		return madvise_cool(vma, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -716,6 +827,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_FREE:
+	case MADV_COOL:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/swap.c b/mm/swap.c
index 3a75722e68a9..0f94c3b5397d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -46,6 +46,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
@@ -537,6 +538,23 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
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
+		clear_page_young(page);
+		add_page_to_lru_list(page, lruvec, lru);
+
+		__count_vm_events(PGDEACTIVATE, hpage_nr_pages(page));
+		update_page_reclaim_stat(lruvec, file, 0);
+	}
+}
 
 static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
@@ -589,6 +607,10 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+
 	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
@@ -622,6 +644,26 @@ void deactivate_file_page(struct page *page)
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
@@ -686,6 +728,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
-- 
2.21.0.1020.gf2820cf01a-goog

