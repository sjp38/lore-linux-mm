Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D771FC28D16
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:37:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A180258CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 05:37:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RxlmGxFF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A180258CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F20DB6B026E; Mon,  3 Jun 2019 01:37:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF7976B026F; Mon,  3 Jun 2019 01:37:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE7D26B0270; Mon,  3 Jun 2019 01:37:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A66BE6B026E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 01:37:32 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w31so1635861pgk.23
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 22:37:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VaNSbzaDg92x8qknqbR2PMhHNKJQW/ZUsMPGiA5Uvg8=;
        b=WJ7IbSUkepf+5FvV0A1Ot0LjDHc8S/smOBxL6YHNpqT1jBXqDRwvoCB4rYrdqDlf/F
         LlCzbE6+MYycpVp/MuSPALiv5n4L16u51HXqD8HWzkgfZSK59PAfLmt5mzME54nlL7Ds
         68xBoKZLfqwOvZTEQVIs5VWVgZNkuBQOWxU2w7/pa84tsPQv001/B/iAq5gYhFKXdFn/
         y6QEER5W4u004XhvG93RC0cFLhjjBGGFqJj8Re9yNgGrbLtCXTr2kxJH9Me70NkxqXVX
         xMI2YJMf3B5v0u/DKP6YbQpZWK3QK1dt9EyI+58UzzL45z/nTQByKVJ+r3QyfrojaIXh
         ZrfQ==
X-Gm-Message-State: APjAAAW0o/YRf1iWLxnNSFqnljBYQV7zXPWkxCtbrE/TJJ+kDNz+NmE3
	i0/2cvr7YpIPkwhGJVKZFlnXM5rrF9WhRqEelv1Wke0oVe81Z6DjjO7z9ERPm7juYdCb9taTt7N
	Swe79bPKdDu+73D5e5PZs7De13aKecyRLKB0nBBNlqzvVwKeFA4RJU/MXNEf9A1w=
X-Received: by 2002:a63:dc09:: with SMTP id s9mr26747212pgg.425.1559540252145;
        Sun, 02 Jun 2019 22:37:32 -0700 (PDT)
X-Received: by 2002:a63:dc09:: with SMTP id s9mr26747168pgg.425.1559540251139;
        Sun, 02 Jun 2019 22:37:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559540251; cv=none;
        d=google.com; s=arc-20160816;
        b=pc9ocEIOQ9JInH0OY3Ob40u5jVwKQp8w25EITG37C52sQD4wBgK7ef2XifVb8JwS5t
         Tw0zNYeXnU6Quvnnr1UMeuQ88Hf3ai/lDoC4ZsFZWbeckc8pUM/M2vIO/k95q/jVewv5
         Ghjhv2qqbuTscehC1/NvUHGkZ+IreKvbItKoGyPwViFF5iOllRjMzgRiWQuIOrQWrKQJ
         +/truzzMW1eiC3GDgJvNhns95QwSkcdtrbBEQwSHo0x+5tc/ZsRmYqvwoCGKIuTeLHaW
         bXf51hEoGaplAoY/F4FcrXpIQ8RLD/2gw5cBEf90fldsO5YSAaI5G6CTQUjQo/NqHw3e
         XGzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=VaNSbzaDg92x8qknqbR2PMhHNKJQW/ZUsMPGiA5Uvg8=;
        b=qBiCBJYh6Qc5Zj7Ve4plFx8YCAdxcWyJSEV1bJHdoH3w9FM8Rr44gxpjV2gqf7hkJt
         444OrYAuSbVfcK/7qI+e15/WSom67PxvJKbgrr4Fd/fnbRTddoVpGMqvVB+2LUm5G0UC
         3ARtSfg2ZrpELlvu0WmEL67ioPt2YTgmudhKoAzAZv8q6mkUptZ+oSHFpNlVmBguL6RO
         o+kDuEkxWFx5oQ2sf41dTaxR2zd2kxdntcrAN8EyRHwJ7Z5LuneKgrJy4I4NYjYcfb9l
         hFjcyJDyJ6a/brZ/Qxzm4cZv14wCebvknBhTMwRHelGdWBjN7R4gjF3WJSGxuQZDTaXU
         5r8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RxlmGxFF;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e7sor13887514pgs.66.2019.06.02.22.37.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 22:37:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RxlmGxFF;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VaNSbzaDg92x8qknqbR2PMhHNKJQW/ZUsMPGiA5Uvg8=;
        b=RxlmGxFF55pcXEOln35FcFIZu+PdPTL0LdwKA1pVLJlIkeHoSJPdwUhAQL+utkqzHo
         NST5Y28/3uWp49yOuAXC69lRpT8U/7wJfNKRbDccCel9sowRaghbB4/2Av3V8730h7ng
         Pm7zotIIs85u4FjfVCRy6k0zMVUO3GiG/EaxlkYl04/CnV5DsfOQxXUGWZPoaLZmgujS
         IeLaCWl8gm/8jtyv/Ilg5Ild53oSpiiG7Sg7WMCn9W82n/lGrManYfGTxKUnQ6tUH+L8
         LkiFT714c3XySvK+52Sg8p24JprTvTiwhcq+t8FCE5/58tl5yjlSvyuGm1GYvZ/rdRt0
         rQxg==
X-Google-Smtp-Source: APXvYqzm2ZazlKrN8EN4M9IRPtD+xIiqdbjl/PDwyA9mR2zzwo/ifQNNgsq6O4hvJBv6D42bhm4NXg==
X-Received: by 2002:a63:b547:: with SMTP id u7mr26726840pgo.322.1559540250731;
        Sun, 02 Jun 2019 22:37:30 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a18sm5986222pjq.0.2019.06.02.22.37.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 22:37:29 -0700 (PDT)
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
Subject: [PATCH v1 4/4] mm: introduce MADV_PAGEOUT
Date: Mon,  3 Jun 2019 14:36:55 +0900
Message-Id: <20190603053655.127730-5-minchan@kernel.org>
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

When a process expects no accesses to a certain memory range
for a long time, it could hint kernel that the pages can be
reclaimed instantly but data should be preserved for future use.
This could reduce workingset eviction so it ends up increasing
performance.

This patch introduces the new MADV_PAGEOUT hint to madvise(2)
syscall. MADV_PAGEOUT can be used by a process to mark a memory
range as not expected to be used for a long time so that kernel
reclaims *any LRU* pages instantly. The hint can help kernel in deciding
which pages to evict proactively.

All of error rule is same with MADV_DONTNEED.

Note:
    This hint works with only private pages(IOW, page_mapcount(page) < 2)
    because shared page could have more chance to be accessed from other
    processes sharing the page so that it could cause major fault soon,
    which is inefficient.

* RFC v2
 * make reclaim_pages simple via factoring out isolate logic - hannes

* RFCv1
 * rename from MADV_COLD to MADV_PAGEOUT - hannes
 * bail out if process is being killed - Hillf
 * fix reclaim_pages bugs - Hillf

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h                   |   1 +
 include/uapi/asm-generic/mman-common.h |   1 +
 mm/madvise.c                           | 126 +++++++++++++++++++++++++
 mm/vmscan.c                            |  34 +++++++
 4 files changed, 162 insertions(+)

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
index ab158766858a..b010249cb8b6 100644
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
+	if (!can_madv_lru_vma(vma))
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
index 56df55e8afcd..2c2cf442db58 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2136,6 +2136,40 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }
 
+unsigned long reclaim_pages(struct list_head *page_list)
+{
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
+		list_move(&page->lru, &node_page_list);
+		nr_reclaimed += shrink_page_list(&node_page_list,
+						page_pgdat(page),
+						&sc, TTU_IGNORE_ACCESS,
+						&dummy_stat, true);
+		if (!list_empty(&node_page_list)) {
+			struct page *page = lru_to_page(&node_page_list);
+
+			list_del(&page->lru);
+			putback_lru_page(page);
+
+		}
+	}
+
+	return nr_reclaimed;
+}
+
 /*
  * The inactive anon list should be small enough that the VM never has
  * to do too much work.
-- 
2.22.0.rc1.311.g5d7573a151-goog

