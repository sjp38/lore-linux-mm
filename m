Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24725C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E32FC222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E32FC222B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6892D8E0006; Wed, 13 Feb 2019 03:06:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60ED68E0001; Wed, 13 Feb 2019 03:06:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48DD48E0006; Wed, 13 Feb 2019 03:06:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE3138E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:06:54 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so665915edd.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:06:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=lLU9a6ZQu0wuumQ0c/KrMdC8hoqxGAN16ZlPM6u6TQ0=;
        b=ugLHYkkdeMi6KdU4Utjx4WBJU8KixKbCtqiFkJDbimh5vkhhcJjcEdvqVyxbpbxKfA
         kw1tF+5RlEFrvJXs0WTUvx1Z3II/eDM9ja6QuXaXcpg9S1yrbZPlYsy2YxaKqCxxbxJk
         Ah/scg3BEbcKTFiSxIM5ybcVRAW9KCCaJdj1eYggnCXR2ziG4k8oecDSP8jTNhEfh9UY
         ml6YPo9NeRRiOpcMGvWlVGbe8tkrtZGKiOmr55WovrZxLlRa+o7CYMwfm8Dkjnu9fc1w
         xgWiNJDE64ei5RyKu9CspSVl7wXz+Ab/OFMHcOQE8ocNr27DyUaiV/IANVOp2PRPEY4s
         wO5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaKi+TH/oJ3tZO2zbLA4uYCY3pPdbeGYmoVrE/+84/PJlp/EV7M
	5cExH1EQM0/THRpK/NlADkwpUVIy8hINd32T9OIGpLE0HBW7PI8RbpAQS/4hYvEbiW8fCGRjuQl
	5bCCdVSMeOtfOWmY2/rqM7+d83vofkJ057aFQPzQko+Qm8ppqACEoReq5je7hEqSlBg==
X-Received: by 2002:aa7:c0c4:: with SMTP id j4mr6332646edp.182.1550045214418;
        Wed, 13 Feb 2019 00:06:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYV7GKfOCGWNKpOzc87kKvs/n5mGYEDsbcaW6H+1Vt/W+w1xzZrwE8fTstLKE4K1IaOephj
X-Received: by 2002:aa7:c0c4:: with SMTP id j4mr6332590edp.182.1550045213148;
        Wed, 13 Feb 2019 00:06:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045213; cv=none;
        d=google.com; s=arc-20160816;
        b=Ybei5Cm1MR5eIvwQH9I29JaQlUCZKsFYew2GLXPOPK8cptpoLGtErklx9CQ5nJXKFV
         V43CWOE3I5VyqLji6GtVTUKvO5gE+UF5k+rqw/KrmUKmSiwn58DkndnUTNzLLHTpHg4X
         4EB961o8WQ8rIHOIekMHpY30JGZhqeWVS3YDgxwbXYA54rrmsfDO0uDQHWPbk1x97Q8F
         xbs7Tz+knS5seBvaNgMLmgExzkYPLp9RjCFy5pbBV8lpQOOBamYy2KvK0IZM/SxKwgl1
         PET4S5aKt351RBkaUQ5HFqCVSBpkCe2J/XasljMvv+vsWncP5O0FA1bXkCOusALL1tiY
         JsJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=lLU9a6ZQu0wuumQ0c/KrMdC8hoqxGAN16ZlPM6u6TQ0=;
        b=jTtBkkkk+kmVbai0OaultWH1afIhRnnbqwU0U+MzJseziQIwCFt2xxSUsUkdXUHp+l
         e/qYKKPWpRJqVqmpEFbFa2hB6Qmhu3GAxV2+wGalhzyDY+s5WDlF8OYMsy8bzCF9IRGF
         MiUedkZ1hBeOQeB45lnxKmj+INMmVMWpvxHWTbaN3Aiu0NTeFJ8/LHbwM4Xm3JGB9Is5
         ydB+FpUvJVWLf0yMhhCYNxY2y1R9hDiM+9ircsjrKVeDRgf5PvR3nWzXzHMrqriBLWMU
         Fhy7Q9OIr7CRCjFjwYwURxussHcM+G4lY5Z+ahLd3uShdHDJ6jH2XRHBQAWKAdJwIm/a
         c6LA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t17si1525918eds.207.2019.02.13.00.06.52
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 00:06:53 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2A4561596;
	Wed, 13 Feb 2019 00:06:52 -0800 (PST)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.147])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 5D1023F575;
	Wed, 13 Feb 2019 00:06:49 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	kirill@shutemov.name,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	dave.hansen@intel.com
Subject: [RFC 4/4] arm64/mm: Enable ARCH_SUPPORTS_LAZY_EXEC
Date: Wed, 13 Feb 2019 13:36:31 +0530
Message-Id: <1550045191-27483-5-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make arm64 subscribe to ARCH_SUPPORTS_LAZY_EXEC framework and provided all
required helpers for this purpose. This moves away execution cost from the
migration path to exec fault path as expected.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig               |  1 +
 arch/arm64/include/asm/pgtable.h | 17 +++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d3..3cdb3e4 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -59,6 +59,7 @@ config ARM64
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
+	select ARCH_SUPPORTS_LAZY_EXEC
 	select ARCH_SUPPORTS_MEMORY_FAILURE
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_SUPPORTS_INT128 if GCC_VERSION >= 50000 || CC_IS_CLANG
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index de70c1e..f2a5716 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -217,6 +217,18 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
 	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
 }
 
+#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
+static inline pte_t pte_mkexec(pte_t pte)
+{
+	return clear_pte_bit(pte, __pgprot(PTE_UXN));
+}
+
+static inline pte_t pte_mklazyexec(pte_t pte)
+{
+	return set_pte_bit(pte, __pgprot(PTE_UXN));
+}
+#endif
+
 static inline void set_pte(pte_t *ptep, pte_t pte)
 {
 	WRITE_ONCE(*ptep, pte);
@@ -355,6 +367,11 @@ static inline int pmd_protnone(pmd_t pmd)
 }
 #endif
 
+#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
+#define pmd_mkexec(pmd)		pte_pmd(pte_mkexec(pmd_pte(pmd)))
+#define pmd_mklazyexec(pmd)	pte_pmd(pte_mklazyexec(pmd_pte(pmd)))
+#endif
+
 /*
  * THP definitions.
  */
-- 
2.7.4

