Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DC7FC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:43:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C395264BD
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:43:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kuACxbXH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C395264BD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3E4E6B027A; Fri, 31 May 2019 02:43:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC86A6B027C; Fri, 31 May 2019 02:43:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B698C6B027E; Fri, 31 May 2019 02:43:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6046B027A
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:43:42 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z10so4045279pgf.15
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G+TrQWebb1OQqIMsOPBwXOFrxSHqKpw5UQ00aCYRV6U=;
        b=dX10TIFBzFiOL0yxDdc0929tUiKXiza1mO44G/N0beC2adiJA3TePRUEvQn/9zEh9w
         VnngCJyLyNB3dIPddo7ZbQu1kfaG1Xfut4L1d3j2g7GjKFUJyh2PNzdbby2QZ93KPI/c
         uItCfx+4CBU1oKopUBq31GbajBq5SzhQBTgAu+oeB5J89WC7du+czcqTHRnRt723tTG7
         jVlRHlmX0SNmlGf0Mvtl8J1LOcpnhPdUWA4V5mk/5O9LQpRCkg/RJ+iaI5EvU7XjPqq2
         cYsZGAuUn+pVHI8ggT1ApDo0VmfxA2QAQBsDrMu9U+rks7SNYPg1Yt4lSwc3Si4IB2SV
         fcSA==
X-Gm-Message-State: APjAAAV8NobSEwIC4ImNsp9yo/1lATp2MThP2eSOM3mnbLvGpbXHvtHu
	vE5ui05ky7uwHpo/c4cgrP3WBP0hLPnvCPI7dkM5cszbnfQTJSwb4f+4WKmJhuhyhzdONa7uD34
	BXCJ3gEU6NvyPbC+NEkDKv0TA+GdZ2weGTO6LLwTalOnhePrJBR1JPkL0JQpMaFc=
X-Received: by 2002:a62:7e8d:: with SMTP id z135mr7669950pfc.260.1559285022067;
        Thu, 30 May 2019 23:43:42 -0700 (PDT)
X-Received: by 2002:a62:7e8d:: with SMTP id z135mr7669917pfc.260.1559285021166;
        Thu, 30 May 2019 23:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559285021; cv=none;
        d=google.com; s=arc-20160816;
        b=MJBe4SfGz/zuwFmsi/rePreLcKcCs4maklqP7YPJonY4FmBSq4WIAWRpY4r53nYszv
         BlBgNqLd0EiFianFZ/h65jSDgDo3GjU48ub51yI+oMBOF0FjAmZVcrVa1j91VJSAjWVf
         kYEGB1hWSMnc6gd9kW3uDdE4CGsQ/D0YNh3Eot167N6HKYMoxM9bLx+mXuPaB+dtSDv7
         9TZPk6W3T/zD/dFVhdNWyUizMQ31tmwUAkoleVpc3iOUDuWrx1iIIjxc6S+Dwwum2Aqv
         6Pxy+wMiVEZu7dGaD9k2etiZelim9CZFpaCbtLJa+15x2xSIhE2aV8JHUXifSgq4xTry
         lvsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=G+TrQWebb1OQqIMsOPBwXOFrxSHqKpw5UQ00aCYRV6U=;
        b=SLkG7OdnVD3+gWxat9dwuJXSz6dRWOA7d58W0NjJWIxSsshNG5OCH9kqSXPDVhxIYX
         HrrDVgITZrJITd3nhKobz04hkN3q6N15YawcQpBdyPIOQs3vUClsb0m4JgqAzb3TF0qk
         y8FDd+BZnSpZQ36XKFI5QNrIoyu8a0vBSBemO/W8MfxcsKg0cuwYrYUhdQnMq2ukE4qn
         rTyI+iQYk/Q8XKl898VGdJBUe6N5RZpHABo7Fei3uoh4781iHvgnLyVpGurf/eXelG4Q
         R/6ysXn8G9U0jhqObsLEe0xoniG/zoNlIea1DYLl7uoA3Y7Hw+SbMToct70/MgRx5bf0
         IYNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kuACxbXH;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor5553044plh.19.2019.05.30.23.43.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 23:43:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kuACxbXH;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=G+TrQWebb1OQqIMsOPBwXOFrxSHqKpw5UQ00aCYRV6U=;
        b=kuACxbXH+9FoOl8y32mUGUSFvG3BNUwt7h4d8u+U1DMvt0f0dWSJxfj0SIY9/t3bGB
         J6Xc51DsKnBPFaE4WbaMPk1mAgGh7Uoe9JiYM5kmLCvZOUS/NwOpzEGLN1TVUAciqAZY
         j/MFHhAydSn2PLOj6PmQ59xb5YmVCJTGYCNMeiLopGArg/Hc3cTHxmLOuBW3cOKVHjYN
         Gudc1YJevZoVh/8NVigzrpCmlDHGNfTao83N+IApxFs1dKuDmEDuGtiQ1ARmSLXeRDrW
         Wxg+6NIRSZuT02jPArGbPPUbPMYXC7btU9n1KVReG/mzKU5L1n9Tq0Uc4NCQvXJGkqRQ
         8SRg==
X-Google-Smtp-Source: APXvYqwAhOWjoSgAiirZU4CO+Y4FLGljQXQatDXZpfewPZcwELP4PX2gZp7hdg8bFpts+exduLmpIQ==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr7376613plb.334.1559285020728;
        Thu, 30 May 2019 23:43:40 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f30sm4243340pjg.13.2019.05.30.23.43.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:43:39 -0700 (PDT)
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
Subject: [RFCv2 3/6] mm: introduce MADV_PAGEOUT
Date: Fri, 31 May 2019 15:43:10 +0900
Message-Id: <20190531064313.193437-4-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc1.257.g3120a18244-goog
In-Reply-To: <20190531064313.193437-1-minchan@kernel.org>
References: <20190531064313.193437-1-minchan@kernel.org>
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

This patch introduces the new MADV_PAGEOUT hint to madvise(2)
syscall. MADV_PAGEOUT can be used by a process to mark a memory
range as not expected to be used for a long time so that kernel
reclaims the memory instantly. The hint can help kernel in deciding
which pages to evict proactively.

* RFCv1
 * rename from MADV_COLD to MADV_PAGEOUT - hannes
 * bail out if process is being killed - Hillf
 * fix reclaim_pages bugs - Hillf

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           | 126 +++++++++++++++++++++++++
 mm/vmscan.c                            |  77 +++++++++++++++
 4 files changed, 205 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 0ce997edb8bb..063c0c1e112b 100644
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
index 1190f4e7f7b9..92e347a89ddc 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -44,6 +44,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
 #define MADV_COLD	5		/* deactivatie these pages */
+#define MADV_PAGEOUT	6		/* reclaim these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/madvise.c b/mm/madvise.c
index bff150eab6da..9d749a1420b4 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -41,6 +41,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_COLD:
+	case MADV_PAGEOUT:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -415,6 +416,128 @@ static long madvise_cold(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
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
+	if (fatal_signal_pending(current))
+		return -EINTR;
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
+static void madvise_pageout_page_range(struct mmu_gather *tlb,
+			     struct vm_area_struct *vma,
+			     unsigned long addr, unsigned long end)
+{
+	struct mm_walk warm_walk = {
+		.pmd_entry = madvise_pageout_pte_range,
+		.mm = vma->vm_mm,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &warm_walk);
+	tlb_end_vma(tlb, vma);
+}
+
+
+static long madvise_pageout(struct vm_area_struct *vma,
+			struct vm_area_struct **prev,
+			unsigned long start_addr, unsigned long end_addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct mmu_gather tlb;
+
+	*prev = vma;
+	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+		return -EINVAL;
+
+	lru_add_drain();
+	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
+	madvise_pageout_page_range(&tlb, vma, start_addr, end_addr);
+	tlb_finish_mmu(&tlb, start_addr, end_addr);
+
+	return 0;
+}
+
 static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 
@@ -805,6 +928,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_COLD:
 		return madvise_cold(vma, prev, start, end);
+	case MADV_PAGEOUT:
+		return madvise_pageout(vma, prev, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -827,6 +952,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_DONTNEED:
 	case MADV_FREE:
 	case MADV_COLD:
+	case MADV_PAGEOUT:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0973a46a0472..280dd808fb91 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2126,6 +2126,83 @@ static void shrink_active_list(unsigned long nr_to_scan,
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
+		if (nid == -1) {
+			nid = page_to_nid(page);
+			INIT_LIST_HEAD(&node_page_list);
+			nr_isolated[0] = nr_isolated[1] = 0;
+		}
+
+		if (nid == page_to_nid(page)) {
+			list_move(&page->lru, &node_page_list);
+			nr_isolated[!!page_is_file_cache(page)] +=
+						hpage_nr_pages(page);
+			continue;
+		}
+
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
+					nr_isolated[0]);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
+					nr_isolated[1]);
+		nr_reclaimed += shrink_page_list(&node_page_list,
+				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
+				&dummy_stat, true);
+		while (!list_empty(&node_page_list)) {
+			struct page *page = lru_to_page(&node_page_list);
+
+			list_del(&page->lru);
+			putback_lru_page(page);
+		}
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
+					-nr_isolated[0]);
+		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
+					-nr_isolated[1]);
+		nid = -1;
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
+
+		while (!list_empty(&node_page_list)) {
+			struct page *page = lru_to_page(&node_page_list);
+
+			list_del(&page->lru);
+			putback_lru_page(page);
+		}
+
+	}
+
+	return nr_reclaimed;
+}
+
 /*
  * The inactive anon list should be small enough that the VM never has
  * to do too much work.
-- 
2.22.0.rc1.257.g3120a18244-goog

