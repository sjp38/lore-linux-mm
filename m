Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 137F7C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFF522086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFF522086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71AD88E0078; Thu, 21 Feb 2019 06:35:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EFCD8E0075; Thu, 21 Feb 2019 06:35:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 593098E0078; Thu, 21 Feb 2019 06:35:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE72F8E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:36 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so1903280eds.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=dhAridJa5RC9XXe4KwJw8YVGyjtEqlig6nrFwcv+O6Hyhz/v5rvJuwLAdiM7qYV+3T
         6jX5IBAwsUDtGwMDOQ9MDpOjVKt6qThQakuQoGhsZLbKzlHYTmVBvtSb3d6Uzz7eDnNI
         1chwQYvNHebj7Fr1ukCLRSkPD/YTPB38q0KGQztGCPuMu4OUrVB6lXDQZ/8VWXCFWF/Q
         0rHNiXozIZ9xEl2nlEyBGlf89NmUmLVh62TnrgRHrlDOPva9ZUHBq6HkaZ1P5MvkG89X
         iwY6EgoY/jPcDhIeIjQBjdJcownEIYmE2MhpYDGArJ+Em/XMdWTayfeoGzaTxqlN/+0K
         bmdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub+65qiLD9kj45Lx8u/8mehQoCgtzdPmeDcirZxoLi2oXR64tEA
	cx1Srap9D/pHVt/zAemHTWuX+q0f6fI4zKqUmL+2L9ydPrBTg42lBOlhrqAXYdTNv+bvgXnHgTf
	kSwmbsMI5Yh05JaS7541t3A+jsoKjxSMxiLTDfgpSODQaBb5tazxp0dss4z7tfC8eKA==
X-Received: by 2002:a17:906:4f15:: with SMTP id t21mr7075387eju.179.1550748936475;
        Thu, 21 Feb 2019 03:35:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iba6dIKtD7muF5BLXUJvdeWUmyzHHs+agSy7RUrZwZKk1tg9x42dYXYMkKVOJ9EHIuIVaV0
X-Received: by 2002:a17:906:4f15:: with SMTP id t21mr7075342eju.179.1550748935515;
        Thu, 21 Feb 2019 03:35:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748935; cv=none;
        d=google.com; s=arc-20160816;
        b=nZkM1WlB+L2bFtWj1xVPOGHof70PWX5YAnfT63HwU8Fu/Ilbykl8ktyznDYFeRf6Sx
         rOtkybyl8chftHPaOs+jvJ0i8ab3vlCHx2Z6aAvZjMsWCgHm0richllZNvPZjq4zkIO5
         8gLNEIZAcfh8d39s2YNTewePtrRznMocAtXV/ND56dn/8DN6E5k2Zmquzj5lPZkhNK8S
         KLbeR8y2qFjuFaK0N4H9Hglkpxo+oxY5h6jbv7XLr1OCG839cEaMJ+CliALTN1EuCzCg
         wgc4f/UfiIN7KCHYKuojYPEEMSlBBenrQi4t51/3VpskTUdVu8tyjgvMWrpnyQqovhJE
         2F+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NXbLxkVEjkUC98nDqbwMu9XwBnfr8Fy+W9xUz87hsi8=;
        b=Zf+mmTTJQ1qTV6t8WxwfYbw0EhZNc3zuH3ukhc9yIUq2NJFge0Cq9acpqyhNTRo3FE
         EghxY+LijaDdT8uttRvoHSz/kvmcmWCN/YrcoEhApylrIR+jt7R3UkmhO/SwS1/KDY14
         sk1nBcAoF8Qqg4LkSdLq0Zb79ppQnrU3GBvZ1TkWjwSKfh7CUZwlsZwFiUED1TtC8AEn
         egL6o4a0qy+eRyXznsOLVp7jdM1KJfXsm2Juc3Kpp6UFIeBjuS3ZRNir7DJ1PWuPtoMJ
         qcdjbCXYbWo4agnI5e/CBDlDbaQfMKd5VciEffxDU+KYiF4CQvufY9TXsPs2HFoPd5b9
         PiDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o21si80779edc.54.2019.02.21.03.35.35
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:35 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 93A1C1682;
	Thu, 21 Feb 2019 03:35:34 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 131053F5C1;
	Thu, 21 Feb 2019 03:35:30 -0800 (PST)
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
Subject: [PATCH v2 05/13] mm: pagewalk: Allow walking without vma
Date: Thu, 21 Feb 2019 11:34:54 +0000
Message-Id: <20190221113502.54153-6-steven.price@arm.com>
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

