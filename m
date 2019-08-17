Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5E1C3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54A6E21019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="oXQfO2Fq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54A6E21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DE816B026F; Fri, 16 Aug 2019 22:46:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 466AD6B0270; Fri, 16 Aug 2019 22:46:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 155F26B0271; Fri, 16 Aug 2019 22:46:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id E3E0D6B026F
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:39 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8CCE78248ADA
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:39 +0000 (UTC)
X-FDA: 75830381718.08.sheep67_9162601e8a234
X-HE-Tag: sheep67_9162601e8a234
X-Filterd-Recvd-Size: 10100
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:38 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id j15so8155138qtl.13
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8WbcRUtcHS2GIYxAvuez1hxS2GbdOM3ZjGBgXllqxc8=;
        b=oXQfO2Fq0+QO8q1nxDXVLE8A340S8v0eM8eMEpfD8VCqrlolgOHZ/Jl4EOXvD1hBmN
         qUvUvJtldvU6AW3L+EyqAm5Fe/+a5+pIPehabKcS8bDJegz8Wnr8Zot1F8UHt5Sx9H0s
         oh904Zd6R9xJUn3e+uu59HVjR1rYCil+ohry7eNsDwnQ7TgpvGc+7ZAohfziUL/xB5Uf
         QigCZp1KU9V+ek+gKpoFh+7Y8AzwUZ3SvyQFDN/z9HvDer6uVe3fJhNIh7ndo41vaccT
         KCx+SSUXT0FW47qAr2agJ3tfNSttmXEfsU+J2R7GnC8Qe5qf2OT7EKa/vamIoTeHGcAI
         moAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=8WbcRUtcHS2GIYxAvuez1hxS2GbdOM3ZjGBgXllqxc8=;
        b=HtIqyz6o7sVe2Qs5fnLzhIjXLpRJaCdlGqH1PAD1EmP8wEsgv9CnmGaIKh1METbuU6
         +NxRXuO7zt+svhh7n11LXOWdG8i0cpNFQICfLEv9nQTI6FwDv0cENaGHGHQP/Cr2sDiF
         KEjp2NMQm13hodMW/MFXQ+WkRm+Qta+6u/eSqWrGrpiXpSrSNPxCGljZYgP3OAcHw7FT
         +jk0bHjyQBT0qNXVy8tNlXLNZMD4QCEK3345nuxD0Ns/bLP4K+K6P99T0cAqREeIptqS
         DYxaGebB5QcE4r7vjaUjKhtcYQUhhhmEv79UKO5GNlLgFgYSgMR+akIX9dfjd+FSm5Sw
         ZmJA==
X-Gm-Message-State: APjAAAUFyWiSV4B+PGVFdIQ2n9tJ2prE2ZyNBLWnqVaKXkfOMHq3TSxi
	jVo3V1dIGh8un31VxzbrQ8QcnQ==
X-Google-Smtp-Source: APXvYqzw8XVlfyeSlginpUsJyP3V5lwU2lsl83ETWErVpn1VDaT1lh+VZAzw47gT8aBurcy+cJ6XLg==
X-Received: by 2002:ac8:128c:: with SMTP id y12mr11453271qti.242.1566009998439;
        Fri, 16 Aug 2019 19:46:38 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:37 -0700 (PDT)
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
Subject: [PATCH v2 05/14] arm64, trans_table: make trans_table_map_page generic
Date: Fri, 16 Aug 2019 22:46:20 -0400
Message-Id: <20190817024629.26611-6-pasha.tatashin@soleen.com>
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

Currently, trans_table_map_page has assumptions that are relevant to
hibernate. But, to make it generic we must allow it to use any allocator
and also, can't assume that entries do not exist in the page table
already. Also, we can't use init_mm here.

Also, add "flags" for trans_table_info, they are going to be used
in copy functions once they are generalized.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_table.h | 40 +++++++++++++-
 arch/arm64/kernel/hibernate.c        | 13 ++++-
 arch/arm64/mm/trans_table.c          | 83 +++++++++++++++++++---------
 3 files changed, 107 insertions(+), 29 deletions(-)

diff --git a/arch/arm64/include/asm/trans_table.h b/arch/arm64/include/as=
m/trans_table.h
index f57b2ab2a0b8..1a57af09ded5 100644
--- a/arch/arm64/include/asm/trans_table.h
+++ b/arch/arm64/include/asm/trans_table.h
@@ -11,11 +11,45 @@
 #include <linux/bits.h>
 #include <asm/pgtable-types.h>
=20
+/*
+ * trans_alloc_page
+ *	- Allocator that should return exactly one uninitilaized page, if thi=
s
+ *	 allocator fails, trans_table returns -ENOMEM error.
+ *
+ * trans_alloc_arg
+ *	- Passed to trans_alloc_page as an argument
+ *
+ * trans_flags
+ *	- bitmap with flags that control how page table is filled.
+ *	  TRANS_MKWRITE: during page table copy make PTE, PME, and PUD page
+ *			 writeable by removing RDONLY flag from PTE.
+ *	  TRANS_MKVALID: during page table copy, if PTE present, but not vali=
d,
+ *			 make it valid.
+ *	  TRANS_CHECKPFN: During page table copy, for every PTE entry check t=
hat
+ *			  PFN that this PTE points to is valid. Otherwise return
+ *			  -ENXIO
+ */
+
+#define	TRANS_MKWRITE	BIT(0)
+#define	TRANS_MKVALID	BIT(1)
+#define	TRANS_CHECKPFN	BIT(2)
+
+struct trans_table_info {
+	void * (*trans_alloc_page)(void *arg);
+	void *trans_alloc_arg;
+	unsigned long trans_flags;
+};
+
 int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
 			    unsigned long end);
=20
-int trans_table_map_page(pgd_t *trans_table, void *page,
-			 unsigned long dst_addr,
-			 pgprot_t pgprot);
+/*
+ * Add map entry to trans_table for a base-size page at PTE level.
+ * page:	page to be mapped.
+ * dst_addr:	new VA address for the pages
+ * pgprot:	protection for the page.
+ */
+int trans_table_map_page(struct trans_table_info *info, pgd_t *trans_tab=
le,
+			 void *page, unsigned long dst_addr, pgprot_t pgprot);
=20
 #endif /* _ASM_TRANS_TABLE_H */
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 0cb858b3f503..524b68ec3233 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -179,6 +179,12 @@ int arch_hibernation_header_restore(void *addr)
 }
 EXPORT_SYMBOL(arch_hibernation_header_restore);
=20
+static void *
+hibernate_page_alloc(void *arg)
+{
+	return (void *)get_safe_page((gfp_t)(unsigned long)arg);
+}
+
 /*
  * Copies length bytes, starting at src_start into an new page,
  * perform cache maintentance, then maps it at the specified address low
@@ -195,6 +201,11 @@ static int create_safe_exec_page(void *src_start, si=
ze_t length,
 				 unsigned long dst_addr,
 				 phys_addr_t *phys_dst_addr)
 {
+	struct trans_table_info trans_info =3D {
+		.trans_alloc_page	=3D hibernate_page_alloc,
+		.trans_alloc_arg	=3D (void *)GFP_ATOMIC,
+		.trans_flags		=3D 0,
+	};
 	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
 	pgd_t *trans_table;
 	int rc;
@@ -209,7 +220,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	if (!trans_table)
 		return -ENOMEM;
=20
-	rc =3D trans_table_map_page(trans_table, page, dst_addr,
+	rc =3D trans_table_map_page(&trans_info, trans_table, page, dst_addr,
 				  PAGE_KERNEL_EXEC);
 	if (rc)
 		return rc;
diff --git a/arch/arm64/mm/trans_table.c b/arch/arm64/mm/trans_table.c
index b4bbb559d9cf..12f4b3cab6d6 100644
--- a/arch/arm64/mm/trans_table.c
+++ b/arch/arm64/mm/trans_table.c
@@ -17,6 +17,16 @@
 #include <asm/pgtable.h>
 #include <linux/suspend.h>
=20
+static void *trans_alloc(struct trans_table_info *info)
+{
+	void *page =3D info->trans_alloc_page(info->trans_alloc_arg);
+
+	if (page)
+		clear_page(page);
+
+	return page;
+}
+
 static void _copy_pte(pte_t *dst_ptep, pte_t *src_ptep, unsigned long ad=
dr)
 {
 	pte_t pte =3D READ_ONCE(*src_ptep);
@@ -172,41 +182,64 @@ int trans_table_create_copy(pgd_t **dst_pgdp, unsig=
ned long start,
 	return rc;
 }
=20
-int trans_table_map_page(pgd_t *trans_table, void *page,
-			 unsigned long dst_addr,
-			 pgprot_t pgprot)
+int trans_table_map_page(struct trans_table_info *info, pgd_t *trans_tab=
le,
+			 void *page, unsigned long dst_addr, pgprot_t pgprot)
 {
-	pgd_t *pgdp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t *ptep;
-
-	pgdp =3D pgd_offset_raw(trans_table, dst_addr);
-	if (pgd_none(READ_ONCE(*pgdp))) {
-		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!pudp)
+	int pgd_idx =3D pgd_index(dst_addr);
+	int pud_idx =3D pud_index(dst_addr);
+	int pmd_idx =3D pmd_index(dst_addr);
+	int pte_idx =3D pte_index(dst_addr);
+	pgd_t *pgdp =3D trans_table;
+	pgd_t pgd =3D READ_ONCE(pgdp[pgd_idx]);
+	pud_t *pudp, pud;
+	pmd_t *pmdp, pmd;
+	pte_t *ptep, pte;
+
+	if (pgd_none(pgd)) {
+		pud_t *t =3D trans_alloc(info);
+
+		if (!t)
 			return -ENOMEM;
-		pgd_populate(&init_mm, pgdp, pudp);
+
+		__pgd_populate(&pgdp[pgd_idx], __pa(t), PUD_TYPE_TABLE);
+		pgd =3D READ_ONCE(pgdp[pgd_idx]);
 	}
=20
-	pudp =3D pud_offset(pgdp, dst_addr);
-	if (pud_none(READ_ONCE(*pudp))) {
-		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!pmdp)
+	pudp =3D __va(pgd_page_paddr(pgd));
+	pud =3D READ_ONCE(pudp[pud_idx]);
+	if (pud_sect(pud)) {
+		return -ENXIO;
+	} else if (pud_none(pud) || pud_sect(pud)) {
+		pmd_t *t =3D trans_alloc(info);
+
+		if (!t)
 			return -ENOMEM;
-		pud_populate(&init_mm, pudp, pmdp);
+
+		__pud_populate(&pudp[pud_idx], __pa(t), PMD_TYPE_TABLE);
+		pud =3D READ_ONCE(pudp[pud_idx]);
 	}
=20
-	pmdp =3D pmd_offset(pudp, dst_addr);
-	if (pmd_none(READ_ONCE(*pmdp))) {
-		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!ptep)
+	pmdp =3D __va(pud_page_paddr(pud));
+	pmd =3D READ_ONCE(pmdp[pmd_idx]);
+	if (pmd_sect(pmd)) {
+		return -ENXIO;
+	} else if (pmd_none(pmd) || pmd_sect(pmd)) {
+		pte_t *t =3D trans_alloc(info);
+
+		if (!t)
 			return -ENOMEM;
-		pmd_populate_kernel(&init_mm, pmdp, ptep);
+
+		__pmd_populate(&pmdp[pmd_idx], __pa(t), PTE_TYPE_PAGE);
+		pmd =3D READ_ONCE(pmdp[pmd_idx]);
 	}
=20
-	ptep =3D pte_offset_kernel(pmdp, dst_addr);
-	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
+	ptep =3D __va(pmd_page_paddr(pmd));
+	pte =3D READ_ONCE(ptep[pte_idx]);
+
+	if (!pte_none(pte))
+		return -ENXIO;
+
+	set_pte(&ptep[pte_idx], pfn_pte(virt_to_pfn(page), pgprot));
=20
 	return 0;
 }
--=20
2.22.1


