Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 223B5C3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DACF52173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="W88elMS7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DACF52173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B419F6B0271; Fri, 16 Aug 2019 22:46:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF8E46B0272; Fri, 16 Aug 2019 22:46:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9962A6B0273; Fri, 16 Aug 2019 22:46:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0167.hostedemail.com [216.40.44.167])
	by kanga.kvack.org (Postfix) with ESMTP id 71A8A6B0271
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:42 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 18A18181AC9CB
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:42 +0000 (UTC)
X-FDA: 75830381844.11.fifth43_42e77ebdd53
X-HE-Tag: fifth43_42e77ebdd53
X-Filterd-Recvd-Size: 7574
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:41 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id w18so5649371qki.0
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ekaKdccxVH9Vd+/E5UI//vE0AEA91U4VJzNQTwl8d/E=;
        b=W88elMS7kW8jg3EvlTR8TpaW28BxanfKAEZA1T8tCbXzGsz62pHn2DbtF/0gi1MvG6
         QnxWiMVsfkxQUm0Ae/FuzabuFMIch0uoq5Zhg7oba7ZeKDDAzmXRQ2n1IvGcQFjc8nYV
         m4/JkZyrt8pdX01FitiJJx0cPgVJ/FhH5Tu9IkA2IMuX557W2Y50K7mGgQhAzvNA1s7Q
         wWqVrMrxEqH7/ouO/0/KTzJm5DoKmotecr6ZDZVSYpvnvvHXAki018cukTq6oT85R9s1
         ylwJHOA8a1x0T03lSz9YDdycI4Gy2dKPQXITbseL26rSf0oItWq1y+PT+gj0RZzI1Xzc
         2brw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ekaKdccxVH9Vd+/E5UI//vE0AEA91U4VJzNQTwl8d/E=;
        b=AP5WcpM9TaSILaUcNKLc0hDZzcK+BvxqKv2Avv2D3BtyQ+Li7YX13oSFwil+DsTs4e
         wWgwEdiUUKbF1dOrMeYHGKzcI7orYzGM0GUsp6PJ3lUjYqIYV+39yU13UAzxZdvrqcGV
         Li7A3Qeau2TxClcz0MSU5LrgFnVOUKNS6dyU/scMNTUMoKKHkjsSSisR+qCxrsHOTYEx
         BD3TezQGtoIM6nKiuCSu6wr+8tdlTPWkWsIZlaccvbYZOn3UhQjsPLi7oIiyql37ayCn
         84QfgEpC2mEqQm0FAazbm5C6UXJ3WtTx0nGmoNyGzs18QgTYMjknTLaxSIVVylLlk6xJ
         CXow==
X-Gm-Message-State: APjAAAWGnbe+5ANcSl8UlYVpUMaAhi+mzsguqh7jOPJOtGaf5JHTkaEO
	VHyu0A1hfWOf5dZ7VBGrg6Bn9A==
X-Google-Smtp-Source: APXvYqwwaSAihWvkXLVrmpYscesC91A5cT8+kN1NZAN7lWtU4GZ2OM1L0rSQkXGfKeYYArAeLuF39A==
X-Received: by 2002:a37:6905:: with SMTP id e5mr11456548qkc.121.1566010001248;
        Fri, 16 Aug 2019 19:46:41 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:40 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 07/14] arm64, trans_table: adjust trans_table_create_copy interface
Date: Fri, 16 Aug 2019 22:46:22 -0400
Message-Id: <20190817024629.26611-8-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make trans_table_create_copy inline with the other functions in
trans_table: use the trans_table_info argument, and also use the
trans_table_create_empty.

Note, that the functions that are called by trans_table_create_copy are
not yet adjusted to be compliant with trans_table: they do not yet use
the provided allocator, do not check for generic errors, and do not yet
use the flags in info argument.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_table.h |  7 ++++++-
 arch/arm64/kernel/hibernate.c        | 31 ++++++++++++++++++++++++++--
 arch/arm64/mm/trans_table.c          | 17 ++++++---------
 3 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/arch/arm64/include/asm/trans_table.h b/arch/arm64/include/as=
m/trans_table.h
index 02d3a0333dc9..8c296bd3e10f 100644
--- a/arch/arm64/include/asm/trans_table.h
+++ b/arch/arm64/include/asm/trans_table.h
@@ -44,7 +44,12 @@ struct trans_table_info {
 int trans_table_create_empty(struct trans_table_info *info,
 			     pgd_t **trans_table);
=20
-int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
+/*
+ * Create trans table and copy entries from from_table to trans_table in=
 range
+ * [start, end)
+ */
+int trans_table_create_copy(struct trans_table_info *info, pgd_t **trans=
_table,
+			    pgd_t *from_table, unsigned long start,
 			    unsigned long end);
=20
 /*
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 3a7b362e5a58..6fbaff769c1d 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -323,15 +323,42 @@ int swsusp_arch_resume(void)
 	phys_addr_t phys_hibernate_exit;
 	void __noreturn (*hibernate_exit)(phys_addr_t, phys_addr_t, void *,
 					  void *, phys_addr_t, phys_addr_t);
+	struct trans_table_info trans_info =3D {
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
-	rc =3D trans_table_create_copy(&tmp_pg_dir, PAGE_OFFSET, 0);
-	if (rc)
+	rc =3D trans_table_create_copy(&trans_info, &tmp_pg_dir, init_mm.pgd,
+				     PAGE_OFFSET, 0);
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
diff --git a/arch/arm64/mm/trans_table.c b/arch/arm64/mm/trans_table.c
index 6deb35f83118..634293ffb54c 100644
--- a/arch/arm64/mm/trans_table.c
+++ b/arch/arm64/mm/trans_table.c
@@ -176,22 +176,17 @@ int trans_table_create_empty(struct trans_table_inf=
o *info, pgd_t **trans_table)
 	return 0;
 }
=20
-int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
+int trans_table_create_copy(struct trans_table_info *info, pgd_t **trans=
_table,
+			    pgd_t *from_table, unsigned long start,
 			    unsigned long end)
 {
 	int rc;
-	pgd_t *trans_table =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
=20
-	if (!trans_table) {
-		pr_err("Failed to allocate memory for temporary page tables.\n");
-		return -ENOMEM;
-	}
-
-	rc =3D copy_page_tables(trans_table, start, end);
-	if (!rc)
-		*dst_pgdp =3D trans_table;
+	rc =3D trans_table_create_empty(info, trans_table);
+	if (rc)
+		return rc;
=20
-	return rc;
+	return copy_page_tables(*trans_table, start, end);
 }
=20
 int trans_table_map_page(struct trans_table_info *info, pgd_t *trans_tab=
le,
--=20
2.22.1


