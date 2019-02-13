Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EA0FC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AE01222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AE01222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C064A8E0003; Wed, 13 Feb 2019 03:06:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8DBE8E0001; Wed, 13 Feb 2019 03:06:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2EC98E0003; Wed, 13 Feb 2019 03:06:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48FBB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:06:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w51so652878edw.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:06:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+ic/ZUhdIlQiYtEt1g3sTWSG5TMvSGuJzs/LGycdU/o=;
        b=W88tjtgNSu28PN3a1BDxuBl1tUCJ+MVAfw1xKNpR8HGSBMG1p9tOn/gDRr6bsNVwEy
         7+RG+d9NeXtLJdNVzSWtjaXOc4gAysVUZTcMAsipYC0u5RpGJDrCoJAgAvITiv+lbJyA
         CEGWet2Pn0TKEKIcmcdZrt9jE2ijGIllSiAQzMpFtm8NkTzkf55rCopSHIivo3Xo42h1
         awTcjgDLwdfDI3t26J2ABa+MbguiofYz0Y3Z7w0Uf0MpU63Wz2r56yva4u4TJHLVlAjf
         qpX1DNBk2jO6u4PMnJaNnh+7C1by5jHQ4+b790v2tECKbUMDookZSvo3Phw2gI4Y5zfs
         e4Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuYK29so0s4r+PLgeNxlddyZWiy7Zwis1+aeDy0UdnVQTB2/rHaW
	YwE/bSutp7pons1o1HNJsGdjJMRUuFq4hYMJcFTmDVzwGKXgM01VN956n33Qq5Qowtlseyn9D37
	dOQtbReJMKooRtVDvaeTwwv70LXiJXZDOVP1IBbc4OlPvEVFpL1myKtQ9ys6e9ugkoA==
X-Received: by 2002:a05:6402:1295:: with SMTP id w21mr6350776edv.293.1550045203834;
        Wed, 13 Feb 2019 00:06:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZqxpRldpWQtOalTxV0whRX0mK17ieXENDv3iMTUprws/0PaaVrtw3hy/Uw9vj0fHg3mx39
X-Received: by 2002:a05:6402:1295:: with SMTP id w21mr6350718edv.293.1550045202836;
        Wed, 13 Feb 2019 00:06:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045202; cv=none;
        d=google.com; s=arc-20160816;
        b=YKe6oFuKaZ+hKaPCM8AUUnrgr6mbTaDufcwASnGS/Z1fh36TvTobujit+1MGjyxJLS
         v0ppqKUlJ2tTtYQGJC78pzci3EFLnqcTSgma+W4plXAv42aV40qWwHGixnXN5mDX5uoK
         36dI6CtBPIMj3VITL35YTLdiVOlnE1qY5t7cg/z3cREtZv6JkcFao25CtloPlp/fPWEJ
         KnNsT2ykhUM99wP0atO5Sub0Yd4mdNJu3jHxJUmQCPl44nITuHm4+MDMybbss2DyC36z
         T81+fY9+AIDYRBetQ8lBRN1iRV02vVtzRr4yU9HOYR9yY6kiPYa6ReDg3irrhg5kmJrE
         tErw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+ic/ZUhdIlQiYtEt1g3sTWSG5TMvSGuJzs/LGycdU/o=;
        b=PBOyURsAdnjnmoZxL44f8o6TkMf4LM8uAkNkdf0zA5X8a1KxaMHk6p5NxXbRL/Pmia
         95jbbp0NpY1wmi8FK3RKGU9sZ/E8qd7tuX+DrN4v1/MuY5uH6j7sJ3OiZ/1TqlR74WJH
         S3xtI0ZlqEEWjJiEwWGbDg/HwoPP/sM5OOPSQ/SoTn0SUFhcFo4LEm0YGx1ge0EOkhwk
         KeQXDULUDwzYkOGQ0Erm/EyuEd2w8URHuM5gf1R94WN2+PE2niyInW61FTVg6YotY99I
         v3baFUiEZdsu7cgdVXdr/airEZm+mhqa/P5GYyNgwK80k/lPjLpdTtVkY0BE6TXhjuPT
         9CSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o21si799544edc.54.2019.02.13.00.06.42
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 00:06:42 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9AE501596;
	Wed, 13 Feb 2019 00:06:41 -0800 (PST)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.147])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2FBFA3F575;
	Wed, 13 Feb 2019 00:06:37 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	kirill@shutemov.name,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	dave.hansen@intel.com
Subject: [RFC 1/4] mm: Introduce lazy exec permission setting on a page
Date: Wed, 13 Feb 2019 13:36:28 +0530
Message-Id: <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Setting an exec permission on a page normally triggers I-cache invalidation
which might be expensive. I-cache invalidation is not mandatory on a given
page if there is no immediate exec access on it. Non-fault modification of
user page table from generic memory paths like migration can be improved if
setting of the exec permission on the page can be deferred till actual use.

This introduces [pte|pmd]_mklazyexec() which clears the exec permission on
a page during migration. This exec permission deferral must be enabled back
with maybe_[pmd]_mkexec() during exec page fault (FAULT_FLAG_INSTRUCTION)
if the corresponding VMA contains exec flag (VM_EXEC).

This framework is encapsulated under CONFIG_ARCH_SUPPORTS_LAZY_EXEC so that
non-subscribing architectures don't take any performance hit. For now only
generic memory migration path will be using this framework but later it can
be extended to other generic memory paths as well.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/asm-generic/pgtable.h | 12 ++++++++++++
 include/linux/mm.h            | 26 ++++++++++++++++++++++++++
 mm/Kconfig                    |  9 +++++++++
 mm/huge_memory.c              |  5 +++++
 mm/hugetlb.c                  |  2 ++
 mm/memory.c                   |  4 ++++
 mm/migrate.c                  |  2 ++
 7 files changed, 60 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 05e61e6..d35d129 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -26,6 +26,18 @@
 #define USER_PGTABLES_CEILING	0UL
 #endif
 
+#ifndef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
+static inline pte_t pte_mklazyexec(pte_t entry)
+{
+	return entry;
+}
+
+static inline pmd_t pmd_mklazyexec(pmd_t entry)
+{
+	return entry;
+}
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..04d7a0a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -755,6 +755,32 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 	return pte;
 }
 
+#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
+static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
+{
+	if (unlikely(vma->vm_flags & VM_EXEC))
+		return pte_mkexec(entry);
+	return entry;
+}
+
+static inline pmd_t maybe_pmd_mkexec(pmd_t entry, struct vm_area_struct *vma)
+{
+	if (unlikely(vma->vm_flags & VM_EXEC))
+		return pmd_mkexec(entry);
+	return entry;
+}
+#else
+static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
+{
+	return entry;
+}
+
+static inline pmd_t maybe_pmd_mkexec(pmd_t entry, struct vm_area_struct *vma)
+{
+	return entry;
+}
+#endif
+
 vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
 vm_fault_t finish_fault(struct vm_fault *vmf);
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb..5c046cb 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -322,6 +322,15 @@ config DEFAULT_MMAP_MIN_ADDR
 	  This value can be changed after boot using the
 	  /proc/sys/vm/mmap_min_addr tunable.
 
+config ARCH_SUPPORTS_LAZY_EXEC
+	bool "Architecture supports deferred exec permission setting"
+	help
+	  Some architectures can improve performance during non-fault page
+	  table modifications paths with deferred exec permission setting
+	  which helps in avoiding expensive I-cache invalidations. This
+	  requires arch implementation of ptep_set_access_flags() to allow
+	  non-exec to exec transition.
+
 config ARCH_SUPPORTS_MEMORY_FAILURE
 	bool
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index faf357e..9ef7662 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1126,6 +1126,8 @@ void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (write)
 		entry = pmd_mkdirty(entry);
 	haddr = vmf->address & HPAGE_PMD_MASK;
+	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
+		entry = maybe_pmd_mkexec(entry, vmf->vma);
 	if (pmdp_set_access_flags(vmf->vma, haddr, vmf->pmd, entry, write))
 		update_mmu_cache_pmd(vmf->vma, vmf->address, vmf->pmd);
 
@@ -1290,6 +1292,8 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (vmf->flags & FAULT_FLAG_INSTRUCTION)
+			entry = maybe_pmd_mkexec(entry, vma);
 		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
 			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
@@ -2944,6 +2948,7 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 		pmde = pmd_mksoft_dirty(pmde);
 	if (is_write_migration_entry(entry))
 		pmde = maybe_pmd_mkwrite(pmde, vma);
+	pmde = pmd_mklazyexec(pmde);
 
 	flush_cache_range(vma, mmun_start, mmun_start + HPAGE_PMD_SIZE);
 	if (PageAnon(new))
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef616..ea41832 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4018,6 +4018,8 @@ vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		entry = huge_pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
+	if (flags & FAULT_FLAG_INSTRUCTION)
+		entry = maybe_mkexec(entry, vma);
 	if (huge_ptep_set_access_flags(vma, haddr, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, haddr, ptep);
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9d..74c406b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2218,6 +2218,8 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
+		entry = maybe_mkexec(entry, vma);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -3804,6 +3806,8 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
+	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
+		entry = maybe_mkexec(entry, vmf->vma);
 	if (ptep_set_access_flags(vmf->vma, vmf->address, vmf->pte, entry,
 				vmf->flags & FAULT_FLAG_WRITE)) {
 		update_mmu_cache(vmf->vma, vmf->address, vmf->pte);
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680..7587717 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -257,6 +257,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (PageHuge(new)) {
 			pte = pte_mkhuge(pte);
 			pte = arch_make_huge_pte(pte, vma, new, 0);
+			pte = pte_mklazyexec(pte);
 			set_huge_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 			if (PageAnon(new))
 				hugepage_add_anon_rmap(new, vma, pvmw.address);
@@ -265,6 +266,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		} else
 #endif
 		{
+			pte = pte_mklazyexec(pte);
 			set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 
 			if (PageAnon(new))
-- 
2.7.4

