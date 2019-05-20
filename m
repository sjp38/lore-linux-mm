Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B885C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5247720449
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t2f8Wzza"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5247720449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F236C6B0008; Sun, 19 May 2019 23:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED3AB6B000A; Sun, 19 May 2019 23:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9D286B000C; Sun, 19 May 2019 23:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0BDD6B0008
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so4181624pfn.6
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+ky+Sp7MhEB6EVoatOc2laxLncqWcKPthCrhwamx588=;
        b=kjRTKKvNTPHCZ5rMF0nWxvMYWHosgTKE2DGkwbo/m/hcKf/ZkV/7i19Y/wvhjOZuyT
         9FIZw/Asc3b0G1yAMZNyhRvk6pjZUdWsFupCzHCQ2OewbSA4LPlu+ClMk7f0eScrCTE4
         jCOn87HLg/HsMtrr2FdMxdgiRcX9gOx0LCdqEfGjxzQvgsFUmH4pN78L9fLzsJYcqG7V
         +BWQ2mRNGa++sKDV5itVSGAYsKfMZdMImIb+YyO6gDFaAwCfs1AAPkGcQMvj7OLVcP9/
         RPtWppjVPVYvOE1gKQ+IksYPp73aA9fLcZEglAi0FjNLd17u1MY/7bnWiOSVxu2U9xkf
         qktA==
X-Gm-Message-State: APjAAAUhKwXajTqrtNxP+7B/AZetbynj6K1rWknkssYhB5SKLjQB6k/I
	xChzdL28Ipa5vOwQgGYquI1cNeqhtddC/tBePb1h1dzO73NDRlKNGWe3ZSdBqABouWPeJrLardd
	R0O7V2z6RJwb31xX8jVKwzRHjiA6Hk+ECmpF2Nh2I0lcmzXbV0UuzSlR1JsKC4fc=
X-Received: by 2002:a63:c14:: with SMTP id b20mr72496670pgl.163.1558324399290;
        Sun, 19 May 2019 20:53:19 -0700 (PDT)
X-Received: by 2002:a63:c14:: with SMTP id b20mr72496588pgl.163.1558324398150;
        Sun, 19 May 2019 20:53:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324398; cv=none;
        d=google.com; s=arc-20160816;
        b=tvVvegr/4TnkCDFz3K/y5Phlwu0vAbxfABoML71E2HhOHA0rcBeei/8cIH6st9k6Jq
         gVruvy8EOtJFo/tuOMZvF4gmjcHFEpM/Ji0H0Q9K3UriMHdpwRfoMXs3yzbMNTitB3ZH
         NMfUlfEaRa7vv267/ivADgk2T4YLYeh48+EWz6i27Iw/p4+j5iu2lIqb7f1az2aqTP45
         jndDHcr+nCwzDFqdjwi+enQwOX4XaxTNkzVQhPywBagP9aga18MIrPUO10pwCLJdJ5Me
         mrRB38ppv7cAYqLZ2Mjdh5H3IKut0ynmALg65GX/6yYrl/vihThdDq/DR1LkJhtGhEMi
         aKLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=+ky+Sp7MhEB6EVoatOc2laxLncqWcKPthCrhwamx588=;
        b=XUSg6nq7c4yjJAjuBp7q+ZVPZiIAndjnjCcf24KkWsIuuxnRKaPbfPsa1Ag8veB4Fh
         x6/y+r6Z3V9sJe+iZ0WnKRgHd+vCdS4+U+RefRXJX+9p+0yEXOnTGk1nETXM1F1U7R/k
         4w0fxmRERkXRfglb6plgvMGLIykqEHEeDos8xRIyPybta0M6kjUyekpswlSKDO7AZSXJ
         OxVZU4HGYifGqTJsS23UWI2dL8KZpgKdrYddT5d9wiXcZeXktcya+KwBLw9bM3T3UT1F
         NKJyX3oy3nVeWxZdI8q3IFeNsXLgjqOXAn3JE+7borDVqcn8Jx0bu/MXXWanInZ14VJG
         VIhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t2f8Wzza;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 78sor16509067pgb.30.2019.05.19.20.53.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t2f8Wzza;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=+ky+Sp7MhEB6EVoatOc2laxLncqWcKPthCrhwamx588=;
        b=t2f8WzzaADAETNhuYxhAeKtM/AHj0gzF4ATQn35I6pm9JPzSen+jglx4e4pZ5fhTwU
         yfl9in1HjDniapwXdxLyTS0ZiCttr/UomYlRYsPCC8JOpISY3vsZhbsyFNnG12Pup8mF
         1EN8H/bhHAbAcKQnL9RTvd7gosK4ZvyIA0nLBhxvSY5SbH+CBcHzMo5VFmQ1LkcUT9S5
         L7AbHVKJvY9bgH+SYi+OK1krwIAN0PjhZDZw5tHxl7mxx9GOZPdWIsczCdPmrDdaQsPe
         aYDc3I3sTfuGtZ+4lUU/zpLoiEIBNE6G5dH/2HVLc4cFyx0rjfs7E5tvAU0USZmN4cRX
         fOag==
X-Google-Smtp-Source: APXvYqzoHwcC2b/fGoVNKZk6bvd4p0rDW0BF5P0YqY4DqaB1uH9QaANxyS77XhPl27ae5RPUynAF4A==
X-Received: by 2002:a65:6648:: with SMTP id z8mr23825282pgv.303.1558324397745;
        Sun, 19 May 2019 20:53:17 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.53.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:16 -0700 (PDT)
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
Subject: [RFC 3/7] mm: introduce MADV_COLD
Date: Mon, 20 May 2019 12:52:50 +0900
Message-Id: <20190520035254.57579-4-minchan@kernel.org>
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
for a long time, it could hint kernel that the pages can be
reclaimed instantly but data should be preserved for future use.
This could reduce workingset eviction so it ends up increasing
performance.

This patch introduces the new MADV_COLD hint to madvise(2)
syscall. MADV_COLD can be used by a process to mark a memory range
as not expected to be used for a long time. The hint can help
kernel in deciding which pages to evict proactively.

Internally, it works via reclaiming memory in process context
the syscall is called. If the page is dirty but backing storage
is not synchronous device, the written page will be rotate back
into LRU's tail once the write is done so they will reclaim easily
when memory pressure happens. If backing storage is
synchrnous device(e.g., zram), hte page will be reclaimed instantly.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           | 123 +++++++++++++++++++++++++
 mm/vmscan.c                            |  74 +++++++++++++++
 4 files changed, 199 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 64795abea003..7f32a948fc6a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -365,6 +365,7 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
+extern unsigned long reclaim_pages(struct list_head *page_list);
 #ifdef CONFIG_NUMA
 extern int node_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index f7a4a5d4b642..b9b51eeb8e1a 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -43,6 +43,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
 #define MADV_COOL	5		/* deactivatie these pages */
+#define MADV_COLD	6		/* reclaim these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/madvise.c b/mm/madvise.c
index c05817fb570d..9a6698b56845 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -42,6 +42,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_COOL:
+	case MADV_COLD:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -416,6 +417,125 @@ static long madvise_cool(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	pte_t *orig_pte, *pte, ptent;
+	spinlock_t *ptl;
+	LIST_HEAD(page_list);
+	struct page *page;
+	int isolated = 0;
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
+		if (isolate_lru_page(page))
+			goto huge_unlock;
+
+		list_add(&page->lru, &page_list);
+huge_unlock:
+		spin_unlock(ptl);
+		reclaim_pages(&page_list);
+		return 0;
+	}
+
+	if (pmd_trans_unstable(pmd))
+		return 0;
+regular_page:
+	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
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
+		if (isolate_lru_page(page))
+			continue;
+
+		isolated++;
+		list_add(&page->lru, &page_list);
+		if (isolated >= SWAP_CLUSTER_MAX) {
+			pte_unmap_unlock(orig_pte, ptl);
+			reclaim_pages(&page_list);
+			isolated = 0;
+			pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+			orig_pte = pte;
+		}
+	}
+
+	pte_unmap_unlock(orig_pte, ptl);
+	reclaim_pages(&page_list);
+	cond_resched();
+
+	return 0;
+}
+
+static void madvise_cold_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk warm_walk = {
+		.pmd_entry = madvise_cold_pte_range,
+		.mm = vma->vm_mm,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &warm_walk);
+	tlb_end_vma(tlb, vma);
+}
+
+
+static long madvise_cold(struct vm_area_struct *vma,
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
+	madvise_cold_page_range(&tlb, vma, start_addr, end_addr);
+	tlb_finish_mmu(&tlb, start_addr, end_addr);
+
+	return 0;
+}
+
 static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 
@@ -806,6 +926,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_COOL:
 		return madvise_cool(vma, start, end);
+	case MADV_COLD:
+		return madvise_cold(vma, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -828,6 +950,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_DONTNEED:
 	case MADV_FREE:
 	case MADV_COOL:
+	case MADV_COLD:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a28e5d17b495..1701b31f70a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2096,6 +2096,80 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }
 
+unsigned long reclaim_pages(struct list_head *page_list)
+{
+	int nid = -1;
+	unsigned long nr_isolated[2] = {0, };
+	unsigned long nr_reclaimed = 0;
+	LIST_HEAD(node_page_list);
+	struct reclaim_stat dummy_stat;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_writepage = 1,
+		.may_unmap = 1,
+		.may_swap = 1,
+	};
+
+	while (!list_empty(page_list)) {
+		struct page *page;
+
+		page = lru_to_page(page_list);
+		list_del(&page->lru);
+
+		if (nid == -1) {
+			nid = page_to_nid(page);
+			INIT_LIST_HEAD(&node_page_list);
+			nr_isolated[0] = nr_isolated[1] = 0;
+		}
+
+		if (nid == page_to_nid(page)) {
+			list_add(&page->lru, &node_page_list);
+			nr_isolated[!!page_is_file_cache(page)] +=
+						hpage_nr_pages(page);
+			continue;
+		}
+
+		nid = page_to_nid(page);
+
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
+					nr_isolated[0]);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
+					nr_isolated[1]);
+		nr_reclaimed += shrink_page_list(&node_page_list,
+				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
+				&dummy_stat, true);
+		while (!list_empty(&node_page_list)) {
+			struct page *page = lru_to_page(page_list);
+
+			list_del(&page->lru);
+			putback_lru_page(page);
+		}
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
+					-nr_isolated[0]);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
+					-nr_isolated[1]);
+		nr_isolated[0] = nr_isolated[1] = 0;
+		INIT_LIST_HEAD(&node_page_list);
+	}
+
+	if (!list_empty(&node_page_list)) {
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
+					nr_isolated[0]);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
+					nr_isolated[1]);
+		nr_reclaimed += shrink_page_list(&node_page_list,
+				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
+				&dummy_stat, true);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
+					-nr_isolated[0]);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
+					-nr_isolated[1]);
+	}
+
+	return nr_reclaimed;
+}
+
 /*
  * The inactive anon list should be small enough that the VM never has
  * to do too much work.
-- 
2.21.0.1020.gf2820cf01a-goog

