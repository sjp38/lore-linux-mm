Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E7E7C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D61B21924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="UthcQ8kO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D61B21924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38CA86B000C; Mon,  9 Sep 2019 14:12:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2052C6B000D; Mon,  9 Sep 2019 14:12:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0097E6B000E; Mon,  9 Sep 2019 14:12:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id CF9006B000C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:32 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5184545C1
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:32 +0000 (UTC)
X-FDA: 75916177344.16.boy71_6d67a4ddbcf3f
X-HE-Tag: boy71_6d67a4ddbcf3f
X-Filterd-Recvd-Size: 5666
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:31 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id c9so17255985qth.9
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Zyn9vu/MXqap+nTmKUuDMqr9t65lKRkBEWPsGRxQJWw=;
        b=UthcQ8kO9S9FCLunJhnz0p5vTTeqpswrs8HKI3djcyn4qVoYH5c1zslsQ8icQsNuPw
         lTHINs8zJxAuS3r7gWwVequPv79z7btg4C4cIvo/Bvv7pMUfe3fuVe+bUmep95QO26L2
         BI+gHcf2ROIyYWP16vdZ+yqFXHBvGWqGqai0v9yIfE//FjF2txzR9RwNq/Ro6no5KKwV
         SKLynI2BWiFTWDKzVEX3Ev6oQFBlSmwcv6iEYGjrpwCBHaXU8FBvmaYyobFXAihr09Sg
         +JDVKpR/sFM89wtVQck3jZCL1jiTauTsbPzPg+yIyOU05PD6RocOP6Ax0DRQKCCIMsDE
         CEUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Zyn9vu/MXqap+nTmKUuDMqr9t65lKRkBEWPsGRxQJWw=;
        b=VjCc/3o2osWc1LJ5WrRK+GPu8iiH+498KaGnr9OuLw2ntEcx+yfNzZUUBXK4xX4q+h
         wViSLL37vPcZAzxFIFFlUAyucANhMacx3yFNqJRdumo63I6ijBCH7JATEdXCSaLeEiEk
         ImyOfNi1/3mLuixBS/CXm90q47DtJw1mrJ3iejUDKKqNdXDClI1zWnCUMc0efEWsw+ie
         25HkgZ62oYpkVbL8UbQaZwRXwtTlhVyH2YZ+L8wFLj10gYMnNWGH8PhAnmKpvD5FJl5N
         3N2pZsUXZT7WWrRg4wrqMuMtCX4o4HlkT/VwjyV1Fba5m0XEz5oMSdHME+NW9dy2s0bE
         GgKA==
X-Gm-Message-State: APjAAAXbYm7VwseTOVMWwRgseGAC0mBB+8z/IffQ/qPBKH0UtIcctVbm
	O57eH5MJMyX6xruLl7mu6fh/HQ==
X-Google-Smtp-Source: APXvYqxD+/dgh77RiunjjHz4vq1SlUkRHl7ZhEwgGQCd/ojd17d3Y9qj1SZatp7epiPygaYzVXaPxA==
X-Received: by 2002:a05:6214:451:: with SMTP id cc17mr15008123qvb.15.1568052751174;
        Mon, 09 Sep 2019 11:12:31 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:30 -0700 (PDT)
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
Subject: [PATCH v4 05/17] arm64: hibernate: remove gotos in create_safe_exec_page
Date: Mon,  9 Sep 2019 14:12:09 -0400
Message-Id: <20190909181221.309510-6-pasha.tatashin@soleen.com>
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

Usually, gotos are used to handle cleanup after exception, but
in case of create_safe_exec_page there are no clean-ups. So,
simply return the errors directly.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: James Morse <james.morse@arm.com>
---
 arch/arm64/kernel/hibernate.c | 34 +++++++++++-----------------------
 1 file changed, 11 insertions(+), 23 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 47a861e0cb0c..7bbeb33c700d 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -198,7 +198,6 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 				 unsigned long dst_addr,
 				 phys_addr_t *phys_dst_addr)
 {
-	int rc =3D 0;
 	pgd_t *trans_pgd;
 	pgd_t *pgdp;
 	pud_t *pudp;
@@ -206,47 +205,37 @@ static int create_safe_exec_page(void *src_start, s=
ize_t length,
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
=20
 	trans_pgd =3D (void *)get_safe_page(GFP_ATOMIC);
-	if (!trans_pgd) {
-		rc =3D -ENOMEM;
-		goto out;
-	}
+	if (!trans_pgd)
+		return -ENOMEM;
=20
 	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
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
@@ -272,8 +261,7 @@ static int create_safe_exec_page(void *src_start, siz=
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


