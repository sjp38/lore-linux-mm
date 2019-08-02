Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66114C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:06:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20316216C8
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:06:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20316216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92E9B6B0003; Fri,  2 Aug 2019 12:06:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DF396B0005; Fri,  2 Aug 2019 12:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CDE06B0006; Fri,  2 Aug 2019 12:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 307FB6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 12:06:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so47274517edr.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 09:06:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=+MNXp8kagUIMDzOJZI83xJHbSrwpbTyc3oyuG7/SJOk=;
        b=rbhbqfXuVN8EXeozwrl6RnseT+HRKqzECLWlYj/UEnm3o7O/fYZj3LeqsV/s6NmUy3
         PYOyaOfURPNTdaisrynVuiLVfc4RpS+Kiv805JoX+5upK50gh01qkn6aR7E2G3Jfbub8
         ukIYGWQVnUr4Pv32LWaaAbsKavWlBZ6/Ze8vAFXE3f+caYryaHXiHQxGYfvQK1xifOWY
         qMLPjWhq/MTxggVeFtjNGnDI0gKd8Q2WHoXY3wpycsvA2DdDIHwwyTzVii3rJy6YamUN
         dUi7k+AMtysryso9PuDxqtoz+yX0BP0sjRSGD3uN+0XnHNph3QFyR4WDonnyXgI5XvBF
         nJNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWAQaBswEhB48yAffAth7ERzs0st09Hl/oJ0yqceYpllIJZpnGU
	hNUXnuTOozEBBXbaKwqBspRt2RDmmAjYfKi6XoAE8sxp8J/4V4KJFc6c0tmm5sU/AlJHM4z9d1w
	QY2k6NO12GjxPcZMvWB075mZkvKy9HEzZrI4rLKmqx6mC1u2M0p77i/jpaosLDv4GWQ==
X-Received: by 2002:aa7:c99a:: with SMTP id c26mr117816492edt.118.1564761991642;
        Fri, 02 Aug 2019 09:06:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpZ2ZsC7qv1JWa4DOqEhdm187+gemlHQ15uJ82Cr/NEZs+hXV19ec6VUvkoygQfb5LgvAB
X-Received: by 2002:aa7:c99a:: with SMTP id c26mr117816373edt.118.1564761990568;
        Fri, 02 Aug 2019 09:06:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564761990; cv=none;
        d=google.com; s=arc-20160816;
        b=pU3033Bjrm7g5D/OE67lXVCkoVvWB/WOyqs6y30qdvYgZAgn0m0Ac4k1HhwFml9F4Z
         q0Q/QXrJCrK1xuGEXsjd5PXCTK3kE2DpwQ8qDuU9zX6dC7NCBHsUXZrnmzCQH812J1Qs
         TjKeDo3Gi5u/1ZTQyPsSiGRg9qjhlO7trkhYCtOqx+K8mUA9o1BAwXSFom5LmESvA3gP
         11XbBeoGrT54xH4VQ0tr4C4hPhktttupfjLdk9FTMKIZdezpK7EcLsWBSNXA/KEAtdLA
         kY5u29IzZCJrdOKsOSB/cte0R8JtBneeH+siEB5CFMkj3dwi7mXuZNqBVn5VsK75Xdfp
         8zbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=+MNXp8kagUIMDzOJZI83xJHbSrwpbTyc3oyuG7/SJOk=;
        b=Bpx6iPl2Upxv8AMKTzr1zdxeSha4pNhQD3syfl1MnHUe7fJYlA5j2vW/FNhuhSVUZw
         ODo9oCRYCoFaOdmjDV2Ee7zwhgoHYSDtD/VFpGQPoAMW2zOHjGGFnbZEpY6OqeRFkyU2
         icdMF66JNyEOApjFj3cws6+dYdKDIedq4/Cc3YnP5mHAZM3+V+RdT1xVlAon20saSfvf
         n36Y3truYtqN1RhXNp259sfWcB8uNAUSQGkbtoYIGf3Sii2538AcQXOD9jRyuJcbhN0c
         Iw269hzBZmdykpctBwiyZUz51dyKD9FuaWbLyrANeASGuiJmcl4VGfN1UbSvQhijg/KC
         6xBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w50si25600631edd.84.2019.08.02.09.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 09:06:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BDFEBAC91;
	Fri,  2 Aug 2019 16:06:29 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: stable@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	Jann Horn <jannh@google.com>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>,
	xen-devel@lists.xenproject.org,
	Oscar Salvador <osalvador@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Juergen Gross <jgross@suse.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: [PATCH STABLE 4.9] x86, mm, gup: prevent get_page() race with munmap in paravirt guest
Date: Fri,  2 Aug 2019 18:06:14 +0200
Message-Id: <20190802160614.8089-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The x86 version of get_user_pages_fast() relies on disabled interrupts to
synchronize gup_pte_range() between gup_get_pte(ptep); and get_page() against
a parallel munmap. The munmap side nulls the pte, then flushes TLBs, then
releases the page. As TLB flush is done synchronously via IPI disabling
interrupts blocks the page release, and get_page(), which assumes existing
reference on page, is thus safe.
However when TLB flush is done by a hypercall, e.g. in a Xen PV guest, there is
no blocking thanks to disabled interrupts, and get_page() can succeed on a page
that was already freed or even reused.

We have recently seen this happen with our 4.4 and 4.12 based kernels, with
userspace (java) that exits a thread, where mm_release() performs a futex_wake()
on tsk->clear_child_tid, and another thread in parallel unmaps the page where
tsk->clear_child_tid points to. The spurious get_page() succeeds, but futex code
immediately releases the page again, while it's already on a freelist. Symptoms
include a bad page state warning, general protection faults acessing a poisoned
list prev/next pointer in the freelist, or free page pcplists of two cpus joined
together in a single list. Oscar has also reproduced this scenario, with a
patch inserting delays before the get_page() to make the race window larger.

Fix this by removing the dependency on TLB flush interrupts the same way as the
generic get_user_pages_fast() code by using page_cache_add_speculative() and
revalidating the PTE contents after pinning the page. Mainline is safe since
4.13 where the x86 gup code was removed in favor of the common code. Accessing
the page table itself safely also relies on disabled interrupts and TLB flush
IPIs that don't happen with hypercalls, which was acknowledged in commit
9e52fc2b50de ("x86/mm: Enable RCU based page table freeing
(CONFIG_HAVE_RCU_TABLE_FREE=y)"). That commit with follups should also be
backported for full safety, although our reproducer didn't hit a problem
without that backport.

Reproduced-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
---

Hi, I'm sending this stable-only patch for consideration because it's probably
unrealistic to backport the 4.13 switch to generic GUP. I can look at 4.4 and
3.16 if accepted. The RCU page table freeing could be also considered.
Note the patch also includes page refcount protection. I found out that
8fde12ca79af ("mm: prevent get_user_pages() from overflowing page refcount")
backport to 4.9 missed the arch-specific gup implementations:
https://lore.kernel.org/lkml/6650323f-dbc9-f069-000b-f6b0f941a065@suse.cz/

 arch/x86/mm/gup.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 1680768d392c..d7db45bdfb3b 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -97,6 +97,20 @@ static inline int pte_allows_gup(unsigned long pteval, int write)
 	return 1;
 }
 
+/*
+ * Return the compund head page with ref appropriately incremented,
+ * or NULL if that failed.
+ */
+static inline struct page *try_get_compound_head(struct page *page, int refs)
+{
+	struct page *head = compound_head(page);
+	if (WARN_ON_ONCE(page_ref_count(head) < 0))
+		return NULL;
+	if (unlikely(!page_cache_add_speculative(head, refs)))
+		return NULL;
+	return head;
+}
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -112,7 +126,7 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 	ptep = pte_offset_map(&pmd, addr);
 	do {
 		pte_t pte = gup_get_pte(ptep);
-		struct page *page;
+		struct page *head, *page;
 
 		/* Similar to the PMD case, NUMA hinting must take slow path */
 		if (pte_protnone(pte)) {
@@ -138,7 +152,21 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 		}
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
-		get_page(page);
+
+		head = try_get_compound_head(page, 1);
+		if (!head) {
+			put_dev_pagemap(pgmap);
+			pte_unmap(ptep);
+			return 0;
+		}
+
+		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+			put_page(head);
+			put_dev_pagemap(pgmap);
+			pte_unmap(ptep);
+			return 0;
+		}
+
 		put_dev_pagemap(pgmap);
 		SetPageReferenced(page);
 		pages[*nr] = page;
-- 
2.22.0

