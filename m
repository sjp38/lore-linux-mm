Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F31BDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B935821924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B935821924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55DF78E0007; Fri, 15 Feb 2019 12:03:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50A6B8E0001; Fri, 15 Feb 2019 12:03:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9998E0007; Fri, 15 Feb 2019 12:03:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBC038E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:21 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f11so4241824edi.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=MzqF2dqOIKIYvc6wHsXsbvlRYCBpS90JZx+zXhYB6FwC+uRlJyHpPg/vf5q11/guSB
         JABt9F46330VhpZP7isN6mnQAqfHiYUwh/NbSim9QxuRVradTONXIShPiYt18mjAYkKE
         iLthzo24mJs8Ylr3vReBfvaB1M8yAaa0WVSUDrzTxM28BcpvExSSgL3QPFrHoLJEUgXQ
         dmJ/AQHTOhT/7R49Iu4lq8hV0U6n74txkdeKFFxKP2j9peO6cYWGjAsWoP+aCXoRO857
         h6HfRPLf2FZLbiU6koXrG5kNlEWcFDJ1ld34hmGk/3jmDCLZ/YDWsDjZfGESYEtsw45e
         wGMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubiB8ESNCGc4SpycBP4D162L7b70UkVrCq0pv/5z+LWmJREIK64
	yxXg3GNa5y1RlIAes1z2mtS9uI812YZ4RHnOduMZ/YuIl/vsfvYeCK9FfogJzY0WJ0sI8GIp560
	hQ4i61gvwLRent98fiooX23JCPmd9VWy+bBzPpbBvIuEMIecN3N0jyBuHTJa529Xe0w==
X-Received: by 2002:a17:906:ee1:: with SMTP id x1mr7281284eji.85.1550250201377;
        Fri, 15 Feb 2019 09:03:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbWB2FCaQ8MET2ZoWm6lQxyL8Z58ALfHvYDprzy1ly2FA/3/XiFSGeDw5/vPVp6VXRxHV5K
X-Received: by 2002:a17:906:ee1:: with SMTP id x1mr7281194eji.85.1550250199898;
        Fri, 15 Feb 2019 09:03:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250199; cv=none;
        d=google.com; s=arc-20160816;
        b=XjWFY+H/o0veg5uTQ7CiKqaznfrHBo7cs1gsUGv62PPG3LFdB5vB63sIYP/lWqv4ID
         Um2fLMjGxGAlYAXxsJHlqqFWifCylNDb0J6IASt2SffpwfIiyY7A/v9azFH8VDB+Q+wx
         PJ1Z1mtmDB3oxgsged3JELeF2O98Q6a2T8GEVD9QwKhwnREcTtknDqkFPIzM8aIBt61x
         bJj6sa4VqVXoQ90VvqYHCUf7/SLNWeNzDhk/UbeZ6SUGm4v2elQiXjFfM5TF/IyFnKLh
         Q8/Si/lnhxsq+e516JDQlN08XTxTLhFSPlvaLEiB7LYMWrpgp9YqoFR0VFmwfxwLM7oS
         mwww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HrdRugGr2uKHHo/TiR13vk3LQ/wnulW6YNAfJqdWS6g=;
        b=bxG74RvXv7hInV/M7ywrQVPGBFURaSyqy5FvlkqFoDCm3FqJ7N4DjlG81mXk2YhGph
         nYsY3IgAIXrQZ77DNRl3X7SCdQvuJ1oZeDUJr1sSw85TrHogVsnfF7iZrpIWaEUzgySg
         GR8p4wZu0Jqzuneejdi7x5uKh+rGkVQc8RhsGOST4Du4rlYvs8apn6f6e1dgVvECcwJ2
         ca8076ynMRUjkFDWSfUQVfweASricguvwDcfu3NDMURlHK4V83QmT0vGAM+96Ej97nzb
         +bdYWWGbylGuErED+qNrEgETqBPsJ6dZtgsjlYrvCPWtEc5nc7ranDkdcP6cKPvkEUFI
         ccBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r26si1066670edb.333.2019.02.15.09.03.19
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:19 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A4D441596;
	Fri, 15 Feb 2019 09:03:18 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B0C343F557;
	Fri, 15 Feb 2019 09:03:15 -0800 (PST)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/13] mm: pagewalk: Add p4d_entry() and pgd_entry()
Date: Fri, 15 Feb 2019 17:02:25 +0000
Message-Id: <20190215170235.23360-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215170235.23360-1-steven.price@arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
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

