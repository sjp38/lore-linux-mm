Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A31EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 637C820842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 637C820842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16C048E000F; Wed, 27 Feb 2019 12:07:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B518E0001; Wed, 27 Feb 2019 12:07:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F27F98E000F; Wed, 27 Feb 2019 12:07:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96EE18E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:12 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so7237843edo.5
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZR8Pi3jJ1KIw24YeuZCSXA+UGKblSCif1NtzpVDNSOM=;
        b=Itbg5V1bT4tVpEGR4PlCvqZDLoSEh+w/UaIYEE9r6HSSfAIqWFrFtPQ3cTnVUHyae3
         7u1JXB1SdwgNqrbFwIAx6+5Oz8UHTMB9q/jJkhyYWOR6IevvAjmS0A2re812GEQSMosE
         z7pe8gonrHED8LZsIQ6PmVha8oyg+I1TNr1O0Bs1s+3gDNKp3LYgp0+Ie8wbq7klVkk1
         3TB/m+ko8CrHxkCD1Nw1T15hJFv8B35/+6t6TemlF6n1Hj+be42e1C9PjMtRe6WBMRgs
         fovd8sJtvBXgUBGwUK18PL2cSP+GJczQtUazUikXZ04AnOFB7Q20qh+ylHK4LTgThOK5
         AzDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubXZZ8gtKzX6gjfcgoSRyD/6RsNjlxscSD/F7WDkDIwHZYlqOxV
	alD0UBoWqXbaHLa4Ys9POKSdhDhaXuo5wU8IL8zkJgB62KkLEAhEMxwCvsxZQ8oMBtdduyDd0bQ
	2iV51uGyrLBmmPOajGo1AaVBkPSksSJoWtO8UafQFaH+/SSM5rOfBuj88T7w0+CX3gA==
X-Received: by 2002:a50:9e61:: with SMTP id z88mr3268324ede.100.1551287232127;
        Wed, 27 Feb 2019 09:07:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbWMxZ9VCX9Bqy3c8EPMyNPWrWMqMprp9uLorFASo3qwPuavuYVjXp5sAuglerr8KfGlIqU
X-Received: by 2002:a50:9e61:: with SMTP id z88mr3268248ede.100.1551287231178;
        Wed, 27 Feb 2019 09:07:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287231; cv=none;
        d=google.com; s=arc-20160816;
        b=GF8kdY0HYTKCB8kwT179h4R2pko7cKPmxOuwl/2c38o6aWnJLtURGrJdAzMpVwhKAA
         +Q9m9Dei/E+nFSKJRawknlu21m6etKapkBK5jt4V2aCKEEql6uELjPgXkFpLZbMb+6Wu
         gvBbtopCMjIBZ607Zpv3C14XgyaR1TixnsDGwidpxFfRRLPv21jXUbarVebUcmSn11ZM
         H5VycVoOgIImvmow/vr8mTZDhHXK5kuqRgwJZzhuXdTes8hjGArDBQZADDP11A/L4mH9
         BaGFBiFObBwvdrdGtvgieIliocxtrUlzsQejR3/B/TIkTMjeokfVwApjb7znJR5650Ml
         oTSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZR8Pi3jJ1KIw24YeuZCSXA+UGKblSCif1NtzpVDNSOM=;
        b=l9ewjp1UXSH6HyOj92s1EmhzieGQQKDgVTd4kvvhosnXgMn+0czbNUYLjufIAFbB5r
         DuGLhONPnGBlP98VmCbM1PnkIQgdiBy/BZn9qQhJ945MUavjwMhTkwOhsjcpwVibu5kb
         OIQxt+Y6lGHYN3OhydvXwZvGCdGuEHRO8Dafmz6mZSXdydiTgpTnrslo36zFq+Sc3q2G
         LiLzlHVyW2d2hjNtrFj5znmGbydPUrQf4J92zDrQle5H41WZzkC3psDX7rVQ/nwiQq8H
         ITaCjQnogFx8+/jTCOfpeVGHNgfM4NRD4t1pdG2p2lR45Qfn4Dgq2GJPDXioXGRmcrRQ
         RjUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id bq19si3264776ejb.45.2019.02.27.09.07.10
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:11 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EC55B16A3;
	Wed, 27 Feb 2019 09:07:09 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 240003F738;
	Wed, 27 Feb 2019 09:07:06 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH v3 11/34] mips: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:45 +0000
Message-Id: <20190227170608.27963-12-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For mips, we don't support large pages on 32 bit so add stubs returning 0.
For 64 bit look for _PAGE_HUGE flag being set. This means exposing the
flag when !CONFIG_MIPS_HUGE_TLB_SUPPORT.

CC: Ralf Baechle <ralf@linux-mips.org>
CC: Paul Burton <paul.burton@mips.com>
CC: James Hogan <jhogan@kernel.org>
CC: linux-mips@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/mips/include/asm/pgtable-32.h   |  5 +++++
 arch/mips/include/asm/pgtable-64.h   | 15 +++++++++++++++
 arch/mips/include/asm/pgtable-bits.h |  2 +-
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/arch/mips/include/asm/pgtable-32.h b/arch/mips/include/asm/pgtable-32.h
index 74afe8c76bdd..58cab62d768b 100644
--- a/arch/mips/include/asm/pgtable-32.h
+++ b/arch/mips/include/asm/pgtable-32.h
@@ -104,6 +104,11 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_val(pmd) != (unsigned long) invalid_pte_table;
 }
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return 0;
+}
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	pmd_val(*pmdp) = ((unsigned long) invalid_pte_table);
diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index 93a9dce31f25..981930e1f843 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -204,6 +204,11 @@ static inline int pgd_present(pgd_t pgd)
 	return pgd_val(pgd) != (unsigned long)invalid_pud_table;
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return 0;
+}
+
 static inline void pgd_clear(pgd_t *pgdp)
 {
 	pgd_val(*pgdp) = (unsigned long)invalid_pud_table;
@@ -273,6 +278,11 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_val(pmd) != (unsigned long) invalid_pte_table;
 }
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return (pmd_val(pmd) & _PAGE_HUGE) != 0;
+}
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	pmd_val(*pmdp) = ((unsigned long) invalid_pte_table);
@@ -297,6 +307,11 @@ static inline int pud_present(pud_t pud)
 	return pud_val(pud) != (unsigned long) invalid_pmd_table;
 }
 
+static inline int pud_large(pud_t pud)
+{
+	return (pud_val(pud) & _PAGE_HUGE) != 0;
+}
+
 static inline void pud_clear(pud_t *pudp)
 {
 	pud_val(*pudp) = ((unsigned long) invalid_pmd_table);
diff --git a/arch/mips/include/asm/pgtable-bits.h b/arch/mips/include/asm/pgtable-bits.h
index f88a48cd68b2..5ab296dee8fa 100644
--- a/arch/mips/include/asm/pgtable-bits.h
+++ b/arch/mips/include/asm/pgtable-bits.h
@@ -132,7 +132,7 @@ enum pgtable_bits {
 #define _PAGE_WRITE		(1 << _PAGE_WRITE_SHIFT)
 #define _PAGE_ACCESSED		(1 << _PAGE_ACCESSED_SHIFT)
 #define _PAGE_MODIFIED		(1 << _PAGE_MODIFIED_SHIFT)
-#if defined(CONFIG_64BIT) && defined(CONFIG_MIPS_HUGE_TLB_SUPPORT)
+#if defined(CONFIG_64BIT)
 # define _PAGE_HUGE		(1 << _PAGE_HUGE_SHIFT)
 #endif
 
-- 
2.20.1

