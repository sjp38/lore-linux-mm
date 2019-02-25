Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB610C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BBDE213A2
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:49:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="imulGtqB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BBDE213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 545978E0180; Mon, 25 Feb 2019 08:48:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 454EC8E011F; Mon, 25 Feb 2019 08:48:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33F078E0180; Mon, 25 Feb 2019 08:48:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4A238E011F
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:47 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id b6so1266871wmj.7
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=8i6BZYBVOnklYOVbK567NRMBSuNfNdhf+35JteJYb48=;
        b=nJwUjQab4+c8puFLEXW3m07kuOQemLP4c9E/3XAipklL1NWA86IX10XUnohQNEqZiZ
         4W1BTULSjtwF4q39+HEP18c3RM4LYIBglb3h5ky3Q+zxcAFGhAFDoj8RlQ3WL5JDi4CE
         +H7cfLT/nEukBkpTqXSDYfcXBHTnSJq34v8WgqyPCEMnMqjv4WLNG1PcNJXunYBo6dXd
         XVU4fOb0TXu4fSglfG20TzsS5atofJrVx8BIU0huPkKj5//s7Xqdf/rBCo9n/jkDEG7D
         5/dWm2nzxuF6uWHWxmTaTnZ2FIpLwxfNHfUfPp0s6n4S1AWPT5Dl6rCGSgcZQpufKNHB
         5PVQ==
X-Gm-Message-State: AHQUAuYx6gBPQqmX++VvZM1MwiJdaK6HODZWf9988yU1udkwOvNuVikz
	79bTuUP2ZlIPAW3hXUgICnEQsKAhZiEIFIBAXPdYsb+v9rzZuN/yNAin0NH1xjhXw9EZmzN70WY
	jpbfkBYiERriQqIBBgu9ZIJH2J7I4dZf6X/8z5430pm4P5669XR6Vip3pp8baKyTWfQ==
X-Received: by 2002:adf:c7c6:: with SMTP id y6mr12454913wrg.217.1551102527352;
        Mon, 25 Feb 2019 05:48:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4zXPL7Uv2UHx/aLGQLT+cHD768WMdbCPVhV/4Xh01PZ98xuaAVAu2pLgOUXvfM30aj5wX
X-Received: by 2002:adf:c7c6:: with SMTP id y6mr12454879wrg.217.1551102526405;
        Mon, 25 Feb 2019 05:48:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102526; cv=none;
        d=google.com; s=arc-20160816;
        b=Rkt1HmZqYFw+FhUhPWKMtAxaddAAVby5MCQ2y7x4xmALSvAeCVKunvHxfNZ5zTImn2
         Ej83Wu/owuXEfE4SSSXDNiljoX7pFJnfemslVMyqT5Xu+YjbeacWl08pJQP+7ECsvhqK
         R9HeVdYo6Y3rE1FogWIoGS/DntovaCt4DuK+JrI+LEieY3vkOrA5Ws3ynG4BQ4NQAhlT
         XoBWe+fUUtlFbTNMGOuMokGi8l0f46ZO9f2hztt9laZESR/f64BWrcXAD27UlAAljFNR
         4vA7YL5vR6tm+47uxv7epICU67a6flgiE8llNFS8zpcgXg35qtbxxSIYIi9gpATNKf7k
         yl+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=8i6BZYBVOnklYOVbK567NRMBSuNfNdhf+35JteJYb48=;
        b=F+EQGWCRUq4GwqkNiVKcK3DT5ECxRR5S8TCuykHGH2xIy2xxtAlfUuxw1miF5AnH//
         QRgBJJ+Kt2KCr20QvvoUJi8IFKAlFShZZaeuQW62DW37CbxWa7MZsi8k8anlUaOdq4ze
         9lLCoEaV1bqHwqTPHbMDk+2r/VH/+aJg83ueR6k3x8fjzZtE2B7JSsc2EbGfGzN/22wR
         FizM2S/qkpAYmoR1Oy1iWLud/mcKZNpf+o85YCgUNDQU+L2fuTFnBlkMYskOirILmA/B
         f9U6Lc5FYU43JrR2ocHtfIUx8bFHZyV/o2dE8OAhFzCmCSKrEmo1JVj36k58eYn04uqg
         UwCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=imulGtqB;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id e6si5355144wmh.71.2019.02.25.05.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:46 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=imulGtqB;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZd0Ft2zB09b3;
	Mon, 25 Feb 2019 14:48:41 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=imulGtqB; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id OO7uHKRQX9Et; Mon, 25 Feb 2019 14:48:40 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZc6HvszB09Zn;
	Mon, 25 Feb 2019 14:48:40 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102520; bh=8i6BZYBVOnklYOVbK567NRMBSuNfNdhf+35JteJYb48=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=imulGtqBo/ES7Z2dxdDVORNqJ3N0i4PSkqYblVgWQX+panXUiCtjEQGguU3Pal7vr
	 EBaZzGCsI6+36+zobAcXGdiRj7IkLBt0xbxRtaFyvCGdv/zRr6w1joTF6MgoA7lJLU
	 /G29i5DppfA1z7QDqhT51JApPIklKA0m9V17yE/s=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 366BA8B844;
	Mon, 25 Feb 2019 14:48:45 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id VXX0HYr9fIOD; Mon, 25 Feb 2019 14:48:45 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0A9AA8B81D;
	Mon, 25 Feb 2019 14:48:45 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 8A7636F20E; Mon, 25 Feb 2019 13:48:45 +0000 (UTC)
Message-Id: <a7d608d51bda982afbe51ec6a34c67cd6a7c8cef.1551098215.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 10/11] powerpc/32s: move hash code patching out of
 MMU_init_hw()
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For KASAN, hash table handling will be activated early for
accessing to KASAN shadow areas.

In order to avoid any modification of the hash functions while
they are still used with the early hash table, the code patching
is moved out of MMU_init_hw() and put close to the big-bang switch
to the final hash table.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_32.S |  3 +++
 arch/powerpc/mm/mmu_decl.h    |  1 +
 arch/powerpc/mm/ppc_mmu_32.c  | 34 ++++++++++++++++++++--------------
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 02229c005853..e644aab2cf5b 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -960,6 +960,9 @@ start_here:
 	bl	machine_init
 	bl	__save_cpu_setup
 	bl	MMU_init
+BEGIN_MMU_FTR_SECTION
+	bl	MMU_init_hw_patch
+END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
 
 /*
  * Go back to running unmapped so we can load up new values
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index 74ff61dabcb1..d726ff776054 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -130,6 +130,7 @@ extern void wii_memory_fixups(void);
  */
 #ifdef CONFIG_PPC32
 extern void MMU_init_hw(void);
+void MMU_init_hw_patch(void);
 unsigned long mmu_mapin_ram(unsigned long base, unsigned long top);
 #endif
 
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index 2d5b0d50fb31..d591f768fac6 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -39,6 +39,7 @@
 struct hash_pte *Hash, *Hash_end;
 unsigned long Hash_size, Hash_mask;
 unsigned long _SDR1;
+static unsigned int Hash_mb, Hash_mb2;
 
 struct ppc_bat BATS[8][2];	/* 8 pairs of IBAT, DBAT */
 
@@ -308,7 +309,6 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
  */
 void __init MMU_init_hw(void)
 {
-	unsigned int hmask, mb, mb2;
 	unsigned int n_hpteg, lg_n_hpteg;
 
 	if (!mmu_has_feature(MMU_FTR_HPTE_TABLE))
@@ -349,20 +349,28 @@ void __init MMU_init_hw(void)
 	       (unsigned long long)(total_memory >> 20), Hash_size >> 10, Hash);
 
 
-	/*
-	 * Patch up the instructions in hashtable.S:create_hpte
-	 */
-	if ( ppc_md.progress ) ppc_md.progress("hash:patch", 0x345);
 	Hash_mask = n_hpteg - 1;
-	hmask = Hash_mask >> (16 - LG_HPTEG_SIZE);
-	mb2 = mb = 32 - LG_HPTEG_SIZE - lg_n_hpteg;
+	Hash_mb2 = Hash_mb = 32 - LG_HPTEG_SIZE - lg_n_hpteg;
 	if (lg_n_hpteg > 16)
-		mb2 = 16 - LG_HPTEG_SIZE;
+		Hash_mb2 = 16 - LG_HPTEG_SIZE;
+}
+
+void __init MMU_init_hw_patch(void)
+{
+	unsigned int hmask = Hash_mask >> (16 - LG_HPTEG_SIZE);
+
+	if ( ppc_md.progress ) ppc_md.progress("hash:patch", 0x345);
+	if ( ppc_md.progress ) ppc_md.progress("hash:done", 0x205);
 
+	/* WARNING: Make sure nothing can trigger a KASAN check past this point */
+
+	/*
+	 * Patch up the instructions in hashtable.S:create_hpte
+	 */
 	modify_instruction_site(&patch__hash_page_A0, 0xffff,
 				((unsigned int)Hash - PAGE_OFFSET) >> 16);
-	modify_instruction_site(&patch__hash_page_A1, 0x7c0, mb << 6);
-	modify_instruction_site(&patch__hash_page_A2, 0x7c0, mb2 << 6);
+	modify_instruction_site(&patch__hash_page_A1, 0x7c0, Hash_mb << 6);
+	modify_instruction_site(&patch__hash_page_A2, 0x7c0, Hash_mb2 << 6);
 	modify_instruction_site(&patch__hash_page_B, 0xffff, hmask);
 	modify_instruction_site(&patch__hash_page_C, 0xffff, hmask);
 
@@ -371,11 +379,9 @@ void __init MMU_init_hw(void)
 	 */
 	modify_instruction_site(&patch__flush_hash_A0, 0xffff,
 				((unsigned int)Hash - PAGE_OFFSET) >> 16);
-	modify_instruction_site(&patch__flush_hash_A1, 0x7c0, mb << 6);
-	modify_instruction_site(&patch__flush_hash_A2, 0x7c0, mb2 << 6);
+	modify_instruction_site(&patch__flush_hash_A1, 0x7c0, Hash_mb << 6);
+	modify_instruction_site(&patch__flush_hash_A2, 0x7c0, Hash_mb2 << 6);
 	modify_instruction_site(&patch__flush_hash_B, 0xffff, hmask);
-
-	if ( ppc_md.progress ) ppc_md.progress("hash:done", 0x205);
 }
 
 void setup_initial_memory_limit(phys_addr_t first_memblock_base,
-- 
2.13.3

