Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9C30ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CD23222BF
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CD23222BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D8526B000C; Wed, 11 Sep 2019 03:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AFE06B000D; Wed, 11 Sep 2019 03:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F06106B000E; Wed, 11 Sep 2019 03:10:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id C5B376B000C
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:10:50 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3DAA3824CA3F
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:50 +0000 (UTC)
X-FDA: 75921767460.23.cork11_7ba09f6a73f2a
X-HE-Tag: cork11_7ba09f6a73f2a
X-Filterd-Recvd-Size: 19806
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:49 +0000 (UTC)
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5052C796EB
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:48 +0000 (UTC)
Received: by mail-pg1-f200.google.com with SMTP id m17so12159792pgh.21
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 00:10:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=0nEw8OAi2qZaszwJFzF1LByyK8VJPwpm+mPV/8Jjhrc=;
        b=rSQLV+MUkDFIUeFdSetXmx36Tn3LpsgQZqVRx77RtaxMM9DGA3zPgrlXilZWPmwfH3
         fgQB1yS45hPOwdT35DJ4RNKYm4D9y9PbJ1htStjMNYHD53Wcgcg+06L1RfAy4WtFS3Uh
         QkkhGjELzTXp1Hr2jy+ZumB4Hmzo0pzo4Tzv1R0balm0e8baF64CBYOLZQkpP1Z0f12Q
         V1JNybeAu/ussi6DBr38wJUqAmLCcX8l6op1uHTRSC44iswQSL0cvo8OllKxWvop+NjY
         2iWDZp3m8s4AKkI6X7ZAaJgsQ4vQhhykDY+f/JfFVfQyLSfoocc+OEnDumKDnPg3qDW6
         o+Bw==
X-Gm-Message-State: APjAAAU+mwbCSHiF6WF8jKvyuramB1sN1wa3kR3FL9T9ps2Y7K9qtyVC
	R7pdaZcs3nSP3QLy53KwERXOf6oqtPWaN/qW3DmKGBIf8+788OnKnW5qYOk5Ithncl8Wwk7RQHe
	qGfx4zG4g874=
X-Received: by 2002:a62:52d0:: with SMTP id g199mr41347109pfb.120.1568185847534;
        Wed, 11 Sep 2019 00:10:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIWZudHJrwibmBOwIls8/LydpUvOHGVp72vDAmrYxh+cgi6+mMCatsxVL8SUjZfewcoS0qAA==
X-Received: by 2002:a62:52d0:: with SMTP id g199mr41347055pfb.120.1568185847130;
        Wed, 11 Sep 2019 00:10:47 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j10sm1573091pjn.3.2019.09.11.00.10.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 00:10:46 -0700 (PDT)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 4/7] mm: Return faster for non-fatal signals in user mode faults
Date: Wed, 11 Sep 2019 15:10:04 +0800
Message-Id: <20190911071007.20077-5-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190911071007.20077-1-peterx@redhat.com>
References: <20190911071007.20077-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
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

This patch is a preparation of removing that special path by allowing
the page fault to return even faster if we were interrupted by a
non-fatal signal during a user-mode page fault handling routine.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c        |  3 ++-
 arch/arc/mm/fault.c          |  5 +++++
 arch/arm/mm/fault.c          |  9 +++++----
 arch/arm64/mm/fault.c        |  9 +++++----
 arch/hexagon/mm/vm_fault.c   |  3 ++-
 arch/ia64/mm/fault.c         |  3 ++-
 arch/m68k/mm/fault.c         |  5 +++--
 arch/microblaze/mm/fault.c   |  3 ++-
 arch/mips/mm/fault.c         |  3 ++-
 arch/nds32/mm/fault.c        |  9 +++++----
 arch/nios2/mm/fault.c        |  3 ++-
 arch/openrisc/mm/fault.c     |  3 ++-
 arch/parisc/mm/fault.c       |  3 ++-
 arch/powerpc/mm/fault.c      |  2 ++
 arch/riscv/mm/fault.c        |  5 +++--
 arch/s390/mm/fault.c         |  4 ++--
 arch/sh/mm/fault.c           |  4 ++++
 arch/sparc/mm/fault_32.c     |  2 +-
 arch/sparc/mm/fault_64.c     |  3 ++-
 arch/um/kernel/trap.c        |  4 +++-
 arch/unicore32/mm/fault.c    |  5 +++--
 arch/x86/mm/fault.c          |  2 ++
 arch/xtensa/mm/fault.c       |  3 ++-
 include/linux/sched/signal.h | 12 ++++++++++++
 24 files changed, 75 insertions(+), 32 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index de4cc6936391..ab1d4212d658 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -150,7 +150,8 @@ do_page_fault(unsigned long address, unsigned long mm=
csr,
 	   the fault.  */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 61919e4e4eec..27adf4e608e4 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -142,6 +142,11 @@ void do_page_fault(unsigned long address, struct pt_=
regs *regs)
 				goto no_context;
 			return;
 		}
+
+		/* Allow user to handle non-fatal signals first */
+		if (signal_pending(current) && user_mode(regs))
+			return;
+
 		/*
 		 * retry state machine
 		 */
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 2ae28ffec622..f00fb4eafe54 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -291,14 +291,15 @@ do_page_fault(unsigned long addr, unsigned int fsr,=
 struct pt_regs *regs)
=20
 	fault =3D __do_page_fault(mm, addr, fsr, flags, tsk);
=20
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, try to handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if (unlikely(fault & VM_FAULT_RETRY && signal_pending(current))) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
-		return 0;
+		if (user_mode(regs))
+			return 0;
 	}
=20
 	/*
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 613e7434c208..0d3fe0ea6a70 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -479,15 +479,16 @@ static int __kprobes do_page_fault(unsigned long ad=
dr, unsigned int esr,
=20
 	if (fault & VM_FAULT_RETRY) {
 		/*
-		 * If we need to retry but a fatal signal is pending,
+		 * If we need to retry but a signal is pending, try to
 		 * handle the signal first. We do not need to release
 		 * the mmap_sem because it would already be released
 		 * in __lock_page_or_retry in mm/filemap.c.
 		 */
-		if (fatal_signal_pending(current)) {
-			if (!user_mode(regs))
+		if (signal_pending(current)) {
+			if (fatal_signal_pending(current) && !user_mode(regs))
 				goto no_context;
-			return 0;
+			if (user_mode(regs))
+				return 0;
 		}
=20
 		/*
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 223787e01bdd..88a2e5635bfb 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -91,7 +91,8 @@ void do_page_fault(unsigned long address, long cause, s=
truct pt_regs *regs)
=20
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	/* The most common case -- we are done. */
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index d039b846f671..8d47acf50fda 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -141,7 +141,8 @@ ia64_do_page_fault (unsigned long address, unsigned l=
ong isr, struct pt_regs *re
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 8e734309ace9..103f93ba8139 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -138,8 +138,9 @@ int do_page_fault(struct pt_regs *regs, unsigned long=
 address,
 	fault =3D handle_mm_fault(vma, address, flags);
 	pr_debug("handle_mm_fault returns %x\n", fault);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
-		return 0;
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
+		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 45c9f66c1dbc..8b0615eab4b6 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -217,7 +217,8 @@ void do_page_fault(struct pt_regs *regs, unsigned lon=
g address,
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 6660b77ff8f3..48aac20a1ded 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -154,7 +154,8 @@ static void __kprobes __do_page_fault(struct pt_regs =
*regs, unsigned long write,
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index a40de112a23a..baa44f9d0b4a 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -206,14 +206,15 @@ void do_page_fault(unsigned long entry, unsigned lo=
ng addr,
 	fault =3D handle_mm_fault(vma, addr, flags);
=20
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, try to handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current)) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
-		return;
+		if (user_mode(regs))
+			return;
 	}
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index a401b45cae47..f9f178484184 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -133,7 +133,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, u=
nsigned long cause,
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index fd1592a56238..8ba3696dd10c 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -161,7 +161,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs, u=
nsigned long address,
=20
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 355e3e13fa72..163dcb080c7b 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -304,7 +304,8 @@ void do_page_fault(struct pt_regs *regs, unsigned lon=
g code,
=20
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 408ee769c470..d321a6c5fe62 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -596,6 +596,8 @@ static int __do_page_fault(struct pt_regs *regs, unsi=
gned long address,
 			 */
 			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
+			if (is_user && signal_pending(current))
+				return 0;
 			if (!fatal_signal_pending(current))
 				goto retry;
 		}
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index deeb820bd855..ea8f301de65b 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -111,11 +111,12 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	fault =3D handle_mm_fault(vma, addr, flags);
=20
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, try to handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(tsk))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 74a77b2bca75..3ad77501deef 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -480,8 +480,8 @@ static inline vm_fault_t do_exception(struct pt_regs =
*regs, int access)
 	 * the fault.
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
-	/* No reason to continue if interrupted by SIGKILL. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs))) {
 		fault =3D VM_FAULT_SIGNAL;
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			goto out_up;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index becf0be267bb..f620282a37fd 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -489,6 +489,10 @@ asmlinkage void __kprobes do_page_fault(struct pt_re=
gs *regs,
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
index 0863f6fdd2c5..9af0c3ad50d6 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -237,7 +237,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, =
int text_fault, int write,
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fault_should_check_signal(from_user))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index a1cba3eef79e..566f05f9040b 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -421,7 +421,8 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_=
regs *regs)
=20
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(flags & FAULT_FLAG_USER))
 		goto exit_exception;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index bc2756782d64..3c72111f27e9 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -76,7 +76,9 @@ int handle_page_fault(unsigned long address, unsigned l=
ong ip,
=20
 		fault =3D handle_mm_fault(vma, address, flags);
=20
-		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+
+		if ((fault & VM_FAULT_RETRY) &&
+		    fault_should_check_signal(is_user))
 			goto out_nosemaphore;
=20
 		if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 60453c892c51..04c193439c97 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -246,11 +246,12 @@ static int do_pf(unsigned long addr, unsigned int f=
sr, struct pt_regs *regs)
=20
 	fault =3D __do_pf(mm, addr, fsr, flags, tsk);
=20
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, try to handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return 0;
=20
 	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_RETRY)) {
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 994c860ac2d8..f7836472961e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1451,6 +1451,8 @@ void do_user_addr_fault(struct pt_regs *regs,
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
 			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
+			if ((flags & FAULT_FLAG_USER) && signal_pending(tsk))
+				return;
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index d2b082908538..094606676c36 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -110,7 +110,8 @@ void do_page_fault(struct pt_regs *regs)
 	 */
 	fault =3D handle_mm_fault(vma, address, flags);
=20
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) &&
+	    fault_should_check_signal(user_mode(regs)))
 		return;
=20
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index efd8ce7675ed..ccce63f2822d 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -377,6 +377,18 @@ static inline int signal_pending_state(long state, s=
truct task_struct *p)
 	return (state & TASK_INTERRUPTIBLE) || __fatal_signal_pending(p);
 }
=20
+/*
+ * This should only be used in fault handlers to decide whether we
+ * should stop the current fault routine to handle the signals
+ * instead.  It should normally be used when a signal interrupted a
+ * page fault which can lead to a VM_FAULT_RETRY.
+ */
+static inline bool fault_should_check_signal(bool is_user)
+{
+	return (fatal_signal_pending(current) ||
+		(is_user && signal_pending(current)));
+}
+
 /*
  * Reevaluate whether the task has signals pending delivery.
  * Wake the task if so.
--=20
2.21.0


