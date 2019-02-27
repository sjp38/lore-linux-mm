Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 361BFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F275120842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F275120842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A7C48E0016; Wed, 27 Feb 2019 12:07:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 956688E0001; Wed, 27 Feb 2019 12:07:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 846728E0016; Wed, 27 Feb 2019 12:07:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28E1B8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:44 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x13so5022884edq.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=N4WRLTZt28lkUemP8bmvX63q6AU2uYVq26PdhSIkK84=;
        b=ZvB+UHT+qmolZim0X7naZ3UT5Rjf9hav/wylHxpe5IpqLPt+TaYXp2Op9joZsNjpNY
         UY5WZJIoX4uZ09XADU7ifQ8EHncGDyaHx2zLtNibQJA+fkpED/abdhugOPz84xupQfua
         sijEb5eaQgg0Z1E2BkfjAohZHiR9tzWiWRAKfRXWIbBHYomUfsZOcLRaPrdBLRlsAI6w
         gBfJH7PvkC/qK1Eg0IrYxOynlqXjPmvTRW+s8mJF1WLix/eyQLLjZqTKTxNk+6YQ7f88
         Rmfl3dNO/FMC/CChhD68bs/DBCrm9riNRaU1mDWENrNx9ZCjH+/eHAD9XJsVLAF/wYWK
         R3Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZwTR/ovEpc7dfQkYCtlbSiswdq9uzPYoDpWrCeARcJ85L1/bBC
	g7B0UbP920jtwCSbriGC8JficCeXPfYX68m1H3kACAhVrDur5g0npanzGTJQaDM7cRE9EoOm0Xt
	RKmz0pJnlbzLCKw3URqGtQXecSYQ+riKcxJYBHa9tOPnF2l8sYNlVATYoIrYpaYgCdg==
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr3143769ede.196.1551287263689;
        Wed, 27 Feb 2019 09:07:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZRsbWjTWYkaEqxkNAe8YrUhaX6aYtPyvp/g3cKbpln7YN0L+PNyjsZZ0LMoE/flpUl63Rd
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr3143709ede.196.1551287262713;
        Wed, 27 Feb 2019 09:07:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287262; cv=none;
        d=google.com; s=arc-20160816;
        b=e4TRZExSSplfMeR/kpjwdFM8BuYFhwJZtK63RRaUwxhE/SYx8kSjDsCGG8Prxijchb
         J2FlYFCmFR+SLSGe3Se9wodqGIcLHhawTC/WgAdoNkSrHeEvOEzy8r8h/JBWm4dQ0U3L
         977xPvFdFdDYhR6lK2cF3GipdfHCn0LVANRkEHptuLpGkCVV6U7DoMT1LubMLcZU0iI5
         8LaKj/4+vTPUUVNSSNphNbsTyCpY/todq4m2VfSJHSXG491aczgySYpeS2o8qSZNUe/L
         BQVLUmxxoy139kdRw/M2OnY5VK+gBQI1owPcNom+RZ9GS5UeWcW01kbV/wnOYax6tlVn
         rHYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=N4WRLTZt28lkUemP8bmvX63q6AU2uYVq26PdhSIkK84=;
        b=oAK300+9iwTrQd/uqOFax2eEbPQBGr0Zt960RT2RoKaTMoWEpAh7gsazxScImnNykb
         DLg5vWQtC6UIN9/OE31EBeMu5Z6lGI1zj+pk6TXZVd3FD/7JEW9J4VWDlsj0QE2hEj2b
         AS946xox+1bCbJN8Xq6O3JdncV4GykZt0xELqJjwv7R5B6nbYdQf5wtvW5GgjcEf+V9D
         k4to5QnPb7+A20ktU+KaaOOSdhuJiq3xq0WwZ/Qwtthd0O+kWbzZlAzp7oRf80rXj/Cy
         3ucW+h7a8QGzd7EypNe7Y9ZIpbpaiFOcNnWOScA1Mr1sjVLBrzGhKFeE/WqCJAOT2Zyh
         Wtuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e11si2277200ede.46.2019.02.27.09.07.42
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:42 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9E822174E;
	Wed, 27 Feb 2019 09:07:41 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ED5CD3F738;
	Wed, 27 Feb 2019 09:07:37 -0800 (PST)
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
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	linux-sh@vger.kernel.org
Subject: [PATCH v3 19/34] sh: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:53 +0000
Message-Id: <20190227170608.27963-20-steven.price@arm.com>
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

For sh, we don't support large pages, so add stubs returning 0.

CC: Yoshinori Sato <ysato@users.sourceforge.jp>
CC: Rich Felker <dalias@libc.org>
CC: linux-sh@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/sh/include/asm/pgtable-3level.h | 1 +
 arch/sh/include/asm/pgtable_32.h     | 1 +
 arch/sh/include/asm/pgtable_64.h     | 1 +
 3 files changed, 3 insertions(+)

diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 7d8587eb65ff..9d8b2b002582 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -48,6 +48,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 #define pud_present(x)	(pud_val(x))
 #define pud_clear(xp)	do { set_pud(xp, __pud(0)); } while (0)
 #define	pud_bad(x)	(pud_val(x) & ~PAGE_MASK)
+#define pud_large(x)	(0)
 
 /*
  * (puds are folded into pgds so this doesn't get actually called,
diff --git a/arch/sh/include/asm/pgtable_32.h b/arch/sh/include/asm/pgtable_32.h
index 29274f0e428e..61186aa11021 100644
--- a/arch/sh/include/asm/pgtable_32.h
+++ b/arch/sh/include/asm/pgtable_32.h
@@ -329,6 +329,7 @@ static inline void set_pte(pte_t *ptep, pte_t pte)
 #define pmd_present(x)	(pmd_val(x))
 #define pmd_clear(xp)	do { set_pmd(xp, __pmd(0)); } while (0)
 #define	pmd_bad(x)	(pmd_val(x) & ~PAGE_MASK)
+#define pmd_large(x)	(0)
 
 #define pages_to_mb(x)	((x) >> (20-PAGE_SHIFT))
 #define pte_page(x)	pfn_to_page(pte_pfn(x))
diff --git a/arch/sh/include/asm/pgtable_64.h b/arch/sh/include/asm/pgtable_64.h
index 1778bc5971e7..80fe9264babf 100644
--- a/arch/sh/include/asm/pgtable_64.h
+++ b/arch/sh/include/asm/pgtable_64.h
@@ -64,6 +64,7 @@ static __inline__ void set_pte(pte_t *pteptr, pte_t pteval)
 #define pmd_clear(pmd_entry_p)	(set_pmd((pmd_entry_p), __pmd(_PMD_EMPTY)))
 #define pmd_none(pmd_entry)	(pmd_val((pmd_entry)) == _PMD_EMPTY)
 #define pmd_bad(pmd_entry)	((pmd_val(pmd_entry) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
+#define pmd_large(pmd_entry)	(0)
 
 #define pmd_page_vaddr(pmd_entry) \
 	((unsigned long) __va(pmd_val(pmd_entry) & PAGE_MASK))
-- 
2.20.1

