Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3C01C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2AC021924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2AC021924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D73FD8E0008; Fri, 15 Feb 2019 12:03:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFC3C8E0001; Fri, 15 Feb 2019 12:03:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEA1E8E0008; Fri, 15 Feb 2019 12:03:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69E7F8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:24 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a21so2959166eda.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=aWlJcoWIFJXMTKe9/JgiNjW04A9sSNuohtUluBSQWCuHWkTNytrXUlCxEya8SrRjCv
         ysNOkEvlk4ENuXbGCwbd1KFUvKppl6UDLsfmodnJvE3P05zla9FEoYtDKPnaafj03rre
         HonBY5OO5etaYNK3JCIP6NuIzqVVMHKUP8fpWdAxFWZeVA0j7KjS3dfjr3oifZk8IplT
         DD5KyX7rmHwURu5p/LBuXiaXWhu8tz9yx8LI27uN2aBTH+FpRlW7ZDtWWuTfqKpZ1fv9
         P2gYjZssM83FkgxnRUpDjdhTzfnUMi0AM5SXpLqWPIbyrg0K9z40donQFpBkvF62EDe3
         8IXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYTjXFJ0yCwVh3RDQyeWya9wBj1rCkqAEmIAYUcl/c4EdeLZFx1
	PFBAebOmHBV143XbJnH2ZJHeGP9bbjnGW2VariaSOZ8jvXFNyGITzJFG1qQrMXGDyquXO8P/E5a
	IXa0QYXWtboHp4uxaC+Thgm3KoBV6l87A3Hw7c8LWjx+zS93wG+9UBs7T8FYdtgwCDw==
X-Received: by 2002:a50:8b26:: with SMTP id l35mr8043349edl.146.1550250203912;
        Fri, 15 Feb 2019 09:03:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZfAeFieHoUj7KrANvljbNoWb614R3s+Nh8Rz+d362XN54KrVQC8CtjD4zxYE3coIC+oDBd
X-Received: by 2002:a50:8b26:: with SMTP id l35mr8043287edl.146.1550250202791;
        Fri, 15 Feb 2019 09:03:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250202; cv=none;
        d=google.com; s=arc-20160816;
        b=waIlE0tQbn4S7ZLbQM/q6rak5nlqemSTOJ5iWaBBIQV7f1tJMQ/zaMcaV6OF8wHa6t
         QsBUVUUa+/39JgreZmRRXAurrZeahzrVPNqxOKucXWmOYSadsg3/XOYby6dY2N1uKpfi
         b02hkuWsbPGgCSi9hwA9T4EnweC/H+8xxIPbhtag5HfNXRljfxUj0FrPCfY+TLOEOPiN
         Vewbk8UobxD5O5yuQCDi4gDbIHxg3K3uIG0cmWZijy8aER5LQj7m+M5yuR1q0y9h/lHZ
         GZgt7iUf74HP8drulx2ueahJqkV2oTKcG115d1oOsNItJvUNwXF8M722vh17cIqJMXLP
         7ItQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=F3RYZds8BVbuBKTnCrJGSZXKV7qWnnOEKq+qry3hHyGFOuidix5tET5cDTAYf3Rik7
         SJqafpVHaG7yPET8I4aHjoG6Jqv6ML1/iIfTwFMjUiIXAIsMTlnKjOUqSMP88gWEC5Pj
         MhXWLnHno0G7dHpFZffhSkOuerusNAgfpjJD7NaTCMY0+VR1N+FdoxzZ5dX+a576wR2e
         HfjfISyxsSrmMJC7ZMpGWYCIAKKtFrSWrAxZNgN2fkFE45ejwh23etkwvyIM+MQfoP9k
         uelyRhgQHWAIhduoA3e2b+7ILFAQFjaTph64b1IRwUf4joOuzEcAgI8aiHpmvlASmZDx
         KaRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y59si433330edy.301.2019.02.15.09.03.22
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:22 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D806115BF;
	Fri, 15 Feb 2019 09:03:21 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E40033F557;
	Fri, 15 Feb 2019 09:03:18 -0800 (PST)
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
Subject: [PATCH 05/13] mm: pagewalk: Allow walking without vma
Date: Fri, 15 Feb 2019 17:02:26 +0000
Message-Id: <20190215170235.23360-6-steven.price@arm.com>
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

Since 48684a65b4e3: "mm: pagewalk: fix misbehavior of walk_page_range
for vma(VM_PFNMAP)", page_table_walk() will report any kernel area as
a hole, because it lacks a vma.

This means each arch has re-implemented page table walking when needed,
for example in the per-arch ptdump walker.

Remove the requirement to have a vma except when trying to split huge
pages.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 mm/pagewalk.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 98373a9f88b8..dac0c848b458 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -36,7 +36,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	do {
 again:
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(*pmd) || !walk->vma) {
+		if (pmd_none(*pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
@@ -59,9 +59,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 		if (!walk->pte_entry)
 			continue;
 
-		split_huge_pmd(walk->vma, pmd, addr);
-		if (pmd_trans_unstable(pmd))
-			goto again;
+		if (walk->vma) {
+			split_huge_pmd(walk->vma, pmd, addr);
+			if (pmd_trans_unstable(pmd))
+				goto again;
+		} else if (pmd_large(*pmd)) {
+			continue;
+		}
+
 		err = walk_pte_range(pmd, addr, next, walk);
 		if (err)
 			break;
@@ -81,7 +86,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	do {
  again:
 		next = pud_addr_end(addr, end);
-		if (pud_none(*pud) || !walk->vma) {
+		if (pud_none(*pud)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
@@ -95,9 +100,13 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 				break;
 		}
 
-		split_huge_pud(walk->vma, pud, addr);
-		if (pud_none(*pud))
-			goto again;
+		if (walk->vma) {
+			split_huge_pud(walk->vma, pud, addr);
+			if (pud_none(*pud))
+				goto again;
+		} else if (pud_large(*pud)) {
+			continue;
+		}
 
 		if (walk->pmd_entry || walk->pte_entry)
 			err = walk_pmd_range(pud, addr, next, walk);
-- 
2.20.1

