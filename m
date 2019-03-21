Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0954C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A76321916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A76321916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A690C6B0275; Thu, 21 Mar 2019 10:21:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A18B96B0276; Thu, 21 Mar 2019 10:21:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92E436B0277; Thu, 21 Mar 2019 10:21:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 454486B0275
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:21:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n12so2298701edo.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:21:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=pX/PB4n2IeBS7sjZhWU1hfRYsJGKweBLwoVKBOHKWGQsCoqtuQG9bF/iOeSghyo7Bg
         HUFXuqRqMYTVWtkgzozT8mnj0PHrBZt7OZJ7SGu6GxwNAUe3gjxSlFWUJe4HbVDkFph5
         AGwFsPbqTiRzlm8APwLsNb/Tdumxv3Lu4aFdqwN5tB/3xkHQc5yAvyNDsoyBq8BWTfRX
         mBAUUHBBZlGQ4TBGkdc7HkW74h0lOMmlbzpyLyo2rqAN+GVZkF1SAW0jxSvpRCLWrCIg
         +hXgrqFjLxolIw3jPPd7xSakTyzckp0rMrLMMfcIoEPbBRm9sNvdNC5g7qf3FxfZ/q7+
         9+kQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV57+ezVYF/wsY6Ze0VJ2I6twwkLKAPCQ4x0lY5sGngEW+6whpX
	oDt0p2dDriDaP3Zvhde97xp9xZHw0MywYulAT7c5+NIg61oz/YdbeGG6FNWBp5mJIpn4QXB4+bu
	UxZSjL4i/KyGxZW42Gvw9tjH9n/LmIOqQgv93cAQjGiXo4D5gpIcmXtDF/vxbYNI82Q==
X-Received: by 2002:a50:fe14:: with SMTP id f20mr2610472edt.187.1553178066818;
        Thu, 21 Mar 2019 07:21:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXzurXw7Q4bu/3YCXHYlrtBq+G3uJ++P4j5gQ1trZT8D+OF78rz5lNdfgYkkaNw/uIkMsg
X-Received: by 2002:a50:fe14:: with SMTP id f20mr2610435edt.187.1553178065996;
        Thu, 21 Mar 2019 07:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178065; cv=none;
        d=google.com; s=arc-20160816;
        b=NqWePeW6BAJUGsCxIyB8hmvY83n8Z8UGwwb5dMX1NudcbDy3BFcdR4WR6TPkMmyKnU
         ejJ8jyUpIEsOEZfQ6pTWs6jmu9q0gwP1kjpsbIbsFLuhPm1j3IFOJ3nq0D13GlYQujU8
         S/g5Q0NNsMmGn7fUs3tyepyFxdxxOiAa7lEmcrmvS24//L60MuarY6QFGEA+sul1ofW2
         b+OhS9cdCRt/NyOj8exv3Sn9juEbl631wqpx9/vGQH56t8jI56ya9uwOjV4opr481+WT
         bQeGacwonexaZQi5BcojGXxAKouxq0ptNUnP0MGSwAp3rZK+6fiYTQeoQz7dokMFteId
         /82Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=qJZpZzQgvblT4kSu1EvSWGm+NdyA3dalpfc0vX+OX4APEj2dhkeQlCrN9vv48nd3xy
         /rCyv96s1G90t+bugjF5KWmSeCG1qrMQxwUnYwe258jeHoO1yovDcLb77GOpdJQtlEpM
         rChX4/tnCwmXvYeqtF62okI6F9qQ+bo3zBYqS2AlwPKHQjusFrld32lLNzHhxDzSolRS
         5eKAYiVsUPJcKV7bVE9ELYfjsChzWf+lwqRUNTrRyIStI1cH4YJ+qD1EdmkGNYEOvXns
         Y6Xt3hV7At0gPkfg+COWf74ZfZRgpj0j4alqgK++8ZXV/cF5D308eikUWh++a1w30yu2
         5fiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t17si507611edf.305.2019.03.21.07.21.05
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:21:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E637BEBD;
	Thu, 21 Mar 2019 07:21:04 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB8203F575;
	Thu, 21 Mar 2019 07:21:01 -0700 (PDT)
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
Subject: [PATCH v5 16/19] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Thu, 21 Mar 2019 14:19:50 +0000
Message-Id: <20190321141953.31960-17-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To enable x86 to use the generic walk_page_range() function, the
callers of ptdump_walk_pgd_level() need to pass an mm_struct rather
than the raw pgd_t pointer. Luckily since commit 7e904a91bf60
("efi: Use efi_mm in x86 as well as ARM") we now have an mm_struct
for EFI on x86.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 2 +-
 arch/x86/mm/dump_pagetables.c  | 4 ++--
 arch/x86/platform/efi/efi_32.c | 2 +-
 arch/x86/platform/efi/efi_64.c | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0dd04cf6ebeb..579959750f34 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -27,7 +27,7 @@
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 3d12ac031144..ddf8ea6b059d 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -574,9 +574,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 		pr_info("x86/mm: Checked W+X mappings: passed, no W+X pages found.\n");
 }
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 {
-	ptdump_walk_pgd_level_core(m, pgd, false, true);
+	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
 }
 
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
diff --git a/arch/x86/platform/efi/efi_32.c b/arch/x86/platform/efi/efi_32.c
index 9959657127f4..9175ceaa6e72 100644
--- a/arch/x86/platform/efi/efi_32.c
+++ b/arch/x86/platform/efi/efi_32.c
@@ -49,7 +49,7 @@ void efi_sync_low_kernel_mappings(void) {}
 void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
-	ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+	ptdump_walk_pgd_level(NULL, init_mm);
 #endif
 }
 
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index cf0347f61b21..a2e0f9800190 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -611,9 +611,9 @@ void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
 	if (efi_enabled(EFI_OLD_MEMMAP))
-		ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+		ptdump_walk_pgd_level(NULL, init_mm);
 	else
-		ptdump_walk_pgd_level(NULL, efi_mm.pgd);
+		ptdump_walk_pgd_level(NULL, efi_mm);
 #endif
 }
 
-- 
2.20.1

