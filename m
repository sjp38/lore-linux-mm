Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B111C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1553B21873
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1553B21873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89C878E001C; Wed, 27 Feb 2019 12:08:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CF958E0001; Wed, 27 Feb 2019 12:08:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69FE88E001C; Wed, 27 Feb 2019 12:08:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 028208E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:07 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id j5so7175066edt.17
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=N2UIVE0jk8GjvQYXybyHQN6/8+Lt7FF5iG/j99JcP9ge9DJp4f84Kt4rEkDIae+WRZ
         OglUqCbl+dV49EwNxCf2L9GSzA/RDZHa4XGRL1O/8hw+Mv8hROksTdPsz+T9gKM1P9N6
         jnb3Y5KCoHrYK1VR8dJkyshxFRO0gENg8+cxbe/zCijFFtvx9+lj2wUPe7lTXSVhxVxj
         iN3RviTEALnhpYsqxRwPgjEhBoVBJcEIhK+2Mb6WDAuhS9MH2ufbl6h6P2bXwZ43JQ3R
         7NAcuw8keq2MgTiMoqUxCjNwzuo6FyQZNh3v/rNzNzagkogI093utKm79l6M7ELYMnbj
         oS6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubeWeQkraaR/jziX2Uie/lkF1CUUd0s4moeo38qAE1lKGmjAcC/
	KziCfPL7l50sFmaDcsSzClAMUL72SSfm25WvQ+7ofYIB2G20T/iVCWpMwN89CJPv5eNDWWlXCsv
	RXOz3N17OkFH4VVVZHZGe10dThoP56cVMBoxSXkaSJFKeOS2HPBtDwkn+3HQoFYrdGQ==
X-Received: by 2002:aa7:dac5:: with SMTP id x5mr3174858eds.56.1551287286517;
        Wed, 27 Feb 2019 09:08:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4n3frB4cd0168sDL1/eY8dbS3km7IC3Pm89TvKSUDRR0o4b6ieuIFsUAPuz7izjSyohwU
X-Received: by 2002:aa7:dac5:: with SMTP id x5mr3174774eds.56.1551287285178;
        Wed, 27 Feb 2019 09:08:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287285; cv=none;
        d=google.com; s=arc-20160816;
        b=pBjH+dizrBn8hnSLFvwM28kwKvH5kX5gdDuVjaKebQvUkmZ7EVpxFO1OYxeRS0PwxX
         bMkh6o+QHG4yptyXLP4RD202ZF3HdK7jnSPgi/wBpRkD8krZ1Pwjp/98v2G+e5w8O2CP
         9PC4OzdR3taE8/D4jxU+TOYNa2yU1z8xRfW/gMJ5ZHP0I5Alzapt0moU5NBiHx3AZIjB
         B+S85HAuLrz2lyNYRS7riPGdJ80FJRaUbOrCBy0ExrECUPQNHRjGq09/FL9O07xr0e1I
         e5NsyVV0BBpY0wr8MzrdBW5MBhja6SBMUarBbW4si5JuV7jXpuwWd89b5d0HdQ91tNVx
         L//Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=WJ8Xa42OqZQh3O6NW34EU6W+WQ9Dl4ktqaR2FIT6pZO47KMSS/xV2O/1yiGELFwJEH
         JyFAKFXuQx4UQMo7PHwjnqOEj3d7wb8QQTJmzuhlRGD1npx8UDCZ2KV1gH1d2SYkh5EW
         XsowKwU7qMFWYdR1FqaHvcU7RTZgMj4EPAgk/xj0S1CDL2weyDCmA8Q8pYu6gzMVR4v2
         NFpSZKTLKVSXTld6/jGDKBbSPsavXAcO+zzo+Nu+WzoAF7EUhkl64/HEJEJbE6qxwLXz
         bvvHG5fRxgKvFAB/eaxrr5RF5pRDi5EAc0c0nS54+EWVL1rxj7swKd4vmyYQ8FrfDbdX
         U3Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f20si594198edd.56.2019.02.27.09.08.04
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:05 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1D8E31715;
	Wed, 27 Feb 2019 09:08:04 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D6C343F738;
	Wed, 27 Feb 2019 09:08:00 -0800 (PST)
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
Subject: [PATCH v3 25/34] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Wed, 27 Feb 2019 17:05:59 +0000
Message-Id: <20190227170608.27963-26-steven.price@arm.com>
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

