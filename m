Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22188C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3942217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3942217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80F136B026B; Tue, 19 Mar 2019 22:08:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 797CC6B026C; Tue, 19 Mar 2019 22:08:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C2F46B026D; Tue, 19 Mar 2019 22:08:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38C816B026B
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 18so879346qtw.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=p2Ht8maPQnGA8z4sqJmE0IlCDOKKYPrI55cTbBsdp2Q=;
        b=F+dOArjUgBetFLiA7osGOi+/8kar2M7MHwmYTUZ5omUmMIrmW6y/cosjTKmUPHM9C+
         8ZE8x359XsJ6UnHaNfSUYs1lOWwdXSCk55MBUtzUzWIIlJcV/Tx+V2qGK823JA7+L/6y
         mqCvDQlr0vQKc8pTuPTsoshglZdE3rwhuAUzIGiC9WwMp0mjRw007CtbHLhce77PBuoM
         fQyde1weHNG3gYGPutpyfkz4tMejMod5WkZnS3Qb/HsWdjU1K5axoQhPeX6DuOzuRbyA
         Ha/GttSodeNtE27xvixdGJg2tz14Jjg5tWJrTcTTV3LMnetPJ2Po6I3/H5NcvVTxXk51
         xCrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX/7Oi57l7PfODpewkSHFZYR4kwVYE7NRefquUMO2dvlV6XJC44
	Z42tNwFxpMdtYBOmNUeIa7wcluLaF+RrAAiVlhGuYX6LV5dVH3UVKFts/QH4+xDkXK/559ulveE
	UPT3UzFXB3pJitnSLUvp8aKyiTA1s829VQFQzuB+twAi24O7kfS9vYT6tHTbNjr3n8w==
X-Received: by 2002:a0c:91f0:: with SMTP id r45mr4920392qvr.7.1553047730987;
        Tue, 19 Mar 2019 19:08:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmshbnYlLaujRZWliZTamGhzru3gwfQ+QipXUHZTzfXIlYS9g//fXM0yy1J90RgI3snl76
X-Received: by 2002:a0c:91f0:: with SMTP id r45mr4920343qvr.7.1553047729690;
        Tue, 19 Mar 2019 19:08:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047729; cv=none;
        d=google.com; s=arc-20160816;
        b=YCk4lQE2ICULpbs9eNe+cIGvCb9RxXPhnh+yQ38xQy5lX0cXzttnZ7ymePSKqoDwhO
         YYqLT+o6bP8RRBXvtc0BlJSZq7EtC6bH6x04HurKgSBTWl2PAhICQuamDPKqRoJ09PDF
         QjN+95s4PFk53NNe0Fy6YIOMdsikqyUjmwV97cmXkxRIFQiDF4qA+ebKsn/WBNEjs8B/
         7cmDjzx7HpyyXyuSdpFp6O3hCehlkzBwpbM0VWKI92jJ1rrekIBFWyDvL057KuO+IyDe
         7Y5pJfvJYUIwcSrMmzfdfSPS6qrlHS1Ub+QG0a58JXUNgLXus6ApsclaD2lhILsVbNVJ
         GNJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=p2Ht8maPQnGA8z4sqJmE0IlCDOKKYPrI55cTbBsdp2Q=;
        b=fbh61FOkLHSKDMLlT6oHOnrkuBz3TCQuZpemt1MU27W8XBc06EaMAkCu/gmwwrDtV3
         TtP0c7O0Id+yYufn2YJHmFfVesVFfIW5z8xP8sCK4V7quTeJx3k0IwqwClLcKxOS7zun
         kFsXHl1tYbe2oJyjX2Oa1RK8S4a9Y3DiWwGlQjShLx3i65FWhtMjIhabAYsCO8bMI1f6
         mQLDDtKXZ/N/YbPtEOubRVsW0SAc8ojZJxcgC7mqjaNXONvomfVpr+TlVkWKEaxf0rOI
         3syCQaaxmjK3LYkJL9e/BSmarq2+jVOHGWIDEAmB/MNsr7Il/k1zDZ31unmPIbXQXo2Q
         LLRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k33si250426qvh.194.2019.03.19.19.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D0B9C59467;
	Wed, 20 Mar 2019 02:08:48 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 222BB605CA;
	Wed, 20 Mar 2019 02:08:42 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 14/28] userfaultfd: wp: handle COW properly for uffd-wp
Date: Wed, 20 Mar 2019 10:06:28 +0800
Message-Id: <20190320020642.4000-15-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 20 Mar 2019 02:08:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This allows uffd-wp to support write-protected pages for COW.

For example, the uffd write-protected PTE could also be write-protected
by other usages like COW or zero pages.  When that happens, we can't
simply set the write bit in the PTE since otherwise it'll change the
content of every single reference to the page.  Instead, we should do
the COW first if necessary, then handle the uffd-wp fault.

To correctly copy the page, we'll also need to carry over the
_PAGE_UFFD_WP bit if it was set in the original PTE.

For huge PMDs, we just simply split the huge PMDs where we want to
resolve an uffd-wp page fault always.  That matches what we do with
general huge PMD write protections.  In that way, we resolved the huge
PMD copy-on-write issue into PTE copy-on-write.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/memory.c   |  5 +++-
 mm/mprotect.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 65 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e7a4b9650225..b8a4c0bab461 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2291,7 +2291,10 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (pte_uffd_wp(vmf->orig_pte))
+			entry = pte_mkuffd_wp(entry);
+		else
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 9d4433044c21..855dddb07ff2 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -73,18 +73,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	flush_tlb_batched_pending(vma->vm_mm);
 	arch_enter_lazy_mmu_mode();
 	do {
+retry_pte:
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
 			pte_t ptent;
 			bool preserve_write = prot_numa && pte_write(oldpte);
+			struct page *page;
 
 			/*
 			 * Avoid trapping faults against the zero or KSM
 			 * pages. See similar comment in change_huge_pmd.
 			 */
 			if (prot_numa) {
-				struct page *page;
-
 				page = vm_normal_page(vma, addr, oldpte);
 				if (!page || PageKsm(page))
 					continue;
@@ -114,6 +114,54 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					continue;
 			}
 
+			/*
+			 * Detect whether we'll need to COW before
+			 * resolving an uffd-wp fault.  Note that this
+			 * includes detection of the zero page (where
+			 * page==NULL)
+			 */
+			if (uffd_wp_resolve) {
+				/* If the fault is resolved already, skip */
+				if (!pte_uffd_wp(*pte))
+					continue;
+				page = vm_normal_page(vma, addr, oldpte);
+				if (!page || page_mapcount(page) > 1) {
+					struct vm_fault vmf = {
+						.vma = vma,
+						.address = addr & PAGE_MASK,
+						.page = page,
+						.orig_pte = oldpte,
+						.pmd = pmd,
+						/* pte and ptl not needed */
+					};
+					vm_fault_t ret;
+
+					if (page)
+						get_page(page);
+					arch_leave_lazy_mmu_mode();
+					pte_unmap_unlock(pte, ptl);
+					ret = wp_page_copy(&vmf);
+					/* PTE is changed, or OOM */
+					if (ret == 0)
+						/* It's done by others */
+						continue;
+					else if (WARN_ON(ret != VM_FAULT_WRITE))
+						return pages;
+					pte = pte_offset_map_lock(vma->vm_mm,
+								  pmd, addr,
+								  &ptl);
+					arch_enter_lazy_mmu_mode();
+					if (!pte_present(*pte))
+						/*
+						 * This PTE could have been
+						 * modified after COW
+						 * before we have taken the
+						 * lock; retry this PTE
+						 */
+						goto retry_pte;
+				}
+			}
+
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
 			if (preserve_write)
@@ -183,6 +231,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
 	struct mmu_notifier_range range;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	range.start = 0;
 
@@ -202,7 +251,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		}
 
 		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
-			if (next - addr != HPAGE_PMD_SIZE) {
+			/*
+			 * When resolving an userfaultfd write
+			 * protection fault, it's not easy to identify
+			 * whether a THP is shared with others and
+			 * whether we'll need to do copy-on-write, so
+			 * just split it always for now to simply the
+			 * procedure.  And that's the policy too for
+			 * general THP write-protect in af9e4d5f2de2.
+			 */
+			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
-- 
2.17.1

