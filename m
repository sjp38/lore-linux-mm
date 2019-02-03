Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD2F1C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 772BD218D8
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 772BD218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=decadent.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08B108E0024; Sun,  3 Feb 2019 08:49:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03B308E001C; Sun,  3 Feb 2019 08:49:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6BED8E0024; Sun,  3 Feb 2019 08:49:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A73768E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 08:49:47 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id t10so9536769plo.13
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 05:49:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-disposition:content-transfer-encoding:mime-version:from:to
         :cc:date:message-id:subject:in-reply-to;
        bh=OkEXknWwHjp+WPixZIhf8SrXXlLE8Zv6mWHK2+7oCWY=;
        b=HoHIAdhgIEeOV+Snpm1baC80AkELlJeB7khxBBVpHvnAT4NWS2XGpsEO5v6WtAt2/x
         FqRhCsdNdWy11z7uI6TpOQT2ROlAPGgiKaAmbFO74VOgk0XMhlJ0KnkUp3u4IrgwqfSa
         Dyq2XobR8eqsbjjzwpOeN0hFyzWA99gNUV//X5le//oQ5pY9nLPlf4kehGcy+SpsZUep
         7bVwky6Ht5/8z5wDcbYL50MrMs/l/zxMhc/2ZOfIDf+iDKOP0hQixKZZdXNvo6gzEc0J
         hYCbI9TcAaWDAagr2/yYQSXRfmFHLv09lLGcy0sbZJV3U160JjySOf+QbfT7TLrvNH+p
         /hPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
X-Gm-Message-State: AJcUukenV1dobO6ob14b4hX9hGyFpbs9QyfuiWjEFT0VF1IbbaIVcUpH
	8Skx8+jy66pkpZSup1xCIn9/Oniank1h7nqaG9YFHDuD1436h4IaVM9fow6m7EfYalFzcvD8ygD
	aWY6JHJFoZfTFMP3jD1vSD3VxvxH0Y/X9UcYRHoUZZ4D8Fn46sPDy5Mz703i9IAIQ3w==
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr46146760plz.174.1549201787258;
        Sun, 03 Feb 2019 05:49:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7dRjpdbgnV+EpK35mOBWdyRXvPrSGnJvxQ/szWcwvBpkkQD8/PA3AUpZ9LfbOfc2PaVvSH
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr46146724plz.174.1549201786383;
        Sun, 03 Feb 2019 05:49:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549201786; cv=none;
        d=google.com; s=arc-20160816;
        b=ec6Zbw1ZaLLJz4jgzrhNqMM50XSMUEH0gtNLhkJt/sxRIsbY7iMUdxj0bwEP+BiYoE
         RIV6cVvmBHpTNDRr7/pd7xuM8LIKXEwaoy5rGKVtgq64rOnpE7cHhFhvUb3k/Uq+jvDQ
         QohDqlE8uD37Rjg9Uzx/8ZheOuJKkhSor2rG8aQcZg3PlEUX7Jd+2peKKA0Ovylef2Vw
         OIwvoFhuCXYVo50Bz4Qp4kfKl2DIi1yRbgA+SxhdCcUzKZ1FyhKBlAHfUFqZV7j4C1Xd
         0KZcDRptDVhTVfvzwukUkJCTFA6Vye/aLnsXP6868D+A8z0B/35OAQciaAEiPU6fyj/2
         Jr4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:subject:message-id:date:cc:to:from:mime-version
         :content-transfer-encoding:content-disposition;
        bh=OkEXknWwHjp+WPixZIhf8SrXXlLE8Zv6mWHK2+7oCWY=;
        b=Fv5NsabAPRV1oJdLU7DGR64odIRtFOso4Lb+SxKYCuAt4Ear8rCeWJZu7bJqVXd78S
         RavDVzdGIXHsZeactNiUAPlPNPNEY8vLqeYA4KzyWuhNZkRU7MFh2DLX8pwQ90GbWWCt
         YzaSnuQb6Qe6BBU2rdmqeSc7gFMnRnU+10xEUjr/qbHXXI9PU2BXf4H2NVBdc1R/BFiS
         WishEAHcJ4z2qLA3Jt1BF5fo7qzUpX2bwCIc3m6UZP0NzFODyn48IraNshF+gENACLFt
         jiMflzHU/kAZbQKQQCCKYsJKeXr6gJnfr4YdUIwOP0bzvbXvUHyzhyY25ALEKqG6f7cH
         TUtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id 21si873075pgx.488.2019.02.03.05.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Feb 2019 05:49:46 -0800 (PST)
Received-SPF: pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) client-ip=88.96.1.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from cable-78.29.236.164.coditel.net ([78.29.236.164] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0003th-4t; Sun, 03 Feb 2019 13:49:39 +0000
Received: from ben by deadeye with local (Exim 4.92-RC4)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0006nE-Db; Sun, 03 Feb 2019 14:49:39 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
CC: akpm@linux-foundation.org, Denis Kirjanov <kda@linux-powerpc.org>,
 "Konrad Wilk" <konrad.wilk@oracle.com>,
 "Thomas Gleixner" <tglx@linutronix.de>,
 "Robert Elliot" <elliott@hpe.com>,
 "Wenkuan Wang" <Wenkuan.Wang@windriver.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "Toshi Kani" <toshi.kani@hpe.com>,
 "Borislav Petkov" <bp@alien8.de>,
 linux-mm@kvack.org,
 "Juergen Gross" <jgross@suse.com>,
 "Ingo Molnar" <mingo@redhat.com>
Date: Sun, 03 Feb 2019 14:45:08 +0100
Message-ID: <lsq.1549201508.370199741@decadent.org.uk>
X-Mailer: LinuxStableQueue (scripts by bwh)
X-Patchwork-Hint: ignore
Subject: [PATCH 3.16 003/305] x86/asm: Fix pud/pmd interfaces to handle
 large PAT bit
In-Reply-To: <lsq.1549201507.384106140@decadent.org.uk>
X-SA-Exim-Connect-IP: 78.29.236.164
X-SA-Exim-Mail-From: ben@decadent.org.uk
X-SA-Exim-Scanned: No (on shadbolt.decadent.org.uk); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

3.16.63-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Toshi Kani <toshi.kani@hpe.com>

commit f70abb0fc3da1b2945c92751ccda2744081bf2b7 upstream.

Now that we have pud/pmd mask interfaces, which handle pfn & flags
mask properly for the large PAT bit.

Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
PTE_FLAGS_MASK with the pud/pmd mask interfaces.

Suggested-by: Juergen Gross <jgross@suse.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Juergen Gross <jgross@suse.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Robert Elliot <elliott@hpe.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1442514264-12475-5-git-send-email-toshi.kani@hpe.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Wenkuan Wang <Wenkuan.Wang@windriver.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/include/asm/pgtable.h       | 14 ++++++++------
 arch/x86/include/asm/pgtable_types.h |  4 ++--
 2 files changed, 10 insertions(+), 8 deletions(-)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -156,14 +156,14 @@ static inline unsigned long pmd_pfn(pmd_
 {
 	phys_addr_t pfn = pmd_val(pmd);
 	pfn ^= protnone_mask(pfn);
-	return (pfn & PTE_PFN_MASK) >> PAGE_SHIFT;
+	return (pfn & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
 }
 
 static inline unsigned long pud_pfn(pud_t pud)
 {
 	phys_addr_t pfn = pud_val(pud);
 	pfn ^= protnone_mask(pfn);
-	return (pfn & PTE_PFN_MASK) >> PAGE_SHIFT;
+	return (pfn & pud_pfn_mask(pud)) >> PAGE_SHIFT;
 }
 
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
@@ -584,14 +584,15 @@ static inline int pmd_none(pmd_t pmd)
 
 static inline unsigned long pmd_page_vaddr(pmd_t pmd)
 {
-	return (unsigned long)__va(pmd_val(pmd) & PTE_PFN_MASK);
+	return (unsigned long)__va(pmd_val(pmd) & pmd_pfn_mask(pmd));
 }
 
 /*
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
+#define pmd_page(pmd)		\
+	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -657,14 +658,15 @@ static inline int pud_present(pud_t pud)
 
 static inline unsigned long pud_page_vaddr(pud_t pud)
 {
-	return (unsigned long)__va((unsigned long)pud_val(pud) & PTE_PFN_MASK);
+	return (unsigned long)__va(pud_val(pud) & pud_pfn_mask(pud));
 }
 
 /*
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pud_page(pud)		pfn_to_page(pud_val(pud) >> PAGE_SHIFT)
+#define pud_page(pud)		\
+	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
 
 /* Find an entry in the second-level page table.. */
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -347,7 +347,7 @@ static inline pudval_t pud_flags_mask(pu
 
 static inline pudval_t pud_flags(pud_t pud)
 {
-	return native_pud_val(pud) & PTE_FLAGS_MASK;
+	return native_pud_val(pud) & pud_flags_mask(pud);
 }
 
 static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
@@ -368,7 +368,7 @@ static inline pmdval_t pmd_flags_mask(pm
 
 static inline pmdval_t pmd_flags(pmd_t pmd)
 {
-	return native_pmd_val(pmd) & PTE_FLAGS_MASK;
+	return native_pmd_val(pmd) & pmd_flags_mask(pmd);
 }
 
 static inline pte_t native_make_pte(pteval_t val)

