Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E82C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6365420842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6365420842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64B018E0024; Wed, 27 Feb 2019 12:08:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 601108E0001; Wed, 27 Feb 2019 12:08:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4510B8E0024; Wed, 27 Feb 2019 12:08:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDD0F8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so7103699edm.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ifS9dvr6iRq4OG1WYTg+vUcyWqkssZWOaBwfUmU1Gxs=;
        b=NwrpTkK+rqIhW9aSrnwBXuOQcUByjyQaaVNbblGigXHfTji+UtwEd7jyaP8RrDnsla
         moSgjrdoxFoJ8Zld2x7EtezHwfA95HpSm6KGtSbMy/zbkOHT0hb4dPyKf27Nbx4myHR0
         iMpkkeHU8ICxebrTFSmcvRYpzbj2ZLDXxEJyTf6M3YOzYXabThZYO1bbBywwZw3jPaMn
         93q5GXrmGc9obEY29sNGd/FiSQMhF9kmI6dllGH2Ad0UYrabfy7LhyVdFicABZnBNIg5
         SfR7euuYrlap2BHSyRoD6/OtU60UtdurhXjM6UV+tsb55o/upbqoc6Ajb6JCk/j3eL8W
         XWLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAua3Qv6fIP0x0QnFtBgPQbv2jlohnnT8CX5u3Blo/mU793ki45FA
	KB9t4zkHnbfXqiF9+bzCYNRgEcSa+Bbnpvr6solW1rBh09FpXMxW/5TNu3YQmDKp/3Of0n3Nw0h
	MHvcVXqNbLa7XYWKk6/rkwZ2bOQw2PmKkhzHPZ9Ed388KrBe8xe6/WW7Y4p4VRsrdag==
X-Received: by 2002:a50:8916:: with SMTP id e22mr3207578ede.242.1551287314394;
        Wed, 27 Feb 2019 09:08:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkje2r03+lE0lrNPYLsmnAWOCVx+oJGv7YqWxDZujWmfBoLgygw9P4JBlghw8HVt96E0QV
X-Received: by 2002:a50:8916:: with SMTP id e22mr3207519ede.242.1551287313347;
        Wed, 27 Feb 2019 09:08:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287313; cv=none;
        d=google.com; s=arc-20160816;
        b=w9axnNB4ilknWRtzSRHnNbfab2kbV2oFL8+xfguJfEE59luzvTvp00YohpvU7LDsGt
         0PYMKkOsJe5K7GZOT9xOl99qRCZGxDj6C5dSYAbo+gJRoVR5qmLr9UntHCFnjL7VyNuj
         Ouftiu50fuHFB8tMyvqo5Cv23e++UoBddf1NeJbcebJ5HrCbs1hz25RhfdtadL9MyVCI
         WLALJ1I1OlRpu2GRXkWQ7RYG8s2XufXn1+U4A6EPVDYukehfROjcZYjhYiE2N4jWjRHi
         2iGIE3EN0xk2WYdp87mTXHfiAPpgZk8UCOkPjYMiV/v6kneELpqYAemoYXXaXR+ZfDXU
         gw9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ifS9dvr6iRq4OG1WYTg+vUcyWqkssZWOaBwfUmU1Gxs=;
        b=yweqO0DFxmI+bEFbudKPCFCIme/YGEa2azNSxInYE+D2TULi6vCaL0Z69n2d1pHyxV
         tCW+WzBDPDuDUhN+qECN3uK16VV2ouudoZiDznsx9yt+51L15xaIE9NB03/MQHRbP1WH
         DGnAOwn3K8945n2l6F0RiPQFuCyYXMAqMtNRSxj3zuUCzf4vtTuO4JMfCIO1dO/GT/6b
         R3mIeCcmgkbTQWdLnTNtzLQ2vzGTm303d4PmmgcDXQxg3/ILMivoZxoaehI3RQAPVxpY
         bRblOVOCND96fCMI4pOet8SzO9wQM0Xa9Rd7j3Pda+cdGPUE0fbyV0lEVVc7H9xgWN+r
         HuxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y2si168860ejw.302.2019.02.27.09.08.32
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:33 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 43FFEA78;
	Wed, 27 Feb 2019 09:08:32 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 089B63F738;
	Wed, 27 Feb 2019 09:08:28 -0800 (PST)
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
Subject: [PATCH v3 33/34] x86/mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Wed, 27 Feb 2019 17:06:07 +0000
Message-Id: <20190227170608.27963-34-steven.price@arm.com>
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

An mm_struct is needed to enable x86 to use of the generic
walk_page_range() function.

In the case of walking the user page tables (when
CONFIG_PAGE_TABLE_ISOLATION is enabled), it is necessary to create a
fake_mm structure because there isn't an mm_struct with a pointer
to the pgd of the user page tables. This fake_mm structure is
initialised with the minimum necessary for the generic page walk code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/mm/dump_pagetables.c | 36 ++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index fb4b9212cae5..40a8b0da2170 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -111,8 +111,6 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
-#define INIT_PGD	((pgd_t *) &init_top_pgt)
-
 #else /* CONFIG_X86_64 */
 
 enum address_markers_idx {
@@ -147,8 +145,6 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
-#define INIT_PGD	(swapper_pg_dir)
-
 #endif /* !CONFIG_X86_64 */
 
 /* Multipliers for offsets within the PTEs */
@@ -520,10 +516,10 @@ static inline bool is_hypervisor_range(int idx)
 #endif
 }
 
-static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
+static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
 				       bool checkwx, bool dmesg)
 {
-	pgd_t *start = pgd;
+	pgd_t *start = mm->pgd;
 	pgprotval_t prot, eff;
 	int i;
 	struct pg_state st = {};
@@ -570,39 +566,49 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
 void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 {
-	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
+	ptdump_walk_pgd_level_core(m, mm, false, true);
 }
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+static void ptdump_walk_pgd_level_user_core(struct seq_file *m,
+					    struct mm_struct *mm,
+					    bool checkwx, bool dmesg)
+{
+	struct mm_struct fake_mm = {
+		.pgd = kernel_to_user_pgdp(mm->pgd)
+	};
+	init_rwsem(&fake_mm.mmap_sem);
+	ptdump_walk_pgd_level_core(m, &fake_mm, checkwx, dmesg);
+}
+#endif
+
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
 				   bool user)
 {
-	pgd_t *pgd = mm->pgd;
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	if (user && static_cpu_has(X86_FEATURE_PTI))
-		pgd = kernel_to_user_pgdp(pgd);
+		ptdump_walk_pgd_level_user_core(m, mm, false, false);
+	else
 #endif
-	ptdump_walk_pgd_level_core(m, pgd, false, false);
+		ptdump_walk_pgd_level_core(m, mm, false, false);
 }
 EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
 
 void ptdump_walk_user_pgd_level_checkwx(void)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-	pgd_t *pgd = INIT_PGD;
-
 	if (!(__supported_pte_mask & _PAGE_NX) ||
 	    !static_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	pr_info("x86/mm: Checking user space page tables\n");
-	pgd = kernel_to_user_pgdp(pgd);
-	ptdump_walk_pgd_level_core(NULL, pgd, true, false);
+	ptdump_walk_pgd_level_user_core(NULL, &init_mm, true, false);
 #endif
 }
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
+	ptdump_walk_pgd_level_core(NULL, &init_mm, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

