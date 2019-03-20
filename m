Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2038BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C328F21850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C328F21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AEA86B000A; Tue, 19 Mar 2019 22:08:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 690206B0269; Tue, 19 Mar 2019 22:08:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 574EE6B026A; Tue, 19 Mar 2019 22:08:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35B156B000A
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:35 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so19651622qkg.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Qv5XBK4pCyxq2qwVsBnYbqwBzqvU6bqRS5Ws8Mc0WTE=;
        b=SOgQ/p31Db+iuaMZ0buZ53ohCIwkifGjDmX0y0nlPyoB2w+n6l3n04ArYIIhvMWSK/
         741jhTIzZDJmhDEB9cDCLS3x+Pd3yGErWjFBDUMlBBOELvODZUPFKy2RbVlOI6eMF/FJ
         wttCy9Ql/Ph56lkHIi6ksEILXl67c8+hlxucSQz6JczA5ug6iQNcU9f0nU/4Q5ZrZ2X6
         TH7ZSwT5HNJf0Snt6LusXJsUAIy3g2+BMIohalf6aXaVeBJmAEta3tx7rHvcYVMUFiuZ
         L7EBzMIluxE37b7SVakiunIHohL3XrWkG5fdPsw8UCHyKyvXHrSIcCg6fRGAMP8y5yB/
         E8Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUpsJ0N3w59jq7O7b4Tq9aqGw/iw+5OSFsZKyxS+XIqx/Vblnzm
	XXXvbqg9rIBrzNUi8VIfSGTpCosyXATX08M6wkp3AohY1ilaMYcV8b0dlaPYNR9w168J2aLx4IH
	QSWnjPqLob+ljiKKcA7y7qJaX5CFJxA0rm5cfN1S+9in5+/9GaEz/zMtdoQZMsENJZw==
X-Received: by 2002:a37:4801:: with SMTP id v1mr4620340qka.312.1553047714989;
        Tue, 19 Mar 2019 19:08:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbr/qnyTJXH4T7VkTfgJNmw5fupvzP4qMjudS2oxWQqlQMyhTAC79ckSCzR2uhgQD/r3/Q
X-Received: by 2002:a37:4801:: with SMTP id v1mr4620289qka.312.1553047713571;
        Tue, 19 Mar 2019 19:08:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047713; cv=none;
        d=google.com; s=arc-20160816;
        b=ggEsbXZoI8Gb2e3S9P202apgnSHebN2POpmABMIxAjdJv8EzF9DMgwjFPdxUOL2IdJ
         fGrzal9t/uZwvNf1LckGD9KvSKPG+nrRtPV7f96c9ySjenzTxw3fsipvVJcIQN+YgRPp
         3ECqGKAx0iKk/dgM1xr+giGgIICelSYCosHNtPAapB1tg5Fi2Xf8kHN19accq6QAEoWE
         arfDSRjyU690Pm3b9LlkLCWKLeOyC6fjEiZskOti0lNoHEAukOzeVBQZe9Eedss3gyNS
         Xj99pk0pQZJGAjVOPbjypmGWIRpjaUU1bPIHGOo+s19fRupI7PUOw96txin1Yh1+1PHx
         RakA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Qv5XBK4pCyxq2qwVsBnYbqwBzqvU6bqRS5Ws8Mc0WTE=;
        b=hiGfn0i9q8LLmN3mkYl9f/MaFfzApaFqaPtHgLkd8zXW3449np6ivVC79A4Q81QzJE
         FEA0kDTvbv0e4LeHuoC1PIwowwnKCpcrmANGeBFNfNU2qJcF7UUcHZzdZcnEP24oEH1J
         8GG9nqPfbEZjtKFASAHPMRKTDyhFga5r0yZO02uho8sO7b8cCdT9Ab5QaaBOCkjTR5u3
         ImZZVPlWrcq4PCYR6HOtv41+I7xikooKZ+hy6IZZAIuXWFxXhh+obaGR14AGML8ItyqU
         EofeKAX1PLq+kV+pPR7I/78CBvI+54ded6ZBAMj5kDWytfCmGIpXMbeaBYJnZR+Y6SEc
         NvrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a8si415740qtb.82.2019.03.19.19.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A40623086205;
	Wed, 20 Mar 2019 02:08:32 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EB86660634;
	Wed, 20 Mar 2019 02:08:26 +0000 (UTC)
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
Subject: [PATCH v3 12/28] userfaultfd: wp: apply _PAGE_UFFD_WP bit
Date: Wed, 20 Mar 2019 10:06:26 +0800
Message-Id: <20190320020642.4000-13-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 20 Mar 2019 02:08:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Firstly, introduce two new flags MM_CP_UFFD_WP[_RESOLVE] for
change_protection() when used with uffd-wp and make sure the two new
flags are exclusively used.  Then,

  - For MM_CP_UFFD_WP: apply the _PAGE_UFFD_WP bit and remove _PAGE_RW
    when a range of memory is write protected by uffd

  - For MM_CP_UFFD_WP_RESOLVE: remove the _PAGE_UFFD_WP bit and recover
    _PAGE_RW when write protection is resolved from userspace

And use this new interface in mwriteprotect_range() to replace the old
MM_CP_DIRTY_ACCT.

Do this change for both PTEs and huge PMDs.  Then we can start to
identify which PTE/PMD is write protected by general (e.g., COW or soft
dirty tracking), and which is for userfaultfd-wp.

Since we should keep the _PAGE_UFFD_WP when doing pte_modify(), add it
into _PAGE_CHG_MASK as well.  Meanwhile, since we have this new bit, we
can be even more strict when detecting uffd-wp page faults in either
do_wp_page() or wp_huge_pmd().

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h |  5 +++++
 mm/huge_memory.c   | 14 +++++++++++++-
 mm/memory.c        |  4 ++--
 mm/mprotect.c      | 12 ++++++++++++
 mm/userfaultfd.c   |  8 ++++++--
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 937559a74dc4..b39efe5ca7f6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1693,6 +1693,11 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 #define  MM_CP_DIRTY_ACCT                  (1UL << 0)
 /* Whether this protection change is for NUMA hints */
 #define  MM_CP_PROT_NUMA                   (1UL << 1)
+/* Whether this change is for write protecting */
+#define  MM_CP_UFFD_WP                     (1UL << 2) /* do wp */
+#define  MM_CP_UFFD_WP_RESOLVE             (1UL << 3) /* Resolve wp */
+#define  MM_CP_UFFD_WP_ALL                 (MM_CP_UFFD_WP | \
+					    MM_CP_UFFD_WP_RESOLVE)
 
 extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end, pgprot_t newprot,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8d65b0f041f9..817335b443c2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1868,6 +1868,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	bool preserve_write;
 	int ret;
 	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
+	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
@@ -1934,6 +1936,13 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	entry = pmd_modify(entry, newprot);
 	if (preserve_write)
 		entry = pmd_mk_savedwrite(entry);
+	if (uffd_wp) {
+		entry = pmd_wrprotect(entry);
+		entry = pmd_mkuffd_wp(entry);
+	} else if (uffd_wp_resolve) {
+		entry = pmd_mkwrite(entry);
+		entry = pmd_clear_uffd_wp(entry);
+	}
 	ret = HPAGE_PMD_NR;
 	set_pmd_at(mm, addr, pmd, entry);
 	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
@@ -2083,7 +2092,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t old_pmd, _pmd;
-	bool young, write, soft_dirty, pmd_migration = false;
+	bool young, write, soft_dirty, pmd_migration = false, uffd_wp = false;
 	unsigned long addr;
 	int i;
 
@@ -2165,6 +2174,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		write = pmd_write(old_pmd);
 		young = pmd_young(old_pmd);
 		soft_dirty = pmd_soft_dirty(old_pmd);
+		uffd_wp = pmd_uffd_wp(old_pmd);
 	}
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
@@ -2198,6 +2208,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_mkold(entry);
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
+			if (uffd_wp)
+				entry = pte_mkuffd_wp(entry);
 		}
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
diff --git a/mm/memory.c b/mm/memory.c
index 567686ec086d..50c2990648ab 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2483,7 +2483,7 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	if (userfaultfd_wp(vma)) {
+	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		return handle_userfault(vmf, VM_UFFD_WP);
 	}
@@ -3690,7 +3690,7 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
 static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma)) {
-		if (userfaultfd_wp(vmf->vma))
+		if (userfaultfd_huge_pmd_wp(vmf->vma, orig_pmd))
 			return handle_userfault(vmf, VM_UFFD_WP);
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
 	}
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a6ba448c8565..9d4433044c21 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -46,6 +46,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	int target_node = NUMA_NO_NODE;
 	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
 	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
+	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	/*
 	 * Can be called with only the mmap_sem for reading by
@@ -117,6 +119,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			if (preserve_write)
 				ptent = pte_mk_savedwrite(ptent);
 
+			if (uffd_wp) {
+				ptent = pte_wrprotect(ptent);
+				ptent = pte_mkuffd_wp(ptent);
+			} else if (uffd_wp_resolve) {
+				ptent = pte_mkwrite(ptent);
+				ptent = pte_clear_uffd_wp(ptent);
+			}
+
 			/* Avoid taking write faults for known dirty pages */
 			if (dirty_accountable && pte_dirty(ptent) &&
 					(pte_soft_dirty(ptent) ||
@@ -301,6 +311,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 {
 	unsigned long pages;
 
+	BUG_ON((cp_flags & MM_CP_UFFD_WP_ALL) == MM_CP_UFFD_WP_ALL);
+
 	if (is_vm_hugetlb_page(vma))
 		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index eaecc21806da..240de2a8492d 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -73,8 +73,12 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 		goto out_release;
 
 	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
-	if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
-		_dst_pte = pte_mkwrite(_dst_pte);
+	if (dst_vma->vm_flags & VM_WRITE) {
+		if (wp_copy)
+			_dst_pte = pte_mkuffd_wp(_dst_pte);
+		else
+			_dst_pte = pte_mkwrite(_dst_pte);
+	}
 
 	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
 	if (dst_vma->vm_file) {
-- 
2.17.1

