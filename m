Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9AF7C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 736E72147A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 736E72147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 128AF8E0077; Thu, 21 Feb 2019 06:35:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D7BC8E0075; Thu, 21 Feb 2019 06:35:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6EAA8E0077; Thu, 21 Feb 2019 06:35:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 87D988E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:33 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o27so944230edc.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=gAd2dQiK5S/Cji2eJ+YbjThNN7IlcdesHOzdeLpKS5M68v4e7c/G6XLDJNHBEF+sNb
         eC1rXvAwqgm2mST9b1G6RuQnkFQbwy2oLH7nGatt12ZfWlx0y4SeJYJGLtfbSiPIfjRk
         5/Vd+aan7EEiVVM8SWY8jLM3cLDoCXa1SCUvkvp/cpUGHPo5icQNsyWaSCGrviXJxnJ2
         wRAy/teSbOhY6/tq/mt3rzR7Muj5+atcpmO2hG+4l6mWZ27VydN+0zzYJSFsRC48LPAs
         ibJxovLwybuhVJRwkjsYVCotRicwPYOcWcUTvMBeWDMbKGHieAcLRtWFJU1jayX1/dBb
         3d1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYBDngdByqB+2onQmlqKsaQ2oAa3a2C9BoBVMDQmmeJqJCqQu/O
	47YEEhD8uyaMeLfxReedkqtFW1wQhLeEUcizhEsczqnEdvyOik+omuHwdhyF5+7v+gExrc7WHye
	z7893rTxTTcX6RCYnduu6gsUG03duHWfjYvgA6XKh3EVJg8SRA/ZUBgBuVRuyG64iFg==
X-Received: by 2002:a50:ae8a:: with SMTP id e10mr15746040edd.24.1550748933057;
        Thu, 21 Feb 2019 03:35:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaWYkrWK0l9fucY2kSlhM1zOh2Nt1wb2R4ZH+TRATnjS3Vl5h69eTGJutnJs9OePBlmZLy3
X-Received: by 2002:a50:ae8a:: with SMTP id e10mr15745978edd.24.1550748931964;
        Thu, 21 Feb 2019 03:35:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748931; cv=none;
        d=google.com; s=arc-20160816;
        b=AYcfUOpZqWyMD+0gtZQTv16WTbrw723KYG2A0fxUgZV6l65fsdoyPJ6EZqCil4tbuO
         4UeEKCnzbNwza1Ns5mH35vOVV+2TwArOA2SpfNcR59rDBJMqX8kv0eW0OHN0/VnCR9Zu
         PJdwrs414nJboUx8YO8NNAspooVLBjRDXqGN1bpAaB1buJPxdL5U/x90QbbcR5/T3oae
         WYf7dUyo9AWTihQWhPpXJFvmcAtZUT7UIetXvDL5WOCUwyN8jvFiDml/lqyU6ppgXvmf
         hiVxJKT4cv2zYPechJu3NBKCjZg1bfMyiGJYUGeO+HRR6aa3ofGLp9CVsp8Jui1mk+C6
         24QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=mWOLyUlf+Jp26OsKIz1Fe4FRABsrA2R4urK+jXOw8oqkLDN3GP8/KkcsjUp5AAcSO5
         tkG5ohE9h5X48dld0t6JCbzMuT8GJewiofAB5ywD6qkEoe9MpzxiyO2z60kJOEv18Ktu
         V38E+m8d7ENl4/qL3j/+HS9PzBWQ4lbACzORg7fZKV+J/ymYHxbf005ThbeMd4qJx16X
         19AFg0dCQFar25R+OgLbD1OIw4ao+IymymvyUa8AfkqVoFWN64VQ9Odxo0y1NFZNdK7v
         hEizxau0+oLMkH6ttWx1T7++a8nN45+aTLW2Szz8OOrdQqsRmIH0xdzfHCGDCHZ9Xpg6
         u53w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i14si6372834edj.46.2019.02.21.03.35.31
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:31 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C4CC780D;
	Thu, 21 Feb 2019 03:35:30 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 446643F5C1;
	Thu, 21 Feb 2019 03:35:27 -0800 (PST)
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
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v2 04/13] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Thu, 21 Feb 2019 11:34:53 +0000
Message-Id: <20190221113502.54153-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190221113502.54153-1-steven.price@arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
no users. We're about to add users so reintroduce them, along with
p4d_entry() as we now have 5 levels of tables.

Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
PUD-sized transparent hugepages") already re-added pud_entry() but with
different semantics to the other callbacks. Since there have never
been upstream users of this, revert the semantics back to match the
other callbacks. This means pud_entry() is called for all entries, not
just transparent huge pages.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/mm.h |  9 ++++++---
 mm/pagewalk.c      | 27 ++++++++++++++++-----------
 2 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..1a4b1615d012 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1412,10 +1412,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
+ * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
+ * @p4d_entry: if set, called for each non-empty P4D (1st-level) entry
  * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
- *	       this handler should only handle pud_trans_huge() puds.
- *	       the pmd_entry or pte_entry callbacks will be used for
- *	       regular PUDs.
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1435,6 +1434,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
+	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
+	int (*p4d_entry)(p4d_t *p4d, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
 	int (*pud_entry)(pud_t *pud, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index c3084ff2569d..98373a9f88b8 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -90,15 +90,9 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 		}
 
 		if (walk->pud_entry) {
-			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
-
-			if (ptl) {
-				err = walk->pud_entry(pud, addr, next, walk);
-				spin_unlock(ptl);
-				if (err)
-					break;
-				continue;
-			}
+			err = walk->pud_entry(pud, addr, next, walk);
+			if (err)
+				break;
 		}
 
 		split_huge_pud(walk->vma, pud, addr);
@@ -131,7 +125,12 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (walk->p4d_entry) {
+			err = walk->p4d_entry(p4d, addr, next, walk);
+			if (err)
+				break;
+		}
+		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry)
 			err = walk_pud_range(p4d, addr, next, walk);
 		if (err)
 			break;
@@ -157,7 +156,13 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
 				break;
 			continue;
 		}
-		if (walk->pmd_entry || walk->pte_entry)
+		if (walk->pgd_entry) {
+			err = walk->pgd_entry(pgd, addr, next, walk);
+			if (err)
+				break;
+		}
+		if (walk->p4d_entry || walk->pud_entry || walk->pmd_entry ||
+				walk->pte_entry)
 			err = walk_p4d_range(pgd, addr, next, walk);
 		if (err)
 			break;
-- 
2.20.1

