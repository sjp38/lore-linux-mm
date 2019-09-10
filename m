Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BF0FC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE5E120872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Q+/VrpLZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE5E120872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E75396B0270; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E26936B0272; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D6D6B0270; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id A691F6B0271
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:21 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 614988243765
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:21 +0000 (UTC)
X-FDA: 75918457482.18.bear83_5f3ba3e96239
X-HE-Tag: bear83_5f3ba3e96239
X-Filterd-Recvd-Size: 12051
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:20 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDZ3jDFz9txW4;
	Tue, 10 Sep 2019 11:17:18 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Q+/VrpLZ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 6XwP7np1WQcI; Tue, 10 Sep 2019 11:17:18 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDZ2V45z9txW3;
	Tue, 10 Sep 2019 11:17:18 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107038; bh=ZoAw49VCT8ne5Yeo1dRk2fXtv2R60t2YgTp5B7ZoyCw=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Q+/VrpLZO8+MuHu0zmNZbHYXC7+36vhUwJ8cyNlxJXKHLP4ej4wrYqDk+FBQjs2hC
	 gZo+UuVJ7DR+gYfkZ82gFJNLRrTgWMkVcrFeSBd/KJTeXZfwkyGE0lXJZu+3K89xSS
	 Zp0fQGPN3LtKC2FmBPa046mUiMv3xYoggWd4biKs=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A2D008B88D;
	Tue, 10 Sep 2019 11:17:16 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 4IsK2LFNfSqA; Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D33BB8B89D;
	Tue, 10 Sep 2019 11:16:34 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 6DD2B6B739; Tue, 10 Sep 2019 09:16:34 +0000 (UTC)
Message-Id: <a99bdfb64e287b16b8cd3f7ec1abfdfb50c7cc64.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 15/15] powerpc/32s: Activate CONFIG_VMAP_STACK
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A few changes to retrieve DAR and DSISR from struct regs
instead of retrieving them directly, as they may have
changed due to a TLB miss.

Also modifies hash_page() and friends to work with virtual
data addresses instead of physical ones.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/entry_32.S         |  4 +++
 arch/powerpc/kernel/head_32.S          | 19 +++++++++++---
 arch/powerpc/kernel/head_32.h          |  4 ++-
 arch/powerpc/mm/book3s32/hash_low.S    | 46 +++++++++++++++++++++-------------
 arch/powerpc/mm/book3s32/mmu.c         |  9 +++++--
 arch/powerpc/platforms/Kconfig.cputype |  2 ++
 6 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index 00fcf954e742..1d3b152ee54f 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -1365,7 +1365,11 @@ _GLOBAL(enter_rtas)
 	lis	r6,1f@ha	/* physical return address for rtas */
 	addi	r6,r6,1f@l
 	tophys(r6,r6)
+#ifdef CONFIG_VMAP_STACK
+	mr	r7, r1
+#else
 	tophys(r7,r1)
+#endif
 	lwz	r8,RTASENTRY(r4)
 	lwz	r4,RTASBASE(r4)
 	mfmsr	r9
diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 5bda6a092673..97bc02306a34 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -272,14 +272,22 @@ __secondary_hold_acknowledge:
  */
 	. = 0x200
 	DO_KVM  0x200
+MachineCheck:
 	EXCEPTION_PROLOG_0
+#ifdef CONFIG_VMAP_STACK
+	li	r11, MSR_KERNEL & ~(MSR_IR | MSR_RI) /* can take DTLB miss */
+	mtmsr	r11
+#endif
 #ifdef CONFIG_PPC_CHRP
 	mfspr	r11, SPRN_SPRG_THREAD
+#ifdef CONFIG_VMAP_STACK
+	tovirt(r11, r11)
+#endif
 	lwz	r11, RTAS_SP(r11)
 	cmpwi	cr1, r11, 0
 	bne	cr1, 7f
 #endif /* CONFIG_PPC_CHRP */
-	EXCEPTION_PROLOG_1
+	EXCEPTION_PROLOG_1 rtas
 7:	EXCEPTION_PROLOG_2
 	addi	r3,r1,STACK_FRAME_OVERHEAD
 #ifdef CONFIG_PPC_CHRP
@@ -294,7 +302,7 @@ __secondary_hold_acknowledge:
 	. = 0x300
 	DO_KVM  0x300
 DataAccess:
-	EXCEPTION_PROLOG
+	EXCEPTION_PROLOG dar
 	get_and_save_dar_dsisr_on_stack	r4, r5, r11
 BEGIN_MMU_FTR_SECTION
 #ifdef CONFIG_PPC_KUAP
@@ -336,7 +344,7 @@ END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
 	. = 0x600
 	DO_KVM  0x600
 Alignment:
-	EXCEPTION_PROLOG
+	EXCEPTION_PROLOG dar
 	save_dar_dsisr_on_stack r4, r5, r11
 	addi	r3,r1,STACK_FRAME_OVERHEAD
 	EXC_XFER_STD(0x600, alignment_exception)
@@ -643,6 +651,11 @@ END_MMU_FTR_SECTION_IFSET(MMU_FTR_NEED_DTLB_SW_LRU)
 handle_page_fault_tramp:
 	EXC_XFER_LITE(0x300, handle_page_fault)
 
+#ifdef CONFIG_VMAP_STACK
+stack_ovf_trampoline:
+	b	stack_ovf
+#endif
+
 AltiVecUnavailable:
 	EXCEPTION_PROLOG
 #ifdef CONFIG_ALTIVEC
diff --git a/arch/powerpc/kernel/head_32.h b/arch/powerpc/kernel/head_32.h
index 283d4298d555..ae2c8e07e1d5 100644
--- a/arch/powerpc/kernel/head_32.h
+++ b/arch/powerpc/kernel/head_32.h
@@ -38,10 +38,12 @@
 	andi.	r11, r11, MSR_PR
 .endm
 
-.macro EXCEPTION_PROLOG_1
+.macro EXCEPTION_PROLOG_1 rtas
 #ifdef CONFIG_VMAP_STACK
+	.ifb	\rtas
 	li	r11, MSR_KERNEL & ~(MSR_IR | MSR_RI) /* can take DTLB miss */
 	mtmsr	r11
+	.endif
 	subi	r11, r1, INT_FRAME_SIZE		/* use r1 if kernel */
 #else
 	tophys(r11,r1)			/* use tophys(r1) if kernel */
diff --git a/arch/powerpc/mm/book3s32/hash_low.S b/arch/powerpc/mm/book3s32/hash_low.S
index 8bbbd9775c8a..c11b0a005196 100644
--- a/arch/powerpc/mm/book3s32/hash_low.S
+++ b/arch/powerpc/mm/book3s32/hash_low.S
@@ -25,6 +25,12 @@
 #include <asm/feature-fixups.h>
 #include <asm/code-patching-asm.h>
 
+#ifdef CONFIG_VMAP_STACK
+#define ADDR_OFFSET	0
+#else
+#define ADDR_OFFSET	PAGE_OFFSET
+#endif
+
 #ifdef CONFIG_SMP
 	.section .bss
 	.align	2
@@ -47,8 +53,8 @@ mmu_hash_lock:
 	.text
 _GLOBAL(hash_page)
 #ifdef CONFIG_SMP
-	lis	r8, (mmu_hash_lock - PAGE_OFFSET)@h
-	ori	r8, r8, (mmu_hash_lock - PAGE_OFFSET)@l
+	lis	r8, (mmu_hash_lock - ADDR_OFFSET)@h
+	ori	r8, r8, (mmu_hash_lock - ADDR_OFFSET)@l
 	lis	r0,0x0fff
 	b	10f
 11:	lwz	r6,0(r8)
@@ -66,9 +72,12 @@ _GLOBAL(hash_page)
 	cmplw	0,r4,r0
 	ori	r3,r3,_PAGE_USER|_PAGE_PRESENT /* test low addresses as user */
 	mfspr	r5, SPRN_SPRG_PGDIR	/* phys page-table root */
+#ifdef CONFIG_VMAP_STACK
+	tovirt(r5, r5)
+#endif
 	blt+	112f			/* assume user more likely */
-	lis	r5, (swapper_pg_dir - PAGE_OFFSET)@ha	/* if kernel address, use */
-	addi	r5 ,r5 ,(swapper_pg_dir - PAGE_OFFSET)@l	/* kernel page table */
+	lis	r5, (swapper_pg_dir - ADDR_OFFSET)@ha	/* if kernel address, use */
+	addi	r5 ,r5 ,(swapper_pg_dir - ADDR_OFFSET)@l	/* kernel page table */
 	rlwimi	r3,r9,32-12,29,29	/* MSR_PR -> _PAGE_USER */
 112:
 #ifndef CONFIG_PTE_64BIT
@@ -80,6 +89,9 @@ _GLOBAL(hash_page)
 	lwzx	r8,r8,r5		/* Get L1 entry */
 	rlwinm.	r8,r8,0,0,20		/* extract pt base address */
 #endif
+#ifdef CONFIG_VMAP_STACK
+	tovirt(r8, r8)
+#endif
 #ifdef CONFIG_SMP
 	beq-	hash_page_out		/* return if no mapping */
 #else
@@ -137,9 +149,9 @@ retry:
 
 #ifdef CONFIG_SMP
 	eieio
-	lis	r8, (mmu_hash_lock - PAGE_OFFSET)@ha
+	lis	r8, (mmu_hash_lock - ADDR_OFFSET)@ha
 	li	r0,0
-	stw	r0, (mmu_hash_lock - PAGE_OFFSET)@l(r8)
+	stw	r0, (mmu_hash_lock - ADDR_OFFSET)@l(r8)
 #endif
 
 	/* Return from the exception */
@@ -152,9 +164,9 @@ retry:
 #ifdef CONFIG_SMP
 hash_page_out:
 	eieio
-	lis	r8, (mmu_hash_lock - PAGE_OFFSET)@ha
+	lis	r8, (mmu_hash_lock - ADDR_OFFSET)@ha
 	li	r0,0
-	stw	r0, (mmu_hash_lock - PAGE_OFFSET)@l(r8)
+	stw	r0, (mmu_hash_lock - ADDR_OFFSET)@l(r8)
 	blr
 #endif /* CONFIG_SMP */
 
@@ -329,7 +341,7 @@ END_FTR_SECTION_IFCLR(CPU_FTR_NEED_COHERENT)
 	patch_site	1f, patch__hash_page_A1
 	patch_site	2f, patch__hash_page_A2
 	/* Get the address of the primary PTE group in the hash table (r3) */
-0:	lis	r0, (Hash_base - PAGE_OFFSET)@h	/* base address of hash table */
+0:	lis	r0, (Hash_base - ADDR_OFFSET)@h	/* base address of hash table */
 1:	rlwimi	r0,r3,LG_PTEG_SIZE,HASH_LEFT,HASH_RIGHT    /* VSID -> hash */
 2:	rlwinm	r3,r4,20+LG_PTEG_SIZE,HASH_LEFT,HASH_RIGHT /* PI -> hash */
 	xor	r3,r3,r0		/* make primary hash */
@@ -343,10 +355,10 @@ END_FTR_SECTION_IFCLR(CPU_FTR_NEED_COHERENT)
 	beq+	10f			/* no PTE: go look for an empty slot */
 	tlbie	r4
 
-	lis	r4, (htab_hash_searches - PAGE_OFFSET)@ha
-	lwz	r6, (htab_hash_searches - PAGE_OFFSET)@l(r4)
+	lis	r4, (htab_hash_searches - ADDR_OFFSET)@ha
+	lwz	r6, (htab_hash_searches - ADDR_OFFSET)@l(r4)
 	addi	r6,r6,1			/* count how many searches we do */
-	stw	r6, (htab_hash_searches - PAGE_OFFSET)@l(r4)
+	stw	r6, (htab_hash_searches - ADDR_OFFSET)@l(r4)
 
 	/* Search the primary PTEG for a PTE whose 1st (d)word matches r5 */
 	mtctr	r0
@@ -378,10 +390,10 @@ END_FTR_SECTION_IFCLR(CPU_FTR_NEED_COHERENT)
 	beq+	found_empty
 
 	/* update counter of times that the primary PTEG is full */
-	lis	r4, (primary_pteg_full - PAGE_OFFSET)@ha
-	lwz	r6, (primary_pteg_full - PAGE_OFFSET)@l(r4)
+	lis	r4, (primary_pteg_full - ADDR_OFFSET)@ha
+	lwz	r6, (primary_pteg_full - ADDR_OFFSET)@l(r4)
 	addi	r6,r6,1
-	stw	r6, (primary_pteg_full - PAGE_OFFSET)@l(r4)
+	stw	r6, (primary_pteg_full - ADDR_OFFSET)@l(r4)
 
 	patch_site	0f, patch__hash_page_C
 	/* Search the secondary PTEG for an empty slot */
@@ -415,8 +427,8 @@ END_FTR_SECTION_IFCLR(CPU_FTR_NEED_COHERENT)
 	 * lockup here but that shouldn't happen
 	 */
 
-1:	lis	r4, (next_slot - PAGE_OFFSET)@ha	/* get next evict slot */
-	lwz	r6, (next_slot - PAGE_OFFSET)@l(r4)
+1:	lis	r4, (next_slot - ADDR_OFFSET)@ha	/* get next evict slot */
+	lwz	r6, (next_slot - ADDR_OFFSET)@l(r4)
 	addi	r6,r6,HPTE_SIZE			/* search for candidate */
 	andi.	r6,r6,7*HPTE_SIZE
 	stw	r6,next_slot@l(r4)
diff --git a/arch/powerpc/mm/book3s32/mmu.c b/arch/powerpc/mm/book3s32/mmu.c
index 84d5fab94f8f..087487323948 100644
--- a/arch/powerpc/mm/book3s32/mmu.c
+++ b/arch/powerpc/mm/book3s32/mmu.c
@@ -404,6 +404,7 @@ void __init MMU_init_hw(void)
 void __init MMU_init_hw_patch(void)
 {
 	unsigned int hmask = Hash_mask >> (16 - LG_HPTEG_SIZE);
+	unsigned int hash;
 
 	if (ppc_md.progress)
 		ppc_md.progress("hash:patch", 0x345);
@@ -415,8 +416,12 @@ void __init MMU_init_hw_patch(void)
 	/*
 	 * Patch up the instructions in hashtable.S:create_hpte
 	 */
-	modify_instruction_site(&patch__hash_page_A0, 0xffff,
-				((unsigned int)Hash - PAGE_OFFSET) >> 16);
+	if (IS_ENABLED(CONFIG_VMAP_STACK))
+		hash = (unsigned int)Hash;
+	else
+		hash = (unsigned int)Hash - PAGE_OFFSET;
+
+	modify_instruction_site(&patch__hash_page_A0, 0xffff, hash >> 16);
 	modify_instruction_site(&patch__hash_page_A1, 0x7c0, hash_mb << 6);
 	modify_instruction_site(&patch__hash_page_A2, 0x7c0, hash_mb2 << 6);
 	modify_instruction_site(&patch__hash_page_B, 0xffff, hmask);
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 3c42569b75cc..15c9097dc4f7 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -31,12 +31,14 @@ config PPC_BOOK3S_6xx
 	select PPC_HAVE_PMU_SUPPORT
 	select PPC_HAVE_KUEP
 	select PPC_HAVE_KUAP
+	select HAVE_ARCH_VMAP_STACK
 
 config PPC_BOOK3S_601
 	bool "PowerPC 601"
 	select PPC_BOOK3S_32
 	select PPC_FPU
 	select PPC_HAVE_KUAP
+	select HAVE_ARCH_VMAP_STACK
 
 config PPC_85xx
 	bool "Freescale 85xx"
-- 
2.13.3


