Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A906BC41514
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C9A32339E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="VGVxsXxZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C9A32339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 536C46B000D; Wed, 21 Aug 2019 14:32:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 498236B0010; Wed, 21 Aug 2019 14:32:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C3F66B0266; Wed, 21 Aug 2019 14:32:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 0273D6B000D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:11 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B03F255FB7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:11 +0000 (UTC)
X-FDA: 75847279662.02.land32_30373b24f7b43
X-HE-Tag: land32_30373b24f7b43
X-Filterd-Recvd-Size: 5472
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:11 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id q4so4284194qtp.1
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eQcqgkViU39lFjlil3M8Svf5iGtzpDKWpUSwhlO3OFw=;
        b=VGVxsXxZVLgXe5xWt0w3J/cqZt4mPm3JCoyIMlx5/qCn3/rV+mpLZawysJ4O+rAw6f
         rcWCltuXomYefOmYS9boAk8MlSKZLFLpez1T2eU5UAOqBtCk+eYnrncQN08lpCSdkGyf
         PIsqybRE87/1zUPakM9BVxyUVwgSzcG8e5BR8hciBGCYtpef1hxwksC/bkTpUh63Nu1z
         r0dkWmNaCt6fZ3R/kbEqGqQMcBBJJlmFx2gVi5g4eCZFia+JeGbvB2BJNqBqglpwB9Jf
         fmNp4wajHEt1++t2qwnHfsKFYrMhCXmXUTxxMoR3CJGBHUqEsKoJ+KSJJuoJouAB+CBk
         jgnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=eQcqgkViU39lFjlil3M8Svf5iGtzpDKWpUSwhlO3OFw=;
        b=qGjzQAO31ny4da07mv79yL7uIOZ7aU+O5VtwwSpvUDzw2NI0woAyfriBrbVH7f0yTf
         MT8JyQUSA6M4+EZKhcnnoGrCLlAs+RXDl/vGhOU70+WS3iw0nexiIDa5BD5k99zrgLiI
         vAaVpnUxz7+HEaT8oCoPOxfRcfJEJvvZA7wbJ3Ivo9x7+lYEHU1WkID/ZhORZ8jmSTkT
         60DEPt3pkYTD111xI3m5OSHI3DKz3Qe7zpPr2NCWmZeM9H6n1TlBipLEADBqpXQZiR7q
         /LJeRazYzN/ADHNX/KsHW0TNH8Ts005X3uXi/1sMHWZ9L+xKgoXCUXCxCfhwrq4ibKFM
         RLEQ==
X-Gm-Message-State: APjAAAU6ZMuYp9UGUTp3vx9odtdvkN66uIMGhOKBTmCWA2RNApVNhDp1
	xRk4CemDseZTak0V2cNFL2NWwg==
X-Google-Smtp-Source: APXvYqyiSUshBCv3Qv8uDRoW17fIP4H2R6mRVwcxyZZdx7O0GxR1GLWG+PqB5n8Xzz5Ldks8Zgr+lA==
X-Received: by 2002:a0c:8910:: with SMTP id 16mr19279920qvp.55.1566412330418;
        Wed, 21 Aug 2019 11:32:10 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:09 -0700 (PDT)
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
Subject: [PATCH v3 03/17] arm64, hibernate: remove gotos in create_safe_exec_page
Date: Wed, 21 Aug 2019 14:31:50 -0400
Message-Id: <20190821183204.23576-4-pasha.tatashin@soleen.com>
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

Usually, gotos are used to handle cleanup after exception, but
in case of create_safe_exec_page there are no clean-ups. So,
simply return the errors directly.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 4bb4d17a6a7c..c8211108ec11 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -198,17 +198,14 @@ static int create_safe_exec_page(void *src_start, s=
ize_t length,
 				 unsigned long dst_addr,
 				 phys_addr_t *phys_dst_addr)
 {
-	int rc =3D 0;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
 	unsigned long dst =3D get_safe_page(GFP_ATOMIC);
=20
-	if (!dst) {
-		rc =3D -ENOMEM;
-		goto out;
-	}
+	if (!dst)
+		return -ENOMEM;
=20
 	memcpy((void *)dst, src_start, length);
 	__flush_icache_range(dst, dst + length);
@@ -216,30 +213,24 @@ static int create_safe_exec_page(void *src_start, s=
ize_t length,
 	pgdp =3D pgd_offset_raw((void *)get_safe_page(GFP_ATOMIC), dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
 		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!pudp) {
-			rc =3D -ENOMEM;
-			goto out;
-		}
+		if (!pudp)
+			return -ENOMEM;
 		pgd_populate(&init_mm, pgdp, pudp);
 	}
=20
 	pudp =3D pud_offset(pgdp, dst_addr);
 	if (pud_none(READ_ONCE(*pudp))) {
 		pmdp =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!pmdp) {
-			rc =3D -ENOMEM;
-			goto out;
-		}
+		if (!pmdp)
+			return -ENOMEM;
 		pud_populate(&init_mm, pudp, pmdp);
 	}
=20
 	pmdp =3D pmd_offset(pudp, dst_addr);
 	if (pmd_none(READ_ONCE(*pmdp))) {
 		ptep =3D (void *)get_safe_page(GFP_ATOMIC);
-		if (!ptep) {
-			rc =3D -ENOMEM;
-			goto out;
-		}
+		if (!ptep)
+			return -ENOMEM;
 		pmd_populate_kernel(&init_mm, pmdp, ptep);
 	}
=20
@@ -265,8 +256,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
=20
 	*phys_dst_addr =3D virt_to_phys((void *)dst);
=20
-out:
-	return rc;
+	return 0;
 }
=20
 #define dcache_clean_range(start, end)	__flush_dcache_area(start, (end -=
 start))
--=20
2.23.0


