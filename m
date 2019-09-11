Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97373ECDE28
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:11:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EB1D2084D
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:11:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EB1D2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1EAE6B0005; Wed, 11 Sep 2019 03:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF57F6B000E; Wed, 11 Sep 2019 03:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C956F6B0010; Wed, 11 Sep 2019 03:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 99DA06B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:11:05 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 55B291F23F
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:11:05 +0000 (UTC)
X-FDA: 75921768090.10.juice15_7dd3ad69dbe53
X-HE-Tag: juice15_7dd3ad69dbe53
X-Filterd-Recvd-Size: 23358
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:11:04 +0000 (UTC)
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 956BD796EB
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:11:03 +0000 (UTC)
Received: by mail-pf1-f198.google.com with SMTP id n186so14999983pfn.6
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 00:11:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=RteZilvrp+Hc7vY9UjUpix1iBfAzoNk2FpSYPfWtuOg=;
        b=P6D5KVESjpxPBU4dt7S35oRyqoUeVW0gRIaQ+8DjFJX+8MqW0ePZjpUO7OeFkerYiJ
         LsuVKErUjGNx7fhKWCGdDanV5nuEGtyjkEa55YoRy87GK7D7du0Nld876NBW02mjBK0T
         A2IaCLjg+MsOfsKzYs0sClDRzzdl22R1I/ynhV3OcqTt2Mv6ii0NJt/lIXhPnZKqQ/IZ
         fpgjk+j9j9xTdt5ANkZf6RAsP0pLrwwX5dKPH1v0KH+rnCS8rJucDdDWKTSZj0/h+3ff
         YAGc083RoX3+aquALibqYekZd3mQppWn8AvSwXukktXPagc1Jwb4G+ks7t8vYF8PVOA2
         Qcvw==
X-Gm-Message-State: APjAAAWRJ/RxwcF5qpXTJWSuY4KXDlyQmSCJWJWP4wDmYFHgYUucXoje
	2+c+RmJG6DwPe8vZZdrDFE3UC4BUHKy8P9KoyAkKi8yHcQTAxOh4K/0B1ZFPMRxvZIYZ/5S1yk8
	eDp/pVXldESo=
X-Received: by 2002:a65:680b:: with SMTP id l11mr13681679pgt.35.1568185861035;
        Wed, 11 Sep 2019 00:11:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfKvyHkx/Z5O05BZuxLuVrR0hkB9jlqlJlxu2Q/wpp9mtRYdhBifukXGHiPXxEcOvRJqWEIg==
X-Received: by 2002:a65:680b:: with SMTP id l11mr13681628pgt.35.1568185860456;
        Wed, 11 Sep 2019 00:11:00 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j10sm1573091pjn.3.2019.09.11.00.10.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 00:10:59 -0700 (PDT)
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
Subject: [PATCH v3 6/7] mm: Allow VM_FAULT_RETRY for multiple times
Date: Wed, 11 Sep 2019 15:10:06 +0800
Message-Id: <20190911071007.20077-7-peterx@redhat.com>
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

The idea comes from a discussion between Linus and Andrea [1].

Before this patch we only allow a page fault to retry once.  We
achieved this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
handle_mm_fault() the second time.  This was majorly used to avoid
unexpected starvation of the system by looping over forever to handle
the page fault on a single page.  However that should hardly happen,
and after all for each code path to return a VM_FAULT_RETRY we'll
first wait for a condition (during which time we should possibly yield
the cpu) to happen before VM_FAULT_RETRY is really returned.

This patch removes the restriction by keeping the
FAULT_FLAG_ALLOW_RETRY flag when we receive VM_FAULT_RETRY.  It means
that the page fault handler now can retry the page fault for multiple
times if necessary without the need to generate another page fault
event.  Meanwhile we still keep the FAULT_FLAG_TRIED flag so page
fault handler can still identify whether a page fault is the first
attempt or not.

Then we'll have these combinations of fault flags (only considering
ALLOW_RETRY flag and TRIED flag):

  - ALLOW_RETRY and !TRIED:  this means the page fault allows to
                             retry, and this is the first try

  - ALLOW_RETRY and TRIED:   this means the page fault allows to
                             retry, and this is not the first try

  - !ALLOW_RETRY and !TRIED: this means the page fault does not allow
                             to retry at all

  - !ALLOW_RETRY and TRIED:  this is forbidden and should never be used

In existing code we have multiple places that has taken special care
of the first condition above by checking against (fault_flags &
FAULT_FLAG_ALLOW_RETRY).  This patch introduces a simple helper to
detect the first retry of a page fault by checking against
both (fault_flags & FAULT_FLAG_ALLOW_RETRY) and !(fault_flag &
FAULT_FLAG_TRIED) because now even the 2nd try will have the
ALLOW_RETRY set, then use that helper in all existing special paths.
One example is in __lock_page_or_retry(), now we'll drop the mmap_sem
only in the first attempt of page fault and we'll keep it in follow up
retries, so old locking behavior will be retained.

This will be a nice enhancement for current code [2] at the same time
a supporting material for the future userfaultfd-writeprotect work,
since in that work there will always be an explicit userfault
writeprotect retry for protected pages, and if that cannot resolve the
page fault (e.g., when userfaultfd-writeprotect is used in conjunction
with swapped pages) then we'll possibly need a 3rd retry of the page
fault.  It might also benefit other potential users who will have
similar requirement like userfault write-protection.

GUP code is not touched yet and will be covered in follow up patch.

Please read the thread below for more information.

[1] https://lkml.org/lkml/2017/11/2/833
[2] https://lkml.org/lkml/2018/12/30/64

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c           |  2 +-
 arch/arc/mm/fault.c             |  1 -
 arch/arm/mm/fault.c             |  3 ---
 arch/arm64/mm/fault.c           |  5 -----
 arch/hexagon/mm/vm_fault.c      |  1 -
 arch/ia64/mm/fault.c            |  1 -
 arch/m68k/mm/fault.c            |  3 ---
 arch/microblaze/mm/fault.c      |  1 -
 arch/mips/mm/fault.c            |  1 -
 arch/nds32/mm/fault.c           |  1 -
 arch/nios2/mm/fault.c           |  3 ---
 arch/openrisc/mm/fault.c        |  1 -
 arch/parisc/mm/fault.c          |  4 +---
 arch/powerpc/mm/fault.c         |  6 ------
 arch/riscv/mm/fault.c           |  5 -----
 arch/s390/mm/fault.c            |  5 +----
 arch/sh/mm/fault.c              |  1 -
 arch/sparc/mm/fault_32.c        |  1 -
 arch/sparc/mm/fault_64.c        |  1 -
 arch/um/kernel/trap.c           |  1 -
 arch/unicore32/mm/fault.c       |  4 +---
 arch/x86/mm/fault.c             |  2 --
 arch/xtensa/mm/fault.c          |  1 -
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 12 ++++++++---
 include/linux/mm.h              | 37 +++++++++++++++++++++++++++++++++
 mm/filemap.c                    |  2 +-
 mm/shmem.c                      |  2 +-
 27 files changed, 52 insertions(+), 55 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index ab1d4212d658..e032d2d03012 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -170,7 +170,7 @@ do_page_fault(unsigned long address, unsigned long mm=
csr,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
+			flags |=3D FAULT_FLAG_TRIED;
=20
 			 /* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 27adf4e608e4..bbcde83e010a 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -151,7 +151,6 @@ void do_page_fault(unsigned long address, struct pt_r=
egs *regs)
 		 * retry state machine
 		 */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index f00fb4eafe54..5f1fb46a37b0 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -320,9 +320,6 @@ do_page_fault(unsigned long addr, unsigned int fsr, s=
truct pt_regs *regs)
 					regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			* of starvation. */
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 0d3fe0ea6a70..8c26097bcf0d 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -491,12 +491,7 @@ static int __kprobes do_page_fault(unsigned long add=
r, unsigned int esr,
 				return 0;
 		}
=20
-		/*
-		 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk of
-		 * starvation.
-		 */
 		if (mm_flags & FAULT_FLAG_ALLOW_RETRY) {
-			mm_flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			mm_flags |=3D FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 88a2e5635bfb..a299d2142cbb 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -103,7 +103,6 @@ void do_page_fault(unsigned long address, long cause,=
 struct pt_regs *regs)
 			else
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
-				flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 				flags |=3D FAULT_FLAG_TRIED;
 				goto retry;
 			}
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 8d47acf50fda..7679e960c685 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -168,7 +168,6 @@ ia64_do_page_fault (unsigned long address, unsigned l=
ong isr, struct pt_regs *re
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 103f93ba8139..d4ef4fdf4de4 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -163,9 +163,6 @@ int do_page_fault(struct pt_regs *regs, unsigned long=
 address,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/*
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 8b0615eab4b6..9a359568f70a 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -237,7 +237,6 @@ void do_page_fault(struct pt_regs *regs, unsigned lon=
g address,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/*
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 48aac20a1ded..5eeea572ff3f 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -179,7 +179,6 @@ static void __kprobes __do_page_fault(struct pt_regs =
*regs, unsigned long write,
 			tsk->min_flt++;
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/*
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index baa44f9d0b4a..954ca83d3289 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -243,7 +243,6 @@ void do_page_fault(unsigned long entry, unsigned long=
 addr,
 				      1, regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index f9f178484184..07f467577e77 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -158,9 +158,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, u=
nsigned long cause,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/*
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 8ba3696dd10c..e7dadbdb21b3 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -182,7 +182,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, u=
nsigned long address,
 		else
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 163dcb080c7b..c837da780a79 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -329,14 +329,12 @@ void do_page_fault(struct pt_regs *regs, unsigned l=
ong code,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
-
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
 			 * in mm/filemap.c.
 			 */
-
+			flags |=3D FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index d321a6c5fe62..321f24d0762f 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -588,13 +588,7 @@ static int __do_page_fault(struct pt_regs *regs, uns=
igned long address,
 	 * case.
 	 */
 	if (unlikely(fault & VM_FAULT_RETRY)) {
-		/* We retry only once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			/*
-			 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation.
-			 */
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
 			if (is_user && signal_pending(current))
 				return 0;
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index ea8f301de65b..d1710ef75432 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -143,11 +143,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 				      1, regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			/*
-			 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation.
-			 */
-			flags &=3D ~(FAULT_FLAG_ALLOW_RETRY);
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/*
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 3ad77501deef..46ef1159d146 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -514,10 +514,7 @@ static inline vm_fault_t do_exception(struct pt_regs=
 *regs, int access)
 				fault =3D VM_FAULT_PFAULT;
 				goto out_up;
 			}
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &=3D ~(FAULT_FLAG_ALLOW_RETRY |
-				   FAULT_FLAG_RETRY_NOWAIT);
+			flags &=3D ~FAULT_FLAG_RETRY_NOWAIT;
 			flags |=3D FAULT_FLAG_TRIED;
 			down_read(&mm->mmap_sem);
 			goto retry;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index f620282a37fd..2e9cf3fd395f 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -481,7 +481,6 @@ asmlinkage void __kprobes do_page_fault(struct pt_reg=
s *regs,
 				      regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/*
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 9af0c3ad50d6..97494086f1e5 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -261,7 +261,6 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, =
int text_fault, int write,
 				      1, regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 566f05f9040b..a1730c3a8f30 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -446,7 +446,6 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_=
regs *regs)
 				      1, regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 3c72111f27e9..063da0930d31 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -98,7 +98,6 @@ int handle_page_fault(unsigned long address, unsigned l=
ong ip,
 			else
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
-				flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 				flags |=3D FAULT_FLAG_TRIED;
=20
 				goto retry;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 04c193439c97..8b3367ec0d80 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -260,9 +260,7 @@ static int do_pf(unsigned long addr, unsigned int fsr=
, struct pt_regs *regs)
 		else
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			* of starvation. */
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
+			flags |=3D FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index f7836472961e..7664f0f89ef6 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1447,9 +1447,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * that we made any progress. Handle this case first.
 	 */
 	if (unlikely(fault & VM_FAULT_RETRY)) {
-		/* Retry at most once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
 			if ((flags & FAULT_FLAG_USER) && signal_pending(tsk))
 				return;
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 094606676c36..1d91a23d27d3 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -129,7 +129,6 @@ void do_page_fault(struct pt_regs *regs)
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &=3D ~FAULT_FLAG_ALLOW_RETRY;
 			flags |=3D FAULT_FLAG_TRIED;
=20
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo=
_vm.c
index 6dacff49c1cc..8f2f9ee6effa 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -61,9 +61,10 @@ static vm_fault_t ttm_bo_vm_fault_idle(struct ttm_buff=
er_object *bo,
=20
 	/*
 	 * If possible, avoid waiting for GPU with mmap_sem
-	 * held.
+	 * held.  We only do this if the fault allows retry and this
+	 * is the first attempt.
 	 */
-	if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
+	if (fault_flag_allow_retry_first(vmf->flags)) {
 		ret =3D VM_FAULT_RETRY;
 		if (vmf->flags & FAULT_FLAG_RETRY_NOWAIT)
 			goto out_unlock;
@@ -132,7 +133,12 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *v=
mf)
 	 * for the buffer to become unreserved.
 	 */
 	if (unlikely(!reservation_object_trylock(bo->resv))) {
-		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
+		/*
+		 * If the fault allows retry and this is the first
+		 * fault attempt, we try to release the mmap_sem
+		 * before waiting
+		 */
+		if (fault_flag_allow_retry_first(vmf->flags)) {
 			if (!(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				ttm_bo_get(bo);
 				up_read(&vmf->vma->vm_mm->mmap_sem);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 53ec7abb8472..0fdbdcb257d6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -396,6 +396,25 @@ extern pgprot_t protection_map[16];
  * @FAULT_FLAG_REMOTE: The fault is not for current task/mm.
  * @FAULT_FLAG_INSTRUCTION: The fault was during an instruction fetch.
  * @FAULT_FLAG_INTERRUPTIBLE: The fault can be interrupted by non-fatal =
signals.
+ *
+ * About @FAULT_FLAG_ALLOW_RETRY and @FAULT_FLAG_TRIED: we can specify
+ * whether we would allow page faults to retry by specifying these two
+ * fault flags correctly.  Currently there can be three legal combinatio=
ns:
+ *
+ * (a) ALLOW_RETRY and !TRIED:  this means the page fault allows retry, =
and
+ *                              this is the first try
+ *
+ * (b) ALLOW_RETRY and TRIED:   this means the page fault allows retry, =
and
+ *                              we've already tried at least once
+ *
+ * (c) !ALLOW_RETRY and !TRIED: this means the page fault does not allow=
 retry
+ *
+ * The unlisted combination (!ALLOW_RETRY && TRIED) is illegal and shoul=
d never
+ * be used.  Note that page faults can be allowed to retry for multiple =
times,
+ * in which case we'll have an initial fault with flags (a) then later o=
n
+ * continuous faults with flags (b).  We should always try to detect pen=
ding
+ * signals before a retry to make sure the continuous page faults can st=
ill be
+ * interrupted if necessary.
  */
 #define FAULT_FLAG_WRITE			0x01
 #define FAULT_FLAG_MKWRITE			0x02
@@ -416,6 +435,24 @@ extern pgprot_t protection_map[16];
 			     FAULT_FLAG_KILLABLE | \
 			     FAULT_FLAG_INTERRUPTIBLE)
=20
+/**
+ * fault_flag_allow_retry_first - check ALLOW_RETRY the first time
+ *
+ * This is mostly used for places where we want to try to avoid taking
+ * the mmap_sem for too long a time when waiting for another condition
+ * to change, in which case we can try to be polite to release the
+ * mmap_sem in the first round to avoid potential starvation of other
+ * processes that would also want the mmap_sem.
+ *
+ * Return: true if the page fault allows retry and this is the first
+ * attempt of the fault handling; false otherwise.
+ */
+static inline bool fault_flag_allow_retry_first(unsigned int flags)
+{
+	return (flags & FAULT_FLAG_ALLOW_RETRY) &&
+	    (!(flags & FAULT_FLAG_TRIED));
+}
+
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
 	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \
diff --git a/mm/filemap.c b/mm/filemap.c
index d0cf700bf201..543404617f5a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1399,7 +1399,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
-	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+	if (fault_flag_allow_retry_first(flags)) {
 		/*
 		 * CAUTION! In this case, mmap_sem is not released
 		 * even though return 0.
diff --git a/mm/shmem.c b/mm/shmem.c
index 626d8c74b973..c32e7101294e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2011,7 +2011,7 @@ static vm_fault_t shmem_fault(struct vm_fault *vmf)
 			DEFINE_WAIT_FUNC(shmem_fault_wait, synchronous_wake_function);
=20
 			ret =3D VM_FAULT_NOPAGE;
-			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
+			if (fault_flag_allow_retry_first(vmf->flags) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
 				up_read(&vma->vm_mm->mmap_sem);
--=20
2.21.0


