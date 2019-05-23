Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F9E2C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 11:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C1EF21882
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 11:30:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="e14TSiAK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C1EF21882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE7B6B0007; Thu, 23 May 2019 07:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B14D6B0008; Thu, 23 May 2019 07:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1256B000A; Thu, 23 May 2019 07:30:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B45BB6B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 07:30:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t16so3681570pgv.13
        for <linux-mm@kvack.org>; Thu, 23 May 2019 04:30:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=UyYoniEPDMQGygYTq3Pw9bM6xCQ15njNPtlFQj1whmM=;
        b=Tn+1S8OBU/O0VezQtx5hg4fnCjShf5FnGypsF0NPJVe759ciZmvb+e4BnaPdTbg5la
         2LEhwAjU0YlfErqoVEtVlMFXmH4uuIbS9u+CXheALtylkkIWDzHWDayu9sH428AbmAsl
         fCM7QI+zU1vOUuPu3baa8TvCWO5OgYH9/JYkcioqnKdRQCxc1i/LUhUHiUK/ksi81YYB
         u2zCXOtvObGJx7zECrzQIYuMnPiD+97hYO7PPyrGdSWPSGt59UVOACWlv6Vfs0k0lHKh
         Avz911JvfP/Ku23M+d03fB8pJifn4dHIwbff+o/dJlDNzKwvcZ1uuhuLcAnQcdqnLueg
         CtRg==
X-Gm-Message-State: APjAAAX+4mLy/o8edUx5HBfvAJx9gqQXr3bk1doRAv8v73i1UcTbUUQt
	HYt5LMFH4U6d4Avb0OYg3M3VrfnowVsq5YtzjyJRx1BTpCvR7n8YvkUj7de28mffjSNal8rn4LC
	wztDlpGKP7xfe+3QfUKuoz/NCdeueKrPpqhcOEUaeD1pjnapJGObQYJ9iL/qgXxDaHw==
X-Received: by 2002:a17:90a:658b:: with SMTP id k11mr645019pjj.44.1558611040329;
        Thu, 23 May 2019 04:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1Nlw+3foQqTGSb/ixYfJtROnTMA+Rq+ZhiwaiTZEiDfXZ/1xp1IkglRbbAHbmYLiK32C0
X-Received: by 2002:a17:90a:658b:: with SMTP id k11mr644941pjj.44.1558611039119;
        Thu, 23 May 2019 04:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558611039; cv=none;
        d=google.com; s=arc-20160816;
        b=D10YgEyAYAVets+DDppbH4ttm2/+qVQJiN+oi/BGqtSlgjnXOS5FDHb6+wmEFO4Znr
         MZWf/3hm3UhhDSz01qf5eBudH5IEzzb/88/NNEVGWAkjYV8uesjRgEW5OyvRyjWv0aBm
         7pcLZmGPq9eakNpobtZbR1q9p4xMPbH4plapGOVNYVWNz1qX3aMmu5Zx0KI/PBoHfnFM
         KNPToaIG9685Cwv6yKOtvlde1qLsyPVAVVcFGCzPJJnJQ2ZTlbWNqEz/rEIWH5I7g1gk
         KCSgUWmibqLppY1U2VO08FNY76QL1I4UCsbWRp/owfjk4hxff6OkdLKavb6p/iEQrKZI
         p3ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=UyYoniEPDMQGygYTq3Pw9bM6xCQ15njNPtlFQj1whmM=;
        b=SagPNqZFcnxbus/C0BXmfBQwr6Ub84ju5HyeS7aX80uoeRUxSL1wk1Ilt18SaTZT5p
         8gFhi2/HgGxMAmLiiBulo0cRCD4RfdDvaOriAjWXyiRKaS34gPpnXe5dz3qcrDOXxhyT
         EkmzsGzWTSmf6eVdrCgQgo9Zl181kDDSI1ROTXZY5ZsJyfhapkdf/0vQVFz1eQ8pcaNf
         AtpK6XK3MIWSl+gjYOEaaXfglKvx2SyuvU56ZH3YXjIw2hzuBkmWJR6GWV1bCct6YRsR
         UGNYCuEH1E3NdwyEHd2lwNrrPwAU9SQeeaggJ0Fke0hLtXRVhl4u2dPvgzcAnPvEhvpP
         uRAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=e14TSiAK;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l36si704195plb.58.2019.05.23.04.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 04:30:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=e14TSiAK;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4461A21873;
	Thu, 23 May 2019 11:30:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558611038;
	bh=iqSuTD7PVtjRi6mKaicsjbueODzhC9YF2RHYYjQezXc=;
	h=Subject:To:Cc:From:Date:From;
	b=e14TSiAKol5YPgz8qbyTOmVxUN3dibzJXd4G3qeAjfnKXBnrSE3MoThjgBKbLlZJo
	 n4fz46EE9gLdx1syZk2fNgzco+76pslVL6sLaaODPd0kfwWSARnmt4wCIcYBeU3YY6
	 1M1RSvi0BDe5UCBQuANwP4zP0DwiHNTT5qFeqzH8=
Subject: Patch "x86/mpx, mm/core: Fix recursive munmap() corruption" has been added to the 5.1-stable tree
To: 20190419194747.5E1AD6DC@viggo.jf.intel.com,akpm@linux-foundation.org,anton.ivanov@cambridgegreys.com,benh@kernel.crashing.org,bp@alien8.de,dave.hansen@linux.intel.com,gregkh@linuxfoundation.org,gxt@pku.edu.cn,hjl.tools@gmail.com,hpa@zytor.com,jdike@addtoit.com,linux-mm@kvack.org,linux-um@lists.infradead.org,linuxppc-dev@lists.ozlabs.org,luto@kernel.org,mhocko@suse.com,mingo@kernel.org,mpe@ellerman.id.au,paulus@samba.org,peterz@infradead.org,rguenther@suse.de,richard@nod.at,riel@surriel.com,tglx@linutronix.de,torvalds@linux-foundation.org,vbabka@suse.cz,yang.shi@linux.alibaba.com
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Thu, 23 May 2019 13:26:35 +0200
Message-ID: <155861079524166@kroah.com>
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

    x86/mpx, mm/core: Fix recursive munmap() corruption

to the 5.1-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mpx-mm-core-fix-recursive-munmap-corruption.patch
and it can be found in the queue-5.1 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From 5a28fc94c9143db766d1ba5480cae82d856ad080 Mon Sep 17 00:00:00 2001
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 19 Apr 2019 12:47:47 -0700
Subject: x86/mpx, mm/core: Fix recursive munmap() corruption

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 5a28fc94c9143db766d1ba5480cae82d856ad080 upstream.

This is a bit of a mess, to put it mildly.  But, it's a bug
that only seems to have showed up in 4.20 but wasn't noticed
until now, because nobody uses MPX.

MPX has the arch_unmap() hook inside of munmap() because MPX
uses bounds tables that protect other areas of memory.  When
memory is unmapped, there is also a need to unmap the MPX
bounds tables.  Barring this, unused bounds tables can eat 80%
of the address space.

But, the recursive do_munmap() that gets called vi arch_unmap()
wreaks havoc with __do_munmap()'s state.  It can result in
freeing populated page tables, accessing bogus VMA state,
double-freed VMAs and more.

See the "long story" further below for the gory details.

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

The long story:

munmap() has a couple of pieces:

 1. Find the affected VMA(s)
 2. Split the start/end one(s) if neceesary
 3. Pull the VMAs out of the rbtree
 4. Actually zap the memory via unmap_region(), including
    freeing page tables (or queueing them to be freed).
 5. Fix up some of the accounting (like fput()) and actually
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

There are some reports that this commit triggered this bug:

  dd2283f2605 ("mm: mmap: zap pages with read mmap_sem in munmap")

While that commit certainly made the issues easier to hit, I believe
the fundamental issue has been with us as long as MPX itself, thus
the Fixes: tag below is for one of the original MPX commits.

[ mingo: Minor edits to the changelog and the patch. ]

Reported-by: Richard Biener <rguenther@suse.de>
Reported-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Yang Shi <yang.shi@linux.alibaba.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Guan Xuetao <gxt@pku.edu.cn>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Richard Weinberger <richard@nod.at>
Cc: Rik van Riel <riel@surriel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-um@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: stable@vger.kernel.org
Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Link: http://lkml.kernel.org/r/20190419194747.5E1AD6DC@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/powerpc/include/asm/mmu_context.h   |    1 -
 arch/um/include/asm/mmu_context.h        |    1 -
 arch/unicore32/include/asm/mmu_context.h |    1 -
 arch/x86/include/asm/mmu_context.h       |    6 +++---
 arch/x86/include/asm/mpx.h               |   15 ++++++++-------
 arch/x86/mm/mpx.c                        |   10 ++++++----
 include/asm-generic/mm_hooks.h           |    1 -
 mm/mmap.c                                |   15 ++++++++-------
 8 files changed, 25 insertions(+), 25 deletions(-)

--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -237,7 +237,6 @@ extern void arch_exit_mmap(struct mm_str
 #endif
 
 static inline void arch_unmap(struct mm_struct *mm,
-			      struct vm_area_struct *vma,
 			      unsigned long start, unsigned long end)
 {
 	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
--- a/arch/um/include/asm/mmu_context.h
+++ b/arch/um/include/asm/mmu_context.h
@@ -22,7 +22,6 @@ static inline int arch_dup_mmap(struct m
 }
 extern void arch_exit_mmap(struct mm_struct *mm);
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -88,7 +88,6 @@ static inline int arch_dup_mmap(struct m
 }
 
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
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
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -64,12 +64,15 @@ struct mpx_fault_info {
 };
 
 #ifdef CONFIG_X86_INTEL_MPX
-int mpx_fault_info(struct mpx_fault_info *info, struct pt_regs *regs);
-int mpx_handle_bd_fault(void);
+
+extern int mpx_fault_info(struct mpx_fault_info *info, struct pt_regs *regs);
+extern int mpx_handle_bd_fault(void);
+
 static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
 {
 	return (mm->context.bd_addr != MPX_INVALID_BOUNDS_DIR);
 }
+
 static inline void mpx_mm_init(struct mm_struct *mm)
 {
 	/*
@@ -78,11 +81,10 @@ static inline void mpx_mm_init(struct mm
 	 */
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
 }
-void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-		      unsigned long start, unsigned long end);
 
-unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len,
-		unsigned long flags);
+extern void mpx_notify_unmap(struct mm_struct *mm, unsigned long start, unsigned long end);
+extern unsigned long mpx_unmapped_area_check(unsigned long addr, unsigned long len, unsigned long flags);
+
 #else
 static inline int mpx_fault_info(struct mpx_fault_info *info, struct pt_regs *regs)
 {
@@ -100,7 +102,6 @@ static inline void mpx_mm_init(struct mm
 {
 }
 static inline void mpx_notify_unmap(struct mm_struct *mm,
-				    struct vm_area_struct *vma,
 				    unsigned long start, unsigned long end)
 {
 }
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -881,9 +881,10 @@ static int mpx_unmap_tables(struct mm_st
  * the virtual address region start...end have already been split if
  * necessary, and the 'vma' is the first vma in this range (start -> end).
  */
-void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long start, unsigned long end)
+void mpx_notify_unmap(struct mm_struct *mm, unsigned long start,
+		      unsigned long end)
 {
+	struct vm_area_struct *vma;
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
--- a/include/asm-generic/mm_hooks.h
+++ b/include/asm-generic/mm_hooks.h
@@ -18,7 +18,6 @@ static inline void arch_exit_mmap(struct
 }
 
 static inline void arch_unmap(struct mm_struct *mm,
-			struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 }
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2735,9 +2735,17 @@ int __do_munmap(struct mm_struct *mm, un
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
@@ -2746,7 +2754,6 @@ int __do_munmap(struct mm_struct *mm, un
 	/* we have  start < vma->vm_end  */
 
 	/* if it doesn't overlap, we have nothing.. */
-	end = start + len;
 	if (vma->vm_start >= end)
 		return 0;
 
@@ -2816,12 +2823,6 @@ int __do_munmap(struct mm_struct *mm, un
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
 


Patches currently in stable-queue which might be from dave.hansen@linux.intel.com are

queue-5.1/x86-mpx-mm-core-fix-recursive-munmap-corruption.patch

