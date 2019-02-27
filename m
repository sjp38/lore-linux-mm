Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A54DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF06020842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF06020842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ABB38E0022; Wed, 27 Feb 2019 12:08:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 736438E0001; Wed, 27 Feb 2019 12:08:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 587898E0022; Wed, 27 Feb 2019 12:08:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F0FA08E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f11so5788989edd.2
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sR0SZrw+YPSbYFiP2a4kSO4+FoSeAg5NladWs9lGEmQ=;
        b=UigB6eIV3DHeOWTPY8sEP+by7Q7M5cb5t5CgjB2SctmnslPWe6MaKAa0U4K6Ca2ils
         DPEPYwO6kWAuQ3jPRirAYZPhFN6i3gQtmGKbRUTSm24k8XwIEuPzg1y9gOsu1yj2IgPT
         Sb1gDAfOVfNcXC3OQb5ecVk1Foq2G41HVpwC3kh7RLvKLKfFpVGwyuQ3sDaLolg0mktU
         /4glgouB5GK9/1NrQd5owbv1dEcv59WNJaxFMDHRFOlrrJytWJxlkEGOo9Ucwtvb7AdP
         V3j9dDVZqK0zvqaoli7aaFZrq0paoxNGAeKoezKWjkzVD0gFfzajh/DUOsEZgG7/4wEF
         BUSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYV3waLkBhOLdI4EQmkm9LNP8g4M1bp+uyc3R2vVx6vFKBUmD+b
	9RvY0Gj36Yk/zf9/5SJxt2d3KMWJktonCO2am2RAma/0e9nL3un9hbHjgnA/wUtA2a5z0tjJsBM
	W5okgoxrL6m4tm8Gx53D0jUjDGpg7TUPB93JgbpkwnJHa0k10YyPCFJOM0hewG/XCOQ==
X-Received: by 2002:a17:906:190f:: with SMTP id a15mr2249667eje.231.1551287307475;
        Wed, 27 Feb 2019 09:08:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZyVs2hJ6IMyDT2R/Ef23zc9P4tOJbCIEJLvZ98Gp45xAwWjfhymABhBm5DbM1G5WwiXuTb
X-Received: by 2002:a17:906:190f:: with SMTP id a15mr2249599eje.231.1551287306332;
        Wed, 27 Feb 2019 09:08:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287306; cv=none;
        d=google.com; s=arc-20160816;
        b=t3k6jJmiJxu5hnwpfMXA4LrXEpa5z69QmuKTup0oIpMgirFT16CrlGUmGInpgJFJTI
         TdNJxrDp2w6gxsL/RDlE8c1fMsDfFpJt4+OwitVxU54eprRaL8TeGcrQxTbEaxdIk56Y
         hrIBdhT2Kr6UuZFTx069EzhLlJKHoZZoUdha3C9+AI4qyy+yJcFMZkcWPPisvlXt27In
         9ocJjtRigUzcgoYgp0lRdtmZOQhcM57Sz3VzLYSmiaWqpcz2nKLo+XA8AbOY6Ohp+XsX
         M3bUseCRrY4qnWnlKy0dgKzwGToJurBZ7o11mY8W6pRY3FZ64sMTZpk6Cc0m/Gj/F4gV
         COtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sR0SZrw+YPSbYFiP2a4kSO4+FoSeAg5NladWs9lGEmQ=;
        b=pkx3GLl4N9TF2/kR6bIBItgn61oJtNIfTko0rzR1PT0s9s4fHbUJoPeg9zsaCBREov
         HMiwh9WDq/axHiHwsFY4ABsYbdzm24Q4DR1v95ZlUB7kBmXBe0Gmjwsqx1sKLaEdat03
         as3yu4Q5rWGKkR/qbnEp3efpispsJoCXjUfJfeh+jfZkvD0eDL6bJSFdt9XXvZC54np5
         aaXxisWHQDnUjOjteiNJ3L4ORcolP6/TvhYP27JVI/5auPtJ70QSADnypPvB+JV8W6ql
         vMljfi1ItjPk9A8zSsRcg8WrJQxeYLUh35tAJRfYjibW40osNBvcCpAn8unTcnVhiVJj
         9uPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k56si797987eda.180.2019.02.27.09.08.25
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:26 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 42BE51715;
	Wed, 27 Feb 2019 09:08:25 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 07FAC3F738;
	Wed, 27 Feb 2019 09:08:21 -0800 (PST)
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
Subject: [PATCH v3 31/34] x86/mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Wed, 27 Feb 2019 17:06:05 +0000
Message-Id: <20190227170608.27963-32-steven.price@arm.com>
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
index 1b854c64cc7d..def035fa230e 100644
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
index ecbaf30a6a2f..3a8cf6699976 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -572,9 +572,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
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

