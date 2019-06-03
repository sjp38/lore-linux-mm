Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24024C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1DE424CB7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:37:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ufaZOuUq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1DE424CB7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E4F96B026B; Mon,  3 Jun 2019 01:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6939B6B026C; Mon,  3 Jun 2019 01:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55BBA6B026D; Mon,  3 Jun 2019 01:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17B466B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 01:37:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r12so12610266pfl.2
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 22:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QINx6pc+u7G6MZku2LRFGj1TYkzHOt+jmXPT4uDcbyI=;
        b=isiHovSs+L1Yi0OS5WopLVKTkMQHmMwXvM6opXdEBXv7+wvLYL9DEUTeIXMr3RMh6D
         LbEkY5JQf3ZDAFBu0WC3dFBbX195vEstCUD4rxJZz/4A5jYcWZ8Q/BFwVZx4c+LbzvpL
         0TMZT13z7wKu9hHZv3OjOhyv4Mdr72758eH0mLDBSZZKRg2ya2j/Hj9W2pUfCI9R7YHW
         NR6Tp/h3mU5Mqv3Db+VOlttgnXwnFUjpkOf7G4OP5hN2SqTsZRALl0I8qTVxDnd4sB4w
         9wSDNuT7cEpZ5CdhxgniuISE9JZn4RR2vS+ov/roa7Sbefp1RA8UtmGPAH515GOBKoBH
         3H5Q==
X-Gm-Message-State: APjAAAXs7cFdBqwuxpoJu/Q7cKAsX85SrvV/k467aTyvaVO3vWzqntCB
	DwDB43tSjpne7AyYsGa/pr+3AYR0tIR9Q08Wc0how202/3d/YW5BsQNPMmm53863Yaq4lMvs/xj
	wqdkAbvvRpcjauqGiPwHZWE0N8Jw6V97bziTX90HKgHL6qDHKZ8AIjLaFnyGSdgY=
X-Received: by 2002:a17:902:ba8c:: with SMTP id k12mr26460696pls.229.1559540236445;
        Sun, 02 Jun 2019 22:37:16 -0700 (PDT)
X-Received: by 2002:a17:902:ba8c:: with SMTP id k12mr26460644pls.229.1559540235095;
        Sun, 02 Jun 2019 22:37:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559540235; cv=none;
        d=google.com; s=arc-20160816;
        b=OUvcNFJNW730PivGG2pmAqh/MUrjZlcoy2/YhTMeUmRbnNknmxnDaHBTDC040VF2Ju
         cssVvTjGesBP/Y93oiGo7KIPxsM7ljRTNl98PJlgemHvuhgHpSqTB3W+CKGoy29cHmkX
         5PFAXJgr8yKXdsZ038cKFv7GTrAiS49Aa/1BhpLOpoH2j9i5X/U77FNWRyWv5MIIIMlx
         VQq7pP01aj8ttdrBCtGwkoPDRU/KqsadyOZdIAA34XsSPLGWFZVkj4Mt2ZU9/+0+Pr7E
         47yWpzThreTznLPvX7PMUYmRnHy1PZJjm5H5iU3okqMOT7hquFdelz5tIlspUfeZZanj
         IMsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=QINx6pc+u7G6MZku2LRFGj1TYkzHOt+jmXPT4uDcbyI=;
        b=gXNdpkrUy2W8GjxalCtWa9fw2BxdLz8w4zE3qL9EUgEZHq7r4onSvnAgdSAvT9b94Q
         7eWz3Owl3Bl5+bAQIRF1/9+ns+5gYizaFTLpcZGA3VsqkkKr5YhlaZ1zHF1YjzwubP08
         x1tFuXm/M0mDIylJU+2XIkA6DDcLd/GzjtLvL2KSXpNhPaSv5NeCr30MIvqtwPjXuX0x
         w5E9tzEp20jn4FivxQh4O1T2hbtqKmubjP82XfvYLH3e7VgNArhnYCiLC8raf/kyedas
         2sBcW6XOOQGgPXzNJ5MCXAFSpt4mF/oCFXBMHe0Cgi/MPJF9cGaFqJWrgnWzfv5Tn2+8
         pLhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ufaZOuUq;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor15731919plg.28.2019.06.02.22.37.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 22:37:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ufaZOuUq;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QINx6pc+u7G6MZku2LRFGj1TYkzHOt+jmXPT4uDcbyI=;
        b=ufaZOuUqMTgOmRUAaC8szMySjRN8xjP/S+UVtUe9i963vnxK8XV/H7BcR8d57rqIdT
         se4D2zRcp+51NYNxRmljaP/H0uxuy/TcEXdbWvPgB9i1oEMsaFK7hBRcFQCTUqvmB/sK
         DT1Q/z//tp5EEOOoFeVHdwRWYB7eRMVsqLYhXrBg1LeIUcOLJ5a/Ej9U569HOecFqyXB
         3GWnKFf+szY80jarHnJxI3RvXlRgQ9KEydsOVqeP5/BhkupHpvWTbsptOXzxCvnIC9K9
         GJsaDd89lCYPTC+7j2UJtTyapST5nG5ivbYYDQP6fAlLqtq47Tg1B+y2fcCr35XrTfQa
         FD0A==
X-Google-Smtp-Source: APXvYqydyq+MAblN2aWsCApQJrSKcDOSW1ecP2q+rxdQ2AiRWjcyp2qMg2i6j8P10fcHFgO5Vwq4cA==
X-Received: by 2002:a17:902:a415:: with SMTP id p21mr27724890plq.46.1559540234640;
        Sun, 02 Jun 2019 22:37:14 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a18sm5986222pjq.0.2019.06.02.22.37.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 22:37:13 -0700 (PDT)
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
	Brian Geffon <bgeffon@google.com>,
	jannh@google.com,
	oleg@redhat.com,
	christian@brauner.io,
	oleksandr@redhat.com,
	hdanton@sina.com,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 1/4] mm: introduce MADV_COLD
Date: Mon,  3 Jun 2019 14:36:52 +0900
Message-Id: <20190603053655.127730-2-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
In-Reply-To: <20190603053655.127730-1-minchan@kernel.org>
References: <20190603053655.127730-1-minchan@kernel.org>
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
files's head because MADV_COLD is a little bit different symantic.
MADV_FREE means it's okay to discard when the memory pressure because
the content of the page is *garbage* so freeing such pages is almost zero
overhead since we don't need to swap out and access afterward causes just
minor fault. Thus, it would make sense to put those freeable pages in
inactive file LRU to compete other used-once pages. Even, it could
give a bonus to make them be reclaimed on swapless system. However,
MADV_COLD doesn't mean garbage so reclaiming them requires swap-out/in
in the end. So it's better to move inactive anon's LRU list, not file LRU.
Furthermore, it would help to avoid unnecessary scanning of cold anonymous
if system doesn't have a swap device.

All of error rule is same with MADV_DONTNEED.

Note:
This hint works with only private pages(IOW, page_mapcount(page) < 2)
because shared page could have more chance to be accessed from other
processes sharing the page although the caller reset the reference bits.
It ends up preventing the reclaim of the page and wastes CPU cycle.

* RFCv2
 * add more description - mhocko

* RFCv1
 * renaming from MADV_COOL to MADV_COLD - hannes

* internal review
 * use clear_page_youn in deactivate_page - joelaf
 * Revise the description - surenb
 * Renaming from MADV_WARM to MADV_COOL - surenb

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/page-flags.h             |   1 +
 include/linux/page_idle.h              |  15 ++++
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/internal.h                          |   2 +-
 mm/madvise.c                           | 115 ++++++++++++++++++++++++-
 mm/oom_kill.c                          |   2 +-
 mm/swap.c                              |  43 +++++++++
 8 files changed, 176 insertions(+), 4 deletions(-)

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
index bea0278f65ab..1190f4e7f7b9 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -43,6 +43,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_COLD	5		/* deactivatie these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b95166..75a4f96ec0fb 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -43,7 +43,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
-static inline bool can_madv_dontneed_vma(struct vm_area_struct *vma)
+static inline bool can_madv_lru_vma(struct vm_area_struct *vma)
 {
 	return !(vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP));
 }
diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..ab158766858a 100644
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
@@ -307,6 +308,113 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
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
+static void madvise_cold_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk cool_walk = {
+		.pmd_entry = madvise_cold_pte_range,
+		.mm = vma->vm_mm,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &cool_walk);
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
 
@@ -519,7 +627,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 				  int behavior)
 {
 	*prev = vma;
-	if (!can_madv_dontneed_vma(vma))
+	if (!can_madv_lru_vma(vma))
 		return -EINVAL;
 
 	if (!userfaultfd_remove(vma, start, end)) {
@@ -541,7 +649,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 			 */
 			return -ENOMEM;
 		}
-		if (!can_madv_dontneed_vma(vma))
+		if (!can_madv_lru_vma(vma))
 			return -EINVAL;
 		if (end > vma->vm_end) {
 			/*
@@ -695,6 +803,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_COLD:
+		return madvise_cold(vma, prev, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -716,6 +826,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_FREE:
+	case MADV_COLD:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5a58778c91d4..f73d5f5145f0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -515,7 +515,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	set_bit(MMF_UNSTABLE, &mm->flags);
 
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
-		if (!can_madv_dontneed_vma(vma))
+		if (!can_madv_lru_vma(vma))
 			continue;
 
 		/*
diff --git a/mm/swap.c b/mm/swap.c
index 7b079976cbec..cebedab15aa2 100644
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
@@ -538,6 +539,23 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
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
@@ -590,6 +608,10 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+
 	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
@@ -623,6 +645,26 @@ void deactivate_file_page(struct page *page)
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
@@ -687,6 +729,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
-- 
2.22.0.rc1.311.g5d7573a151-goog

