Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05768C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B546720842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B546720842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49F258E0020; Wed, 27 Feb 2019 12:08:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44FF68E0001; Wed, 27 Feb 2019 12:08:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 279AF8E0020; Wed, 27 Feb 2019 12:08:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C23D58E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:20 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d16so7168423edv.22
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+F2lxaeFDvQ8eJHjFbD9vB/FESYGJ6cBcX+b4/bW6NY=;
        b=mRwimeeTuO2AV42wy6iRySqtCUeWxl2L/poBO/MDh5VrmWvGL/f/vozLFplN30o81L
         M7j7srik2eoNU5DoiRDtiPSPzgUUazXvO4+ZbljNQq/VH7ExXnOZ2nIs6w/Gp3298pqM
         MMg2qnc/q0cFhKwa6HjQZLx3QgueJ2ficdksZkKhfQcBSV7JJh/BRdpVxSvBGdlmbDSQ
         4FjE33Qy82kA5wAeS+Q5s3DzHDE4iqByP+ECvA6EhrPjU3biJ/hsysszpJDdVDK78D+r
         oAOgCkDREQ8S6hom2u8veMknFfnQvAZ9sWdC17xfHUNKSfMlFxeGlFEkY6nXraAdlQ6W
         8/ZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubKCPp0+4W/Mz7vFvGVy9JlVuEX2wskoQ5YpcFIyTaIydPa+9Fp
	XapXQrUyP6ks2NafB4+j4vE9ci1vunZE+kxkUI04hD1ae7MOdRuo+L588XU4/K0LrF1Z45gfkB3
	tj1hVcQjDCziJb5eA5KT9bdY6rcdX+QRNP+TWFxDmUjs6l6mJg8dTCnAhlpNrWJB3GQ==
X-Received: by 2002:a17:906:7b03:: with SMTP id e3mr2293408ejo.21.1551287300230;
        Wed, 27 Feb 2019 09:08:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZChEDf0ZfGbh7VdtgaWwRJrUne9Ns2n+x/75LEGo2oMO7n6wXMKA1p+aX2/81Zd2oTJ1+M
X-Received: by 2002:a17:906:7b03:: with SMTP id e3mr2293346ejo.21.1551287299211;
        Wed, 27 Feb 2019 09:08:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287299; cv=none;
        d=google.com; s=arc-20160816;
        b=01Eqieemwqskd8s0YW1gXpXmA0bObNiA2wiYK38X8IBq27JRqa2QXW+s5YiWj5iqID
         fIYLHFX5YujCEIxcdsTdqVepwlvO6Vx/D2+Flu+DizRMSyrKdkPLfu4YOf6/3iLzl0ah
         NMyxF8rQTYiwWFuyiEVY1BcgzPyUp32fu4GNiz82uenuH9ARk7Up0IA3Q9ARTPImNj6U
         gFILvg1MrK9TojICbBU7BrTpeNmnDEEvGYw0w7WEMxmG2QTxF/b5CYdT/yyV3iMu7JDB
         FYJDAxzIerc5hqAahdk5SpHw7flvg7yyv+2EVB67UC7JKwI59DLtD8jioXzuVQ20Eh8R
         zkwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+F2lxaeFDvQ8eJHjFbD9vB/FESYGJ6cBcX+b4/bW6NY=;
        b=xbdu/24CIiTvGp00+ElG/zjfvkwbg7P+A3OsRBcywnC0RrFIZ2Gyj/1Qy1hltui9w+
         6DlyiQnOetIb5bdRinKTdrcepOGzWWhoaEQ/4OeawlIkfuJl1TpZVTdwyp+we7jGH2AO
         oMgGz8mWFuxonPq5E/UtztwC7knINLsPq0tR6uIWKAIbPZlGudZBZmIuCAJrmpCKetZw
         /H6v/JTv9MErMjQuiRQHXB9h+XdjtwKvROrxWt6XlifaIWo7lrSFYjqO8ZBnmTNgt8Ip
         BcRYvjD102gDqmPdK9GMtaDdVTLynOwlEfPO9ilKq1qGWA3jrZb4Z11bvuZyawJWiaKe
         FnEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y2si168628ejw.302.2019.02.27.09.08.18
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:19 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1E9FE19BF;
	Wed, 27 Feb 2019 09:08:18 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D7C103F738;
	Wed, 27 Feb 2019 09:08:14 -0800 (PST)
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
Subject: [PATCH v3 29/34] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Wed, 27 Feb 2019 17:06:03 +0000
Message-Id: <20190227170608.27963-30-steven.price@arm.com>
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

Now walk_page_range() can walk kernel page tables, we can switch the
arm64 ptdump code over to using it, simplifying the code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/mm/dump.c | 108 +++++++++++++++++++++----------------------
 1 file changed, 53 insertions(+), 55 deletions(-)

diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index 99bb8facb5cb..ee0bc1441dd0 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -286,73 +286,71 @@ static void note_page(struct pg_state *st, unsigned long addr, unsigned level,
 
 }
 
-static void walk_pte(struct pg_state *st, pmd_t *pmdp, unsigned long start,
-		     unsigned long end)
+static int pud_entry(pud_t *pud, unsigned long addr,
+		unsigned long next, struct mm_walk *walk)
 {
-	unsigned long addr = start;
-	pte_t *ptep = pte_offset_kernel(pmdp, start);
+	struct pg_state *st = walk->private;
+	pud_t val = READ_ONCE(*pud);
 
-	do {
-		note_page(st, addr, 4, READ_ONCE(pte_val(*ptep)));
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
+	if (pud_table(val))
+		return 0;
+
+	note_page(st, addr, 2, pud_val(val));
+
+	return 0;
 }
 
-static void walk_pmd(struct pg_state *st, pud_t *pudp, unsigned long start,
-		     unsigned long end)
+static int pmd_entry(pmd_t *pmd, unsigned long addr,
+		unsigned long next, struct mm_walk *walk)
 {
-	unsigned long next, addr = start;
-	pmd_t *pmdp = pmd_offset(pudp, start);
-
-	do {
-		pmd_t pmd = READ_ONCE(*pmdp);
-		next = pmd_addr_end(addr, end);
-
-		if (pmd_none(pmd) || pmd_sect(pmd)) {
-			note_page(st, addr, 3, pmd_val(pmd));
-		} else {
-			BUG_ON(pmd_bad(pmd));
-			walk_pte(st, pmdp, addr, next);
-		}
-	} while (pmdp++, addr = next, addr != end);
+	struct pg_state *st = walk->private;
+	pmd_t val = READ_ONCE(*pmd);
+
+	if (pmd_table(val))
+		return 0;
+
+	note_page(st, addr, 3, pmd_val(val));
+
+	return 0;
 }
 
-static void walk_pud(struct pg_state *st, pgd_t *pgdp, unsigned long start,
-		     unsigned long end)
+static int pte_entry(pte_t *pte, unsigned long addr,
+		unsigned long next, struct mm_walk *walk)
 {
-	unsigned long next, addr = start;
-	pud_t *pudp = pud_offset(pgdp, start);
-
-	do {
-		pud_t pud = READ_ONCE(*pudp);
-		next = pud_addr_end(addr, end);
-
-		if (pud_none(pud) || pud_sect(pud)) {
-			note_page(st, addr, 2, pud_val(pud));
-		} else {
-			BUG_ON(pud_bad(pud));
-			walk_pmd(st, pudp, addr, next);
-		}
-	} while (pudp++, addr = next, addr != end);
+	struct pg_state *st = walk->private;
+	pte_t val = READ_ONCE(*pte);
+
+	note_page(st, addr, 4, pte_val(val));
+
+	return 0;
+}
+
+static int pte_hole(unsigned long addr, unsigned long next, int depth,
+		struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+
+	note_page(st, addr, depth+1, 0);
+
+	return 0;
 }
 
 static void walk_pgd(struct pg_state *st, struct mm_struct *mm,
-		     unsigned long start)
+		unsigned long start)
 {
-	unsigned long end = (start < TASK_SIZE_64) ? TASK_SIZE_64 : 0;
-	unsigned long next, addr = start;
-	pgd_t *pgdp = pgd_offset(mm, start);
-
-	do {
-		pgd_t pgd = READ_ONCE(*pgdp);
-		next = pgd_addr_end(addr, end);
-
-		if (pgd_none(pgd)) {
-			note_page(st, addr, 1, pgd_val(pgd));
-		} else {
-			BUG_ON(pgd_bad(pgd));
-			walk_pud(st, pgdp, addr, next);
-		}
-	} while (pgdp++, addr = next, addr != end);
+	struct mm_walk walk = {
+		.mm = mm,
+		.private = st,
+		.pud_entry = pud_entry,
+		.pmd_entry = pmd_entry,
+		.pte_entry = pte_entry,
+		.pte_hole = pte_hole
+	};
+	down_read(&mm->mmap_sem);
+	walk_page_range(start, start | (((unsigned long)PTRS_PER_PGD <<
+					 PGDIR_SHIFT) - 1),
+			&walk);
+	up_read(&mm->mmap_sem);
 }
 
 void ptdump_walk_pgd(struct seq_file *m, struct ptdump_info *info)
-- 
2.20.1

