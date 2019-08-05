Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 074C0C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:25:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE63921880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:25:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zm4UWAlr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE63921880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F8396B0005; Mon,  5 Aug 2019 08:25:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8A06B0007; Mon,  5 Aug 2019 08:25:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1976E6B0008; Mon,  5 Aug 2019 08:25:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54B16B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 08:25:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m17so43664115pgh.21
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 05:25:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :in-reply-to:message-id:mime-version:content-transfer-encoding;
        bh=5nUYIWXAMGpUhwKnDXPeQEAKPFruK8eSTkg35uIyRus=;
        b=ftPzGnwvtxtUtyA2B0pr1+1lYaw24u0bFDrrA0DVn3TlOWHOJplL+cyjA0Gf5KTPFU
         azZe6Qxrc2hLHGsmXtj5vSWHSW8tnihGCT3bKWiEZF7+IokdAQ98V8inLO3IMdFVvq1X
         hu2xxxQq0xzbsgmUuDgOJwmdmIG4sgmFCjcfx/WwlPg50q+i22Zv0bU1KrWkWfTtobTW
         kD6R2NpDB6/azV4YriL2z4rZXwwww+L+snn+o3mx7cnd1JUX/dwi2M6VDnXTENVdeYN+
         ksTSI6VmA01ByPLjipZjoSwJRF4455kFyYn6qxG8e/UINWflE4QKPGKtWxlZnVetmWPL
         UaCw==
X-Gm-Message-State: APjAAAUPfZqh6L4K2RfLt8DmKl2DNUMb37K6Rf8ZGxznrrHGB5Gn6NK9
	YnHXOz/u/1syi9ljkS33YO4qA2BB5oHKD0jgGhjArX77FiuejOGAhhRNUsJBC52wKR2E/vm9SZX
	5GHqXm4ZY084MeR1BNqQwXcpM5vMfgQyl+mJ3a67m6VnAx5Vilv9XMu4t0XTEC5frTg==
X-Received: by 2002:a63:e213:: with SMTP id q19mr134401567pgh.180.1565007915243;
        Mon, 05 Aug 2019 05:25:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/14GA2tqXCDyJ6mSG15DN/k2aXB9eKg2kokiIyFiesgpXAQtL2n0IE3hRSuhfejRITLia
X-Received: by 2002:a63:e213:: with SMTP id q19mr134401506pgh.180.1565007914240;
        Mon, 05 Aug 2019 05:25:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565007914; cv=none;
        d=google.com; s=arc-20160816;
        b=FOhEljsf98amnBM3oz4OuP5ImTkv3GyulzHb1192OygrzQ7g3PW4MvYzjcQPmdDJgo
         Rzs//yba5PKig0ecGoiv1HZFfXyrriJAyIBiApWhGe4HFxna7040pFGgl83VQqc29qnZ
         qgcoNi0Lp3SZzcfw12ASFZkKDiC0yo8zAPAUY08Pr+0OoLu9FAziFGpi5iHNCojC1C0Q
         S5/dN5SrC/4T6zUz5DS974sKydjlbd1EcHuJZbFG34jQURI3//5RzYTDlvIcZ0rIaidy
         q2aFNYl1s4DLu1ZDerwrC/s722IXcIzjJcB4pmz3QDgNyOI5X3HOo8OApRxSviKXQfrr
         uLLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:in-reply-to:date
         :from:cc:to:subject:dkim-signature;
        bh=5nUYIWXAMGpUhwKnDXPeQEAKPFruK8eSTkg35uIyRus=;
        b=qlUsqtk1sqhJ2VNYrJb1ZiAT4H/nVrzITZAa5205UBu5uvvmDtI0AeDBEanP6l0BtV
         9fsg8/xnhur+pzyQ4zVznt14hSj1gNAjKixix1QkwrKY77QsOifXUhQ39U4Hh+W8mGtR
         l93Q71GTXrGY4+bv3LaEywR3XhKjKtxS62sBUAyaCcThRe572LOiMVwGgzAzs+XyudCH
         P6O5SvCli5ryiP22OYp6UrSmlQ4ovkpLmjeLRHnojP40PWn62DQnbo/+wCyfxKKK2A9R
         ZEB72hnf2SKLoWwRpaO+NEBKzkrajRcWUqNdDxhHjZZ9tSr1szN9HYoOTDEPNa16r0En
         1lbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zm4UWAlr;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m5si38763729plt.167.2019.08.05.05.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 05:25:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zm4UWAlr;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5EB6A2086D;
	Mon,  5 Aug 2019 12:25:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565007913;
	bh=+Xs0kj8VCQPLFkJyxL+QIyNc9IVmkOW/SLIz1vz17Hc=;
	h=Subject:To:Cc:From:Date:In-Reply-To:From;
	b=zm4UWAlryFn8ORRc8LfbaGxhXdT9dmF8Zqhxq/pFQj7868pEfdKqrEC/QwRJ/ydNX
	 IW8rxcrECmwgh07+0Rq4DQGOJBmeC/VWSirtCy5pWi/Vkr6ibSzkIALadXzm9eYFs8
	 M85A+RfjDwVGpoakl5JkRlqbNjYe8NISjF89c4tU=
Subject: Patch "x86, mm, gup: prevent get_page() race with munmap in paravirt guest" has been added to the 4.9-stable tree
To: ben.hutchings@codethink.co.uk,bp@alien8.de,dave.hansen@linux.intel.com,gregkh@linuxfoundation.org,jannh@google.com,jgross@suse.com,kirill.shutemov@linux.intel.com,linux-mm@kvack.org,luto@kernel.org,mingo@redhat.com,osalvador@suse.de,peterz@infradead.org,tglx@linutronix.de,torvalds@linux-foundation.org,vbabka@suse.cz,vkuznets@redhat.com,x86@kernel.org,xen-devel@lists.xenproject.org
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Mon, 05 Aug 2019 14:25:11 +0200
In-Reply-To: <20190802160614.8089-1-vbabka@suse.cz>
Message-ID: <156500791117217@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
X-stable: commit
X-Patchwork-Hint: ignore 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This is a note to let you know that I've just added the patch titled

    x86, mm, gup: prevent get_page() race with munmap in paravirt guest

to the 4.9-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-gup-prevent-get_page-race-with-munmap-in-paravirt-guest.patch
and it can be found in the queue-4.9 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From vbabka@suse.cz  Mon Aug  5 13:56:29 2019
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri,  2 Aug 2019 18:06:14 +0200
Subject: x86, mm, gup: prevent get_page() race with munmap in paravirt guest
To: stable@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Ben Hutchings <ben.hutchings@codethink.co.uk>, xen-devel@lists.xenproject.org, Oscar Salvador <osalvador@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Juergen Gross <jgross@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>
Message-ID: <20190802160614.8089-1-vbabka@suse.cz>

From: Vlastimil Babka <vbabka@suse.cz>

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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

---
 arch/x86/mm/gup.c |   32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -98,6 +98,20 @@ static inline int pte_allows_gup(unsigne
 }
 
 /*
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
+/*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
  * register pressure.
@@ -112,7 +126,7 @@ static noinline int gup_pte_range(pmd_t
 	ptep = pte_offset_map(&pmd, addr);
 	do {
 		pte_t pte = gup_get_pte(ptep);
-		struct page *page;
+		struct page *head, *page;
 
 		/* Similar to the PMD case, NUMA hinting must take slow path */
 		if (pte_protnone(pte)) {
@@ -138,7 +152,21 @@ static noinline int gup_pte_range(pmd_t
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


Patches currently in stable-queue which might be from vbabka@suse.cz are

queue-4.9/x86-mm-gup-prevent-get_page-race-with-munmap-in-paravirt-guest.patch

