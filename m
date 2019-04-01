Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 408D2C10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:23:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0E4F208E4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:23:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0E4F208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C44A6B0006; Mon,  1 Apr 2019 10:23:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 772F06B0008; Mon,  1 Apr 2019 10:23:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 614386B000A; Mon,  1 Apr 2019 10:23:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDF86B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 10:23:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p8so7355073pfd.4
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 07:23:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:message-id;
        bh=faqu+HDovbB+h4KFPoMaoz4kGn7nIwDbpnMi1XAKxeE=;
        b=q/2hPAanZw+9t/oVha8wtVHlb0tOaz8rqtCsl73INnqZehQV41DIit2/hMEWtbKAxe
         Hg6OIl/UofeK2XS88bGbAIETPFvbv83G9G/QO9kXV2CEs457imwIq1RWH3xjkf7+LCPR
         5MB274Pgn0eWMFFIxnr3xlLaDf/DLAa+WzvShXFYZtGHX7Yy5vK7pWUwLSJUXw+5c8tM
         HmXrB1RYy+RMAlQqASj1bFwGRdZ6keBsMxKclgNiXt7qZMgz6BBVIWNsceStrza9jsok
         KFVOcnvhh9FRMQsaQYb6HCGy0tQs6OfCWRBuzCoFFEf6xXOGnQHqBPE/i8+i/NCZFHFL
         KbqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW74iyKXeMRfHd8wvw9ldDuFRNys8kT57k59vHN2Ed6JSRAsvv2
	0FqcpIKT10tYD12do03/4YJUAJDlDc6lvI5kdIXLX2FrmdVWLp3OnbXj0ll7rDmVAP8HCtpVClJ
	SkxJy5deVJOp2ubkrTsWDOqj6nmxwszB22iw/PTH8WbSZyFryyxIm90FaX9J9dJHQNw==
X-Received: by 2002:a17:902:1122:: with SMTP id d31mr30293484pla.29.1554128590634;
        Mon, 01 Apr 2019 07:23:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtEoPskXVawilykTfAu1beJhlc5ZuVOTSFQKZAX5+SWYCZDhhYy31GuzvsDx+NpiKCgIGT
X-Received: by 2002:a17:902:1122:: with SMTP id d31mr30293391pla.29.1554128589517;
        Mon, 01 Apr 2019 07:23:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554128589; cv=none;
        d=google.com; s=arc-20160816;
        b=hOlo4K2+5QnwaBQSpxUgxezJHHqPM+jkeh9fFLu3HAaDPCs3wnisDZYAStIommrz5P
         p/Q3sXUrShfU5hT9kbcWZILqoK+nsaKJd9VlKCxMRege6ZzheiUidfHKEN9ggOUrMnJw
         ekC/wY9Hvg6okpvxyJfEtAVFGlDYc527FRawNcB9+RIW2AWz3HZOwcTPtaMfOTvC1LQj
         eBSXrxefmGtuTYkjXt/S/diG1QiBGwnflXCHhlYvlkR3IZu12Fkp+gL0LhwrvoyUDn9D
         UTOG5rWknjBzo3nY/SuBbMYE0LIpzYP0gZvriHypMnCsoEtTgx1oW66JqD060kt2OpIE
         ouOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:from:cc:to:subject;
        bh=faqu+HDovbB+h4KFPoMaoz4kGn7nIwDbpnMi1XAKxeE=;
        b=dbKGpJn65yA16+0DldjNSE/4iOezycCP4wyoHuiNpLinEMAgvUMxPV7gYUxEsdhR0+
         sh84bURfqwa2B5SF3i1orfA/6CUKaRySnOkIHl6Z2SSDII8UdLX7Xg0wrFDZiqsAVjLZ
         juwrRx4/ZeO33ZS6gZEbsMBwf8/12ep+Er/+d+MtHYJJQqznYn7Q9kXbf6kaDC7s/5SB
         Uk2ysonw1wP37Deovp9mqH4EnY4Zksh0yDFqMrs317a0KL11jqQNK5BSMPOztjm+0guc
         Ogfk7y6QfSfyF96e+K40UCXReKH6iF2G5MgbboRbqU4fyygQO4TQCy3HaOM4Jj32DaqH
         Se2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p9si8991722pgn.358.2019.04.01.07.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 07:23:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Apr 2019 07:23:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,296,1549958400"; 
   d="scan'208";a="127643820"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga007.jf.intel.com with ESMTP; 01 Apr 2019 07:23:08 -0700
Subject: [PATCH] x86/mpx: fix recursive munmap() corruption
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,rguenther@suse.de,mhocko@suse.com,vbabka@suse.cz,luto@amacapital.net,x86@kernel.org,akpm@linux-foundation.org,linux-mm@kvack.org,stable@vger.kernel.org
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 01 Apr 2019 07:15:49 -0700
Message-Id: <20190401141549.3F4721FE@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This is a bit of a mess, to put it mildly.  But, it's a bug
that seems to have gone unticked up to now, probably because
nobody uses MPX.  The other alternative to this fix is to just
deprecate MPX, even in -stable kernels.

MPX has the arch_unmap() hook inside of munmap() because MPX
uses bounds tables that protect other areas of memory.  When
memory is unmapped, there is also a need to unmap the MPX
bounds tables.  Barring this, unused bounds tables can eat 80%
of the address space.

But, the recursive do_munmap() that gets called vi arch_unmap()
wreaks havoc with __do_munmap()'s state.  It can result in
freeing populated page tables, accessing bogus VMA state,
double-freed VMAs and more.

To fix this, call arch_unmap() before __do_unmap() has a chance
to do anything meaningful.  Also, remove the 'vma' argument
and force the MPX code to do its own, independent VMA lookup.

For the common success case this is functionally identical to
what was there before.  For the munmap() failure case, it's
possible that some MPX tables will be zapped for memory that
continues to be in use.  But, this is an extraordinarily
unlikely scenario and the harm would be that MPX provides no
protection since the bounds table got reset (zeroed).

I can't imagine anyone doing this:

	ptr = mmap();
	// use ptr
	ret = munmap(ptr);
	if (ret)
		// oh, there was an error, I'll
		// keep using ptr.

Because if you're doing munmap(), you are *done* with the
memory.  There's probably no good data in there _anyway_.

This passes the original reproducer from Richard Biener as
well as the existing mpx selftests/.

====

The long story:

munmap() has a couple of pieces:
1. Find the affected VMA(s)
2. Split the start/end one(s) if neceesary
3. Pull the VMAs out of the rbtree
4. Actually zap the memory via unmap_region(), including
   freeing page tables (or queueing them to be freed).
5. Fixup some of the accounting (like fput()) and actually
   free the VMA itself.

I decided to put the arch_unmap() call right afer #3.  This
was *just* before mmap_sem looked like it might get downgraded
(it won't in this context), but it looked right.  It wasn't.

Richard Biener reported a test that shows this in dmesg:

[1216548.787498] BUG: Bad rss-counter state mm:0000000017ce560b idx:1 val:551
[1216548.787500] BUG: non-zero pgtables_bytes on freeing mm: 24576

What triggered this was the recursive do_munmap() called via
arch_unmap().  It was freeing page tables that has not been
properly zapped.

But, the problem was bigger than this.  For one, arch_unmap()
can free VMAs.  But, the calling __do_munmap() has variables
that *point* to VMAs and obviously can't handle them just
getting freed while the pointer is still valid.

I tried a couple of things here.  First, I tried to fix the page
table freeing problem in isolation, but I then found the VMA
issue.  I also tried having the MPX code return a flag if it
modified the rbtree which would force __do_munmap() to re-walk
to restart.  That spiralled out of control in complexity pretty
fast.

Just moving arch_unmap() and accepting that the bonkers failure
case might eat some bounds tables seems like the simplest viable
fix.

Reported-by: Richard Biener <rguenther@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org

---

 b/arch/x86/include/asm/mmu_context.h |    6 +++---
 b/arch/x86/include/asm/mpx.h         |    5 ++---
 b/arch/x86/mm/mpx.c                  |   10 ++++++----
 b/include/asm-generic/mm_hooks.h     |    1 -
 b/mm/mmap.c                          |   15 ++++++++-------
 5 files changed, 19 insertions(+), 18 deletions(-)

diff -puN mm/mmap.c~mpx-rss-pass-no-vma mm/mmap.c
--- a/mm/mmap.c~mpx-rss-pass-no-vma	2019-04-01 06:56:53.409411123 -0700
+++ b/mm/mmap.c	2019-04-01 06:56:53.423411123 -0700
@@ -2731,9 +2731,17 @@ int __do_munmap(struct mm_struct *mm, un
 		return -EINVAL;
 
 	len = PAGE_ALIGN(len);
+	end = start + len;
 	if (len == 0)
 		return -EINVAL;
 
+	/*
+	 * arch_unmap() might do unmaps itself.  It must be called
+	 * and finish any rbtree manipulation before this code
+	 * runs and also starts to manipulate the rbtree.
+	 */
+	arch_unmap(mm, start, end);
+
 	/* Find the first overlapping VMA */
 	vma = find_vma(mm, start);
 	if (!vma)
@@ -2742,7 +2750,6 @@ int __do_munmap(struct mm_struct *mm, un
 	/* we have  start < vma->vm_end  */
 
 	/* if it doesn't overlap, we have nothing.. */
-	end = start + len;
 	if (vma->vm_start >= end)
 		return 0;
 
@@ -2812,12 +2819,6 @@ int __do_munmap(struct mm_struct *mm, un
 	/* Detach vmas from rbtree */
 	detach_vmas_to_be_unmapped(mm, vma, prev, end);
 
-	/*
-	 * mpx unmap needs to be called with mmap_sem held for write.
-	 * It is safe to call it before unmap_region().
-	 */
-	arch_unmap(mm, vma, start, end);
-
 	if (downgrade)
 		downgrade_write(&mm->mmap_sem);
 
diff -puN arch/x86/include/asm/mmu_context.h~mpx-rss-pass-no-vma arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~mpx-rss-pass-no-vma	2019-04-01 06:56:53.412411123 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2019-04-01 06:56:53.423411123 -0700
@@ -277,8 +277,8 @@ static inline void arch_bprm_mm_init(str
 	mpx_mm_init(mm);
 }
 
-static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-			      unsigned long start, unsigned long end)
+static inline void arch_unmap(struct mm_struct *mm, unsigned long start,
+			      unsigned long end)
 {
 	/*
 	 * mpx_notify_unmap() goes and reads a rarely-hot
@@ -298,7 +298,7 @@ static inline void arch_unmap(struct mm_
 	 * consistently wrong.
 	 */
 	if (unlikely(cpu_feature_enabled(X86_FEATURE_MPX)))
-		mpx_notify_unmap(mm, vma, start, end);
+		mpx_notify_unmap(mm, start, end);
 }
 
 /*
diff -puN include/asm-generic/mm_hooks.h~mpx-rss-pass-no-vma include/asm-generic/mm_hooks.h
--- a/include/asm-generic/mm_hooks.h~mpx-rss-pass-no-vma	2019-04-01 06:56:53.414411123 -0700
+++ b/include/asm-generic/mm_hooks.h	2019-04-01 06:56:53.423411123 -0700
@@ -18,7 +18,6 @@ static inline void arch_exit_mmap(struct
 }
 
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
diff -puN arch/x86/mm/mpx.c~mpx-rss-pass-no-vma arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mpx-rss-pass-no-vma	2019-04-01 06:56:53.416411123 -0700
+++ b/arch/x86/mm/mpx.c	2019-04-01 06:56:53.423411123 -0700
@@ -881,9 +881,10 @@ static int mpx_unmap_tables(struct mm_st
  * the virtual address region start...end have already been split if
  * necessary, and the 'vma' is the first vma in this range (start -> end).
  */
-void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long start, unsigned long end)
+void mpx_notify_unmap(struct mm_struct *mm, unsigned long start,
+		      unsigned long end)
 {
+       	struct vm_area_struct *vma;
 	int ret;
 
 	/*
@@ -902,11 +903,12 @@ void mpx_notify_unmap(struct mm_struct *
 	 * which should not occur normally. Being strict about it here
 	 * helps ensure that we do not have an exploitable stack overflow.
 	 */
-	do {
+	vma = find_vma(mm, start);
+	while (vma && vma->vm_start < end) {
 		if (vma->vm_flags & VM_MPX)
 			return;
 		vma = vma->vm_next;
-	} while (vma && vma->vm_start < end);
+	}
 
 	ret = mpx_unmap_tables(mm, start, end);
 	if (ret)
diff -puN arch/x86/include/asm/mpx.h~mpx-rss-pass-no-vma arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mpx-rss-pass-no-vma	2019-04-01 06:56:53.418411123 -0700
+++ b/arch/x86/include/asm/mpx.h	2019-04-01 06:56:53.424411123 -0700
@@ -78,8 +78,8 @@ static inline void mpx_mm_init(struct mm
 	 */
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
 }
-void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-		      unsigned long start, unsigned long end);
+void mpx_notify_unmap(struct mm_struct *mm, unsigned long start,
+		unsigned long end);
 
 unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
 		unsigned long flags);
@@ -100,7 +100,6 @@ static inline void mpx_mm_init(struct mm
 {
 }
 static inline void mpx_notify_unmap(struct mm_struct *mm,
-				    struct vm_area_struct *vma,
 				    unsigned long start, unsigned long end)
 {
 }
_

