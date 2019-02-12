Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 975B2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4382421773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4382421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2B3A8E0155; Mon, 11 Feb 2019 21:57:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDC7A8E000E; Mon, 11 Feb 2019 21:57:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCBA88E0155; Mon, 11 Feb 2019 21:57:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D93F8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:57:09 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a11so3235068qkk.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:57:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GvwN9xwxYWCuruXX3J+EUqHnFqcdGoMxbaeA6oWA0bQ=;
        b=Fq8nkQP8TbFF+S4KX8qet1n38wImVfIVGTqo1V1qP+H8+xI+sXCKAceWr46goN8DvZ
         IbH7KLfNTK/zXR0NZXSwtj3bD9XEhC2ajO2lYsRf0bHCHtA62avoGFJ8IiF+hhAnQMyG
         8xVMSh2N56eZC85gqVWuOm35x8bLyL7wT8sCdjx9rxtpf+/mElP0WAuvbcJuOxLkOA8C
         I8c0YrsGzqMBf/78xe1NOgAuTSAEEPhiTUZzfXF/7Xu0Uwl1NFx8DzQppH5SaTQSpHkv
         RlYgsZRlGuf4sbbFBOH5peHOHagnrh+vOsW7HP7ljAd43Df1Yd50qstdtCHa4u0z/l/o
         bk/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZxgsDYK+HsUnt8wEDji12a0SLyWn0cqQ6zDv0PB4ijqnLc/9/J
	vt7S/cRyrlOqja9ft8S/zCNKkCTkDdhei+nLmhil9BcKJyH7mPnKBBJyyhxpkGhzoG20/dNL8Rf
	G4+b0zAx8qlH6a3AVBohgdmqOVsQ00fgmsa0PDYO/gMsky+W1hCQPnjDjO86HefaSOw==
X-Received: by 2002:a37:484c:: with SMTP id v73mr1009813qka.196.1549940229312;
        Mon, 11 Feb 2019 18:57:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZjqAdYu1pwmJvIPNT3JnLXR1EO+oYHeXQakGueDuj2b8t7DKbofSh39x4SAM6TpAL/6Kl4
X-Received: by 2002:a37:484c:: with SMTP id v73mr1009778qka.196.1549940228162;
        Mon, 11 Feb 2019 18:57:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940228; cv=none;
        d=google.com; s=arc-20160816;
        b=IJb/tVQ17CAEL1VLd0/Z3Oka/epf7B90pz0/XnpkK6jz0J0szUo+l/R8hJGf9nq4wg
         nDdritwKMzpftgMrbczn8eJ5sp7x4gp9m2sK5lpd1sxQnJnMOsBfCNnMdHLzan4vZFAc
         hdaGCNnyMzvUpvWRM+kaf7PsqfgMsB4pbwqSvAP3mR2qIhn64xqhRW5vQybu590orVVz
         MOyqv/HntSdk7W+FKySjQ3OcE7Fh6gvytqZQpWDfzPyRmM70ItofB8TAQ9CZzdIo5/ZY
         /3UeKUP2fMnlo2p4XCEKSmaxbi/B/4MqL9y8UTyPAPRXOchKuZoX6FQw+uZWrbLopXX/
         oOMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GvwN9xwxYWCuruXX3J+EUqHnFqcdGoMxbaeA6oWA0bQ=;
        b=yMiMeOfsFhlGxREIhFo0TJMKgEJ+0FauLPyISGPixaxPz5XcYFNJ4iNfPYvtL2VydH
         pZitpjtRoNN+cNhWVt3QaIIFrd1154Si+cdnb5e/L/fPX+eIICFB+1uLWHf92TlP+YWf
         cXc8Cx1Hb7nfK+l6/NuAiXzvKvDw6xb+6t/12oXDciGP2Xxxomrj1NWWivAaVyWPJJAn
         vOh+48U7T4GCvqnRDMQmZV4eWEBYHRcTRnMAB+dTda/HBBLKEVculLSDGVV6KzatuGDU
         t+nFNbtI0rINZRPrrTZCZSZ0OHDKkVtt5pYd2f9WH4XSDm40rd6ZsNAIBF1OYpErWtcX
         FQQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 14si6555440qtp.203.2019.02.11.18.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:57:08 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 25B2087633;
	Tue, 12 Feb 2019 02:57:07 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B5B91600CC;
	Tue, 12 Feb 2019 02:56:55 +0000 (UTC)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 02/26] mm: userfault: return VM_FAULT_RETRY on signals
Date: Tue, 12 Feb 2019 10:56:08 +0800
Message-Id: <20190212025632.28946-3-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Feb 2019 02:57:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The idea comes from the upstream discussion between Linus and Andrea:

  https://lkml.org/lkml/2017/10/30/560

A summary to the issue: there was a special path in handle_userfault()
in the past that we'll return a VM_FAULT_NOPAGE when we detected
non-fatal signals when waiting for userfault handling.  We did that by
reacquiring the mmap_sem before returning.  However that brings a risk
in that the vmas might have changed when we retake the mmap_sem and
even we could be holding an invalid vma structure.

This patch removes the special path and we'll return a VM_FAULT_RETRY
with the common path even if we have got such signals.  Then for all
the architectures that is passing in VM_FAULT_ALLOW_RETRY into
handle_mm_fault(), we check not only for SIGKILL but for all the rest
of userspace pending signals right after we returned from
handle_mm_fault().  This can allow the userspace to handle nonfatal
signals faster than before.

This patch is a preparation work for the next patch to finally remove
the special code path mentioned above in handle_userfault().

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c      |  2 +-
 arch/arc/mm/fault.c        | 11 ++++-------
 arch/arm/mm/fault.c        |  6 +++---
 arch/arm64/mm/fault.c      |  6 +++---
 arch/hexagon/mm/vm_fault.c |  2 +-
 arch/ia64/mm/fault.c       |  2 +-
 arch/m68k/mm/fault.c       |  2 +-
 arch/microblaze/mm/fault.c |  2 +-
 arch/mips/mm/fault.c       |  2 +-
 arch/nds32/mm/fault.c      |  6 +++---
 arch/nios2/mm/fault.c      |  2 +-
 arch/openrisc/mm/fault.c   |  2 +-
 arch/parisc/mm/fault.c     |  2 +-
 arch/powerpc/mm/fault.c    |  2 ++
 arch/riscv/mm/fault.c      |  4 ++--
 arch/s390/mm/fault.c       |  9 ++++++---
 arch/sh/mm/fault.c         |  4 ++++
 arch/sparc/mm/fault_32.c   |  3 +++
 arch/sparc/mm/fault_64.c   |  3 +++
 arch/um/kernel/trap.c      |  5 ++++-
 arch/unicore32/mm/fault.c  |  4 ++--
 arch/x86/mm/fault.c        |  6 +++++-
 arch/xtensa/mm/fault.c     |  3 +++
 23 files changed, 56 insertions(+), 34 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index d73dc473fbb9..46e5e420ad2a 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -150,7 +150,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	   the fault.  */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 8df1638259f3..dc5f1b8859d2 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -141,17 +141,14 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if (fatal_signal_pending(current)) {
-
+	if (unlikely(fault & VM_FAULT_RETRY && signal_pending(current))) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
+			goto no_context;
 		/*
 		 * if fault retry, mmap_sem already relinquished by core mm
 		 * so OK to return to user mode (with signal handled first)
 		 */
-		if (fault & VM_FAULT_RETRY) {
-			if (!user_mode(regs))
-				goto no_context;
-			return;
-		}
+		return;
 	}
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 58f69fa07df9..c41c021bbe40 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -314,12 +314,12 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
 
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if (unlikely(fault & VM_FAULT_RETRY && signal_pending(current))) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
 		return 0;
 	}
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index efb7b2cbead5..a38ff8c49a66 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -512,13 +512,13 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 
 	if (fault & VM_FAULT_RETRY) {
 		/*
-		 * If we need to retry but a fatal signal is pending,
+		 * If we need to retry but a signal is pending,
 		 * handle the signal first. We do not need to release
 		 * the mmap_sem because it would already be released
 		 * in __lock_page_or_retry in mm/filemap.c.
 		 */
-		if (fatal_signal_pending(current)) {
-			if (!user_mode(regs))
+		if (signal_pending(current)) {
+			if (fatal_signal_pending(current) && !user_mode(regs))
 				goto no_context;
 			return 0;
 		}
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index eb263e61daf4..be10b441d9cc 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -104,7 +104,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	/* The most common case -- we are done. */
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 5baeb022f474..62c2d39d2bed 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -163,7 +163,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 9b6163c05a75..d9808a807ab8 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -138,7 +138,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	fault = handle_mm_fault(vma, address, flags);
 	pr_debug("handle_mm_fault returns %x\n", fault);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return 0;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 202ad6a494f5..4fd2dbd0c5ca 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -217,7 +217,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 73d8a0f0b810..92374fd091d2 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -154,7 +154,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index 68d5f2a27f38..9f6e477b9e30 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -206,12 +206,12 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if (fault & VM_FAULT_RETRY && signal_pending(current)) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
 		return;
 	}
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 24fd84cf6006..5939434a31ae 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -134,7 +134,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index dc4dbafc1d83..873ecb5d82d7 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -165,7 +165,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index c8e8b7c05558..29422eec329d 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -303,7 +303,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 887f11bcf330..aaa853e6592f 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -591,6 +591,8 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 			 */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
+			if (is_user && signal_pending(current))
+				return 0;
 			if (!fatal_signal_pending(current))
 				goto retry;
 		}
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 88401d5125bc..4fc8d746bec3 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -123,11 +123,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(tsk))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(tsk))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 11613362c4e7..aba1dad1efcd 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -476,9 +476,12 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 	 * the fault.
 	 */
 	fault = handle_mm_fault(vma, address, flags);
-	/* No reason to continue if interrupted by SIGKILL. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		fault = VM_FAULT_SIGNAL;
+	/* Do not continue if interrupted by signals. */
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current)) {
+		if (fatal_signal_pending(current))
+			fault = VM_FAULT_SIGNAL;
+		else
+			fault = 0;
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			goto out_up;
 		goto out;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 6defd2c6d9b1..baf5d73df40c 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -506,6 +506,10 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 			 * have already released it in __lock_page_or_retry
 			 * in mm/filemap.c.
 			 */
+
+			if (user_mode(regs) && signal_pending(tsk))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index b0440b0edd97..a2c83104fe35 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -269,6 +269,9 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(tsk))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 8f8a604c1300..cad71ec5c7b3 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -467,6 +467,9 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(current))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 0e8b6158f224..09baf37b65b9 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -76,8 +76,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 
 		fault = handle_mm_fault(vma, address, flags);
 
-		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+		if (fault & VM_FAULT_RETRY && signal_pending(current)) {
+			if (is_user && !fatal_signal_pending(current))
+				err = 0;
 			goto out_nosemaphore;
+		}
 
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index b9a3a50644c1..3611f19234a1 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -248,11 +248,11 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	fault = __do_pf(mm, addr, fsr, flags, tsk);
 
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return 0;
 
 	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_RETRY)) {
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9d5c75f02295..248ff0a28ecd 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1481,16 +1481,20 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * that we made any progress. Handle this case first.
 	 */
 	if (unlikely(fault & VM_FAULT_RETRY)) {
+		bool is_user = flags & FAULT_FLAG_USER;
+
 		/* Retry at most once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
+			if (is_user && signal_pending(tsk))
+				return;
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
 
 		/* User mode? Just return to handle the fatal exception */
-		if (flags & FAULT_FLAG_USER)
+		if (is_user)
 			return;
 
 		/* Not returning to user mode? Handle exceptions or die: */
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 2ab0e0dcd166..792dad5e2f12 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -136,6 +136,9 @@ void do_page_fault(struct pt_regs *regs)
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(current))
+				return;
+
 			goto retry;
 		}
 	}
-- 
2.17.1

