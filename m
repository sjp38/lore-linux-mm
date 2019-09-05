Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9920CC3A5AA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CF4121883
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:16:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CF4121883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04146B027B; Thu,  5 Sep 2019 06:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB8466B027C; Thu,  5 Sep 2019 06:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA59F6B027D; Thu,  5 Sep 2019 06:16:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id A11686B027B
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:16:06 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id F2B0D21EA
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:05 +0000 (UTC)
X-FDA: 75900461490.09.house74_5247d51e2ac0a
X-HE-Tag: house74_5247d51e2ac0a
X-Filterd-Recvd-Size: 17125
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:05 +0000 (UTC)
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8EDE42A09D4
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:16:04 +0000 (UTC)
Received: by mail-pg1-f197.google.com with SMTP id e20so1046910pgt.22
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 03:16:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=iMX6s7oeTnBzBZ0zA0kNaUvnXYwB9KFfx/CrFTaSGBQ=;
        b=MgR8qcmCN/IMmuCkj/qcSyLQhJoD2DLNKEmJGpMJlNFP6XWocnVgqIpGt/76Cj0rxb
         ZaqQOzgmgP9BXYGUzedCHu6Y8ycnGrJOlz4ULH827zCqgx2fxvKtxPdxuUG0OpGF9mUz
         4z4dTlYYsGeFNTDwi7/JPyr1FS4POrliQIqWCyLc4Pc/5RtwqvHVBpW7IKIa1RGh19jp
         iPXDiYPd7A3xFz7rF64QuNdCyKGzjdpOpI3YdY0AU/9aeYulKUd0yU8yurdEotweYmFe
         Mi+e/BlfPPpY52as9FHE41wsAIkDPAfik8sjl2p0uJyQOFWl3/K0f3VraVcfFrBrIzih
         llEA==
X-Gm-Message-State: APjAAAVoCUnT65unjIuxTKPECEZsQUq+uLaROzumwnAzxVaJYZQqVyZt
	YJLsfWKzf6vRynBNKp6msoI+OMxPLsjRhSiG5ORTimQRH4Klz+yP+C/o6HmWRXgFRoQdfAas5Gq
	zX2EhNzW+jIE=
X-Received: by 2002:a62:2ac4:: with SMTP id q187mr2756398pfq.242.1567678563394;
        Thu, 05 Sep 2019 03:16:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyK238bn3DlfGpKaLHvH7uK39heRDkCDTdIqTCq8iMKx9YlL0fNL0Th6egAE0DovW2vcv3nzA==
X-Received: by 2002:a62:2ac4:: with SMTP id q187mr2756355pfq.242.1567678563032;
        Thu, 05 Sep 2019 03:16:03 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id a20sm413852pfo.33.2019.09.05.03.15.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 03:16:02 -0700 (PDT)
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
Subject: [PATCH v2 2/7] mm: Introduce FAULT_FLAG_DEFAULT
Date: Thu,  5 Sep 2019 18:15:29 +0800
Message-Id: <20190905101534.9637-3-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190905101534.9637-1-peterx@redhat.com>
References: <20190905101534.9637-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Although there're tons of arch-specific page fault handlers, most of
them are still sharing the same initial value of the page fault flags.
Say, merely all of the page fault handlers would allow the fault to be
retried, and they also allow the fault to respond to SIGKILL.

Let's define a default value for the fault flags to replace those
initial page fault flags that were copied over.  With this, it'll be
far easier to introduce new fault flag that can be used by all the
architectures instead of touching all the archs.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c      | 2 +-
 arch/arc/mm/fault.c        | 2 +-
 arch/arm/mm/fault.c        | 2 +-
 arch/arm64/mm/fault.c      | 2 +-
 arch/hexagon/mm/vm_fault.c | 2 +-
 arch/ia64/mm/fault.c       | 2 +-
 arch/m68k/mm/fault.c       | 2 +-
 arch/microblaze/mm/fault.c | 2 +-
 arch/mips/mm/fault.c       | 2 +-
 arch/nds32/mm/fault.c      | 2 +-
 arch/nios2/mm/fault.c      | 2 +-
 arch/openrisc/mm/fault.c   | 2 +-
 arch/parisc/mm/fault.c     | 2 +-
 arch/powerpc/mm/fault.c    | 2 +-
 arch/riscv/mm/fault.c      | 2 +-
 arch/s390/mm/fault.c       | 2 +-
 arch/sh/mm/fault.c         | 2 +-
 arch/sparc/mm/fault_32.c   | 2 +-
 arch/sparc/mm/fault_64.c   | 2 +-
 arch/um/kernel/trap.c      | 2 +-
 arch/unicore32/mm/fault.c  | 2 +-
 arch/x86/mm/fault.c        | 2 +-
 arch/xtensa/mm/fault.c     | 2 +-
 include/linux/mm.h         | 7 +++++++
 24 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 741e61ef9d3f..de4cc6936391 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -89,7 +89,7 @@ do_page_fault(unsigned long address, unsigned long mmcs=
r,
 	const struct exception_table_entry *fixup;
 	int si_code =3D SEGV_MAPERR;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
 	   (or is suppressed by the PALcode).  Support that for older CPUs
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 3861543b66a0..61919e4e4eec 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -94,7 +94,7 @@ void do_page_fault(unsigned long address, struct pt_reg=
s *regs)
 	         (regs->ecr_cause =3D=3D ECR_C_PROTV_INST_FETCH))
 		exec =3D 1;
=20
-	flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	flags =3D FAULT_FLAG_DEFAULT;
 	if (user_mode(regs))
 		flags |=3D FAULT_FLAG_USER;
 	if (write)
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 890eeaac3cbb..2ae28ffec622 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -241,7 +241,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, s=
truct pt_regs *regs)
 	struct mm_struct *mm;
 	int sig, code;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	if (kprobe_page_fault(regs, fsr))
 		return 0;
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index cfd65b63f36f..613e7434c208 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -410,7 +410,7 @@ static int __kprobes do_page_fault(unsigned long addr=
, unsigned int esr,
 	struct mm_struct *mm =3D current->mm;
 	vm_fault_t fault, major =3D 0;
 	unsigned long vm_flags =3D VM_READ | VM_WRITE;
-	unsigned int mm_flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int mm_flags =3D FAULT_FLAG_DEFAULT;
=20
 	if (kprobe_page_fault(regs, esr))
 		return 0;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index b3bc71680ae4..223787e01bdd 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -41,7 +41,7 @@ void do_page_fault(unsigned long address, long cause, s=
truct pt_regs *regs)
 	int si_code =3D SEGV_MAPERR;
 	vm_fault_t fault;
 	const struct exception_table_entry *fixup;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	/*
 	 * If we're in an interrupt or have no user context,
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index c2f299fe9e04..d039b846f671 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -65,7 +65,7 @@ ia64_do_page_fault (unsigned long address, unsigned lon=
g isr, struct pt_regs *re
 	struct mm_struct *mm =3D current->mm;
 	unsigned long mask;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	mask =3D ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
 		| (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WRITE_BIT));
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index e9b1d7585b43..8e734309ace9 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -71,7 +71,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long a=
ddress,
 	struct mm_struct *mm =3D current->mm;
 	struct vm_area_struct * vma;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	pr_debug("do page fault:\nregs->sr=3D%#x, regs->pc=3D%#lx, address=3D%#=
lx, %ld, %p\n",
 		regs->sr, regs->pc, address, error_code, mm ? mm->pgd : NULL);
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index e6a810b0c7ad..45c9f66c1dbc 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -91,7 +91,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long =
address,
 	int code =3D SEGV_MAPERR;
 	int is_write =3D error_code & ESR_S;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	regs->ear =3D address;
 	regs->esr =3D error_code;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index f589aa8f47d9..6660b77ff8f3 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -44,7 +44,7 @@ static void __kprobes __do_page_fault(struct pt_regs *r=
egs, unsigned long write,
 	const int field =3D sizeof(unsigned long) * 2;
 	int si_code;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	static DEFINE_RATELIMIT_STATE(ratelimit_state, 5 * HZ, 10);
=20
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index 064ae5d2159d..a40de112a23a 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -76,7 +76,7 @@ void do_page_fault(unsigned long entry, unsigned long a=
ddr,
 	int si_code;
 	vm_fault_t fault;
 	unsigned int mask =3D VM_READ | VM_WRITE | VM_EXEC;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	error_code =3D error_code & (ITYPE_mskINST | ITYPE_mskETYPE);
 	tsk =3D current;
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 6a2e716b959f..a401b45cae47 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -47,7 +47,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, uns=
igned long cause,
 	struct mm_struct *mm =3D tsk->mm;
 	int code =3D SEGV_MAPERR;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	cause >>=3D 2;
=20
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 5d4d3a9691d0..fd1592a56238 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -50,7 +50,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, uns=
igned long address,
 	struct vm_area_struct *vma;
 	int si_code;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	tsk =3D current;
=20
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index adbd5e2144a3..355e3e13fa72 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -274,7 +274,7 @@ void do_page_fault(struct pt_regs *regs, unsigned lon=
g code,
 	if (!mm)
 		goto no_context;
=20
-	flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	flags =3D FAULT_FLAG_DEFAULT;
 	if (user_mode(regs))
 		flags |=3D FAULT_FLAG_USER;
=20
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 8432c281de92..408ee769c470 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -435,7 +435,7 @@ static int __do_page_fault(struct pt_regs *regs, unsi=
gned long address,
 {
 	struct vm_area_struct * vma;
 	struct mm_struct *mm =3D current->mm;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
  	int is_exec =3D TRAP(regs) =3D=3D 0x400;
 	int is_user =3D user_mode(regs);
 	int is_write =3D page_fault_is_write(error_code);
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 96add1427a75..deeb820bd855 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -28,7 +28,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long addr, cause;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
 	int code =3D SEGV_MAPERR;
 	vm_fault_t fault;
=20
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 7b0bb475c166..74a77b2bca75 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -429,7 +429,7 @@ static inline vm_fault_t do_exception(struct pt_regs =
*regs, int access)
=20
 	address =3D trans_exc_code & __FAIL_ADDR_MASK;
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
-	flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	flags =3D FAULT_FLAG_DEFAULT;
 	if (user_mode(regs))
 		flags |=3D FAULT_FLAG_USER;
 	if (access =3D=3D VM_WRITE || (trans_exc_code & store_indication) =3D=3D=
 0x400)
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 5f51456f4fc7..becf0be267bb 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -380,7 +380,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_reg=
s *regs,
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	tsk =3D current;
 	mm =3D tsk->mm;
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 8d69de111470..0863f6fdd2c5 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -168,7 +168,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, =
int text_fault, int write,
 	int from_user =3D !(regs->psr & PSR_PS);
 	int code;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	if (text_fault)
 		address =3D regs->pc;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 2371fb6b97e4..a1cba3eef79e 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -267,7 +267,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_=
regs *regs)
 	int si_code, fault_code;
 	vm_fault_t fault;
 	unsigned long address, mm_rss;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	fault_code =3D get_thread_fault_code();
=20
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 58fe36856182..bc2756782d64 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -32,7 +32,7 @@ int handle_page_fault(unsigned long address, unsigned l=
ong ip,
 	pmd_t *pmd;
 	pte_t *pte;
 	int err =3D -EFAULT;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	*code_out =3D SEGV_MAPERR;
=20
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 76342de9cf8c..60453c892c51 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -202,7 +202,7 @@ static int do_pf(unsigned long addr, unsigned int fsr=
, struct pt_regs *regs)
 	struct mm_struct *mm;
 	int sig, code;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	tsk =3D current;
 	mm =3D tsk->mm;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9ceacd1156db..994c860ac2d8 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1287,7 +1287,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	vm_fault_t fault, major =3D 0;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	tsk =3D current;
 	mm =3D tsk->mm;
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index f81b1478da61..d2b082908538 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -43,7 +43,7 @@ void do_page_fault(struct pt_regs *regs)
=20
 	int is_write, is_exec;
 	vm_fault_t fault;
-	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	unsigned int flags =3D FAULT_FLAG_DEFAULT;
=20
 	code =3D SEGV_MAPERR;
=20
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..57fb5c535f8e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -393,6 +393,13 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruc=
tion fetch */
=20
+/*
+ * The default fault flags that should be used by most of the
+ * arch-specific page fault handlers.
+ */
+#define FAULT_FLAG_DEFAULT  (FAULT_FLAG_ALLOW_RETRY | \
+			     FAULT_FLAG_KILLABLE)
+
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
 	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \
--=20
2.21.0


