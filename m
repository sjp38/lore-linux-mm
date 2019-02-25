Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 595C9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 047AA20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="uFzyzm8M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 047AA20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FD1C8E0181; Mon, 25 Feb 2019 08:48:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D86A8E011F; Mon, 25 Feb 2019 08:48:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6286B8E0181; Mon, 25 Feb 2019 08:48:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 086608E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:49 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id q24so334330wmq.9
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=eNCDjVYIgy6lNbk859Vm+9SPMgCX7rafzT3Fmt9o26w=;
        b=MuucZRQQKYJs7QFUX7owjtRsJYyfMwmTMlogM5FcnEFviZTAdL0bJcfET/cQ+E6TSz
         fq7ALmpKcfzBJawWLVHjBSH2Y6Zw+QwBKCyFaD9MixYLa0l6G81PgPnrMPSlsTGUctix
         JfMmyfWAR8vmdhc/ovWpcNOJNrwWHNxKmOsJ5m51A+MvKFZWKeysWtXG0zg0PsmkbvHd
         FHHTbgJJ9qUSUalbNzS2+xYw/w9fcl2aY9EOqiBjDZjO9u5DCBrx/lj5lZJtw9t5YyrU
         o13VYtnhi4TjMCJ/+9gjNVXRO0zM0Hqbu8N1uMLuyLT2yTBsXPuj08zm4nW6EAcuc4oj
         G0Ug==
X-Gm-Message-State: AHQUAuYHQiwCQv/I7gNQOSUfFeho0l/jsyB9KBdfGe7fWGb2HhPtPj9+
	rniBbZTtPr2EqwScxtqT9L5CfgCCC8Yp+D/szaj97c5zNUie2tcdeC7tKw6R8rEflKt+FtXYarl
	CSNE6mY1L15u7z+Y8+8NkVvGkgTSc8K4SO+IIMYST1wYQZLHzgGAEzckJMY7XU5sXmA==
X-Received: by 2002:a1c:dc07:: with SMTP id t7mr11117114wmg.90.1551102528493;
        Mon, 25 Feb 2019 05:48:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZ1u5DMaHe8oIFAWfeFGfQ4AD0GuzDAwl6UrXCzwDL2zHVUWjHRjeaN7gdQjeubXMuy07x
X-Received: by 2002:a1c:dc07:: with SMTP id t7mr11117078wmg.90.1551102527574;
        Mon, 25 Feb 2019 05:48:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102527; cv=none;
        d=google.com; s=arc-20160816;
        b=OQbzfGVjaW219EoVQ5LCuuiFOuWrasfNgWlvlWg93KWT1GmoLqh4ToCwNrNe3dPI/F
         RQbqzhBqWL/XIqCyYg/bxCMzwlLALIW2liRUu4dFNCkigGMVgXVlJLFxw4oe9AeEgdFq
         DecTBHvbTrLROmiCDqblwmd+VY8BPhcegEWabWOZyHXnEEO5tIPv6sGM4jeRLJyJKdYT
         4p82N8mz117JyhiJ90lEr7cgilvHFDNjpRc8obZ6AaAA7IONgoM9o1AY6knkJiMOrO1F
         Om625uBT5UqCljrR86cn8Z6a3n8ARkPl/bDEtCVwtnxV+L8mf+pWjK/Z6QSuR5F/9kL7
         xk3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=eNCDjVYIgy6lNbk859Vm+9SPMgCX7rafzT3Fmt9o26w=;
        b=YOU0Iiyrrwf3HgWdZ+HjiBpIsKLeq7qI6CVWiVwE1hUwV1+StoHgwG4rrmll2n7Azi
         54BdiKLOXKn0TXtWV22ylf3jiDYYVtkTApIbxSXx1KnHsKLyfemABQZLaXzG/bHnYrtN
         REQvD3DJSl5BRRemKMn7SwxxW/lXfytz6zlGbUju/AhRfiu2qsGqBrxlywqkZlC1/1is
         4fdmGU6cp14inlBYHIADM6/I1bQLCaib0HQJR3mw0Aa9ORT7ObAZanPbdrTbU1jVxBJk
         W7rcdZ98OdCjlBNQ71a2QDEh0N8CSZMDTNYBWiU5mZnicJjIVoEkX9KZrWj9I72gMUdN
         OX+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=uFzyzm8M;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id h9si6392853wrq.2.2019.02.25.05.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:47 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=uFzyzm8M;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZf0NwtzB09b4;
	Mon, 25 Feb 2019 14:48:42 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=uFzyzm8M; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id kBscLWewVmDX; Mon, 25 Feb 2019 14:48:41 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZd6KrLzB09Zn;
	Mon, 25 Feb 2019 14:48:41 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102521; bh=eNCDjVYIgy6lNbk859Vm+9SPMgCX7rafzT3Fmt9o26w=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=uFzyzm8MHshOvTiqr+SoqqSnIL/1hRd+UvKp2q3wxh2kEzVYT66d+sUcACOqTy5uH
	 Wxoj5wDCoJH6zMR9yF2vYt4Qu/Unq/UhpeNTYVtrHYPJX34Mvy7qNtF1Qt0XHQM1XM
	 Ig53qS3xB5renN+INmF1bcyWWukiLMvkf6ppJwQ4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 3E2CB8B844;
	Mon, 25 Feb 2019 14:48:46 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id VlpQTLdF9oug; Mon, 25 Feb 2019 14:48:46 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 110A78B81D;
	Mon, 25 Feb 2019 14:48:46 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 976CC6F20E; Mon, 25 Feb 2019 13:48:46 +0000 (UTC)
Message-Id: <dc2c2eb871dbf1d025b6aa32d325f8aedb85df53.1551098215.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 11/11] powerpc/32s: set up an early static hash table for
 KASAN.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

KASAN requires early activation of hash table, before memblock()
functions are available.

This patch implements an early hash_table statically defined in
__initdata.

During early boot, a single page table is used. For hash32, when doing
the final init, one page table is allocated for each PGD entry because
of the _PAGE_HASHPTE flag which can't be common to several virt pages.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_32.S         | 40 ++++++++++++++++++++++++++---------
 arch/powerpc/mm/kasan/kasan_init_32.c | 32 ++++++++++++++++++++++++----
 arch/powerpc/mm/mmu_decl.h            |  1 +
 3 files changed, 59 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index e644aab2cf5b..1d881047ce76 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -160,6 +160,10 @@ __after_mmu_off:
 	bl	flush_tlbs
 
 	bl	initial_bats
+	bl	load_segment_registers
+#ifdef CONFIG_KASAN
+	bl	early_hash_table
+#endif
 #if defined(CONFIG_BOOTX_TEXT)
 	bl	setup_disp_bat
 #endif
@@ -205,7 +209,7 @@ __after_mmu_off:
  */
 turn_on_mmu:
 	mfmsr	r0
-	ori	r0,r0,MSR_DR|MSR_IR
+	ori	r0,r0,MSR_DR|MSR_IR|MSR_RI
 	mtspr	SPRN_SRR1,r0
 	lis	r0,start_here@h
 	ori	r0,r0,start_here@l
@@ -881,11 +885,24 @@ _ENTRY(__restore_cpu_setup)
 	blr
 #endif /* !defined(CONFIG_PPC_BOOK3S_32) */
 
-
 /*
  * Load stuff into the MMU.  Intended to be called with
  * IR=0 and DR=0.
  */
+#ifdef CONFIG_KASAN
+early_hash_table:
+	sync			/* Force all PTE updates to finish */
+	isync
+	tlbia			/* Clear all TLB entries */
+	sync			/* wait for tlbia/tlbie to finish */
+	TLBSYNC			/* ... on all CPUs */
+	/* Load the SDR1 register (hash table base & size) */
+	lis	r6, early_Hash - PAGE_OFFSET@h
+	ori	r6, r6, 3	/* 256kB table */
+	mtspr	SPRN_SDR1, r6
+	blr
+#endif
+
 load_up_mmu:
 	sync			/* Force all PTE updates to finish */
 	isync
@@ -897,14 +914,6 @@ load_up_mmu:
 	tophys(r6,r6)
 	lwz	r6,_SDR1@l(r6)
 	mtspr	SPRN_SDR1,r6
-	li	r0,16		/* load up segment register values */
-	mtctr	r0		/* for context 0 */
-	lis	r3,0x2000	/* Ku = 1, VSID = 0 */
-	li	r4,0
-3:	mtsrin	r3,r4
-	addi	r3,r3,0x111	/* increment VSID */
-	addis	r4,r4,0x1000	/* address of next segment */
-	bdnz	3b
 
 /* Load the BAT registers with the values set up by MMU_init.
    MMU_init takes care of whether we're on a 601 or not. */
@@ -926,6 +935,17 @@ BEGIN_MMU_FTR_SECTION
 END_MMU_FTR_SECTION_IFSET(MMU_FTR_USE_HIGH_BATS)
 	blr
 
+load_segment_registers:
+	li	r0, 16		/* load up segment register values */
+	mtctr	r0		/* for context 0 */
+	lis	r3, 0x2000	/* Ku = 1, VSID = 0 */
+	li	r4, 0
+3:	mtsrin	r3, r4
+	addi	r3, r3, 0x111	/* increment VSID */
+	addis	r4, r4, 0x1000	/* address of next segment */
+	bdnz	3b
+	blr
+
 /*
  * This is where the main kernel code starts.
  */
diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
index b7c0fdd88c8e..0058bf606fbd 100644
--- a/arch/powerpc/mm/kasan/kasan_init_32.c
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -60,10 +60,13 @@ static int __ref kasan_init_region(void *start, size_t size)
 	unsigned long k_cur;
 	pmd_t *pmd;
 	void *block = NULL;
-	int ret = kasan_init_shadow_page_tables(k_start, k_end);
 
-	if (ret)
-		return ret;
+	if (!early_mmu_has_feature(MMU_FTR_HPTE_TABLE)) {
+		int ret = kasan_init_shadow_page_tables(k_start, k_end);
+
+		if (ret)
+			return ret;
+	}
 
 	if (!slab_is_available())
 		block = memblock_alloc(k_end - k_start, PAGE_SIZE);
@@ -94,6 +97,13 @@ void __init kasan_init(void)
 	int ret;
 	struct memblock_region *reg;
 
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE)) {
+		ret = kasan_init_shadow_page_tables(KASAN_SHADOW_START, KASAN_SHADOW_END);
+
+		if (ret)
+			panic("kasan: kasan_init_shadow_page_tables() failed");
+	}
+
 	for_each_memblock(memory, reg) {
 		phys_addr_t base = reg->base;
 		phys_addr_t top = min(base + reg->size, total_lowmem);
@@ -132,6 +142,20 @@ void *module_alloc(unsigned long size)
 }
 #endif
 
+#ifdef CONFIG_PPC_BOOK3S_32
+u8 __initdata early_Hash[256 << 10] __aligned(256 << 10) = {0};
+
+static void __init kasan_early_hash_table(void)
+{
+	modify_instruction_site(&patch__hash_page_A0, 0xffff, __pa(early_Hash) >> 16);
+	modify_instruction_site(&patch__flush_hash_A0, 0xffff, __pa(early_Hash) >> 16);
+
+	Hash = (struct hash_pte *)early_Hash;
+}
+#else
+static void __init kasan_early_hash_table(void) {}
+#endif
+
 void __init kasan_early_init(void)
 {
 	unsigned long addr = KASAN_SHADOW_START;
@@ -149,5 +173,5 @@ void __init kasan_early_init(void)
 	} while (pmd++, addr = next, addr != end);
 
 	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
-		WARN(1, "KASAN not supported on hash 6xx");
+		kasan_early_hash_table();
 }
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index d726ff776054..525f7640ff40 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -106,6 +106,7 @@ extern unsigned int rtas_data, rtas_size;
 struct hash_pte;
 extern struct hash_pte *Hash, *Hash_end;
 extern unsigned long Hash_size, Hash_mask;
+extern u8 early_Hash[];
 
 #endif /* CONFIG_PPC32 */
 
-- 
2.13.3

