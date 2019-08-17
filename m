Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8828BC3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D57A2173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="mBM/N/z8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D57A2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80F356B026D; Fri, 16 Aug 2019 22:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C27F6B026E; Fri, 16 Aug 2019 22:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59D256B026F; Fri, 16 Aug 2019 22:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id 39CC96B026D
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:37 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C1A5C180C2E61
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:36 +0000 (UTC)
X-FDA: 75830381592.29.music49_90f978055774c
X-HE-Tag: music49_90f978055774c
X-Filterd-Recvd-Size: 8014
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:36 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id j15so8155063qtl.13
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fhpOZXqdUBODzNYqQty59G5Ge7iC8PlIDy+5W4I7/qk=;
        b=mBM/N/z8yGTKkYzwBN4o/dCrlkPlU17gfdIIzSulgS6UObI37vB1wBM5E6QzN8Edol
         +ZIF+vG/LQ4sxc0fhJFMx1EUVqlrj1DZKhZOG5CG+2qnASJdJfF++BFPASeRZHsrOQ7l
         5f5Lc2n5wxaoFUY9/BftGTkGUIh93/1fDGukg46wRC7GIydl3rlFzVY7RYr8PU6ldDDJ
         T2/7MEX8je/x6UAz61qYNb9xAA4NihykJGICQtRl9NHdCGBGDJiuoKt5p6G9UGaGsalu
         ARbq1ne4gYamC8J8nKiChRzS3vCLuqR2484D9RiHFr+NU6SCL7isdVmTwg3yDP1oz/ig
         Fbzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=fhpOZXqdUBODzNYqQty59G5Ge7iC8PlIDy+5W4I7/qk=;
        b=EWlkqTJFNqZ13g3flF6DGmN2XXO5Kf+z4dycuSP28bYDAjsr3KUliRLil9DINyRENU
         R0BGZxPwWRUWYy5Mr1gFmPhJevjuDM+jT8pHy0LOj69FDMSuBCHy1GUC7l0yQwjE+aLk
         NETdKL9D/p0tp+IAkIaOXqNjBsoruQH7gAMeESByHyBPmOirZPuVRd3ZDz7+q2g7uE0X
         fik0RyXsHCjoMrn28Rni7AxgKcl5MLs1CXEG2RT13nLlJZKR7+O+GAF8ly8VPjWUX4tu
         ziyuUDubC8Q0ZttdheBXkoIy7W0eFLrWe7sICXBNHjLP3lcDpP/ar7Ya1gYZN+JA+3Er
         DAyw==
X-Gm-Message-State: APjAAAWXc5+Vpf05WzZYsauHsP9EpbzAPvBDm/GrUWCjZ6QEAcBlTE+R
	kAgmNoPai8V08oUftqo3QVB2Vw==
X-Google-Smtp-Source: APXvYqwmnAgW0ugL2Xh/QQG6ta19bkx2PHnTpQKH7KpRdc000K+gJIFau3+/d7lsbnc3Od8y2BFYyw==
X-Received: by 2002:a0c:d251:: with SMTP id o17mr3892714qvh.109.1566009995607;
        Fri, 16 Aug 2019 19:46:35 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:35 -0700 (PDT)
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
Subject: [PATCH v2 03/14] arm64, hibernate: add trans_table public functions
Date: Fri, 16 Aug 2019 22:46:18 -0400
Message-Id: <20190817024629.26611-4-pasha.tatashin@soleen.com>
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

trans_table_create_copy() and trans_table_map_page() are going to be
the basis for public interface of new subsystem that handles page
tables for cases which are between kernels: kexec, and hibernate.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 96 ++++++++++++++++++++++-------------
 1 file changed, 61 insertions(+), 35 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 96b6f8da7e49..449d69b5651c 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -182,39 +182,15 @@ int arch_hibernation_header_restore(void *addr)
 }
 EXPORT_SYMBOL(arch_hibernation_header_restore);
=20
-/*
- * Copies length bytes, starting at src_start into an new page,
- * perform cache maintentance, then maps it at the specified address low
- * address as executable.
- *
- * This is used by hibernate to copy the code it needs to execute when
- * overwriting the kernel text. This function generates a new set of pag=
e
- * tables, which it loads into ttbr0.
- *
- * Length is provided as we probably only want 4K of data, even on a 64K
- * page system.
- */
-static int create_safe_exec_page(void *src_start, size_t length,
-				 unsigned long dst_addr,
-				 phys_addr_t *phys_dst_addr)
+int trans_table_map_page(pgd_t *trans_table, void *page,
+			 unsigned long dst_addr,
+			 pgprot_t pgprot)
 {
-	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
-	pgd_t *trans_table;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
=20
-	if (!page)
-		return -ENOMEM;
-
-	memcpy((void *)page, src_start, length);
-	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
-
-	trans_table =3D (void *)get_safe_page(GFP_ATOMIC);
-	if (!trans_table)
-		return -ENOMEM;
-
 	pgdp =3D pgd_offset_raw(trans_table, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
 		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
@@ -242,6 +218,44 @@ static int create_safe_exec_page(void *src_start, si=
ze_t length,
 	ptep =3D pte_offset_kernel(pmdp, dst_addr);
 	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
=20
+	return 0;
+}
+
+/*
+ * Copies length bytes, starting at src_start into an new page,
+ * perform cache maintentance, then maps it at the specified address low
+ * address as executable.
+ *
+ * This is used by hibernate to copy the code it needs to execute when
+ * overwriting the kernel text. This function generates a new set of pag=
e
+ * tables, which it loads into ttbr0.
+ *
+ * Length is provided as we probably only want 4K of data, even on a 64K
+ * page system.
+ */
+static int create_safe_exec_page(void *src_start, size_t length,
+				 unsigned long dst_addr,
+				 phys_addr_t *phys_dst_addr)
+{
+	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
+	pgd_t *trans_table;
+	int rc;
+
+	if (!page)
+		return -ENOMEM;
+
+	memcpy(page, src_start, length);
+	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
+
+	trans_table =3D (void *)get_safe_page(GFP_ATOMIC);
+	if (!trans_table)
+		return -ENOMEM;
+
+	rc =3D trans_table_map_page(trans_table, page, dst_addr,
+				  PAGE_KERNEL_EXEC);
+	if (rc)
+		return rc;
+
 	/*
 	 * Load our new page tables. A strict BBM approach requires that we
 	 * ensure that TLBs are free of any entries that may overlap with the
@@ -259,7 +273,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	write_sysreg(phys_to_ttbr(virt_to_phys(trans_table)), ttbr0_el1);
 	isb();
=20
-	*phys_dst_addr =3D virt_to_phys((void *)page);
+	*phys_dst_addr =3D virt_to_phys(page);
=20
 	return 0;
 }
@@ -462,6 +476,24 @@ static int copy_page_tables(pgd_t *dst_pgdp, unsigne=
d long start,
 	return 0;
 }
=20
+int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
+			    unsigned long end)
+{
+	int rc;
+	pgd_t *trans_table =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
+
+	if (!trans_table) {
+		pr_err("Failed to allocate memory for temporary page tables.\n");
+		return -ENOMEM;
+	}
+
+	rc =3D copy_page_tables(trans_table, start, end);
+	if (!rc)
+		*dst_pgdp =3D trans_table;
+
+	return rc;
+}
+
 /*
  * Setup then Resume from the hibernate image using swsusp_arch_suspend_=
exit().
  *
@@ -483,13 +515,7 @@ int swsusp_arch_resume(void)
 	 * Create a second copy of just the linear map, and use this when
 	 * restoring.
 	 */
-	tmp_pg_dir =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
-	if (!tmp_pg_dir) {
-		pr_err("Failed to allocate memory for temporary page tables.\n");
-		rc =3D -ENOMEM;
-		goto out;
-	}
-	rc =3D copy_page_tables(tmp_pg_dir, PAGE_OFFSET, 0);
+	rc =3D trans_table_create_copy(&tmp_pg_dir, PAGE_OFFSET, 0);
 	if (rc)
 		goto out;
=20
--=20
2.22.1


