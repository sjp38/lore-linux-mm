Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACB95C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D58220700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="k1aesh8P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D58220700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E4808E0013; Tue, 19 Feb 2019 05:33:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46F928E000F; Tue, 19 Feb 2019 05:33:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33BCE8E0013; Tue, 19 Feb 2019 05:33:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1DD38E000F
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:07 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id z3so3651115itj.2
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=FNsWh74kzV1TOR4F01eM2Vp8b7v4O6aBxyOGm5+4Sns=;
        b=Oac3aLQMvI8eVdlrIgSvF1BXQIU/8gZQyOIoAUg0xGQR1FubHM3TmoLmT0D6Fb1Jrn
         DXWKMJWWwbv8KKsswcG0Yzy7j5tfEWeqelgYBg6R+XBU2Hz1Q3R/RbNSSoE+iPyS632e
         t05+VIyBVHl+0e0z5qBEUzW++Nfx78yN3PhXVZA/vQSJo4iHLBujQ1HTcdHcfSp0i9Dp
         JzVe93ENfoMLMIGdP9EZwYDQ1maY6N8HeAPvu/N0Htr4oEH0bhXXBS0+nwHoPZOo0GXs
         qtN9IEc9NXhpa/IXiCggASZnUnGynVYPHSfeqASSrEsaTuVZ3ZqKua//UopyHMZgG+9n
         Fy2A==
X-Gm-Message-State: AHQUAuYn+w8y2hRBMF3PsClU0WdrhMGwp/kODmpvPuJDSjpCYydIS3Dq
	DX+okRkOwzD/nMyLt0weKiEc/lPUrhfMD/l59BKmxm/JmRP2YhETQ9SkCEiA18bx9lPXT7Q3NXB
	BYBxd+A+Tny6wRXPTwegPEiS4BcAWCrQErtRaEDdEqfHh/9nlXNT/hR8P8gZMUxj/PQ==
X-Received: by 2002:a6b:1583:: with SMTP id 125mr16095503iov.102.1550572387776;
        Tue, 19 Feb 2019 02:33:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhgPrqVwF8SiNPEyye2dyNqsZiXbXz8/FFdzWux3MvN5qVtug4XdrKuKl/YEXqjQyzW6p0
X-Received: by 2002:a6b:1583:: with SMTP id 125mr16095474iov.102.1550572386947;
        Tue, 19 Feb 2019 02:33:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572386; cv=none;
        d=google.com; s=arc-20160816;
        b=YpXiiCybV2uGA/7Axy3hIIhA544UP+w6eXv1wgWAiqFNp9dzi+hdL+l9gQTFVaLnRM
         K8Yab31kbv93iqkZji1rvLOmlRGimq3sCbMm3xz4Ge36jc9/d0VTDbl4uRDmCekuK5IC
         e070fhjGgBnDmXzcW4LKRJfsD/UVR42zFSYBhOHL2Pst6nLhRKdmxgZAcYThypSSrRJr
         cLw3efc3m/gsvlgdGUcxNy9GMEK50lWG8IwCo2pEjIFzorToL61hbMCnpH7FQurCSzrm
         03MCLtdnOXNUj4u9jI84LRZvW2QmOWxr9xrJF0dPpqy89JL2r3SfRmTMamW3PGjNzqaU
         uZ7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=FNsWh74kzV1TOR4F01eM2Vp8b7v4O6aBxyOGm5+4Sns=;
        b=iJdIK+++jn9ja3EKW1BtqlRObVzs+I9GUr6/zj/GuWOuDt7dJFhyCE9/BZqL1eIqv4
         GrSWpYls/S1w1Dat7Y6tHGwk642JzFND56NFIDFRIzgSnukoOqtHARaddvwc3LlXT37K
         km1wBhc1WmbEfHcVu0dsRfCnf88gQJCTaqjul/uBke7PyJUlBPxqcigzRAlb3IqGvWu/
         +W62miZierZwTPqgH5qfP4yrojxRS5NyKQLyIfADYf5OcecdIH0uyhJ6TNqu156KBn4T
         vixz0noH4d8DIpkPwmkD5d0+JPKF1splQGv9mF5Tg5ckG3grepTQHvfMw6j8ih21MDjv
         NgNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=k1aesh8P;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 68si1532959jan.32.2019.02.19.02.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:06 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=k1aesh8P;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=FNsWh74kzV1TOR4F01eM2Vp8b7v4O6aBxyOGm5+4Sns=; b=k1aesh8Pj5v0Ave60ICG3GY5PJ
	sLSCyE3xHGmhRGtKKa6xwJqaxZ3TNb8KqMDsGKVNP8KXIc+FVyAy+4deOeek8KW0Y2Pn9xNsKJkez
	NjnlH5i+DltZRlRzM7BWsS/9tYXqGXGlzIpxxLEANM3A9OMFNHsC/v4eBdw0nLNSPEV/Cf/ae1luF
	Z4WCjenzQEli/gJIE483INy66ze8RVZaiMRxYSrDdy8GZDHM+fgEuR5qQk7kx2JDhtwgtFZ5e6agE
	VcItGXWZhh8YrEGZa+eCVmblGHYey3mtxlqv5yQJfg5++6RmW/XijzRABUWNpv9HBwJcaIa0C4oGJ
	aWZXKbPQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hm-0000dX-01; Tue, 19 Feb 2019 10:32:50 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 4E1CD285202C5; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.030444300@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: will.deacon@arm.com,
 aneesh.kumar@linux.vnet.ibm.com,
 akpm@linux-foundation.org,
 npiggin@gmail.com
Cc: linux-arch@vger.kernel.org,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 peterz@infradead.org,
 linux@armlinux.org.uk,
 heiko.carstens@de.ibm.com,
 riel@surriel.com,
 David Miller <davem@davemloft.net>,
 Guan Xuetao <gxt@pku.edu.cn>
Subject: [PATCH v6 03/18] asm-generic/tlb: Provide generic VIPT cache flush
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The one obvious thing SH and ARM want is a sensible default for
tlb_start_vma(). (also: https://lkml.org/lkml/2004/1/15/6 )

Avoid all VIPT architectures providing their own tlb_start_vma()
implementation and rely on architectures to provide a no-op
flush_cache_range() when it is not relevant.

The below makes tlb_start_vma() default to flush_cache_range(), which
should be right and sufficient. The only exceptions that I found where
(oddly):

  - m68k-mmu
  - sparc64
  - unicore

Those architectures appear to have flush_cache_range(), but their
current tlb_start_vma() does not call it.

Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Guan Xuetao <gxt@pku.edu.cn>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/arc/include/asm/tlb.h      |    9 ---------
 arch/mips/include/asm/tlb.h     |    9 ---------
 arch/nds32/include/asm/tlb.h    |    6 ------
 arch/nios2/include/asm/tlb.h    |   10 ----------
 arch/parisc/include/asm/tlb.h   |    5 -----
 arch/sparc/include/asm/tlb_32.h |    5 -----
 arch/xtensa/include/asm/tlb.h   |    9 ---------
 include/asm-generic/tlb.h       |   19 +++++++++++--------
 8 files changed, 11 insertions(+), 61 deletions(-)

--- a/arch/arc/include/asm/tlb.h
+++ b/arch/arc/include/asm/tlb.h
@@ -23,15 +23,6 @@ do {						\
  *
  * Note, read http://lkml.org/lkml/2004/1/15/6
  */
-#ifndef CONFIG_ARC_CACHE_VIPT_ALIASING
-#define tlb_start_vma(tlb, vma)
-#else
-#define tlb_start_vma(tlb, vma)						\
-do {									\
-	if (!tlb->fullmm)						\
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
-} while(0)
-#endif
 
 #define tlb_end_vma(tlb, vma)						\
 do {									\
--- a/arch/mips/include/asm/tlb.h
+++ b/arch/mips/include/asm/tlb.h
@@ -5,15 +5,6 @@
 #include <asm/cpu-features.h>
 #include <asm/mipsregs.h>
 
-/*
- * MIPS doesn't need any special per-pte or per-vma handling, except
- * we need to flush cache for area to be unmapped.
- */
-#define tlb_start_vma(tlb, vma)					\
-	do {							\
-		if (!tlb->fullmm)				\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	}  while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
--- a/arch/nds32/include/asm/tlb.h
+++ b/arch/nds32/include/asm/tlb.h
@@ -4,12 +4,6 @@
 #ifndef __ASMNDS32_TLB_H
 #define __ASMNDS32_TLB_H
 
-#define tlb_start_vma(tlb,vma)						\
-	do {								\
-		if (!tlb->fullmm)					\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	} while (0)
-
 #define tlb_end_vma(tlb,vma)				\
 	do { 						\
 		if(!tlb->fullmm)			\
--- a/arch/nios2/include/asm/tlb.h
+++ b/arch/nios2/include/asm/tlb.h
@@ -15,16 +15,6 @@
 
 extern void set_mmu_pid(unsigned long pid);
 
-/*
- * NiosII doesn't need any special per-pte or per-vma handling, except
- * we need to flush cache for the area to be unmapped.
- */
-#define tlb_start_vma(tlb, vma)					\
-	do {							\
-		if (!tlb->fullmm)				\
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-	}  while (0)
-
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
--- a/arch/parisc/include/asm/tlb.h
+++ b/arch/parisc/include/asm/tlb.h
@@ -7,11 +7,6 @@ do {	if ((tlb)->fullmm)		\
 		flush_tlb_mm((tlb)->mm);\
 } while (0)
 
-#define tlb_start_vma(tlb, vma) \
-do {	if (!(tlb)->fullmm)	\
-		flush_cache_range(vma, vma->vm_start, vma->vm_end); \
-} while (0)
-
 #define tlb_end_vma(tlb, vma)	\
 do {	if (!(tlb)->fullmm)	\
 		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
--- a/arch/sparc/include/asm/tlb_32.h
+++ b/arch/sparc/include/asm/tlb_32.h
@@ -2,11 +2,6 @@
 #ifndef _SPARC_TLB_H
 #define _SPARC_TLB_H
 
-#define tlb_start_vma(tlb, vma) \
-do {								\
-	flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
-} while (0)
-
 #define tlb_end_vma(tlb, vma) \
 do {								\
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
--- a/arch/xtensa/include/asm/tlb.h
+++ b/arch/xtensa/include/asm/tlb.h
@@ -16,19 +16,10 @@
 
 #if (DCACHE_WAY_SIZE <= PAGE_SIZE)
 
-/* Note, read http://lkml.org/lkml/2004/1/15/6 */
-
-# define tlb_start_vma(tlb,vma)			do { } while (0)
 # define tlb_end_vma(tlb,vma)			do { } while (0)
 
 #else
 
-# define tlb_start_vma(tlb, vma)					      \
-	do {								      \
-		if (!tlb->fullmm)					      \
-			flush_cache_range(vma, vma->vm_start, vma->vm_end);   \
-	} while(0)
-
 # define tlb_end_vma(tlb, vma)						      \
 	do {								      \
 		if (!tlb->fullmm)					      \
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -19,6 +19,7 @@
 #include <linux/swap.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
+#include <asm/cacheflush.h>
 
 #ifdef CONFIG_MMU
 
@@ -351,17 +352,19 @@ static inline unsigned long tlb_get_unma
  * the vmas are adjusted to only cover the region to be torn down.
  */
 #ifndef tlb_start_vma
-#define tlb_start_vma(tlb, vma) do { } while (0)
+#define tlb_start_vma(tlb, vma)						\
+do {									\
+	if (!tlb->fullmm)						\
+		flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
+} while (0)
 #endif
 
-#define __tlb_end_vma(tlb, vma)					\
-	do {							\
-		if (!tlb->fullmm)				\
-			tlb_flush_mmu_tlbonly(tlb);		\
-	} while (0)
-
 #ifndef tlb_end_vma
-#define tlb_end_vma	__tlb_end_vma
+#define tlb_end_vma(tlb, vma)						\
+do {									\
+	if (!tlb->fullmm)						\
+		tlb_flush_mmu_tlbonly(tlb);				\
+} while (0)
 #endif
 
 #ifndef __tlb_remove_tlb_entry


