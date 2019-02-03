Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43D35C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0A8B218D8
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0A8B218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=decadent.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAFD18E0027; Sun,  3 Feb 2019 08:49:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B18378E001C; Sun,  3 Feb 2019 08:49:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A3988E0027; Sun,  3 Feb 2019 08:49:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 286408E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 08:49:56 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id q18so3877242wrx.0
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 05:49:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-disposition:content-transfer-encoding:mime-version:from:to
         :cc:date:message-id:subject:in-reply-to;
        bh=APFzcIDBk2BOhcDidT82WTJ82pPALfv3bo4NYQjTw/0=;
        b=Zg0pt7vPlX8/dYlAQ9kDhRIASHGLDEM9MykaiiYnCd20cybnOIcCHIoV/eJvjl1O2G
         XAEASX+vETF2RxVYuyG4tDS9xFj+gA36OV4OoJwTyz3PAMLD9oHhtAIkNsodFooGsDwh
         6T/3IPpEm1Kv3WrPI60cGEUuWrj4rcJQkTnSZmv8eJXbmYVN9tlODCexwjVFq+D78gWF
         35WKTlC2F3OxL9hwUgt8qjAkSZp1nsAlmV653ny1E75ESBJb2FPy/cZcCQR0cc5culUa
         emIgEVgL1e+bdoS5QSVkasM1MSno2Ew2fl+mBdt6CjAEMNWgTJfB0CfY5XtpOX++glg3
         xyNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
X-Gm-Message-State: AHQUAuYRuN8fHLVrpfNcvBRQMc+7GkH8bsqfRdebYEln57NKjr4XN+M0
	CFEDKakQZ3kx5JzaNMAe8tf5t1Cqgqky4yLDU0Okn8H74QDDZlv97AaMrnJ7ZOZfGitAiB9T7kD
	AfO9GSPCfnrTyW/O/YjKYt8MxFlLYqou85MXrVCa3IiU5rltFGBZ4ulHczZyzoY4QTw==
X-Received: by 2002:a7b:c0c5:: with SMTP id s5mr2336290wmh.56.1549201795674;
        Sun, 03 Feb 2019 05:49:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0KVMhRaZOjzUNdY1uHwGiKzgxZIOuhgVJLsrRMhISYZjt2vgngheJdMvHVVPB9EqKpAcS
X-Received: by 2002:a7b:c0c5:: with SMTP id s5mr2336262wmh.56.1549201794581;
        Sun, 03 Feb 2019 05:49:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549201794; cv=none;
        d=google.com; s=arc-20160816;
        b=d1rZu5Q8Rky6y91rCBmxcnViQ/LLoyvQQW01qt1+R6bpZZ6cRptMkEjW8HNdY9twk8
         ljwhKf0MSSSFes0HwsawEbk+CxxtC9Ie8pQSjLGA2rHzoZrOxvfBek9olNDm7+57yY3/
         z9jugTPI2I7vbo0s9C1GlSPdifGTjcaa+BTcDMjBtJXzCK6qPPmrhklgVBIb0SpCz7cu
         Vfj2KI9HVsuGJwM+LHxLhaPVbMeafgT69GYcGyEieqkfjVcz5iVHd1FY0C3Ch1SUTL8N
         +gYQpIXWSw1X1k6KCqYw7albx2bOrjh4VehqCX4ithBEwEOIFqAobMun4oKXV6ixxyR5
         kF3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:subject:message-id:date:cc:to:from:mime-version
         :content-transfer-encoding:content-disposition;
        bh=APFzcIDBk2BOhcDidT82WTJ82pPALfv3bo4NYQjTw/0=;
        b=avLFksS/LcX3VymZUbGy5VSKUPXqUrP5pyJTflz7ju1jPNpj84YrzVWTGm3zjyPpLA
         G0EzgcLsa8jd3tPmye2mXdzzdXo/rgOIOatJAuO3z5gw6gDglQmOOqzX2zAXfmtdLYLL
         DLrZ6wcHZ6ge/hLs6lJkBl58/9u3ZDTB+W6Y8Fl2eJW85pbabwI4zkKZ3l/L/DR+JjFr
         zoTQ5g1ikzlZo8L7Pvl4EnOeBZ/CGdZN3ywFaCXCbFnhGpqhR1CTwVDHUeX4qRC7NGZM
         LQtpxkTdtirF5nAA6JXg3EvSxgrTt9k0/2ODZWeFbE3gdMaKMhXEAIdw/Dkw2Bgh8D9u
         dZJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id a10si11033825wrd.333.2019.02.03.05.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Feb 2019 05:49:54 -0800 (PST)
Received-SPF: pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) client-ip=88.96.1.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from cable-78.29.236.164.coditel.net ([78.29.236.164] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0003tm-9S; Sun, 03 Feb 2019 13:49:39 +0000
Received: from ben by deadeye with local (Exim 4.92-RC4)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0006nM-FL; Sun, 03 Feb 2019 14:49:39 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
CC: akpm@linux-foundation.org, Denis Kirjanov <kda@linux-powerpc.org>,
 "Andy Lutomirski" <luto@amacapital.net>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 "Mel Gorman" <mgorman@suse.de>,
 "Denys Vlasenko" <dvlasenk@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 elliott@hpe.com,
 "Borislav Petkov" <bp@suse.de>,
 "linux-mm" <linux-mm@kvack.org>,
 "Ingo Molnar" <mingo@kernel.org>,
 "=?UTF-8?Q?J=C3=BCrgen=20?=Gross" <jgross@suse.com>,
 "Linus Torvalds" <torvalds@linux-foundation.org>,
 "Brian Gerst" <brgerst@gmail.com>,
 "Peter Zijlstra" <peterz@infradead.org>,
 konrad.wilk@oracle.com,
 "Thomas Gleixner" <tglx@linutronix.de>,
 "Borislav Petkov" <bp@alien8.de>,
 "Toshi Kani" <toshi.kani@hpe.com>
Date: Sun, 03 Feb 2019 14:45:08 +0100
Message-ID: <lsq.1549201508.599764490@decadent.org.uk>
X-Mailer: LinuxStableQueue (scripts by bwh)
X-Patchwork-Hint: ignore
Subject: [PATCH 3.16 005/305] x86/mm: Fix regression with huge pages on PAE
In-Reply-To: <lsq.1549201507.384106140@decadent.org.uk>
X-SA-Exim-Connect-IP: 78.29.236.164
X-SA-Exim-Mail-From: ben@decadent.org.uk
X-SA-Exim-Scanned: No (on shadbolt.decadent.org.uk); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

3.16.63-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

commit 70f1528747651b20c7769d3516ade369f9963237 upstream.

Recent PAT patchset has caused issue on 32-bit PAE machines:

  page:eea45000 count:0 mapcount:-128 mapping:  (null) index:0x0 flags: 0x40000000()
  page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
  ------------[ cut here ]------------
  kernel BUG at /home/build/linux-boris/mm/huge_memory.c:1485!
  invalid opcode: 0000 [#1] SMP
  [...]
  Call Trace:
   unmap_single_vma
   ? __wake_up
   unmap_vmas
   unmap_region
   do_munmap
   vm_munmap
   SyS_munmap
   do_fast_syscall_32
   ? __do_page_fault
   sysenter_past_esp
  Code: ...
  EIP: [<c11bde80>] zap_huge_pmd+0x240/0x260 SS:ESP 0068:f6459d98

The problem is in pmd_pfn_mask() and pmd_flags_mask(). These
helpers use PMD_PAGE_MASK to calculate resulting mask.
PMD_PAGE_MASK is 'unsigned long', not 'unsigned long long' as
phys_addr_t is on 32-bit PAE (ARCH_PHYS_ADDR_T_64BIT). As a
result, the upper bits of resulting mask get truncated.

pud_pfn_mask() and pud_flags_mask() aren't problematic since we
don't have PUD page table level on 32-bit systems, but it's
reasonable to keep them consistent with PMD counterpart.

Introduce PHYSICAL_PMD_PAGE_MASK and PHYSICAL_PUD_PAGE_MASK in
addition to existing PHYSICAL_PAGE_MASK and reworks helpers to
use them.

Reported-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
[ Fix -Woverflow warnings from the realmode code. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jürgen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: elliott@hpe.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Fixes: f70abb0fc3da ("x86/asm: Fix pud/pmd interfaces to handle large PAT bit")
Link: http://lkml.kernel.org/r/1448878233-11390-2-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>

Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/boot/boot.h                 |  1 -
 arch/x86/boot/video-mode.c           |  2 ++
 arch/x86/boot/video.c                |  2 ++
 arch/x86/include/asm/page_types.h    | 16 +++++++++-------
 arch/x86/include/asm/pgtable_types.h | 14 ++++----------
 arch/x86/include/asm/x86_init.h      |  1 -
 6 files changed, 17 insertions(+), 19 deletions(-)

--- a/arch/x86/boot/boot.h
+++ b/arch/x86/boot/boot.h
@@ -23,7 +23,6 @@
 #include <stdarg.h>
 #include <linux/types.h>
 #include <linux/edd.h>
-#include <asm/boot.h>
 #include <asm/setup.h>
 #include "bitops.h"
 #include "ctype.h"
--- a/arch/x86/boot/video-mode.c
+++ b/arch/x86/boot/video-mode.c
@@ -19,6 +19,8 @@
 #include "video.h"
 #include "vesa.h"
 
+#include <uapi/asm/boot.h>
+
 /*
  * Common variables
  */
--- a/arch/x86/boot/video.c
+++ b/arch/x86/boot/video.c
@@ -13,6 +13,8 @@
  * Select video mode
  */
 
+#include <uapi/asm/boot.h>
+
 #include "boot.h"
 #include "video.h"
 #include "vesa.h"
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -9,19 +9,21 @@
 #define PAGE_SIZE	(_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK	(~(PAGE_SIZE-1))
 
+#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
+#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
+
+#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
+#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
+
 #define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
 #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
 
-/* Cast PAGE_MASK to a signed type so that it is sign-extended if
+/* Cast *PAGE_MASK to a signed type so that it is sign-extended if
    virtual addresses are 32-bits but physical addresses are larger
    (ie, 32-bit PAE). */
 #define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
-
-#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
-#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
-
-#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
-#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
+#define PHYSICAL_PMD_PAGE_MASK	(((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
+#define PHYSICAL_PUD_PAGE_MASK	(((signed long)PUD_PAGE_MASK) & __PHYSICAL_MASK)
 
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -332,17 +332,14 @@ static inline pmdval_t native_pmd_val(pm
 static inline pudval_t pud_pfn_mask(pud_t pud)
 {
 	if (native_pud_val(pud) & _PAGE_PSE)
-		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return PHYSICAL_PUD_PAGE_MASK;
 	else
 		return PTE_PFN_MASK;
 }
 
 static inline pudval_t pud_flags_mask(pud_t pud)
 {
-	if (native_pud_val(pud) & _PAGE_PSE)
-		return ~(PUD_PAGE_MASK & (pudval_t)PHYSICAL_PAGE_MASK);
-	else
-		return ~PTE_PFN_MASK;
+	return ~pud_pfn_mask(pud);
 }
 
 static inline pudval_t pud_flags(pud_t pud)
@@ -353,17 +350,14 @@ static inline pudval_t pud_flags(pud_t p
 static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
 {
 	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+		return PHYSICAL_PMD_PAGE_MASK;
 	else
 		return PTE_PFN_MASK;
 }
 
 static inline pmdval_t pmd_flags_mask(pmd_t pmd)
 {
-	if (native_pmd_val(pmd) & _PAGE_PSE)
-		return ~(PMD_PAGE_MASK & (pmdval_t)PHYSICAL_PAGE_MASK);
-	else
-		return ~PTE_PFN_MASK;
+	return ~pmd_pfn_mask(pmd);
 }
 
 static inline pmdval_t pmd_flags(pmd_t pmd)
--- a/arch/x86/include/asm/x86_init.h
+++ b/arch/x86/include/asm/x86_init.h
@@ -1,7 +1,6 @@
 #ifndef _ASM_X86_PLATFORM_H
 #define _ASM_X86_PLATFORM_H
 
-#include <asm/pgtable_types.h>
 #include <asm/bootparam.h>
 
 struct mpc_bus;

