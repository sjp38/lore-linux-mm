Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BEF7C28D16
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:13:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB131208E3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:13:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iHwMnlsc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB131208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70A8B6B026E; Mon, 10 Jun 2019 07:13:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 693C06B026F; Mon, 10 Jun 2019 07:13:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 534C66B0270; Mon, 10 Jun 2019 07:13:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 174FC6B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:13:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so5560258plp.12
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:13:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QxZJuWwrSt8e4EoZGdB0xgtw5B8tMulUEiCfRA05PWQ=;
        b=Q6X+BgeZL9+t+9JwECITFC0gKWW1ohjRCxrXx8LmbZFjmz429SHvHH/3MLRb2vM3FQ
         /bojJ5fP8MQ3CK/9BQfko8is1cSia0S80tU4nQyCwf2bqyFgVYd8VWR4jSBW7EQ5CV/1
         gpeUWG5BBn75iaY0dwbUh6pTzJoPlzUv9Tt1rH+v7kGixEADWoAg6ulUwvcWFAkeGjFG
         tYGTEqYIglDjuflbmPFMjaYk7pvg+6gFWs7+Hd5GWK8NdD3immkv0atbvF3sjCEu67nz
         +74A/A2x2r2J985EHM851etJAH7d4JzdIH98nwbojTtqTNwf/D6/pPh04omUZFsLTo7x
         1GKA==
X-Gm-Message-State: APjAAAVBQwSJ9yXMjUiESuy/NyHdQxkayqbniuQQmhla8pUoPoS2EvEW
	9sK7PR+AkD2DRDuvZ7PWKX/MOLSUTkPhAuw9UjupHEv7E2XDESKgX6mtOfss8ma5cZ/ZZKzpnDa
	I4IWwf3sNZjSMsGtn5mMYjbtG+FPw1oOD+VTasVDL6pUMonWPxU37zQeImfgYaF4=
X-Received: by 2002:a17:902:3183:: with SMTP id x3mr16272766plb.321.1560165208706;
        Mon, 10 Jun 2019 04:13:28 -0700 (PDT)
X-Received: by 2002:a17:902:3183:: with SMTP id x3mr16272690plb.321.1560165207619;
        Mon, 10 Jun 2019 04:13:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560165207; cv=none;
        d=google.com; s=arc-20160816;
        b=LOpDseTJZK7T1cSnzGs4XF0sk+gfcJkLNlWR05dfh2aawBXTNH3Z0uUPYetPgZaCiE
         Xh30XY/wMhDJyVBgAy49o1hjMuwHnMORUdscUXsKQL2cGOzJPgZRZybYoXYpefXtAVSN
         BvSaqK0FNyQGRXRY5sTFNN94P4AXhqx2/c9IzROvkQ8cwNE935tOB4dZjDO7b63wpbRU
         7SZ1DhaltNHEnmUTdDF4mHufF+DdwO8rDA7k/uG7VCM8f9AUNT83YjZdoPt+v71JZkMb
         akvw/DnsM3ajjxmSVvpiHs4VAVnc91MrZzExDdoC5zhPw3FdofFlwwpcNTiahSnrhLem
         BHWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=QxZJuWwrSt8e4EoZGdB0xgtw5B8tMulUEiCfRA05PWQ=;
        b=wQkYEezdzcilBVms1R5+kZc7dRjSj9KMqkkVC5eFeRZXErUon1dCGCgL9V85Q4eHvO
         rUGMDpVpwO968pCm9RwlBwd2sdQb3cKXNPijw1G+UOai15RXTNeJYN3qr4yRiTl1z2Lr
         PRXpSEIFUnsZzCu8NwX2cR0Hk93zav3VzxNnWkqjX55dwHh6DTqCdAGmelIG8u58JK2i
         IuiiitNRRKnhaOlXKKlKF+BkuVpARAUGTkuB42zgMPwrnzDtYW70NtqMl85LkUKAEgSs
         DoWCYQPcJNfyjuQ7tkT32LJvCBGa0+DUiFpY/sGQZk861/fcCBnr2vBJDSv76+bDNd3I
         vlrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iHwMnlsc;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t2sor8786895pgu.81.2019.06.10.04.13.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 04:13:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iHwMnlsc;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QxZJuWwrSt8e4EoZGdB0xgtw5B8tMulUEiCfRA05PWQ=;
        b=iHwMnlscA2jX3z1xMikm1LVfnuU2QmIkKk8wIs6d9NgqrVH/KvGSn4Y62YOXnNOAVQ
         ycpRSlEugPyNuTFkhtmfgSRo19++zKdvp3ykbUfkYVtsMeBoHx0AwmrLDznJaeNbMg6P
         TCemf1RAqvpxrePlAt9N154/rh/VE22R5s/rnHyZXBp4OJ6eoBCqcuFPe01cKg11O82v
         GoUcjpOblLIcsyrAEAp2vgamYqIMO52d2mj0FGSzESxOqaAHJu6tTPPa9xX81Rljp25n
         jGp4rLEH+cT+Bq+5EPYVUGltT7ryKrVzz7oyFE/R5sn5PdGqa5NH5J411HpJI8deMMIL
         MaEQ==
X-Google-Smtp-Source: APXvYqyq38tW8Z7RiY2tkkYNH38hLl3AkhvhmjGaPhxvQB5DjCukq8bEPPkMiBqwMP3WTTCCHoOBOA==
X-Received: by 2002:a63:2109:: with SMTP id h9mr15359153pgh.51.1560165207127;
        Mon, 10 Jun 2019 04:13:27 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id h14sm9224633pgj.8.2019.06.10.04.13.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 04:13:25 -0700 (PDT)
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
	lizeb@google.com,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/5] mm: introduce MADV_PAGEOUT
Date: Mon, 10 Jun 2019 20:12:51 +0900
Message-Id: <20190610111252.239156-5-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
In-Reply-To: <20190610111252.239156-1-minchan@kernel.org>
References: <20190610111252.239156-1-minchan@kernel.org>
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
reclaims *any LRU* pages instantly. The hint can help kernel in
deciding which pages to evict proactively.

All of error rule is same with MADV_DONTNEED.

* v1
 * change pte to old and rely on the other's reference - hannes
 * remove page_mapcount to check shared page - mhocko

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
 mm/madvise.c                           | 161 +++++++++++++++++++++++++
 mm/vmscan.c                            |  58 +++++++++
 4 files changed, 221 insertions(+)

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
index d7b4231eea63..f545e159b472 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -48,6 +48,7 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
 #define MADV_COLD	5		/* deactivatie these pages */
+#define MADV_PAGEOUT	6		/* reclaim these pages */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/mm/madvise.c b/mm/madvise.c
index 67c0379f64a7..3b9d2ba421b1 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,7 @@
 #include <linux/syscalls.h>
 #include <linux/mempolicy.h>
 #include <linux/page-isolation.h>
+#include <linux/page_idle.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/hugetlb.h>
 #include <linux/falloc.h>
@@ -41,6 +42,7 @@ static int madvise_need_mmap_write(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_COLD:
+	case MADV_PAGEOUT:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -451,6 +453,162 @@ static long madvise_cold(struct vm_area_struct *vma,
 	return 0;
 }
 
+static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	struct mmu_gather *tlb = walk->private;
+	struct mm_struct *mm = tlb->mm;
+	struct vm_area_struct *vma = walk->vma;
+	pte_t *orig_pte, *pte, ptent;
+	spinlock_t *ptl;
+	LIST_HEAD(page_list);
+	struct page *page;
+	int isolated = 0;
+	unsigned long next;
+
+	if (fatal_signal_pending(current))
+		return -EINTR;
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
+		if (pmd_young(orig_pmd)) {
+			pmdp_invalidate(vma, addr, pmd);
+			orig_pmd = pmd_mkold(orig_pmd);
+
+			set_pmd_at(mm, addr, pmd, orig_pmd);
+			tlb_remove_tlb_entry(tlb, pmd, addr);
+		}
+
+		ClearPageReferenced(page);
+		test_and_clear_page_young(page);
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
+	tlb_change_page_size(tlb, PAGE_SIZE);
+	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	flush_tlb_batched_pending(mm);
+	arch_enter_lazy_mmu_mode();
+	for (; addr < end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		if (isolate_lru_page(page))
+			continue;
+
+		isolated++;
+		if (pte_young(ptent)) {
+			ptent = ptep_get_and_clear_full(mm, addr, pte,
+							tlb->fullmm);
+			ptent = pte_mkold(ptent);
+			set_pte_at(mm, addr, pte, ptent);
+			tlb_remove_tlb_entry(tlb, pte, addr);
+		}
+		ClearPageReferenced(page);
+		test_and_clear_page_young(page);
+		list_add(&page->lru, &page_list);
+		if (isolated >= SWAP_CLUSTER_MAX) {
+			arch_leave_lazy_mmu_mode();
+			pte_unmap_unlock(orig_pte, ptl);
+			reclaim_pages(&page_list);
+			isolated = 0;
+			pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+			arch_enter_lazy_mmu_mode();
+			orig_pte = pte;
+		}
+	}
+
+	arch_leave_lazy_mmu_mode();
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
+	struct mm_walk pageout_walk = {
+		.pmd_entry = madvise_pageout_pte_range,
+		.mm = vma->vm_mm,
+		.private = tlb,
+	};
+
+	tlb_start_vma(tlb, vma);
+	walk_page_range(addr, end, &pageout_walk);
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
 
@@ -841,6 +999,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_COLD:
 		return madvise_cold(vma, prev, start, end);
+	case MADV_PAGEOUT:
+		return madvise_pageout(vma, prev, start, end);
 	case MADV_FREE:
 	case MADV_DONTNEED:
 		return madvise_dontneed_free(vma, prev, start, end, behavior);
@@ -863,6 +1023,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_DONTNEED:
 	case MADV_FREE:
 	case MADV_COLD:
+	case MADV_PAGEOUT:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 56df55e8afcd..04061185677f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2136,6 +2136,64 @@ static void shrink_active_list(unsigned long nr_to_scan,
 			nr_deactivate, nr_rotated, sc->priority, file);
 }
 
+unsigned long reclaim_pages(struct list_head *page_list)
+{
+	int nid = -1;
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
+		}
+
+		if (nid == page_to_nid(page)) {
+			list_move(&page->lru, &node_page_list);
+			continue;
+		}
+
+		nr_reclaimed += shrink_page_list(&node_page_list,
+						NODE_DATA(nid),
+						&sc, 0,
+						&dummy_stat, false);
+		while (!list_empty(&node_page_list)) {
+			struct page *page = lru_to_page(&node_page_list);
+
+			list_del(&page->lru);
+			putback_lru_page(page);
+		}
+
+		nid = -1;
+	}
+
+	if (!list_empty(&node_page_list)) {
+		nr_reclaimed += shrink_page_list(&node_page_list,
+						NODE_DATA(nid),
+						&sc, 0,
+						&dummy_stat, false);
+		while (!list_empty(&node_page_list)) {
+			struct page *page = lru_to_page(&node_page_list);
+
+			list_del(&page->lru);
+			putback_lru_page(page);
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
2.22.0.rc2.383.gf4fbbf30c2-goog

