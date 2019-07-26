Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD66BC41514
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:35:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7637F22C97
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 02:35:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YLR9hvoY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7637F22C97
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F4E76B000C; Thu, 25 Jul 2019 22:35:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A4EB6B000D; Thu, 25 Jul 2019 22:35:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0728E0002; Thu, 25 Jul 2019 22:35:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2FC76B000C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:35:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 71so27494185pld.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:35:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q30YVPvUX3JGM2I0+DyGeQCKX2+K88lPFkslb0rMb3A=;
        b=VBMqyjBhFdrtHH9v7CzK9KYFT59DWtuZ+NQ5GjVvOQlGkPujHZCa7zH8jY9Arv0zpR
         8fhXiTBQVzznjzwU+01Ukzgw5IU8/uTnuLwDWhqlI/D6qLyUIitE9I4lVgG5eXyiMeRA
         OMebdimq3v69bKsmYWXtUAaL0y423Vcy7bCPnJedtELD2evnRF/Kfo90/wI9gwUkYVKo
         9YJu7j5E4EKpjT8AJ5c5mUpT+tYXoNVcfxWzO+otP8c71JbDVbeMc33o9USFtRRxjqjM
         +O3o7RjT+YNtkflmM5mnQR44VK4cYI6LeTcsQSgvSI6rikmi3+46PTU+xpu4jTUsp9CV
         ZZ3A==
X-Gm-Message-State: APjAAAV2ObeaqDKms20IDz9TrZ3brIfcDjaROgPfK6UJJZcCzGwzQQDn
	z7ah8OQWM0TfiieTJU+76YOGs5f+NTvzj3bt2M7bzj0Bf7lI1Lzijh8h9UV88ZGr4bdz5Qt8dEw
	gUT5xgbGLxp8aYnz2/YYh5SkU+WJV651ZrPCoTtlAdZoyB8i7kZllctucwfJ4aro=
X-Received: by 2002:a63:b555:: with SMTP id u21mr90559626pgo.222.1564108515304;
        Thu, 25 Jul 2019 19:35:15 -0700 (PDT)
X-Received: by 2002:a63:b555:: with SMTP id u21mr90559554pgo.222.1564108513976;
        Thu, 25 Jul 2019 19:35:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564108513; cv=none;
        d=google.com; s=arc-20160816;
        b=CGSIK+BPl9XY3Uppt5IXZ6qOq21lixziyBzLqPVpbrTZMFlGJfxetZb1GaF4M9rWcy
         K/Ig+ZuWxwg9jGoRiFn1NBx8w0HOti1H6UOr7wf5nHihyMbq4Clo+dFfsfNl+w2ma/vQ
         naV00JtwpMlIlxB4IyilwHRbB4LX199iIN19wIfclUHeDRynfEmDolWHjfhyzjtQGIoE
         EEY4luOrtUfOJcCNalMlfh1ivFqqtwdvlAFw+kj9sU24rLlrO3IXw4N8/z/CtO8BZf8h
         Prci2LvwOlvDK2W1cQDyYAaIVujvJtyQ1nf3WbTh+YQM4Qx74Nl859/nBJP10PU90trk
         Xxzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=Q30YVPvUX3JGM2I0+DyGeQCKX2+K88lPFkslb0rMb3A=;
        b=ueSWUF8XeXUrFI7yTSQXk92aZswvOl0AF0TkVhuj2YCoPyrgPHUCEYQJGSjW3/2JLG
         ylfQEapoVo9M92MwUykucJjxR4tfdi/Ns3JN5Nh+Krad/JE1YXdpa8nkleb5XDpBRYe/
         fbHPETAqkGGmKZuz8n5n0IqKi/WwkfGfOUNsvHa/kVmMNrhNeXb2PLILJFyuYSNvlHGm
         7LGpbqYGq6f8tmnF8I5Vuk/6PFSEwLFn6ReWyP4yqpWLqZ6xJApq2Osn0vbA6E+6yM6M
         V+dPn56M12p4kHaJAYas1uiXnqcn1+8Wn3LIf5hkiEOxwQ70c3msOE5VxfWwu8s+mPWA
         Z4SA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YLR9hvoY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor32889269pfu.0.2019.07.25.19.35.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 19:35:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YLR9hvoY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Q30YVPvUX3JGM2I0+DyGeQCKX2+K88lPFkslb0rMb3A=;
        b=YLR9hvoYu1W/oZRoUhC8RM52d7UHrKWR7/bpWn0fqe4QguWRF3O+NgHQaQ1qrytgEA
         rfSUKU8VxiFgNwxGvXLRDZj7hyeaopHWPEfwqi8YYq5fbANe99xNyeBPP6yuyIQj9ODK
         jXR9nWVOmCl6PSFSt4d5mYygk5w+iXMm9kv98YWobWNBrgpPlEHtDeLYWpqc/To5SAy1
         x6vQiNUeKn0P+HLzSaX3gpPQ3XDV4mURPLqUCVa679ctL9yPl7hkoCo39G7LQjzGMUQN
         kaNijnQjuf8A6PBq+S5PaR+8vNFGRfIg/NZ5hTg3f84iUDLU7faOEa3pD/wib0p5W7zp
         JmGA==
X-Google-Smtp-Source: APXvYqyy2hrsqR1fSZ3dc6IWHJTQa/8XvoFf1/1yCu8fXgywe6vHznXwamB7QK5HhknOKACRJ2jDdg==
X-Received: by 2002:a62:6c1:: with SMTP id 184mr19175390pfg.230.1564108513527;
        Thu, 25 Jul 2019 19:35:13 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id l31sm88958450pgm.63.2019.07.25.19.35.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 19:35:12 -0700 (PDT)
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
Subject: [PATCH v7 5/5] mm: factor out common parts between MADV_COLD and MADV_PAGEOUT
Date: Fri, 26 Jul 2019 11:34:35 +0900
Message-Id: <20190726023435.214162-6-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
In-Reply-To: <20190726023435.214162-1-minchan@kernel.org>
References: <20190726023435.214162-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are many common parts between MADV_COLD and MADV_PAGEOUT.
This patch factor them out to save code duplication.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 194 ++++++++++++---------------------------------------
 1 file changed, 46 insertions(+), 148 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 78aa6802b95ad..52f9bddbab19c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -30,6 +30,11 @@
 
 #include "internal.h"
 
+struct madvise_walk_private {
+	struct mmu_gather *tlb;
+	bool pageout;
+};
+
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
  * take mmap_sem for writing. Others, which simply traverse vmas, need
@@ -310,15 +315,22 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
-static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
-				unsigned long end, struct mm_walk *walk)
+static int madvise_cold_or_pageout_pte_range(pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
 {
-	struct mmu_gather *tlb = walk->private;
+	struct madvise_walk_private *private = walk->private;
+	struct mmu_gather *tlb = private->tlb;
+	bool pageout = private->pageout;
 	struct mm_struct *mm = tlb->mm;
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *orig_pte, *pte, ptent;
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page = NULL;
+	LIST_HEAD(page_list);
+
+	if (fatal_signal_pending(current))
+		return -EINTR;
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	if (pmd_trans_huge(*pmd)) {
@@ -366,10 +378,17 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		}
 
+		ClearPageReferenced(page);
 		test_and_clear_page_young(page);
-		deactivate_page(page);
+		if (pageout) {
+			if (!isolate_lru_page(page))
+				list_add(&page->lru, &page_list);
+		} else
+			deactivate_page(page);
 huge_unlock:
 		spin_unlock(ptl);
+		if (pageout)
+			reclaim_pages(&page_list);
 		return 0;
 	}
 
@@ -437,12 +456,19 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 		 * As a side effect, it makes confuse idle-page tracking
 		 * because they will miss recent referenced history.
 		 */
+		ClearPageReferenced(page);
 		test_and_clear_page_young(page);
-		deactivate_page(page);
+		if (pageout) {
+			if (!isolate_lru_page(page))
+				list_add(&page->lru, &page_list);
+		} else
+			deactivate_page(page);
 	}
 
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
+	if (pageout)
+		reclaim_pages(&page_list);
 	cond_resched();
 
 	return 0;
@@ -452,10 +478,15 @@ static void madvise_cold_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end)
 {
+	struct madvise_walk_private walk_private = {
+		.tlb = tlb,
+		.pageout = false,
+	};
+
 	struct mm_walk cold_walk = {
-		.pmd_entry = madvise_cold_pte_range,
+		.pmd_entry = madvise_cold_or_pageout_pte_range,
 		.mm = vma->vm_mm,
-		.private = tlb,
+		.private = &walk_private,
 	};
 
 	tlb_start_vma(tlb, vma);
@@ -482,152 +513,19 @@ static long madvise_cold(struct vm_area_struct *vma,
 	return 0;
 }
 
-static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
-				unsigned long end, struct mm_walk *walk)
-{
-	struct mmu_gather *tlb = walk->private;
-	struct mm_struct *mm = tlb->mm;
-	struct vm_area_struct *vma = walk->vma;
-	pte_t *orig_pte, *pte, ptent;
-	spinlock_t *ptl;
-	LIST_HEAD(page_list);
-	struct page *page;
-
-	if (fatal_signal_pending(current))
-		return -EINTR;
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	if (pmd_trans_huge(*pmd)) {
-		pmd_t orig_pmd;
-		unsigned long next = pmd_addr_end(addr, end);
-
-		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
-		ptl = pmd_trans_huge_lock(pmd, vma);
-		if (!ptl)
-			return 0;
-
-		orig_pmd = *pmd;
-		if (is_huge_zero_pmd(orig_pmd))
-			goto huge_unlock;
-
-		if (unlikely(!pmd_present(orig_pmd))) {
-			VM_BUG_ON(thp_migration_supported() &&
-					!is_pmd_migration_entry(orig_pmd));
-			goto huge_unlock;
-		}
-
-		page = pmd_page(orig_pmd);
-		if (next - addr != HPAGE_PMD_SIZE) {
-			int err;
-
-			if (page_mapcount(page) != 1)
-				goto huge_unlock;
-			get_page(page);
-			spin_unlock(ptl);
-			lock_page(page);
-			err = split_huge_page(page);
-			unlock_page(page);
-			put_page(page);
-			if (!err)
-				goto regular_page;
-			return 0;
-		}
-
-		if (pmd_young(orig_pmd)) {
-			pmdp_invalidate(vma, addr, pmd);
-			orig_pmd = pmd_mkold(orig_pmd);
-
-			set_pmd_at(mm, addr, pmd, orig_pmd);
-			tlb_remove_tlb_entry(tlb, pmd, addr);
-		}
-
-		ClearPageReferenced(page);
-		test_and_clear_page_young(page);
-
-		if (!isolate_lru_page(page))
-			list_add(&page->lru, &page_list);
-huge_unlock:
-		spin_unlock(ptl);
-		reclaim_pages(&page_list);
-		return 0;
-	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-regular_page:
-#endif
-	tlb_change_page_size(tlb, PAGE_SIZE);
-	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	flush_tlb_batched_pending(mm);
-	arch_enter_lazy_mmu_mode();
-	for (; addr < end; pte++, addr += PAGE_SIZE) {
-		ptent = *pte;
-		if (!pte_present(ptent))
-			continue;
-
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page)
-			continue;
-
-		/*
-		 * creating a THP page is expensive so split it only if we
-		 * are sure it's worth. Split it if we are only owner.
-		 */
-		if (PageTransCompound(page)) {
-			if (page_mapcount(page) != 1)
-				break;
-			get_page(page);
-			if (!trylock_page(page)) {
-				put_page(page);
-				break;
-			}
-			pte_unmap_unlock(orig_pte, ptl);
-			if (split_huge_page(page)) {
-				unlock_page(page);
-				put_page(page);
-				pte_offset_map_lock(mm, pmd, addr, &ptl);
-				break;
-			}
-			unlock_page(page);
-			put_page(page);
-			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-			pte--;
-			addr -= PAGE_SIZE;
-			continue;
-		}
-
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
-
-		if (pte_young(ptent)) {
-			ptent = ptep_get_and_clear_full(mm, addr, pte,
-							tlb->fullmm);
-			ptent = pte_mkold(ptent);
-			set_pte_at(mm, addr, pte, ptent);
-			tlb_remove_tlb_entry(tlb, pte, addr);
-		}
-		ClearPageReferenced(page);
-		test_and_clear_page_young(page);
-
-		if (!isolate_lru_page(page))
-			list_add(&page->lru, &page_list);
-	}
-
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(orig_pte, ptl);
-	reclaim_pages(&page_list);
-	cond_resched();
-
-	return 0;
-}
-
 static void madvise_pageout_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end)
 {
+	struct madvise_walk_private walk_private = {
+		.pageout = true,
+		.tlb = tlb,
+	};
+
 	struct mm_walk pageout_walk = {
-		.pmd_entry = madvise_pageout_pte_range,
+		.pmd_entry = madvise_cold_or_pageout_pte_range,
 		.mm = vma->vm_mm,
-		.private = tlb,
+		.private = &walk_private,
 	};
 
 	tlb_start_vma(tlb, vma);
-- 
2.22.0.709.g102302147b-goog

