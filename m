Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D712C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BADC92086D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:54:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iyGK6Aca"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BADC92086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58B6B6B000C; Thu, 27 Jun 2019 07:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53C328E0003; Thu, 27 Jun 2019 07:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42B578E0002; Thu, 27 Jun 2019 07:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 088D56B000C
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:54:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q2so1306677plr.19
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=93WnCRK2teuF0qh7ke2oj7ryC0s9RBV/iR71KvnFbIA=;
        b=B+bfAGvnqXfgo+UAz+5KWNzpD8hexu61SIUyQwwJXmd8HhEMrPUX/cxJ4ylChsqGWH
         dRRkP7g12uOT4TFfD7bUsu3ok6z2QhT4OhGWGu2wYkfBW//Aj7B3Eg54hQjMtYqPAqe1
         4E2fUz3eG8Fg0GyOJ7sAZAbOE7zxDJaDqpEKZQM719B4Kn9nUbI8AGBJxcNAH/YX4iDl
         KSyW9FOk7g//0vC6O/9wZNEcV95M92Mu39jIa3VBWpB6deP9jAOBRGceAeMItIMbTMVM
         wZ/gRrXAA/tL12PbjzTrmsD/SePkLpW6tf1bdoLWJAiBPR8bLsg1vR/QMyTg7KUo3k84
         0XcA==
X-Gm-Message-State: APjAAAV1RNALo01gS7FdOj/uxY8TPQUHBz6W2m34WLC6oXHxluP9RpD/
	bXngudXLM1EJT1bH+rwgNQuE8KPA7KEQ+NhzlJmrdtqyklVyVfGPuC4KJk6l326nD0hiCtWpAn+
	GARyQJwZUjZmvBPXtYUznWLVpb3yVcuVFEhLGVkmsI6VlZylw6dDYh4f/SJjGM2k=
X-Received: by 2002:a17:902:23:: with SMTP id 32mr4234022pla.34.1561636483674;
        Thu, 27 Jun 2019 04:54:43 -0700 (PDT)
X-Received: by 2002:a17:902:23:: with SMTP id 32mr4233920pla.34.1561636482150;
        Thu, 27 Jun 2019 04:54:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561636482; cv=none;
        d=google.com; s=arc-20160816;
        b=Qo4SbQuyJwGlIxUkd/M917lPn8iA3dQA6/YFKLGr/Q6TBo4Xe1k7gVUpnsAztzWGg3
         vP8dM23t51zbQnGwvZeyqycQ4Xh6znrhPJkhq+ac3B1+pLGf05OqYEgg4jvH5UfHbzcW
         YgaclgBHPERaPcz2jaUddAXQflbyPSUGTCBfy70AWxpfE+btyr+tEp4z4q0bjqcIBOha
         u74OSumiwhTLTE7x+4pkssXWa4Ux3rURJ/zmn4gGnpnd1fWfGEMJMVXNPbZiHh02IolA
         +CB2J2ek6q6xfueLnqjW6l/+sRY/cWTOKAYwpex+uMJwNL5KCQf+k/tsIy8jYdJGg+IO
         B10g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=93WnCRK2teuF0qh7ke2oj7ryC0s9RBV/iR71KvnFbIA=;
        b=HSx+Rx/yOVci/RL/DhZMRfi0Ph+rIY8hwCerwvKHeiht+Cv7k2G4uRyBf7fkUTNW0a
         3YEj52vF4JyqbfhMrCPwSHb2KnST/homXvIM7bedKLQZUuk8MZetINryh6GB8GNzjhKK
         dXEZLzIlMckDQ3nSSV7PrbOhbDtkDtJzTDz1SFUpyk1NYZCm17qYcfkrzr+vLsG6LqwS
         NfMs3nBmeZnQYe4+JL2FM1KhBZkzvrgoohjVIM9S6Dub8sopwiEWaHXsYuDQFC1zMbi9
         vDZ38uPy2LFe6fd2OV9qt9TM27sgGbGJTYzgoEBYzsKG6Ir4KJ1anyGKTQ88TUEqUUzY
         JQGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iyGK6Aca;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 67sor724122pgc.77.2019.06.27.04.54.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 04:54:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iyGK6Aca;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=93WnCRK2teuF0qh7ke2oj7ryC0s9RBV/iR71KvnFbIA=;
        b=iyGK6AcageSWTpRAoEpFUqvpCfRBe+B8O3rjFHJn3q6n+QUE2aGU3IDPSmEiPtIVUL
         Xg47qIEk6eFEwg0G2Jeoeps4LOOnepBZyXy5j7pTK+19F75BknvEu0JMRjkvsm6SabuX
         LPgluwglHGZSnnHpNupub0knft7bc4VRrnrmE5f06L3VgXqylHMANP45wYE3SPqZzYG/
         KocSGqOiKnlEJ7pHywFnr5E/ddYTeTz7fqrc2ItpU9dj3Z8oyto43aGeX7h/XqbVEvPB
         hj3HIQK0C+q8pIHNmpLGNBI2FmXzzqSMBdroNatU+YNp/Ssdc5XNda3aKRpdxHlE4oXx
         EXPQ==
X-Google-Smtp-Source: APXvYqxwNuznR8PQUPWGciSUojLRogFx9FhnqXbvCrOQeZ10M0UmgIixyw2S3h3r+SYWovqv+zsvng==
X-Received: by 2002:a63:c0e:: with SMTP id b14mr3457713pgl.4.1561636481596;
        Thu, 27 Jun 2019 04:54:41 -0700 (PDT)
Received: from bbox-1.seo.corp.google.com ([2401:fa00:d:0:d988:f0f2:984f:445b])
        by smtp.gmail.com with ESMTPSA id x14sm3241419pfq.158.2019.06.27.04.54.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 04:54:40 -0700 (PDT)
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
Subject: [PATCH v3 5/5] mm: factor out pmd young/dirty bit handling and THP split
Date: Thu, 27 Jun 2019 20:54:05 +0900
Message-Id: <20190627115405.255259-6-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
In-Reply-To: <20190627115405.255259-1-minchan@kernel.org>
References: <20190627115405.255259-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now, there are common part among MADV_COLD|PAGEOUT|FREE to reset
access/dirty bit resetting or split the THP page to handle part
of subpages in the THP page. This patch factor out the common part.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/huge_mm.h |   3 -
 mm/huge_memory.c        |  74 -------------
 mm/madvise.c            | 234 +++++++++++++++++++++++-----------------
 3 files changed, 135 insertions(+), 176 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c150c21d..2667e1aa3ce5 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -29,9 +29,6 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
-extern bool madvise_free_huge_pmd(struct mmu_gather *tlb,
-			struct vm_area_struct *vma,
-			pmd_t *pmd, unsigned long addr, unsigned long next);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 93f531b63a45..e4b9a06788f3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1671,80 +1671,6 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	return 0;
 }
 
-/*
- * Return true if we do MADV_FREE successfully on entire pmd page.
- * Otherwise, return false.
- */
-bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
-		pmd_t *pmd, unsigned long addr, unsigned long next)
-{
-	spinlock_t *ptl;
-	pmd_t orig_pmd;
-	struct page *page;
-	struct mm_struct *mm = tlb->mm;
-	bool ret = false;
-
-	tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
-
-	ptl = pmd_trans_huge_lock(pmd, vma);
-	if (!ptl)
-		goto out_unlocked;
-
-	orig_pmd = *pmd;
-	if (is_huge_zero_pmd(orig_pmd))
-		goto out;
-
-	if (unlikely(!pmd_present(orig_pmd))) {
-		VM_BUG_ON(thp_migration_supported() &&
-				  !is_pmd_migration_entry(orig_pmd));
-		goto out;
-	}
-
-	page = pmd_page(orig_pmd);
-	/*
-	 * If other processes are mapping this page, we couldn't discard
-	 * the page unless they all do MADV_FREE so let's skip the page.
-	 */
-	if (page_mapcount(page) != 1)
-		goto out;
-
-	if (!trylock_page(page))
-		goto out;
-
-	/*
-	 * If user want to discard part-pages of THP, split it so MADV_FREE
-	 * will deactivate only them.
-	 */
-	if (next - addr != HPAGE_PMD_SIZE) {
-		get_page(page);
-		spin_unlock(ptl);
-		split_huge_page(page);
-		unlock_page(page);
-		put_page(page);
-		goto out_unlocked;
-	}
-
-	if (PageDirty(page))
-		ClearPageDirty(page);
-	unlock_page(page);
-
-	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
-		pmdp_invalidate(vma, addr, pmd);
-		orig_pmd = pmd_mkold(orig_pmd);
-		orig_pmd = pmd_mkclean(orig_pmd);
-
-		set_pmd_at(mm, addr, pmd, orig_pmd);
-		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
-	}
-
-	mark_page_lazyfree(page);
-	ret = true;
-out:
-	spin_unlock(ptl);
-out_unlocked:
-	return ret;
-}
-
 static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
 {
 	pgtable_t pgtable;
diff --git a/mm/madvise.c b/mm/madvise.c
index ee210473f639..13b06dc8d402 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -310,6 +310,91 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+enum madv_pmdp_reset_t {
+	MADV_PMDP_RESET,	/* pmd was reset successfully */
+	MADV_PMDP_SPLIT,	/* pmd was split */
+	MADV_PMDP_ERROR,
+};
+
+static enum madv_pmdp_reset_t madvise_pmdp_reset_or_split(struct mm_walk *walk,
+				pmd_t *pmd, spinlock_t *ptl,
+				unsigned long addr, unsigned long end,
+				bool young, bool dirty)
+{
+	pmd_t orig_pmd;
+	unsigned long next;
+	struct page *page;
+	struct mmu_gather *tlb = walk->private;
+	struct mm_struct *mm = walk->mm;
+	struct vm_area_struct *vma = walk->vma;
+	bool reset_young = false;
+	bool reset_dirty = false;
+	enum madv_pmdp_reset_t ret = MADV_PMDP_ERROR;
+
+	orig_pmd = *pmd;
+	if (is_huge_zero_pmd(orig_pmd))
+		return ret;
+
+	if (unlikely(!pmd_present(orig_pmd))) {
+		VM_BUG_ON(thp_migration_supported() &&
+				!is_pmd_migration_entry(orig_pmd));
+		return ret;
+	}
+
+	next = pmd_addr_end(addr, end);
+	page = pmd_page(orig_pmd);
+	if (next - addr != HPAGE_PMD_SIZE) {
+		/*
+		 * THP collapsing is not cheap so only split the page is
+		 * private to the this process.
+		 */
+		if (page_mapcount(page) != 1)
+			return ret;
+		get_page(page);
+		spin_unlock(ptl);
+		lock_page(page);
+		if (!split_huge_page(page))
+			ret = MADV_PMDP_SPLIT;
+		unlock_page(page);
+		put_page(page);
+		return ret;
+	}
+
+	if (young && pmd_young(orig_pmd))
+		reset_young = true;
+	if (dirty && pmd_dirty(orig_pmd))
+		reset_dirty = true;
+
+	/*
+	 * Other process could rely on the PG_dirty for data consistency,
+	 * not pte_dirty so we could reset PG_dirty only when we are owner
+	 * of the page.
+	 */
+	if (reset_dirty) {
+		if (page_mapcount(page) != 1)
+			goto out;
+		if (!trylock_page(page))
+			goto out;
+		if (PageDirty(page))
+			ClearPageDirty(page);
+		unlock_page(page);
+	}
+
+	ret = MADV_PMDP_RESET;
+	if (reset_young || reset_dirty) {
+		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
+		pmdp_invalidate(vma, addr, pmd);
+		if (reset_young)
+			orig_pmd = pmd_mkold(orig_pmd);
+		if (reset_dirty)
+			orig_pmd = pmd_mkclean(orig_pmd);
+		set_pmd_at(mm, addr, pmd, orig_pmd);
+		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+	}
+out:
+	return ret;
+}
+
 static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
@@ -319,64 +404,31 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte, *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
-	unsigned long next;
 
-	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
-		pmd_t orig_pmd;
-
-		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
 		ptl = pmd_trans_huge_lock(pmd, vma);
 		if (!ptl)
 			return 0;
 
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
-
-			get_page(page);
+		switch (madvise_pmdp_reset_or_split(walk, pmd, ptl, addr, end,
+							true, false)) {
+		case MADV_PMDP_RESET:
 			spin_unlock(ptl);
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
-			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+			page = pmd_page(*pmd);
+			test_and_clear_page_young(page);
+			deactivate_page(page);
+			goto next;
+		case MADV_PMDP_ERROR:
+			spin_unlock(ptl);
+			goto next;
+		case MADV_PMDP_SPLIT:
+			; /* go through */
 		}
-
-		test_and_clear_page_young(page);
-		deactivate_page(page);
-huge_unlock:
-		spin_unlock(ptl);
-		return 0;
 	}
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
-regular_page:
 	tlb_change_page_size(tlb, PAGE_SIZE);
 	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	flush_tlb_batched_pending(mm);
@@ -443,6 +495,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
 
 	arch_enter_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
+next:
 	cond_resched();
 
 	return 0;
@@ -493,70 +546,38 @@ static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
 	LIST_HEAD(page_list);
 	struct page *page;
 	int isolated = 0;
-	unsigned long next;
 
 	if (fatal_signal_pending(current))
 		return -EINTR;
 
-	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
-		pmd_t orig_pmd;
-
-		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
 		ptl = pmd_trans_huge_lock(pmd, vma);
 		if (!ptl)
 			return 0;
 
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
+		switch (madvise_pmdp_reset_or_split(walk, pmd, ptl, addr, end,
+							true, false)) {
+		case MADV_PMDP_RESET:
+			page = pmd_page(*pmd);
 			spin_unlock(ptl);
-			lock_page(page);
-			err = split_huge_page(page);
-			unlock_page(page);
-			put_page(page);
-			if (!err)
-				goto regular_page;
-			return 0;
-		}
-
-		if (isolate_lru_page(page))
-			goto huge_unlock;
-
-		if (pmd_young(orig_pmd)) {
-			pmdp_invalidate(vma, addr, pmd);
-			orig_pmd = pmd_mkold(orig_pmd);
-
-			set_pmd_at(mm, addr, pmd, orig_pmd);
-			tlb_remove_tlb_entry(tlb, pmd, addr);
+			if (isolate_lru_page(page))
+				return 0;
+			ClearPageReferenced(page);
+			test_and_clear_page_young(page);
+			list_add(&page->lru, &page_list);
+			reclaim_pages(&page_list);
+			goto next;
+		case MADV_PMDP_ERROR:
+			spin_unlock(ptl);
+			goto next;
+		case MADV_PMDP_SPLIT:
+			; /* go through */
 		}
-
-		ClearPageReferenced(page);
-		test_and_clear_page_young(page);
-		list_add(&page->lru, &page_list);
-huge_unlock:
-		spin_unlock(ptl);
-		reclaim_pages(&page_list);
-		return 0;
 	}
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
-regular_page:
+
 	tlb_change_page_size(tlb, PAGE_SIZE);
 	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	flush_tlb_batched_pending(mm);
@@ -631,6 +652,7 @@ static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
 	reclaim_pages(&page_list);
+next:
 	cond_resched();
 
 	return 0;
@@ -700,12 +722,26 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte, *pte, ptent;
 	struct page *page;
 	int nr_swap = 0;
-	unsigned long next;
 
-	next = pmd_addr_end(addr, end);
-	if (pmd_trans_huge(*pmd))
-		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
+	if (pmd_trans_huge(*pmd)) {
+		ptl = pmd_trans_huge_lock(pmd, vma);
+		if (!ptl)
+			return 0;
+
+		switch (madvise_pmdp_reset_or_split(walk, pmd, ptl, addr, end,
+							true, true)) {
+		case MADV_PMDP_RESET:
+			page = pmd_page(*pmd);
+			spin_unlock(ptl);
+			mark_page_lazyfree(page);
 			goto next;
+		case MADV_PMDP_ERROR:
+			spin_unlock(ptl);
+			goto next;
+		case MADV_PMDP_SPLIT:
+			; /* go through */
+		}
+	}
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
@@ -817,8 +853,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	}
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(orig_pte, ptl);
-	cond_resched();
 next:
+	cond_resched();
 	return 0;
 }
 
-- 
2.22.0.410.gd8fdbe21b5-goog

