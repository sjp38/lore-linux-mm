Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE739C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F8BB2083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="aF0T3QOn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F8BB2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3F6E8E0009; Tue, 19 Feb 2019 12:23:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9FAD8E0008; Tue, 19 Feb 2019 12:23:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A15E78E0009; Tue, 19 Feb 2019 12:23:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39BD58E0008
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:21 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id s5so9253767wrp.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=Jv4JVBbRhfA3gyIP1EYU/TxFEfL2VMG+F/ri6hG6mlk=;
        b=QXakC02qSsvZm1AeDiKCAQ0fi7k94IQuCPXVTPeDj7z3leJqc6DRolxs5ub40pKg3w
         3vaTYHqQGYSpoOUtPtBGHgl9hQegi3YcfcHhDl9F18KZY0VD5rcSIZ4aH5ktlm6w0dmP
         W3/KHGg6T0fhwpdU1EQGNX2P1Ui9qlZu8fD9KNUfkYMb6cbArH4bUnoqkNTH32MSoABQ
         I31zD/Oexn1rQQ0SnyiATa2utO0oRbJeq4I8rc2ILrCqQrMBROG39psySBAZ9roj8mhL
         pXP0jqJRQa59FGdUHThkmWujmkn5W/M/beNjKIGd6fyKPXmMPRMl1UO3fK4BsMr6x12o
         aHdg==
X-Gm-Message-State: AHQUAuY0sbi+mY6hiFSNi8XFSWUPDuK4mmwQTPU0/IMb2UufQXmNzdIt
	c6mTgw5DqG7qbslE67PQkrrR4iYjATYuOd2apWHAZJfNJIVC4MSOTmdvvIrEtBDTZHfMxL1hTND
	J5dbytG0VnwPySkgHOwArxHiadnYVDe58u+N3L+DOXfjcw4GUb4XLY3iNmjedPKNxyw==
X-Received: by 2002:adf:b646:: with SMTP id i6mr22254774wre.262.1550597000748;
        Tue, 19 Feb 2019 09:23:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IacvXQHs8do7PtUQnJDJfBlZEnFg5xShTWUmx6GcIpWcOwy3yxl8sMykxfeHZge56PX1u4I
X-Received: by 2002:adf:b646:: with SMTP id i6mr22254725wre.262.1550596999768;
        Tue, 19 Feb 2019 09:23:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596999; cv=none;
        d=google.com; s=arc-20160816;
        b=eiHdbf8calKGkO2ujfJJehf0MxPT+RmKId0JQIVhWCepS1/9/O4HZbpdA5FGTNYBmc
         8NZc8yPcp2vMRu0IB0dUUOhb5PRi46u2TitW9iLTtWopJosAyG622kpmtS+a7Ec9ak75
         /tgSVB0VIJ7OuIV+HeMnx0U1WkleU9NTvKiTwe7R1BJg68glpMqyjXQa8+cPMfeJRJNr
         Ycd3ZpwQBfxO8e31Gmpr8JSs7NfUOURB5lm5MBkqIG/2rVw9hBLdp9v8Pp3o09qIrG6k
         P5vV73pi8MPXQX6VR7bQDUhgdWURtjbUjIjU2PmfYVNF+eDVn6R6n+YgPTf3WcI9bmK+
         6H9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=Jv4JVBbRhfA3gyIP1EYU/TxFEfL2VMG+F/ri6hG6mlk=;
        b=GavkRj+C1DPHZFTPVdb2qgQNTIlYmvV41VGdHee62zpd6f46xpFVPVXm+qH+zDMoDZ
         Uo72FHBeWQ9XxX8TyUc83tG7MoBYH++SH0qjtFTiIlvCDfzIKOnhaeopdD++O8337NLG
         i8MD+5gjHJc6Ow1Gq8gWiD9Cmn1z+QoF8U+KX+k67FlB45fumq8e3s4aG/B+34tjn5aN
         8Wi/G97TA4nQvKBtCqJGHZlzqHCavJ+UZziG8klhWuUjnTmtek98ZbxUxmZYrTFN4F9z
         1jFHR8r83yPMXWPy3CZXvK1qWosgGzX8MKaRHFmSaAa736TdVKhQYt3m6B+DI2PqhAJr
         0c2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=aF0T3QOn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n3si1836126wmh.25.2019.02.19.09.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:19 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=aF0T3QOn;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443nd13SlVz9v4wh;
	Tue, 19 Feb 2019 18:23:17 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=aF0T3QOn; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id z64kTG7dNlcw; Tue, 19 Feb 2019 18:23:17 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443nd12Ljjz9v4wf;
	Tue, 19 Feb 2019 18:23:17 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596997; bh=Jv4JVBbRhfA3gyIP1EYU/TxFEfL2VMG+F/ri6hG6mlk=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=aF0T3QOn8yGPZr6IFDElhGbGr/VoMO6mCmlKI6jNFM9Qdog2yFGH0s/P8D6Ar94AI
	 Qjq7crncHc1zDoznvtPGtj/Riko/lE89rVwNOlc+P/hEh//fv8QMfyzgAHiDgtFu7y
	 pkiWOojNjzKmExJ2CQRq19MknrgXXM7ilApNjnjY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id EA8828B7FE;
	Tue, 19 Feb 2019 18:23:18 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 0MSO2AGC11U1; Tue, 19 Feb 2019 18:23:18 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A1DFD8B7F9;
	Tue, 19 Feb 2019 18:23:18 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 739186E81D; Tue, 19 Feb 2019 17:23:18 +0000 (UTC)
Message-Id: <4256ccd5f58f58f13ff06bfcf86fab06d52a86d2.1550596242.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1550596242.git.christophe.leroy@c-s.fr>
References: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 6/6] powerpc/32: enable CONFIG_KASAN for book3s hash
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The challenge with book3s/32 is that the hash table management
has to be set up before being able to use KASAN.

This patch adds a kasan_arch_is_ready() helper to defer
the activation of KASAN until paging is ready.

This limits KASAN to KASAN_MINIMAL mode. The downside of it
is that the 603, which doesn't use hash table, also gets
downgraded to KASAN_MINIMAL because this is no way to
activate full support dynamically because that's compiled-in.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Makefile                 |  2 ++
 arch/powerpc/include/asm/kasan.h      | 13 +++++++++++++
 arch/powerpc/mm/kasan/kasan_init_32.c | 27 +++++++++++++++++++++++++--
 3 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/Makefile b/arch/powerpc/Makefile
index f0738099e31e..06d085558d21 100644
--- a/arch/powerpc/Makefile
+++ b/arch/powerpc/Makefile
@@ -428,11 +428,13 @@ endif
 endif
 
 ifdef CONFIG_KASAN
+ifndef CONFIG_PPC_BOOK3S_32
 prepare: kasan_prepare
 
 kasan_prepare: prepare0
        $(eval KASAN_SHADOW_OFFSET = $(shell awk '{if ($$2 == "KASAN_SHADOW_OFFSET") print $$3;}' include/generated/asm-offsets.h))
 endif
+endif
 
 # Check toolchain versions:
 # - gcc-4.6 is the minimum kernel-wide version so nothing required.
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 0bc9148f5d87..97b5ccf0702f 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -16,6 +16,7 @@
 
 #include <asm/page.h>
 #include <asm/pgtable-types.h>
+#include <linux/jump_label.h>
 
 #define KASAN_SHADOW_SCALE_SHIFT	3
 
@@ -34,5 +35,17 @@
 void kasan_early_init(void);
 void kasan_init(void);
 
+extern struct static_key_false powerpc_kasan_enabled_key;
+
+static inline bool kasan_arch_is_ready(void)
+{
+	if (!IS_ENABLED(CONFIG_BOOK3S_32))
+		return true;
+	if (static_branch_likely(&powerpc_kasan_enabled_key))
+		return true;
+	return false;
+}
+#define kasan_arch_is_ready kasan_arch_is_ready
+
 #endif /* __ASSEMBLY */
 #endif
diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
index 495c908d6ee6..f24f8f56d450 100644
--- a/arch/powerpc/mm/kasan/kasan_init_32.c
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -9,6 +9,9 @@
 #include <linux/vmalloc.h>
 #include <asm/pgalloc.h>
 
+/* Used by BOOK3S_32 only */
+DEFINE_STATIC_KEY_FALSE(powerpc_kasan_enabled_key);
+
 void __init kasan_early_init(void)
 {
 	unsigned long addr = KASAN_SHADOW_START;
@@ -21,7 +24,7 @@ void __init kasan_early_init(void)
 	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
 
 	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
-		panic("KASAN not supported with Hash MMU\n");
+		return;
 
 	for (i = 0; i < PTRS_PER_PTE; i++)
 		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
@@ -32,6 +35,22 @@ void __init kasan_early_init(void)
 		next = pgd_addr_end(addr, end);
 		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
 	} while (pmd++, addr = next, addr != end);
+
+	if (IS_ENABLED(CONFIG_PPC_BOOK3S_32)) {
+		jump_label_init();
+		static_branch_enable(&powerpc_kasan_enabled_key);
+	}
+}
+
+static void __init kasan_late_init(void)
+{
+	unsigned long addr;
+	phys_addr_t pa = __pa(kasan_early_shadow_page);
+
+	for (addr = KASAN_SHADOW_START; addr < KASAN_SHADOW_END; addr += PAGE_SIZE)
+		map_kernel_page(addr, pa, PAGE_KERNEL_RO);
+
+	static_branch_enable(&powerpc_kasan_enabled_key);
 }
 
 static void __ref *kasan_get_one_page(void)
@@ -113,6 +132,9 @@ void __init kasan_init(void)
 {
 	struct memblock_region *reg;
 
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		kasan_late_init();
+
 	for_each_memblock(memory, reg) {
 		int ret = kasan_init_region(__va(reg->base), reg->size);
 
@@ -120,7 +142,8 @@ void __init kasan_init(void)
 			panic("kasan: kasan_init_region() failed");
 	}
 
-	kasan_remap_early_shadow_ro();
+	if (!early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		kasan_remap_early_shadow_ro();
 
 	clear_page(kasan_early_shadow_page);
 
-- 
2.13.3

