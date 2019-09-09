Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30CEBC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA167218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="b4JWeuEq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA167218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29E0D6B026A; Mon,  9 Sep 2019 14:12:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DC456B026B; Mon,  9 Sep 2019 14:12:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07CC86B026C; Mon,  9 Sep 2019 14:12:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0181.hostedemail.com [216.40.44.181])
	by kanga.kvack.org (Postfix) with ESMTP id D75BA6B026A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:41 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 88ECE180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:41 +0000 (UTC)
X-FDA: 75916177722.02.lamp64_6ebcf0e964a3d
X-HE-Tag: lamp64_6ebcf0e964a3d
X-Filterd-Recvd-Size: 9443
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:40 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id j10so17240383qtp.8
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2LohODRye0AXb6pFFAov36EHdB22I7TfTyru75JBhPY=;
        b=b4JWeuEqNHu1nxwYKfDEsBPTvMMBWZi2cqM0adTfZFS4l+t2aJ3B29NCi9xuB49OSa
         C77Y9e1TYrSKEeJmNf39D7K4bVy/4ZNWPvYi4dam1Nwsr0JFlQrwCLlmTVBcNdq5YV+8
         MrgKWmXLLtlYEqTc93GG36FcY0hdxv863oZlRKWBhnek6e0iEXX8ItgAmzFG37ddwOGk
         Amv6GRDOMInAjA3xefoEOGpOL9a8kveoC8s0a5ApLBvvouNSdofiM0Qs0ltzEq6V/nEi
         zarysFCuCJY5uzMpcTTKAdeRqmX51hU5bkn5vuS7qY/SeLhaIpVhrZlj3rOjk+qTrY+j
         iZpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=2LohODRye0AXb6pFFAov36EHdB22I7TfTyru75JBhPY=;
        b=s14CE8kWovTvK3Ul9hz/YF3BY9A+mn4QiljlsxkfgDnvuUGudafJpDUIhymEGVJCgY
         +NTwgvn+WdlQSKGy3LkMHsVX/oxrdORkFsvThsqBNTI6R3mUKxXer0ZSYS7iur5RbJrj
         M3ywUuSpSXXmSmNcpvWqzbLLLQLC+Xd5lXUGk+iCSwDYoWpEkp5VYKZXyFBmgbHVUnXh
         oFiY/1qAe32GUZqgJpUraEVolL2vpZXcqacatv6Phf3trADa9ZSeIFiOrYm/4hVh6iHT
         nmA1m+nLkMQ4LrNgWuXOdCsoUKjBjiju1A7QUjmIYvkCl7FYrA0oxjKwk9efAj1YODyP
         RsuQ==
X-Gm-Message-State: APjAAAUs46tPhC8Swq5KB19fc1TfdSP6TZcbsIuy2d5VQMjujrgaO/ke
	r+tIgIQu4X+PFa+Xs+bJ89jlnQ==
X-Google-Smtp-Source: APXvYqwZbXP54u+gMB+FnMTzfwcMtvxaxlwtPafub/S1cyQjKXudNEOHdzHtrwsLKwZy4rWiD0HpCg==
X-Received: by 2002:a0c:e64e:: with SMTP id c14mr15416016qvn.17.1568052760215;
        Mon, 09 Sep 2019 11:12:40 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:39 -0700 (PDT)
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
Subject: [PATCH v4 11/17] arm64: trans_pgd: pass allocator trans_pgd_create_copy
Date: Mon,  9 Sep 2019 14:12:15 -0400
Message-Id: <20190909181221.309510-12-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909181221.309510-1-pasha.tatashin@soleen.com>
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make trans_pgd_create_copy and its subroutines to use allocator that is
passed as an argument

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_pgd.h |  7 ++++--
 arch/arm64/kernel/hibernate.c      |  6 ++++-
 arch/arm64/mm/trans_pgd.c          | 35 +++++++++++++++---------------
 3 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/arch/arm64/include/asm/trans_pgd.h b/arch/arm64/include/asm/=
trans_pgd.h
index 53f67ec84cdc..61a725fe1093 100644
--- a/arch/arm64/include/asm/trans_pgd.h
+++ b/arch/arm64/include/asm/trans_pgd.h
@@ -25,8 +25,11 @@ struct trans_pgd_info {
 	void *trans_alloc_arg;
 };
=20
-int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
-			  unsigned long end);
+/*
+ * Create trans_pgd and copy linear map [start, end)
+ */
+int trans_pgd_create_copy(struct trans_pgd_info *info, pgd_t **trans_pgd=
,
+			  unsigned long start, unsigned long end);
=20
 /*
  * Add map entry to trans_pgd for a base-size page at PTE level.
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 9b75b680ab70..36eccf63629c 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -322,13 +322,17 @@ int swsusp_arch_resume(void)
 	phys_addr_t phys_hibernate_exit;
 	void __noreturn (*hibernate_exit)(phys_addr_t, phys_addr_t, void *,
 					  void *, phys_addr_t, phys_addr_t);
+	struct trans_pgd_info trans_info =3D {
+		.trans_alloc_page	=3D hibernate_page_alloc,
+		.trans_alloc_arg	=3D (void *)GFP_ATOMIC,
+	};
=20
 	/*
 	 * Restoring the memory image will overwrite the ttbr1 page tables.
 	 * Create a second copy of just the linear map, and use this when
 	 * restoring.
 	 */
-	rc =3D trans_pgd_create_copy(&tmp_pg_dir, PAGE_OFFSET, 0);
+	rc =3D trans_pgd_create_copy(&trans_info, &tmp_pg_dir, PAGE_OFFSET, 0);
 	if (rc)
 		goto out;
=20
diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
index 7521d558a0b9..dfde87159840 100644
--- a/arch/arm64/mm/trans_pgd.c
+++ b/arch/arm64/mm/trans_pgd.c
@@ -57,14 +57,14 @@ static void _copy_pte(pte_t *dst_ptep, pte_t *src_pte=
p, unsigned long addr)
 	}
 }
=20
-static int copy_pte(pmd_t *dst_pmdp, pmd_t *src_pmdp, unsigned long star=
t,
-		    unsigned long end)
+static int copy_pte(struct trans_pgd_info *info, pmd_t *dst_pmdp,
+		    pmd_t *src_pmdp, unsigned long start, unsigned long end)
 {
 	pte_t *src_ptep;
 	pte_t *dst_ptep;
 	unsigned long addr =3D start;
=20
-	dst_ptep =3D (pte_t *)get_safe_page(GFP_ATOMIC);
+	dst_ptep =3D trans_alloc(info);
 	if (!dst_ptep)
 		return -ENOMEM;
 	pmd_populate_kernel(&init_mm, dst_pmdp, dst_ptep);
@@ -78,8 +78,8 @@ static int copy_pte(pmd_t *dst_pmdp, pmd_t *src_pmdp, u=
nsigned long start,
 	return 0;
 }
=20
-static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp, unsigned long star=
t,
-		    unsigned long end)
+static int copy_pmd(struct trans_pgd_info *info, pud_t *dst_pudp,
+		    pud_t *src_pudp, unsigned long start, unsigned long end)
 {
 	pmd_t *src_pmdp;
 	pmd_t *dst_pmdp;
@@ -87,7 +87,7 @@ static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp, u=
nsigned long start,
 	unsigned long addr =3D start;
=20
 	if (pud_none(READ_ONCE(*dst_pudp))) {
-		dst_pmdp =3D (pmd_t *)get_safe_page(GFP_ATOMIC);
+		dst_pmdp =3D trans_alloc(info);
 		if (!dst_pmdp)
 			return -ENOMEM;
 		pud_populate(&init_mm, dst_pudp, dst_pmdp);
@@ -102,7 +102,7 @@ static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp,=
 unsigned long start,
 		if (pmd_none(pmd))
 			continue;
 		if (pmd_table(pmd)) {
-			if (copy_pte(dst_pmdp, src_pmdp, addr, next))
+			if (copy_pte(info, dst_pmdp, src_pmdp, addr, next))
 				return -ENOMEM;
 		} else {
 			set_pmd(dst_pmdp,
@@ -113,7 +113,8 @@ static int copy_pmd(pud_t *dst_pudp, pud_t *src_pudp,=
 unsigned long start,
 	return 0;
 }
=20
-static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp, unsigned long star=
t,
+static int copy_pud(struct trans_pgd_info *info, pgd_t *dst_pgdp,
+		    pgd_t *src_pgdp, unsigned long start,
 		    unsigned long end)
 {
 	pud_t *dst_pudp;
@@ -122,7 +123,7 @@ static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp,=
 unsigned long start,
 	unsigned long addr =3D start;
=20
 	if (pgd_none(READ_ONCE(*dst_pgdp))) {
-		dst_pudp =3D (pud_t *)get_safe_page(GFP_ATOMIC);
+		dst_pudp =3D trans_alloc(info);
 		if (!dst_pudp)
 			return -ENOMEM;
 		pgd_populate(&init_mm, dst_pgdp, dst_pudp);
@@ -137,7 +138,7 @@ static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp,=
 unsigned long start,
 		if (pud_none(pud))
 			continue;
 		if (pud_table(pud)) {
-			if (copy_pmd(dst_pudp, src_pudp, addr, next))
+			if (copy_pmd(info, dst_pudp, src_pudp, addr, next))
 				return -ENOMEM;
 		} else {
 			set_pud(dst_pudp,
@@ -148,8 +149,8 @@ static int copy_pud(pgd_t *dst_pgdp, pgd_t *src_pgdp,=
 unsigned long start,
 	return 0;
 }
=20
-static int copy_page_tables(pgd_t *dst_pgdp, unsigned long start,
-			    unsigned long end)
+static int copy_page_tables(struct trans_pgd_info *info, pgd_t *dst_pgdp=
,
+			    unsigned long start, unsigned long end)
 {
 	unsigned long next;
 	unsigned long addr =3D start;
@@ -160,25 +161,25 @@ static int copy_page_tables(pgd_t *dst_pgdp, unsign=
ed long start,
 		next =3D pgd_addr_end(addr, end);
 		if (pgd_none(READ_ONCE(*src_pgdp)))
 			continue;
-		if (copy_pud(dst_pgdp, src_pgdp, addr, next))
+		if (copy_pud(info, dst_pgdp, src_pgdp, addr, next))
 			return -ENOMEM;
 	} while (dst_pgdp++, src_pgdp++, addr =3D next, addr !=3D end);
=20
 	return 0;
 }
=20
-int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
-			  unsigned long end)
+int trans_pgd_create_copy(struct trans_pgd_info *info, pgd_t **dst_pgdp,
+			  unsigned long start, unsigned long end)
 {
 	int rc;
-	pgd_t *trans_pgd =3D (pgd_t *)get_safe_page(GFP_ATOMIC);
+	pgd_t *trans_pgd =3D trans_alloc(info);
=20
 	if (!trans_pgd) {
 		pr_err("Failed to allocate memory for temporary page tables.\n");
 		return -ENOMEM;
 	}
=20
-	rc =3D copy_page_tables(trans_pgd, start, end);
+	rc =3D copy_page_tables(info, trans_pgd, start, end);
 	if (!rc)
 		*dst_pgdp =3D trans_pgd;
=20
--=20
2.23.0


