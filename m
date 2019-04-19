Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B591C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 19:56:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5C7F217D7
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 19:56:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5C7F217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666096B0003; Fri, 19 Apr 2019 15:56:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3A96B0006; Fri, 19 Apr 2019 15:56:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4664A6B0007; Fri, 19 Apr 2019 15:56:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 029AF6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 15:56:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2so3963438pge.16
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 12:56:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:message-id;
        bh=XATOWYlfY8mWr5n3Rp/7XQFoVZT6Gft99CJj+ScYlHU=;
        b=ejXXMo25EywMcYM558+KPqJCR/mY2z06tNnWtkxz8yehiqgUaxcSE2BWhc6g1Ew5Qx
         kknT6SCQOXWehyImj4dMnl6YeRPNr9wLacOk77akasckf1GRfdO1oNk7aUvEHKUg+tDx
         uxmx561Omq0b32b44KhVrBENKR26OtbYQ/njBL3DNh+rk64uWrrjENnJ88V9OEufsby9
         D7xgjYoEg0fdZSU53w5r/a3dUS3TqPU4KAw3zqRVU/GFyXq7q/jA1FYtKUBpATcQakk6
         VvF4H/ZlrpY/F5HxfWkEHThKbN3pzdxWx4SX9owpxFqBHuae6FpEMYQjC8GJGKYwiwFr
         jdFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWU57GPX0ChZ0MIOTfEgXqg1XYLdIruE0qE2gtaeUixiEZaotfd
	vto6zKRB7O8cypMJfz1fiRQDmLguAislQIaD/oX0tNSb4Wov8acTQdr0y0T12NCVKj7zkT4L3wF
	/gSvPobqX2OqBv3FTi1od5eHiXVqCV0yYBg2e0lJUD0d0Qn7n22G3KjM9cuvudJcNyw==
X-Received: by 2002:a17:902:201:: with SMTP id 1mr5705249plc.89.1555703780596;
        Fri, 19 Apr 2019 12:56:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXrNXefDN+2l1IaeUK1bWzLjLi2k73Worm4o/bGp4+z2XRo9MqnqWdl+zq5apI5n5jYkBL
X-Received: by 2002:a17:902:201:: with SMTP id 1mr5705169plc.89.1555703779274;
        Fri, 19 Apr 2019 12:56:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555703779; cv=none;
        d=google.com; s=arc-20160816;
        b=H8nTv/l4080znQu/aUX4Yjpsv17vaDi3JsCvA+D2x7TjnEcWmrtA7zJa82zBEdkRQM
         bJTp3Tfn3s7j87LoANbqBbEVG5W1dbbWjOm/8reRh4UpTy45GlVTKD5QHBR1gZu2MGlc
         HxyvCfJvpEZhiA4qhK7cAdIE7AzjxE7dHxej7vw5fddJQReOJqwlk/n0KsA5uDullYG8
         gFWaq/rXisNMSLdcgU2jtDGtDeJOEIW+L/Fg8YmMKRqWS8rABRgz81JER1z9Tb7TxB/+
         Y9chUSmpG2YRikYJPenBak92nqiVMqEbU7AktEB2+LJcFNyBD3sAyVy1kB5yP3dEJSwB
         V0Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:from:cc:to:subject;
        bh=XATOWYlfY8mWr5n3Rp/7XQFoVZT6Gft99CJj+ScYlHU=;
        b=F0VDrw9d9/XNbA60YZc7TXx/TPfsGdkePQF8Uq9b6qsXvaw37zr6UPpdAgHm7PeNPV
         qu97OixRBeQEeuQ4k8stG/K5gjBNjGsgE4GJqx9x0AAyBHPTLJiOc6YBnjamDEXyMAAy
         zpz6BrvdonnhkVwl3oQFg7zniRksI1XB47vMk5ztjkWtndM+3T5s25n9lne2kOwJ0qhu
         dmu7tzmh/GkM2i2z86e0iRhVtKZh9X3limm1/F70Kn2KKocRcywEKsw2xKRvmkJDN2CZ
         RPUHWcqRgzQTt/AR5oxHxEq2+mkTNeGUOt4FBfcmjZVYANnSrBINkaMbjP/Qt6g8yr1Y
         p4MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w20si5958821pfi.96.2019.04.19.12.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 12:56:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Apr 2019 12:56:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,371,1549958400"; 
   d="scan'208";a="339124191"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by fmsmga005.fm.intel.com with ESMTP; 19 Apr 2019 12:56:18 -0700
Subject: [PATCH] [v2] x86/mpx: fix recursive munmap() corruption
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,rguenther@suse.de,hjl.tools@gmail.com,yang.shi@linux.alibaba.com,mhocko@suse.com,vbabka@suse.cz,luto@amacapital.net,x86@kernel.org,akpm@linux-foundation.org,linux-mm@kvack.org,stable@vger.kernel.org,linuxppc-dev@lists.ozlabs.org,linux-um@lists.infradead.org,benh@kernel.crashing.org,paulus@samba.org,mpe@ellerman.id.au,linux-arch@vger.kernel.org,gxt@pku.edu.cn,jdike@addtoit.com,richard@nod.at,anton.ivanov@cambridgegreys.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 19 Apr 2019 12:47:47 -0700
Message-Id: <20190419194747.5E1AD6DC@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Changes from v1:
 * Fix compile errors on UML and non-x86 arches
 * Clarify commit message and Fixes about the origin of the
   bug and add the impact to powerpc / uml / unicore32

--

This is a bit of a mess, to put it mildly.  But, it's a bug
that only seems to have showed up in 4.20 but wasn't noticed
until now because nobody uses MPX.

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

== UML / unicore32 impact ==

Remove unused 'vma' argument to arch_unmap().  No functional
change.

I compile tested this on UML but not unicore32.

== powerpc impact ==

powerpc uses arch_unmap() well to watch for munmap() on the
VDSO and zeroes out 'current->mm->context.vdso_base'.  Moving
arch_unmap() makes this happen earlier in __do_munmap().  But,
'vdso_base' seems to only be used in perf and in the signal
delivery that happens near the return to userspace.  I can not
find any likely impact to powerpc, other than the zeroing
happening a little earlier.

powerpc does not use the 'vma' argument and is unaffected by
its removal.

I compile-tested a 64-bit powerpc defconfig.

== x86 impact ==

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

This specific ordering was actually introduced by:

	dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")

during the 4.20 merge window.  The previous __do_munmap() code
was actually safe because the only thing after arch_unmap() was
remove_vma_list().  arch_unmap() could not see 'vma' in the
rbtree because it was detached, so it is not even capable of
doing operations unsafe for remove_vma_list()'s use of 'vma'.

Richard Biener reported a test that shows this in dmesg:

[1216548.787498] BUG: Bad rss-counter state mm:0000000017ce560b idx:1 val:551
[1216548.787500] BUG: non-zero pgtables_bytes on freeing mm: 24576

What triggered this was the recursive do_munmap() called via
arch_unmap().  It was freeing page tables that has not been
properly zapped.

But, the problem was bigger than this.  For one, arch_unmap()
can free VMAs.  But, the calling __do_munmap() has variables
that *point* to VMAs and obviously can't handle them just
getting freed while the pointer is still in use.

I tried a couple of things here.  First, I tried to fix the page
table freeing problem in isolation, but I then found the VMA
issue.  I also tried having the MPX code return a flag if it
modified the rbtree which would force __do_munmap() to re-walk
to restart.  That spiralled out of control in complexity pretty
fast.

Just moving arch_unmap() and accepting that the bonkers failure
case might eat some bounds tables seems like the simplest viable
fix.

This was also reported in the following kernel bugzilla entry:

	https://bugzilla.kernel.org/show_bug.cgi?id=203123

There are some reports that dd2283f2605 ("mm: mmap: zap pages
with read mmap_sem in munmap") triggered this issue.  While that
commit certainly made the issues easier to hit, I belive the
fundamental issue has been with us as long as MPX itself, thus
the Fixes: tag below is for one of the original MPX commits.

Reported-by: Richard Biener <rguenther@suse.de>
Reported-by: H.J. Lu <hjl.tools@gmail.com>
Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-um@lists.infradead.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-arch@vger.kernel.org
Cc: Guan Xuetao <gxt@pku.edu.cn>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>

---

 b/arch/powerpc/include/asm/mmu_context.h   |    1 -
 b/arch/um/include/asm/mmu_context.h        |    1 -
 b/arch/unicore32/include/asm/mmu_context.h |    1 -
 b/arch/x86/include/asm/mmu_context.h       |    6 +++---
 b/arch/x86/include/asm/mpx.h               |    5 ++---
 b/arch/x86/mm/mpx.c                        |   10 ++++++----
 b/include/asm-generic/mm_hooks.h           |    1 -
 b/mm/mmap.c                                |   15 ++++++++-------
 8 files changed, 19 insertions(+), 21 deletions(-)

diff -puN mm/mmap.c~mpx-rss-pass-no-vma mm/mmap.c
--- a/mm/mmap.c~mpx-rss-pass-no-vma	2019-04-19 09:31:09.851509404 -0700
+++ b/mm/mmap.c	2019-04-19 09:31:09.864509404 -0700
@@ -2730,9 +2730,17 @@ int __do_munmap(struct mm_struct *mm, un
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
@@ -2741,7 +2749,6 @@ int __do_munmap(struct mm_struct *mm, un
 	/* we have  start < vma->vm_end  */
 
 	/* if it doesn't overlap, we have nothing.. */
-	end = start + len;
 	if (vma->vm_start >= end)
 		return 0;
 
@@ -2811,12 +2818,6 @@ int __do_munmap(struct mm_struct *mm, un
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
--- a/arch/x86/include/asm/mmu_context.h~mpx-rss-pass-no-vma	2019-04-19 09:31:09.853509404 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2019-04-19 09:31:09.865509404 -0700
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
--- a/include/asm-generic/mm_hooks.h~mpx-rss-pass-no-vma	2019-04-19 09:31:09.856509404 -0700
+++ b/include/asm-generic/mm_hooks.h	2019-04-19 09:31:09.865509404 -0700
@@ -18,7 +18,6 @@ static inline void arch_exit_mmap(struct
 }
 
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
diff -puN arch/x86/mm/mpx.c~mpx-rss-pass-no-vma arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mpx-rss-pass-no-vma	2019-04-19 09:31:09.858509404 -0700
+++ b/arch/x86/mm/mpx.c	2019-04-19 09:31:09.866509404 -0700
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
--- a/arch/x86/include/asm/mpx.h~mpx-rss-pass-no-vma	2019-04-19 09:31:09.860509404 -0700
+++ b/arch/x86/include/asm/mpx.h	2019-04-19 09:31:09.866509404 -0700
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
diff -puN arch/um/include/asm/mmu_context.h~mpx-rss-pass-no-vma arch/um/include/asm/mmu_context.h
--- a/arch/um/include/asm/mmu_context.h~mpx-rss-pass-no-vma	2019-04-19 09:42:05.789507768 -0700
+++ b/arch/um/include/asm/mmu_context.h	2019-04-19 09:42:57.962507638 -0700
@@ -22,7 +22,6 @@ static inline int arch_dup_mmap(struct m
 }
 extern void arch_exit_mmap(struct mm_struct *mm);
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
diff -puN arch/unicore32/include/asm/mmu_context.h~mpx-rss-pass-no-vma arch/unicore32/include/asm/mmu_context.h
--- a/arch/unicore32/include/asm/mmu_context.h~mpx-rss-pass-no-vma	2019-04-19 09:42:06.189507767 -0700
+++ b/arch/unicore32/include/asm/mmu_context.h	2019-04-19 09:43:25.425507569 -0700
@@ -88,7 +88,6 @@ static inline int arch_dup_mmap(struct m
 }
 
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
diff -puN arch/powerpc/include/asm/mmu_context.h~mpx-rss-pass-no-vma arch/powerpc/include/asm/mmu_context.h
--- a/arch/powerpc/include/asm/mmu_context.h~mpx-rss-pass-no-vma	2019-04-19 09:42:06.388507766 -0700
+++ b/arch/powerpc/include/asm/mmu_context.h	2019-04-19 09:43:27.392507564 -0700
@@ -237,7 +237,6 @@ extern void arch_exit_mmap(struct mm_str
 #endif
 
 static inline void arch_unmap(struct mm_struct *mm,
-			      struct vm_area_struct *vma,
 			      unsigned long start, unsigned long end)
 {
 	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
_

