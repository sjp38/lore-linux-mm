Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA4F1C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61A6420843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EnXZgfrE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61A6420843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 089556B000C; Wed, 15 May 2019 09:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039EF6B000D; Wed, 15 May 2019 09:21:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD1B56B000E; Wed, 15 May 2019 09:21:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A32D66B000C
	for <linux-mm@kvack.org>; Wed, 15 May 2019 09:21:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 123so1857772pgh.17
        for <linux-mm@kvack.org>; Wed, 15 May 2019 06:21:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F56UeRM9+QYDMfaKmt6HoAUehngERsrruwV76IERiz0=;
        b=JlCKBMo/JgjwPXCnaCPWuYITPsWIfLWFOp3tf///Q50TUrqwxFjyJN3r+hjYAKxCke
         Vqg80HeNqfWRu8JHjGcmbLiFmSAurmcFhvlwqF7+4CgqG3vIxk/PR378RpWvbGzoAn6e
         OQWlwMJoQSPxTyO3G4QaRSI59QvrVYlDYaUysRMWnH8vd5hSBK77vob8dVhuUJWFOEDS
         7FJO1izGISfWiUC5QVXkkb+xPXjqaqMved6TtK9ZM61AVgAFGvNTdvrgZyls3I7jroKo
         e0HimvEZJr++3kgDFZeqv/Ino6hrPIvS6nES2e5Oq3sDCAXfyfpgNIEdsdqCqXA9YKj7
         kCVg==
X-Gm-Message-State: APjAAAVttLmZMsAytbPjd4POJ6gtvAubJ5mJrC7bGvi/RYgVpOaEh9RZ
	ys5MkAP26kbFi1Pc4AhMTq51myoICQCseMx8QpE11iN/h8AxpJrQ8igxEExNGybcVkJozpbm9kM
	FRm8+HdhGsc54TX16DuU85cBjeofuXqJwHOc/RMEgAQSO0aPoYR+MjRD51YKc43f5AQ==
X-Received: by 2002:a63:f806:: with SMTP id n6mr44082402pgh.242.1557926490169;
        Wed, 15 May 2019 06:21:30 -0700 (PDT)
X-Received: by 2002:a63:f806:: with SMTP id n6mr44082304pgh.242.1557926488955;
        Wed, 15 May 2019 06:21:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557926488; cv=none;
        d=google.com; s=arc-20160816;
        b=LlYPxm7SELuzxYeOjbCqrh5P33eTLzqOqkh8IAFHnDAmobx1Yountucmml3HDKcTGP
         TFlQnGoqDrhY146SI1HjvCSYsoJFxmV3FB4W9qAjHhB1BPx/R9iStxw3UbWoFr8yTWl4
         40r7d8PNx6P6qnCsZga7/Epspy6SnoGpuC1OIrmKa11eNuKrp0pkiOSeIS1FRGFA6FAA
         znbnOKeV7mqEvCt7P4dPEGnNrlYOcTgZupMRCYQbhEhqquCco4eGI6NSQMu5ag/KzxaL
         mGieBcPG1N3LSV13O0R8psxVgmLVG9Sv6khYags7r68KD6V3AwHbwh7rSIqZHVg84bKb
         NTUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=F56UeRM9+QYDMfaKmt6HoAUehngERsrruwV76IERiz0=;
        b=ugS2NaDeWIIgf4mfaHtHj0Q1F4bTMMB5h26XdFSx+V1PkjLF/paEJf2OUbknEL4D1t
         sK2GDklLTBQFyTKwhZetjGgNU14jRA3qdeDvi5XGkhzlKMfunWddEufzxW9pnZqXLsjG
         ij1trWWHs/KsTarRuryv4Oh7DbPdb6nQq/2jj3ncB6BZs0PeKm5aNE0TdX5GKdesfqBN
         w3OodYJQgTnl1RXvNqWjxoRxkYdC/w8dU9feBsJt4zHIrw4suxnyHvTBxFyO5kPfd593
         jMp7jiFFRqs8j3fNcTE96kdE+tALNTf8csQg08OOPmxA2aC5Lx4iAuLm7v2HFm2ole8r
         cakA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EnXZgfrE;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v23sor2019418pgc.6.2019.05.15.06.21.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 06:21:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EnXZgfrE;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=F56UeRM9+QYDMfaKmt6HoAUehngERsrruwV76IERiz0=;
        b=EnXZgfrE9ptE7/0LNjdYsc/YDM7sqSD5aCEtxoZtJAZIW1hcwtm+ySiloTvErKAw8p
         vNyxIyyextQQsrHNEWttfI5X89lSErLIXLUjqUWJCJLAVrFHgOjoZAT4d4sK38Rb/XFX
         UhtKIcbSwDiFN63UIGX3zTIzT4QbS75CPXH26G4v7nnPxahaYQ4x7cERq1rC8Qq5c0Ug
         4ojA+2GvmOfLYBD1KltINcBxdKEvsTR3ZVlJZ7JZjEXO0psx4akGXcApVJJC5ffkAlo7
         e7MmTH6kllp+sE4y/9oUaoqHK7oTrD1uQYZjt6C77QNYAB46orbIVcVNQxHxCWQ1B4S2
         l6Tw==
X-Google-Smtp-Source: APXvYqx9pRh7/Lft1BW35lbNk8d/eVJJbgQXZdep4WpYEIJ5ohMJcto076tmYlbXhID7nMQmyogIrg==
X-Received: by 2002:a65:478a:: with SMTP id e10mr44277114pgs.310.1557926488724;
        Wed, 15 May 2019 06:21:28 -0700 (PDT)
Received: from bobo.local0.net (115-64-240-98.tpgi.com.au. [115.64.240.98])
        by smtp.gmail.com with ESMTPSA id a19sm2784459pgm.46.2019.05.15.06.21.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 06:21:28 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [RFC PATCH 5/5] powerpc/64s/radix: iomap use huge page mappings
Date: Wed, 15 May 2019 23:19:44 +1000
Message-Id: <20190515131944.12489-5-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190515131944.12489-1-npiggin@gmail.com>
References: <20190515131944.12489-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |  8 +++
 arch/powerpc/mm/pgtable_64.c                 | 54 +++++++++++++++++---
 2 files changed, 56 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 7dede2e34b70..93b8a99df88e 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -274,6 +274,14 @@ extern unsigned long __vmalloc_end;
 #define VMALLOC_START	__vmalloc_start
 #define VMALLOC_END	__vmalloc_end
 
+static inline unsigned int ioremap_max_order(void)
+{
+	if (radix_enabled())
+		return PUD_SHIFT;
+	return 7 + PAGE_SHIFT; /* default from linux/vmalloc.h */
+}
+#define IOREMAP_MAX_ORDER ({ ioremap_max_order();})
+
 extern unsigned long __kernel_virt_start;
 extern unsigned long __kernel_virt_size;
 extern unsigned long __kernel_io_start;
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index d2d976ff8a0e..f660116251e6 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -112,7 +112,7 @@ unsigned long ioremap_bot = IOREMAP_BASE;
  * __ioremap_at - Low level function to establish the page tables
  *                for an IO mapping
  */
-void __iomem *__ioremap_at(phys_addr_t pa, void *ea, unsigned long size, pgprot_t prot)
+static void __iomem * hash__ioremap_at(phys_addr_t pa, void *ea, unsigned long size, pgprot_t prot)
 {
 	unsigned long i;
 
@@ -120,6 +120,50 @@ void __iomem *__ioremap_at(phys_addr_t pa, void *ea, unsigned long size, pgprot_
 	if (pgprot_val(prot) & H_PAGE_4K_PFN)
 		return NULL;
 
+	for (i = 0; i < size; i += PAGE_SIZE)
+		if (map_kernel_page((unsigned long)ea + i, pa + i, prot))
+			return NULL;
+
+	return (void __iomem *)ea;
+}
+
+static int radix__ioremap_page_range(unsigned long addr, unsigned long end,
+		       phys_addr_t phys_addr, pgprot_t prot)
+{
+	while (addr != end) {
+		if (!(addr & ~PUD_MASK) && !(phys_addr & ~PUD_MASK) &&
+				end - addr >= PUD_SIZE) {
+			if (radix__map_kernel_page(addr, phys_addr, prot, PUD_SIZE))
+				return -ENOMEM;
+			addr += PUD_SIZE;
+			phys_addr += PUD_SIZE;
+
+		} else if (!(addr & ~PMD_MASK) && !(phys_addr & ~PMD_MASK) &&
+				end - addr >= PMD_SIZE) {
+			if (radix__map_kernel_page(addr, phys_addr, prot, PMD_SIZE))
+				return -ENOMEM;
+			addr += PMD_SIZE;
+			phys_addr += PMD_SIZE;
+
+		} else {
+			if (radix__map_kernel_page(addr, phys_addr, prot, PAGE_SIZE))
+				return -ENOMEM;
+			addr += PAGE_SIZE;
+			phys_addr += PAGE_SIZE;
+		}
+	}
+	return 0;
+}
+
+static void __iomem * radix__ioremap_at(phys_addr_t pa, void *ea, unsigned long size, pgprot_t prot)
+{
+	if (radix__ioremap_page_range((unsigned long)ea, (unsigned long)ea + size, pa, prot))
+		return NULL;
+	return ea;
+}
+
+void __iomem *__ioremap_at(phys_addr_t pa, void *ea, unsigned long size, pgprot_t prot)
+{
 	if ((ea + size) >= (void *)IOREMAP_END) {
 		pr_warn("Outside the supported range\n");
 		return NULL;
@@ -129,11 +173,9 @@ void __iomem *__ioremap_at(phys_addr_t pa, void *ea, unsigned long size, pgprot_
 	WARN_ON(((unsigned long)ea) & ~PAGE_MASK);
 	WARN_ON(size & ~PAGE_MASK);
 
-	for (i = 0; i < size; i += PAGE_SIZE)
-		if (map_kernel_page((unsigned long)ea + i, pa + i, prot))
-			return NULL;
-
-	return (void __iomem *)ea;
+	if (radix_enabled())
+		return radix__ioremap_at(pa, ea, size, prot);
+	return hash__ioremap_at(pa, ea, size, prot);
 }
 
 /**
-- 
2.20.1

