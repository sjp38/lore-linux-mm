Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACD87C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C3F8213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ukLy0Za9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C3F8213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F9C18E000B; Tue, 12 Mar 2019 18:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181B08E000C; Tue, 12 Mar 2019 18:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F41098E000B; Tue, 12 Mar 2019 18:16:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE268E0008
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:17 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n15so1617168wrr.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=qftxIRS2sXPtUc8RllSiVhFeKOVSdrNhU7qz1nf0Bb2QFvqTrA2fRJUTXu+bOepi/q
         K9RaPaOtbmbD4CBeWGDwwcEtxg745TQgh7B5J+iMZsgBsib+/+BVkH3bfjoKDnISq5aY
         NVBWwNWKN1PP84KBjPqXgrr/Q1ZkMUjCmNMtn3s90I0tJ/553nqaTqJzRVb9DOPB39u1
         LruFFYFS8jkvnlXD/CLCFvL7PRrm8aPK/6lYkI3lKwAx0Li+Hm9JWeQL0r7dv97DnPSK
         ZveWNoeQoF2Ze1HvqTIaNCL/U3L1tZRu1T2ULQ57cUVLkk7g4CrtUAnukM+4eeWSE1yO
         0AUA==
X-Gm-Message-State: APjAAAW+ee2cj3bMA5ELQ7LYN87K68yF9aewp0/Ve8jIXyCfs90z9zaJ
	DpB1BKFwzABxOMz/5OUG//nyK4Cy3iisckeGBQkX+gMMSLar4GCE8KNG+eSvAgTq65LN6tG9hgH
	DbzZbGAJev/ZedG9kcxJZ1UCZj3u2eFz5IwAn4mk93WEEOcDmBXh2KtPYNgDv2hsetw==
X-Received: by 2002:adf:ecca:: with SMTP id s10mr4744808wro.138.1552428976797;
        Tue, 12 Mar 2019 15:16:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwByTm386H9vY0vxl4COpm9zrIM/G9lJx+a91hsg0OKfgh4VGtesD2VhxqPPxhfDvigprOd
X-Received: by 2002:adf:ecca:: with SMTP id s10mr4744748wro.138.1552428975098;
        Tue, 12 Mar 2019 15:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428975; cv=none;
        d=google.com; s=arc-20160816;
        b=cXCaPLsQ9ZU6COsdB9mWh5iZc/bX6/paranmtKh5RTqenLLBZtqhvNF4YqtMvOFLYQ
         +1SN6QoXLMYRtHTLu/tScpayh7QRmcm7d3ZLYX9Tz+eAnenT1giGzzy959qQEHNkt+7+
         qm9inyZtpqslkSiDR7ouP6EQLShfEPQ9kt5cB/zgHMqyyDciZI1LGVXTy0CE0XMDicxr
         Bd2H//1Grcu1UQ/uLbhWVaT1Ere2vn5iAo2vZkVlrt2o2W1pcRWQTHkUI0p7/x0qvBqP
         mD0iKkQZi7tlTmXQQGJa8EirZnhWMbecejJUVF0jZieA6lTA57uT04zPNm4wmc96zchA
         wi4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
        b=uxLbzpWkqA3tR5hO08CXpJJJPn1bvUZvZWexXk6B81jUdhdjt8qwniSoWszj1SeHCb
         mzddii9U7YEp4rkDgqJE0iQMsdB1pkEG466hmW2H5PLpms8fQ/L2Uamw+XYLEzMx8TIJ
         5gpuMBwCMGbzZhGtb1DodBhV2dNtEQjNvoXdO83n2KiuADwOZroNdUOLbv/WikzWNV9u
         UU+jqGy8/B8ARgnfx4ztvoLBiPSDnC7LRsw0m1A772e6WKo+IZbarQtdSl5dxW36oLX0
         zc/TNI1j5nuRT7+aaigaodDmMDFpxLMktnW4oGVL8aA7wXcKsrLUTVkFGDHy57tLkalF
         e6RA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ukLy0Za9;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id v62si8551wma.181.2019.03.12.15.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ukLy0Za9;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7L3FNPzB09Zr;
	Tue, 12 Mar 2019 23:16:14 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ukLy0Za9; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id NpOVPJM2k5EE; Tue, 12 Mar 2019 23:16:14 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7L1t58zB09ZG;
	Tue, 12 Mar 2019 23:16:14 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428974; bh=T5roomQKloe+Cr1IT+Xg0/TzN2EQ/rbW1mXIN5nYL+c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=ukLy0Za9/10Y50KeWbhKydgkJlcMYhErBoRYvRsfPVuX8rSO6AVpAdsfVE4jOuIi4
	 fxh/RCV5Ue/ZYpKNg6W57QN2M9NkZ5wT+6ZIMAwhoapHqrA2qN8FA4yY014heZapOp
	 jgM36KvCrY8IRR3k9ZEWbMsySbINf4sVELLVsmqM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 762368B8B1;
	Tue, 12 Mar 2019 23:16:14 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id uIH54hV_LXXN; Tue, 12 Mar 2019 23:16:14 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2AD288B8A7;
	Tue, 12 Mar 2019 23:16:14 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id D31F86FA15; Tue, 12 Mar 2019 22:16:13 +0000 (UTC)
Message-Id: <43d22280ffb24112df6393b912c7f8b9e5962611.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 08/18] powerpc/32: make KVIRT_TOP dependent on
 FIXMAP_START
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we add KASAN shadow area, KVIRT_TOP can't be anymore fixed
at 0xfe000000.

This patch uses FIXADDR_START to define KVIRT_TOP.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/book3s/32/pgtable.h | 13 ++++++++++---
 arch/powerpc/include/asm/nohash/32/pgtable.h | 13 ++++++++++---
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index aa8406b8f7ba..838de59f6754 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -134,15 +134,24 @@ static inline bool pte_user(pte_t pte)
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
 #define USER_PTRS_PER_PGD	(TASK_SIZE / PGDIR_SIZE)
+
+#ifndef __ASSEMBLY__
+
+int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
+
+#endif /* !__ASSEMBLY__ */
+
 /*
  * This is the bottom of the PKMAP area with HIGHMEM or an arbitrary
  * value (for now) on others, from where we can start layout kernel
  * virtual space that goes below PKMAP and FIXMAP
  */
+#include <asm/fixmap.h>
+
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
 #else
-#define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
+#define KVIRT_TOP	FIXADDR_START
 #endif
 
 /*
@@ -373,8 +382,6 @@ static inline void __ptep_set_access_flags(struct vm_area_struct *vma,
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
 
-int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
-
 /* Generic accessors to PTE bits */
 static inline int pte_write(pte_t pte)		{ return !!(pte_val(pte) & _PAGE_RW);}
 static inline int pte_read(pte_t pte)		{ return 1; }
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index bed433358260..0284f8f5305f 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -64,15 +64,24 @@ extern int icache_44x_need_flush;
 #define pgd_ERROR(e) \
 	pr_err("%s:%d: bad pgd %08lx.\n", __FILE__, __LINE__, pgd_val(e))
 
+#ifndef __ASSEMBLY__
+
+int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
+
+#endif /* !__ASSEMBLY__ */
+
+
 /*
  * This is the bottom of the PKMAP area with HIGHMEM or an arbitrary
  * value (for now) on others, from where we can start layout kernel
  * virtual space that goes below PKMAP and FIXMAP
  */
+#include <asm/fixmap.h>
+
 #ifdef CONFIG_HIGHMEM
 #define KVIRT_TOP	PKMAP_BASE
 #else
-#define KVIRT_TOP	(0xfe000000UL)	/* for now, could be FIXMAP_BASE ? */
+#define KVIRT_TOP	FIXADDR_START
 #endif
 
 /*
@@ -379,8 +388,6 @@ static inline int pte_young(pte_t pte)
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
 
-int map_kernel_page(unsigned long va, phys_addr_t pa, pgprot_t prot);
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* __ASM_POWERPC_NOHASH_32_PGTABLE_H */
-- 
2.13.3

