Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F348EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1AE921848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="TbTml2UO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1AE921848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2F2F8E000A; Tue, 26 Feb 2019 12:22:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B14C08E000E; Tue, 26 Feb 2019 12:22:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9198A8E000A; Tue, 26 Feb 2019 12:22:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28F938E000E
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:55 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e14so6490763wrt.12
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=CUXrFBKhYBz+mCNccGBkdNShdaiuJr/Xy6eAIyQykWk=;
        b=DlN6T2xj2jCmbk0EmoEdxSWuCGXnetzM+W3CQZ+c6ykar6PLIfrykEO3DiS1FniTY4
         PWVaYjpOel5gioHCxfJ37kUBoDRRLSHdl0SR97gTrGbMoksKeFLt/OWzB/9IgJPZ4iYm
         1F4mq2uNYx1qRq5mfCWAZIW8yA2uet3Ahhzm+CzRe7Csw6qGnZX/9BXrtN+OGuO7Hv9M
         Yl/l8+xzSzXMpb0jzHUw3I+H0KQ3rXSOrsCMEqK8KL4RokBoo90W0xD5HHpxoQST/Dop
         +yeTzBDwdLs9WLlNOCbSuG70be2z2dWrRBEY0+RSclVCqsus6Qglbyjs8/8KaU1bV1oy
         dxaw==
X-Gm-Message-State: AHQUAuaJUY6KWYwuRWGKGS2iD19dkOGf2Jh+XdfPaTr4kRMDYEm0ACDU
	JlILu+CiMP1Os34d922KEQdxP0nrC9VWDHvgdr7s3CLePRa13Itbba2KyEcmCpWZY+kH0hN86eO
	jb7dSsmFTqJuku0Ks0r95PIA8sO5EJN5mF02iTUHmWY8frwaK9qjRiANW+q27YVn8kw==
X-Received: by 2002:a05:6000:50:: with SMTP id k16mr12816121wrx.153.1551201774676;
        Tue, 26 Feb 2019 09:22:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbPpdYMXLHbRoCPEwxGY+zbANs/9kXEMIL6v8PcHh72PUD7cG8HYKQe/GKdqVJ/GZxApcVJ
X-Received: by 2002:a05:6000:50:: with SMTP id k16mr12816059wrx.153.1551201773578;
        Tue, 26 Feb 2019 09:22:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201773; cv=none;
        d=google.com; s=arc-20160816;
        b=uABUv6B77v5jC+dbfmfjSTjBQQomVA/ykPKrSI8GeBejtBExBArOkAkBalY3HwoQSn
         zmU+jkeqwME/o4tWv5vl7s7TaYXQBb0ackNlICZ9SxhoOu3AD7YwH3D2BiEx6GBwU99N
         L1cdjHssdSpJuSYPXE0MyhXU53+KD9136VXhbfU7JV7+iYAadlHKT7bJWFLOnDV92kEw
         UEtdlrTyDhbgHU7FMk1iXJRw385H7GmaWcQr9L0Bmi7ghyVg4eJm/U7Q3xZaDFZcnjs7
         mdPG5Wd/E47nMH1uWGI11zU4nrDKq3zj4crC+xaS9VFYVrs0xGj0yvvLPAj7AEO6dnsF
         AwTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=CUXrFBKhYBz+mCNccGBkdNShdaiuJr/Xy6eAIyQykWk=;
        b=KlMgX56LXuzYOLW6yCdo5UQDc/qaF2wGeu6FiuDFIW9mN+cYEOz9oTmEkT07xAseeT
         7rxzVMXE+/VATiNu7EFA9O1ptIhGYGcYswZr8uAUNK9nwsef3/G4+W+AKDYE7t15Wjrx
         i/VsgSlYRkEdeQ7fYGcDiiS96TMCOxJ1g8onuKl8NP8G00faedFF1q+1PzHwmdZ7G8RB
         5AHz8gxQZpkzJlJpEljML1nrNJAdmfPakYYelhIJg2aPGezhXosl+UFwVa56yZDsYPP2
         GKFw0gzzAxYEmVMFr9YprAsZJGjH8lhTuWesqmRDGrBddu6azTHX3JMBMIwjDkGtAO6I
         DzMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=TbTml2UO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n16si8519588wrx.115.2019.02.26.09.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:53 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=TbTml2UO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485HH3l0jz9vJLc;
	Tue, 26 Feb 2019 18:22:51 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=TbTml2UO; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id roTJiIgRYxfx; Tue, 26 Feb 2019 18:22:51 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485HH2dx4z9vJLY;
	Tue, 26 Feb 2019 18:22:51 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201771; bh=CUXrFBKhYBz+mCNccGBkdNShdaiuJr/Xy6eAIyQykWk=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=TbTml2UOrOMFk5cVLsf04ffiKDLFYoUnVi3gyaj3KDWMfZqtgY5b8p5lzHRktEiO6
	 Mxaisx+5+S9KEBMqEEo6/ibLk3DY0hE4ywewiZCPL+Yt47jyX9XqKNrx9rKBTS1rjL
	 yOvR023jksF7QaXyz6cIAukt7ZLGOCOv10+4TeMM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 028DF8B97A;
	Tue, 26 Feb 2019 18:22:53 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id fSpD_c9jC6vE; Tue, 26 Feb 2019 18:22:52 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B11228B96A;
	Tue, 26 Feb 2019 18:22:52 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 854736F7A6; Tue, 26 Feb 2019 17:22:52 +0000 (UTC)
Message-Id: <d25f9dea2afed63d30ed4894f0a9b129040f51e1.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 11/11] powerpc/32s: set up an early static hash table for
 KASAN.
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:52 +0000 (UTC)
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
index e644aab2cf5b..65c9e8819da1 100644
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
+	lis	r6, early_hash - PAGE_OFFSET@h
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
index 42f8534ce3ea..8c25c1e8c2c8 100644
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
+u8 __initdata early_hash[256 << 10] __aligned(256 << 10) = {0};
+
+static void __init kasan_early_hash_table(void)
+{
+	modify_instruction_site(&patch__hash_page_A0, 0xffff, __pa(early_hash) >> 16);
+	modify_instruction_site(&patch__flush_hash_A0, 0xffff, __pa(early_hash) >> 16);
+
+	Hash = (struct hash_pte *)early_hash;
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
index d726ff776054..31fce3914ddc 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -106,6 +106,7 @@ extern unsigned int rtas_data, rtas_size;
 struct hash_pte;
 extern struct hash_pte *Hash, *Hash_end;
 extern unsigned long Hash_size, Hash_mask;
+extern u8 early_hash[];
 
 #endif /* CONFIG_PPC32 */
 
-- 
2.13.3

