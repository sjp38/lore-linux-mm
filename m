Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45669C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF8F0233FE
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Z9XdTfPQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF8F0233FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FBBB6B0272; Wed, 21 Aug 2019 14:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35E1E6B0273; Wed, 21 Aug 2019 14:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D6416B0274; Wed, 21 Aug 2019 14:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id E83006B0272
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:21 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A48E955FB5
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:21 +0000 (UTC)
X-FDA: 75847280082.29.ray10_31ac6c4d2874a
X-HE-Tag: ray10_31ac6c4d2874a
X-Filterd-Recvd-Size: 7534
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:21 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id j15so4201316qtl.13
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zx3wi4rxE69hFoeINMbvlrOQdd3v0rMCcWlwgMe+7ro=;
        b=Z9XdTfPQsqrX+ihCr/4v6ItjEm2fTEBbeWz31i5BDIZiOLzaaHMtsuH2gtjkTF6ELA
         7yXqP1MI/fSXDCZ14zn/alA5HSSTPmUHomhmG+JDDkx1iLsTl7o/Iqcn9rPRE3VmTc/X
         /ox8ZTwPDgqdEsBMlW32tnbBoHwMhgBeTxLUP0uouGygQ/O3Fa5pNUVp9reQpI62FyCX
         R3eJo+7FXskAW2/gAKFmeWDiSo7F5wlSMNy8J29CwUOFu7Obx7iEVrbyGTfDJ4oC7JZx
         oOnvCDR8AxKmVTLp02PdeBuOzlYNu4WasPK9T7Aj8+N3bmKh30clQWsDfamV/Ov+aWlZ
         y0Ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zx3wi4rxE69hFoeINMbvlrOQdd3v0rMCcWlwgMe+7ro=;
        b=e+GikIDbKOudmLKjEXvmiX/nrpzbXupNuAZ9nkjSv2z6xYOPKOMTt43ir7L9kE6xlc
         Ejsk8E3zUBHjkhke5RTJ5wp6vc/nw0Uj5GI4zig69mbc5wKLZPpN+6R6VUy+yPgnLygO
         J9VCuhinqP6Kwu5UgbLg8hIWAJNbyQl+fe6XAeJYym4e2Tps4imjpHHrOjtZBdUlFPmP
         dJzWqn66muFfpTVXUfJKu7atVxLXsaNtr1bY+PVXQxKkChdZUzPFZz7xKOmXD+CYJJkW
         h0I1AVd8UfJ8bGamllDA7oC2ASDl88MSyL8yeMAojvGnxMkmARFR5/N4rMijNKPb8kWE
         wJRw==
X-Gm-Message-State: APjAAAWTRxb0gLGxgYYhmG3JAef7Q+Yu9wWnPKY+KmCx6NPvAXfvbUNJ
	kLn8PU4h7/gjZlwOjm7S52HV5w==
X-Google-Smtp-Source: APXvYqwWbwptxQVbDLDq/ThfodFBbNa157DjIxH5pnCxaJLPGWLsptjdu2SMPi7VujUE6fDJ2uoQLg==
X-Received: by 2002:ad4:45e3:: with SMTP id q3mr19092758qvu.140.1566412340641;
        Wed, 21 Aug 2019 11:32:20 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:20 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 10/17] arm64, trans_pgd: adjust trans_pgd_create_copy interface
Date: Wed, 21 Aug 2019 14:31:57 -0400
Message-Id: <20190821183204.23576-11-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make trans_pgd_create_copy inline with the other functions in
trans_pgd: use the trans_pgd_info argument, and also use the
trans_pgd_create_empty.

Note, that the functions that are called by trans_pgd_create_copy are
not yet adjusted to be compliant with trans_pgd: they do not yet use
the provided allocator, do not check for generic errors, and do not yet
use the flags in info argument.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_pgd.h |  7 ++++++-
 arch/arm64/kernel/hibernate.c      | 31 ++++++++++++++++++++++++++++--
 arch/arm64/mm/trans_pgd.c          | 17 ++++++----------
 3 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/arch/arm64/include/asm/trans_pgd.h b/arch/arm64/include/asm/=
trans_pgd.h
index 26e5a63676b5..f4a5f255d4a7 100644
--- a/arch/arm64/include/asm/trans_pgd.h
+++ b/arch/arm64/include/asm/trans_pgd.h
@@ -43,7 +43,12 @@ struct trans_pgd_info {
 /* Create and empty trans_pgd page table */
 int trans_pgd_create_empty(struct trans_pgd_info *info, pgd_t **trans_pg=
d);
=20
-int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
+/*
+ * Create trans_pgd and copy entries from from_table to trans_pgd in ran=
ge
+ * [start, end)
+ */
+int trans_pgd_create_copy(struct trans_pgd_info *info, pgd_t **trans_pgd=
,
+			  pgd_t *from_table, unsigned long start,
 			  unsigned long end);
=20
 /*
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 8c2641a9bb09..8bb602e91065 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -323,15 +323,42 @@ int swsusp_arch_resume(void)
 	phys_addr_t phys_hibernate_exit;
 	void __noreturn (*hibernate_exit)(phys_addr_t, phys_addr_t, void *,
 					  void *, phys_addr_t, phys_addr_t);
+	struct trans_pgd_info trans_info =3D {
+		.trans_alloc_page	=3D hibernate_page_alloc,
+		.trans_alloc_arg	=3D (void *)GFP_ATOMIC,
+		/*
+		 * Resume will overwrite areas that may be marked read only
+		 * (code, rodata). Clear the RDONLY bit from the temporary
+		 * mappings we use during restore.
+		 */
+		.trans_flags		=3D TRANS_MKWRITE,
+	};
+
+	/*
+	 * debug_pagealloc will removed the PTE_VALID bit if the page isn't in
+	 * use by the resume kernel. It may have been in use by the original
+	 * kernel, in which case we need to put it back in our copy to do the
+	 * restore.
+	 *
+	 * Before marking this entry valid, check the pfn should be mapped.
+	 */
+	if (debug_pagealloc_enabled())
+		trans_info.trans_flags |=3D (TRANS_MKVALID | TRANS_CHECKPFN);
=20
 	/*
 	 * Restoring the memory image will overwrite the ttbr1 page tables.
 	 * Create a second copy of just the linear map, and use this when
 	 * restoring.
 	 */
-	rc =3D trans_pgd_create_copy(&tmp_pg_dir, PAGE_OFFSET, 0);
-	if (rc)
+	rc =3D trans_pgd_create_copy(&trans_info, &tmp_pg_dir, init_mm.pgd,
+				   PAGE_OFFSET, 0);
+	if (rc) {
+		if (rc =3D=3D -ENOMEM)
+			pr_err("Failed to allocate memory for temporary page tables.\n");
+		else if (rc =3D=3D -ENXIO)
+			pr_err("Tried to set PTE for PFN that does not exist\n");
 		goto out;
+	}
=20
 	/*
 	 * We need a zero page that is zero before & after resume in order to
diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
index ece797aa1841..7d8734709b61 100644
--- a/arch/arm64/mm/trans_pgd.c
+++ b/arch/arm64/mm/trans_pgd.c
@@ -176,22 +176,17 @@ int trans_pgd_create_empty(struct trans_pgd_info *i=
nfo, pgd_t **trans_pgd)
 	return 0;
 }
=20
-int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
+int trans_pgd_create_copy(struct trans_pgd_info *info, pgd_t **trans_pgd=
,
+			  pgd_t *from_table, unsigned long start,
 			  unsigned long end)
 {
 	int rc;
-	pgd_t *trans_pgd =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
=20
-	if (!trans_pgd) {
-		pr_err("Failed to allocate memory for temporary page tables.\n");
-		return -ENOMEM;
-	}
-
-	rc =3D copy_page_tables(trans_pgd, start, end);
-	if (!rc)
-		*dst_pgdp =3D trans_pgd;
+	rc =3D trans_pgd_create_empty(info, trans_pgd);
+	if (rc)
+		return rc;
=20
-	return rc;
+	return copy_page_tables(*trans_pgd, start, end);
 }
=20
 int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
--=20
2.23.0


