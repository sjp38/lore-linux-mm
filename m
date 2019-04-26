Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36085C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAFCC206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="RzCZfl9l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAFCC206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FCC16B026C; Fri, 26 Apr 2019 12:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D62B6B026D; Fri, 26 Apr 2019 12:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8DF86B026E; Fri, 26 Apr 2019 12:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF836B026C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:40 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id x1so3852428wrd.15
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=3EkWwfm1J9eIRyBAvVT+4ioqJyrfykTcLJkz42zJae0=;
        b=k6dphIMhRehK5AZH5Qv+b+xjXe4DLH0NaqFrCyuVTLCS2VyQgh03Z7qIXhEhObP2Im
         dBsH8qXICkYqz2nhYbVy8V7G+35Rqg1vkyFQfL++fRN8sbdWZqmh+ZGSx9qJD4OX/skY
         eqlw3Okd2X+YxHaAKDiufC7r54yyY6RmuF4jZEgkTe6D8dQAx4YGyuzeuMgfeMt6qW2S
         dbGLgWBRzvGns9WBQCs28N0qFne1PGHB00qPXVflRwlg8cUdxzNkNPZ57XAEGZ2skorX
         yHnyLLJuw8cjV9G/4EitLB7KV8/2uUwxmIyZtNOSztdqOv/BSj68tsrJ13MldZa7vc9V
         HdDA==
X-Gm-Message-State: APjAAAUeIu3BdGpFZrEMMTc5qXoCjOzeESBzx9O4Znf04d02HldRmYG+
	EIqMckd8D2epSNtyVbpcSoegxjAjIEiIwajaegLEioJR+6za8wOpi/4WJ2M0fB4KkFuVFCkS64e
	h9nHFOvxfmmFbZF5qZqjjLsteb1wo2/1FHra4gF2ut1fU2sqxsmwNlyxreldwn4CTmA==
X-Received: by 2002:a7b:c1cf:: with SMTP id a15mr9056223wmj.44.1556295819956;
        Fri, 26 Apr 2019 09:23:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvOSgAoZjyJOh/YDdCUqr4wR9HxS2V8q+89jDyyAgm1vVN4hEaQ2rc5NkKs8n2fqrHzNG1
X-Received: by 2002:a7b:c1cf:: with SMTP id a15mr9056112wmj.44.1556295818575;
        Fri, 26 Apr 2019 09:23:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295818; cv=none;
        d=google.com; s=arc-20160816;
        b=XoWsCFrmJbJmxxu812jKeVk8SXYXMl/z3j8tcIy4Cvy+bXdsFUOMJvzX9PaYuSCD3g
         2xFYeY143JWZvcJQevgxOGh96c5ohIhILdhzb1JyhK9iC4rY06d8xi8E0/9moe2BvsgM
         cmuIGoD3s4UfRfWObKtzyX8FGsHPpA61tDyoWFlI37QL3JPAYh5PGWC1IapuWuy3d8zf
         qtnepUzgXF2bm3fQ4TOu8KBIxXiF2FWs4Nv04jhkonsPk1ch1sTffGFq4LmTzPVnHtFj
         0G9TYrjNdDmlIhjF1g3KExcXQ5fuWkYGmKvVEjWvT8nLRNQ1skH+L8FpuMXb7RsMXK2i
         IkQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=3EkWwfm1J9eIRyBAvVT+4ioqJyrfykTcLJkz42zJae0=;
        b=FqbSocQ+UH/gQFwFA4KNf8pFP1kDandH8Q77S6z9EDB78gpcAicUxDs0JClR+QB1sR
         8GuWVP5a1xSkneIcjU5M5wjxEMTj0s2bA8U/dgReaCNG6ZwwjqLMmiAmaFlt+IhQjTrL
         7p9CN2sp6BD5//5jO6fJiFPRx8TsbTcgCK+n2aKYlzXO948r0xGHkJoiD0LeaTHwPT4l
         ZLAXmcjWuPqDEjHRhNJO7CWnGdefZOfV7ZXrv9AYs1rw+UYPsglbzgmysAQJv9fUdQXj
         qPO9h/XWZuN2hDb/scoh/lgzDCAhVBpu7z5IFPTL3Wa1VZaPbI983LoJ7Jm6A3ZdADiG
         eTyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RzCZfl9l;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id w22si4179163wmk.51.2019.04.26.09.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RzCZfl9l;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9h2mbXz9vDcM;
	Fri, 26 Apr 2019 18:23:36 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=RzCZfl9l; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id NB2S6uXwwIQN; Fri, 26 Apr 2019 18:23:36 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9h1cbwz9v0yk;
	Fri, 26 Apr 2019 18:23:36 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295816; bh=3EkWwfm1J9eIRyBAvVT+4ioqJyrfykTcLJkz42zJae0=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=RzCZfl9lrGv+E2O/U2IO/559Fg/vp/ExGaHGKmyMVcm3NogzJ6PefZ3HSDyIhSVYN
	 R2K2nvdLXxJD49Im7pqWbzy2wDddDSEbkq2gi/TbGD0sfAzgVHn7WaCzKkqe26gC67
	 2uk1URLUA8TBODXz4nmPhy6DQucKWwtzZHV24bJM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DA7EA8B950;
	Fri, 26 Apr 2019 18:23:37 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id i64AY_ketOJA; Fri, 26 Apr 2019 18:23:37 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B5C728B82F;
	Fri, 26 Apr 2019 18:23:37 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 9B7B7666FE; Fri, 26 Apr 2019 16:23:37 +0000 (UTC)
Message-Id: <c829a8a1d366dc83cc7d8c9e00310230c5f21b4e.1556295461.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 13/13] powerpc/32s: map kasan zero shadow with
 PAGE_READONLY instead of PAGE_KERNEL_RO
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For hash32, the zero shadow page gets mapped with PAGE_READONLY instead
of PAGE_KERNEL_RO, because the PP bits don't provide a RO kernel, so
PAGE_KERNEL_RO is equivalent to PAGE_KERNEL. By using PAGE_READONLY,
the page is RO for both kernel and user, but this is not a security issue
as it contains only zeroes.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/mm/kasan/kasan_init_32.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
index ba8361487075..0d62be3cba47 100644
--- a/arch/powerpc/mm/kasan/kasan_init_32.c
+++ b/arch/powerpc/mm/kasan/kasan_init_32.c
@@ -39,7 +39,10 @@ static int kasan_init_shadow_page_tables(unsigned long k_start, unsigned long k_
 
 		if (!new)
 			return -ENOMEM;
-		kasan_populate_pte(new, PAGE_KERNEL_RO);
+		if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+			kasan_populate_pte(new, PAGE_READONLY);
+		else
+			kasan_populate_pte(new, PAGE_KERNEL_RO);
 		pmd_populate_kernel(&init_mm, pmd, new);
 	}
 	return 0;
@@ -84,7 +87,10 @@ static int __ref kasan_init_region(void *start, size_t size)
 
 static void __init kasan_remap_early_shadow_ro(void)
 {
-	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
+	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
+		kasan_populate_pte(kasan_early_shadow_pte, PAGE_READONLY);
+	else
+		kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
 
 	flush_tlb_kernel_range(KASAN_SHADOW_START, KASAN_SHADOW_END);
 }
-- 
2.13.3

