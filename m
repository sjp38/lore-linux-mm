Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB694C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7499E21479
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="mOLsFJgk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7499E21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96C2A6B000D; Tue, 10 Sep 2019 05:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91E846B0010; Tue, 10 Sep 2019 05:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80F8A6B0269; Tue, 10 Sep 2019 05:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 568356B000D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:18 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 11DF321948
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:18 +0000 (UTC)
X-FDA: 75918457356.14.offer91_5756296d9931
X-HE-Tag: offer91_5756296d9931
X-Filterd-Recvd-Size: 10989
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:17 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDV0zcnz9txW7;
	Tue, 10 Sep 2019 11:17:14 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=mOLsFJgk; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Yg88UPZOE0bk; Tue, 10 Sep 2019 11:17:14 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDT6v5Lz9txW3;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107034; bh=PEaY6BcFqvfIN2RrImXZqWCJkmOLOrszffUTEk12pyM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=mOLsFJgkAQYZVW+/fihrHlcKq0/eGkla30Esk0x9RdoCr+B+JJ6KribuswUUZ3jKz
	 bVK7mCyEz3gmbkz5d0xDkUrb/mG5h4lyp/RHd2xMitDHZdRBlDVr2CxVzfcLUjYKO0
	 fHJryQbCAaHJUx1EzS6/TNPGXZmqQJYlB+L23t9s=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0B2DF8B87B;
	Tue, 10 Sep 2019 11:17:14 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id nRxYKRUk1KwH; Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7D6CC8B88E;
	Tue, 10 Sep 2019 11:16:25 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 27F766B739; Tue, 10 Sep 2019 09:16:25 +0000 (UTC)
Message-Id: <7e9771a56539c58dcd8a871c3dfbe7a932e427b0.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 06/15] powerpc/32: prepare for CONFIG_VMAP_STACK
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To support CONFIG_VMAP_STACK, the kernel has to activate Data MMU
Translation for accessing the stack. Before doing that it must save
SRR0, SRR1 and also DAR and DSISR when relevant, in order to not
loose them in case there is a Data TLB Miss once the translation is
reactivated.

This patch adds fields in thread struct for saving those registers.
It prepares entry_32.S to handle exception entry with
Data MMU Translation enabled and alters EXCEPTION_PROLOG macros to
save SRR0, SRR1, DAR and DSISR then reenables Data MMU.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/processor.h   |   6 ++
 arch/powerpc/include/asm/thread_info.h |   5 ++
 arch/powerpc/kernel/asm-offsets.c      |   6 ++
 arch/powerpc/kernel/entry_32.S         |   7 +++
 arch/powerpc/kernel/head_32.h          | 101 +++++++++++++++++++++++++++++----
 5 files changed, 115 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/include/asm/processor.h b/arch/powerpc/include/asm/processor.h
index a9993e7a443b..92c02d15f117 100644
--- a/arch/powerpc/include/asm/processor.h
+++ b/arch/powerpc/include/asm/processor.h
@@ -163,6 +163,12 @@ struct thread_struct {
 #if defined(CONFIG_PPC_BOOK3S_32) && defined(CONFIG_PPC_KUAP)
 	unsigned long	kuap;		/* opened segments for user access */
 #endif
+#ifdef CONFIG_VMAP_STACK
+	unsigned long	srr0;
+	unsigned long	srr1;
+	unsigned long	dar;
+	unsigned long	dsisr;
+#endif
 	/* Debug Registers */
 	struct debug_reg debug;
 	struct thread_fp_state	fp_state;
diff --git a/arch/powerpc/include/asm/thread_info.h b/arch/powerpc/include/asm/thread_info.h
index 8e1d0195ac36..488d5c4670ff 100644
--- a/arch/powerpc/include/asm/thread_info.h
+++ b/arch/powerpc/include/asm/thread_info.h
@@ -10,10 +10,15 @@
 #define _ASM_POWERPC_THREAD_INFO_H
 
 #include <asm/asm-const.h>
+#include <asm/page.h>
 
 #ifdef __KERNEL__
 
+#if defined(CONFIG_VMAP_STACK) && CONFIG_THREAD_SHIFT < PAGE_SHIFT
+#define THREAD_SHIFT		PAGE_SHIFT
+#else
 #define THREAD_SHIFT		CONFIG_THREAD_SHIFT
+#endif
 
 #define THREAD_SIZE		(1 << THREAD_SHIFT)
 
diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
index 484f54dab247..782cbf489ab0 100644
--- a/arch/powerpc/kernel/asm-offsets.c
+++ b/arch/powerpc/kernel/asm-offsets.c
@@ -127,6 +127,12 @@ int main(void)
 	OFFSET(KSP_VSID, thread_struct, ksp_vsid);
 #else /* CONFIG_PPC64 */
 	OFFSET(PGDIR, thread_struct, pgdir);
+#ifdef CONFIG_VMAP_STACK
+	OFFSET(SRR0, thread_struct, srr0);
+	OFFSET(SRR1, thread_struct, srr1);
+	OFFSET(DAR, thread_struct, dar);
+	OFFSET(DSISR, thread_struct, dsisr);
+#endif
 #ifdef CONFIG_SPE
 	OFFSET(THREAD_EVR0, thread_struct, evr[0]);
 	OFFSET(THREAD_ACC, thread_struct, acc);
diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index 317ad9df8ba8..2a26fe19f0b1 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -140,6 +140,9 @@ transfer_to_handler:
 	stw	r12,_CTR(r11)
 	stw	r2,_XER(r11)
 	mfspr	r12,SPRN_SPRG_THREAD
+#ifdef CONFIG_VMAP_STACK
+	tovirt(r12, r12)
+#endif
 	beq	2f			/* if from user, fix up THREAD.regs */
 	addi	r2, r12, -THREAD
 	addi	r11,r1,STACK_FRAME_OVERHEAD
@@ -195,7 +198,11 @@ transfer_to_handler:
 transfer_to_handler_cont:
 3:
 	mflr	r9
+#ifdef CONFIG_VMAP_STACK
+	tovirt(r9, r9)
+#else
 	tovirt(r2, r2)			/* set r2 to current */
+#endif
 	lwz	r11,0(r9)		/* virtual address of handler */
 	lwz	r9,4(r9)		/* where to go when done */
 #if defined(CONFIG_PPC_8xx) && defined(CONFIG_PERF_EVENTS)
diff --git a/arch/powerpc/kernel/head_32.h b/arch/powerpc/kernel/head_32.h
index f19a1ab91fb5..59e775930be8 100644
--- a/arch/powerpc/kernel/head_32.h
+++ b/arch/powerpc/kernel/head_32.h
@@ -10,31 +10,57 @@
  * We assume sprg3 has the physical address of the current
  * task's thread_struct.
  */
-.macro EXCEPTION_PROLOG
-	EXCEPTION_PROLOG_0
+.macro EXCEPTION_PROLOG ext
+	EXCEPTION_PROLOG_0	\ext
 	EXCEPTION_PROLOG_1
-	EXCEPTION_PROLOG_2
+	EXCEPTION_PROLOG_2	\ext
 .endm
 
-.macro EXCEPTION_PROLOG_0
+.macro EXCEPTION_PROLOG_0 ext
 	mtspr	SPRN_SPRG_SCRATCH0,r10
 	mtspr	SPRN_SPRG_SCRATCH1,r11
+#ifdef CONFIG_VMAP_STACK
+	mfspr	r10, SPRN_SPRG_THREAD
+	.ifnb	\ext
+	mfspr	r11, SPRN_DAR
+	stw	r11, DAR(r10)
+	mfspr	r11, SPRN_DSISR
+	stw	r11, DSISR(r10)
+	.endif
+	mfspr	r11, SPRN_SRR0
+	stw	r11, SRR0(r10)
+#endif
 	mfspr	r11, SPRN_SRR1		/* check whether user or kernel */
+#ifdef CONFIG_VMAP_STACK
+	stw	r11, SRR1(r10)
+#endif
 	mfcr	r10
 	andi.	r11, r11, MSR_PR
 .endm
 
 .macro EXCEPTION_PROLOG_1
+#ifdef CONFIG_VMAP_STACK
+	li	r11, MSR_KERNEL & ~(MSR_IR | MSR_RI) /* can take DTLB miss */
+	mtmsr	r11
+	subi	r11, r1, INT_FRAME_SIZE		/* use r1 if kernel */
+#else
 	tophys(r11,r1)			/* use tophys(r1) if kernel */
+	subi	r11, r11, INT_FRAME_SIZE	/* alloc exc. frame */
+#endif
 	beq	1f
 	mfspr	r11,SPRN_SPRG_THREAD
+#ifdef CONFIG_VMAP_STACK
+	tovirt(r11, r11)
+#endif
 	lwz	r11,TASK_STACK-THREAD(r11)
-	addi	r11,r11,THREAD_SIZE
+	addi	r11, r11, THREAD_SIZE - INT_FRAME_SIZE
+#ifndef CONFIG_VMAP_STACK
 	tophys(r11,r11)
-1:	subi	r11,r11,INT_FRAME_SIZE	/* alloc exc. frame */
+#endif
+1:
 .endm
 
-.macro EXCEPTION_PROLOG_2
+.macro EXCEPTION_PROLOG_2 ext
 	stw	r10,_CCR(r11)		/* save registers */
 	stw	r12,GPR12(r11)
 	stw	r9,GPR9(r11)
@@ -44,15 +70,36 @@
 	stw	r12,GPR11(r11)
 	mflr	r10
 	stw	r10,_LINK(r11)
+#ifdef CONFIG_VMAP_STACK
+	mfspr	r12, SPRN_SPRG_THREAD
+	tovirt(r12, r12)
+	.ifnb	\ext
+	lwz	r10, DAR(r12)
+	stw	r10, _DAR(r11)
+	lwz	r10, DSISR(r12)
+	stw	r10, _DSISR(r11)
+	.endif
+	lwz	r9, SRR1(r12)
+	lwz	r12, SRR0(r12)
+#else
 	mfspr	r12,SPRN_SRR0
 	mfspr	r9,SPRN_SRR1
+#endif
 	stw	r1,GPR1(r11)
 	stw	r1,0(r11)
+#ifdef CONFIG_VMAP_STACK
+	mr	r1, r11			/* set new kernel sp */
+#else
 	tovirt(r1,r11)			/* set new kernel sp */
+#endif
 #ifdef CONFIG_40x
 	rlwinm	r9,r9,0,14,12		/* clear MSR_WE (necessary?) */
 #else
+#ifdef CONFIG_VMAP_STACK
+	li	r10, MSR_KERNEL & ~MSR_IR /* can take exceptions */
+#else
 	li	r10,MSR_KERNEL & ~(MSR_IR|MSR_DR) /* can take exceptions */
+#endif
 	mtmsr	r10			/* (except for mach check in rtas) */
 #endif
 	stw	r0,GPR0(r11)
@@ -65,24 +112,49 @@
 
 .macro SYSCALL_ENTRY trapno
 	mfspr	r12,SPRN_SPRG_THREAD
+#ifdef CONFIG_VMAP_STACK
+	mfspr	r9, SPRN_SRR0
+	mfspr	r11, SPRN_SRR1
+	stw	r9, SRR0(r12)
+	stw	r11, SRR1(r12)
+#endif
 	mfcr	r10
 	lwz	r11,TASK_STACK-THREAD(r12)
-	mflr	r9
-	addi	r11,r11,THREAD_SIZE - INT_FRAME_SIZE
 	rlwinm	r10,r10,0,4,2	/* Clear SO bit in CR */
+	addi	r11, r11, THREAD_SIZE - INT_FRAME_SIZE
+#ifdef CONFIG_VMAP_STACK
+	li	r9, MSR_KERNEL & ~(MSR_IR | MSR_RI) /* can take DTLB miss */
+	tovirt(r12, r12)
+	mtmsr	r9
+#else
 	tophys(r11,r11)
+#endif
+	mflr	r9
 	stw	r10,_CCR(r11)		/* save registers */
+	stw	r9, _LINK(r11)
+#ifdef CONFIG_VMAP_STACK
+	lwz	r10, SRR0(r12)
+	lwz	r9, SRR1(r12)
+#else
 	mfspr	r10,SPRN_SRR0
-	stw	r9,_LINK(r11)
 	mfspr	r9,SPRN_SRR1
+#endif
 	stw	r1,GPR1(r11)
 	stw	r1,0(r11)
+#ifdef CONFIG_VMAP_STACK
+	mr	r1, r11
+#else
 	tovirt(r1,r11)			/* set new kernel sp */
+#endif
 	stw	r10,_NIP(r11)
 #ifdef CONFIG_40x
 	rlwinm	r9,r9,0,14,12		/* clear MSR_WE (necessary?) */
 #else
+#ifdef CONFIG_VMAP_STACK
+	LOAD_REG_IMMEDIATE(r10, MSR_KERNEL & ~MSR_IR) /* can take exceptions */
+#else
 	LOAD_REG_IMMEDIATE(r10, MSR_KERNEL & ~(MSR_IR|MSR_DR)) /* can take exceptions */
+#endif
 	mtmsr	r10			/* (except for mach check in rtas) */
 #endif
 	lis	r10,STACK_FRAME_REGS_MARKER@ha /* exception frame marker */
@@ -121,7 +193,9 @@
 #endif
 
 3:
+#ifndef CONFIG_VMAP_STACK
 	tovirt(r2, r2)			/* set r2 to current */
+#endif
 	lis	r11, transfer_to_syscall@h
 	ori	r11, r11, transfer_to_syscall@l
 #ifdef CONFIG_TRACE_IRQFLAGS
@@ -145,14 +219,21 @@
 .endm
 
 .macro save_dar_dsisr_on_stack reg1, reg2, sp
+#ifndef CONFIG_VMAP_STACK
 	mfspr	\reg1, SPRN_DAR
 	mfspr	\reg2, SPRN_DSISR
 	stw	\reg1, _DAR(\sp)
 	stw	\reg2, _DSISR(\sp)
+#endif
 .endm
 
 .macro get_and_save_dar_dsisr_on_stack reg1, reg2, sp
+#ifdef CONFIG_VMAP_STACK
+	lwz	\reg1, _DAR(\sp)
+	lwz	\reg2, _DSISR(\sp)
+#else
 	save_dar_dsisr_on_stack \reg1, \reg2, \sp
+#endif
 .endm
 
 /*
-- 
2.13.3


