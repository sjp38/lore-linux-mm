Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABD59C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4314F218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:16:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="haog/nuW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4314F218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BFC98E0002; Thu, 14 Feb 2019 16:16:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96FAA8E0001; Thu, 14 Feb 2019 16:16:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885588E0002; Thu, 14 Feb 2019 16:16:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61B368E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:16:55 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i18so5508999ite.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:16:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=GvPYFe28/mAoQO+bY6nMt8BakmTEWjcsUcqZny6LKyY=;
        b=NfG58NdMMc+feSyVID6oa9iFRaPUJr1SV/od5H/YwYh38LOU7O4XpmS5TIBqIVigml
         ueUEmmiSJO798oNe27rwiETt2WQ+YA0dxuOqtetWfMBsKmssEdF4OqLVoGKZHeINaKop
         M0ybt61GM5kvNLmpQjR9AqJ878qKh8YhoTeUvJ1LUHAe6KeVNLSnyg2YCt7my/DBryQX
         342adshop7y5KxFvTjwK/VIqDW8va626w9epoN07Tw47Z04mtoqMUXdgWmL7ncyqCyRN
         UfxEsHCWOy5IyRMA0cmZGe94CjG4W9c5Wern/rDKsCAoxbf8GeJeLUstHZ8cc5ZEY7LV
         uSVQ==
X-Gm-Message-State: AHQUAuasKs3lOhhivoTt4UIIkyrTuHHCkSTxrR+x90OmmDiszlA3b7sJ
	4ZXrMzp3YbW1WVpaoRuDrCgCtDT3QTAeG2KWxplzbdZWwcn6zr78/oCSGip6oXnYYNVS1TrJBs6
	Z3h8v6j+vKshOmgG7qqZSuBanE/5RyqHy3/i67Dzgj/idzkAeN6BAf1bPcdmkfpsG/+/6cQ6YUL
	g5ZB8A7y6dT7cdTPTSmuDGpvoAyBgdZ/XXe4l5FC4pJuttn4rn+WKdafb20eYrf7Rgdl/20vKL8
	19nXDlI2ZlcIdC21rbegCAHfLDWczBfrSBaEPcANBogNNhGS4b3lYcccFwWcKbODO7Jzh0d03xH
	TTbs8mw1xqmp1rHIcavH7C/YcuVqA37mQY0pSVyLPzk+5mrXjyW5Dff9TpVt9EN80s/h2AyUewM
	3
X-Received: by 2002:a6b:cd41:: with SMTP id d62mr3864386iog.121.1550179015146;
        Thu, 14 Feb 2019 13:16:55 -0800 (PST)
X-Received: by 2002:a6b:cd41:: with SMTP id d62mr3864351iog.121.1550179014611;
        Thu, 14 Feb 2019 13:16:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550179014; cv=none;
        d=google.com; s=arc-20160816;
        b=WmDOjNZTu4FsW3/LP/C6xngREkd05HVeSDc5A+9p+W1zygJw5Iere6Z2UB1YsbKNr2
         +tE2Al8rpVjnqw2Kf5Xe4ZOoaZfVbz2MeFWsgwuVKr+pToIjbtJY+ibHIQtZlcCSE9Co
         juDfwsyf4dQ/zZEFiEAC9Ag8wgY8rwewgGPkR5fpcwxiGWy/Ln5OwvgcfdRm8DgkWCW6
         ychyf4O7M2lMZMiiwe4BUK6vhHAnCtm5rtdEtx4Fd8xWlJjzcwDYHSMUvcUCfB6/6JiG
         PhI3+XeReA2kf6Tr+Y4G8a/WRsmdukFxTqn3q97axzhMUTwzisLX73muG0r1DFufckOA
         bmGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=GvPYFe28/mAoQO+bY6nMt8BakmTEWjcsUcqZny6LKyY=;
        b=uUSlLmFOU2erlfss0sKqn16hXeHDyE2ggnTXr4PwqPKwChLq/xqp0d3qjI3igs0Dwq
         glIgrBPOssdoFPDtkqDGSHuGQPoh0yHqfJHKVnTE0wuJWihPenZn27vyeM/YSmEQE/4A
         DVHK5X/IH78mYhpvgbYKrKdv1aFwlp5pOgLThfyQwckJJR8NoMkfSIW98lsDpNdDO3Ps
         GPhcfuOlA40OjghSTmoP0NF+YAULq0P49Wnm9/1N0aIpRsXNHNhZSPDX7hargHZv1HGX
         B9SFRQ+F6IO7UfPePEXIOFKP5i/ciUR4qqWT4p2CSjFWK5hMlas3/ZndKde06uawRTKc
         7rFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="haog/nuW";
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b82sor6227272itb.10.2019.02.14.13.16.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 13:16:54 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="haog/nuW";
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=GvPYFe28/mAoQO+bY6nMt8BakmTEWjcsUcqZny6LKyY=;
        b=haog/nuWNwVzMoU13+bJ0VOVleco8VrScsofzKVQriJp/kpIegpS08FgzPJW6MCcMM
         umb1am7jn04ZVfp/yOI5y2yZNIPu/vejkxNHZoUsN71HWLQEH7YIx7zv4pBqIcXovU3w
         JPZM6QRRB7y782DQnTFoAEKXvcAWCZ+X6byTykTsL+dfSL7xz/fpbcUiIBhrukUyvjLi
         g4eVuY6/2Kdj7uMouqF364Lq2Wvvx9u7FnZJDVv0fv6MtPkEGYCwZRV4qimeeXmvzRZw
         7OEpCUNx91DhVAacamw53xKewe0hTNal7SlZMnIezgIODwSu4C+aoijN+x+caBgPcoxZ
         /odw==
X-Google-Smtp-Source: AHgI3IYCX5V8B/n/JHfBn5gh5KmKCeTbBeku15y0Wkk318G3E77K2o5/6CJ6L2HV9dr2oRQlrIFuFg==
X-Received: by 2002:a24:9a84:: with SMTP id l126mr3836833ite.77.1550179014078;
        Thu, 14 Feb 2019 13:16:54 -0800 (PST)
Received: from yuzhao.bld.corp.google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id h2sm1491498itk.0.2019.02.14.13.16.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 13:16:53 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH] arm64: mm: enable per pmd page table lock
Date: Thu, 14 Feb 2019 14:16:42 -0700
Message-Id: <20190214211642.2200-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switch from per mm_struct to per pmd page table lock by enabling
ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
large system.

I'm not sure if there is contention on mm->page_table_lock. Given
the option comes at no cost (apart from initializing more spin
locks), why not enable it now.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/Kconfig               |  3 +++
 arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
 arch/arm64/include/asm/tlb.h     |  5 ++++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..104325a1ffc3 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
 config ARCH_HAS_CACHE_LINE_SIZE
 	def_bool y
 
+config ARCH_ENABLE_SPLIT_PMD_PTLOCK
+	def_bool y
+
 config SECCOMP
 	bool "Enable seccomp to safely compute untrusted bytecode"
 	---help---
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index 52fa47c73bf0..dabba4b2c61f 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -33,12 +33,22 @@
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)__get_free_page(PGALLOC_GFP);
+	struct page *page;
+
+	page = alloc_page(PGALLOC_GFP);
+	if (!page)
+		return NULL;
+	if (!pgtable_pmd_page_ctor(page)) {
+		__free_page(page);
+		return NULL;
+	}
+	return page_address(page);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
 {
 	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
+	pgtable_pmd_page_dtor(virt_to_page(pmdp));
 	free_page((unsigned long)pmdp);
 }
 
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index 106fdc951b6e..4e3becfed387 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -62,7 +62,10 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 				  unsigned long addr)
 {
-	tlb_remove_table(tlb, virt_to_page(pmdp));
+	struct page *page = virt_to_page(pmdp);
+
+	pgtable_pmd_page_dtor(page);
+	tlb_remove_table(tlb, page);
 }
 #endif
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

