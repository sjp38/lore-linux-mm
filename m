Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B96DEC4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 849EF218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="gEFy66rK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 849EF218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC46E6B026B; Mon,  9 Sep 2019 14:12:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6E46B026C; Mon,  9 Sep 2019 14:12:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B77556B026D; Mon,  9 Sep 2019 14:12:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9F56B026B
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:43 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id ED9E88243762
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:42 +0000 (UTC)
X-FDA: 75916177764.27.pot36_6ef0108e6e027
X-HE-Tag: pot36_6ef0108e6e027
X-Filterd-Recvd-Size: 5686
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:42 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id g4so17288882qtq.7
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VDzqkQgnkwsjeSD2sj+xCRv+aPoQdl7/oAUIodozYzI=;
        b=gEFy66rKgwtrGikuVUBnPyDp5wFXvKrpxJzr2q8Qx3ehi4m93SO+cT8ckPzt3hC8G1
         5wjKdyCc5YIkYVxz+nYq19eoJQ0rdnxqNJnsnOqZZT/PzPbJu2FhQiaHyxcaNdKXnr09
         0jnUs37ghN8KKRCsNZnq1V0ltm+b6H7CnXfXZik/8St/OTcFJqQPRi+/6I9Ra8kgjZTm
         yZfQFlr+97DIgzbJ0FcDnqMXwd4Wdj/tGE00x1RC0STKY6PXXcs1ELvfCOTKQMrVguot
         oy2uD6HEOhYRGdzg2HchRp5NQ8ML3hZbKNCubNsZaCy/bs/6SVxAEVcXq+z3OiC54hub
         B0ew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=VDzqkQgnkwsjeSD2sj+xCRv+aPoQdl7/oAUIodozYzI=;
        b=OC4nVbrMAE5bDy+e7br3FAkVLgrktpQpMkD/S5JfPNXyQDGnoRS1HoKb7483WdurBw
         /ppaLbfKQLEWMsUSoOEDEaCRWA8nETBhyz7iE+iLDaf2B9ySlPA9LThYfkJw/kHI8Qvg
         nuynO6QzawTCDuk1ihPZ2vnh0ZDm6g/wSjkYIEP9A3gqu+pLcOFBlJZhLOnrXG7+6asC
         b7HUYEtExmPvWxhKb98SYhz1CPuCh1hE0Z2G+OT/RCsKdrbLZAW0eRVN1asWC9C+vuY0
         Sndlgo/mm8/7MtpUrq+3CV2QjPxGE38JA8zptvcIGHhGS+vBXDGHu1xEsJxIVZ2oRhcr
         OWGw==
X-Gm-Message-State: APjAAAXH/ZGGeNcO0vXCmOroFxpn8D4jZOBV+HbSJRCkY7jpiW0MsIQ3
	ZK150hUqblbJLy/oSKNYF8O4Zg==
X-Google-Smtp-Source: APXvYqy2DfI9VQoDCC6Va2zmAeWcK9TGmDIi0yl0BgAbKSBK0D91mrY30M5+sJkkAC/vKvqTDaqtSg==
X-Received: by 2002:ad4:4d8e:: with SMTP id cv14mr7524241qvb.49.1568052761763;
        Mon, 09 Sep 2019 11:12:41 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:41 -0700 (PDT)
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
Subject: [PATCH v4 12/17] arm64: trans_pgd: pass NULL instead of init_mm to *_populate functions
Date: Mon,  9 Sep 2019 14:12:16 -0400
Message-Id: <20190909181221.309510-13-pasha.tatashin@soleen.com>
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

trans_pgd_* should be independent from mm context because the tables that
are created by this code are used when there are no mm context around, as
it is between kernels. Simply replace mm_init's with NULL.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/mm/trans_pgd.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
index dfde87159840..e7b8625b3ac3 100644
--- a/arch/arm64/mm/trans_pgd.c
+++ b/arch/arm64/mm/trans_pgd.c
@@ -67,7 +67,7 @@ static int copy_pte(struct trans_pgd_info *info, pmd_t =
*dst_pmdp,
 	dst_ptep =3D trans_alloc(info);
 	if (!dst_ptep)
 		return -ENOMEM;
-	pmd_populate_kernel(&init_mm, dst_pmdp, dst_ptep);
+	pmd_populate_kernel(NULL, dst_pmdp, dst_ptep);
 	dst_ptep =3D pte_offset_kernel(dst_pmdp, start);
=20
 	src_ptep =3D pte_offset_kernel(src_pmdp, start);
@@ -90,7 +90,7 @@ static int copy_pmd(struct trans_pgd_info *info, pud_t =
*dst_pudp,
 		dst_pmdp =3D trans_alloc(info);
 		if (!dst_pmdp)
 			return -ENOMEM;
-		pud_populate(&init_mm, dst_pudp, dst_pmdp);
+		pud_populate(NULL, dst_pudp, dst_pmdp);
 	}
 	dst_pmdp =3D pmd_offset(dst_pudp, start);
=20
@@ -126,7 +126,7 @@ static int copy_pud(struct trans_pgd_info *info, pgd_=
t *dst_pgdp,
 		dst_pudp =3D trans_alloc(info);
 		if (!dst_pudp)
 			return -ENOMEM;
-		pgd_populate(&init_mm, dst_pgdp, dst_pudp);
+		pgd_populate(NULL, dst_pgdp, dst_pudp);
 	}
 	dst_pudp =3D pud_offset(dst_pgdp, start);
=20
@@ -199,7 +199,7 @@ int trans_pgd_map_page(struct trans_pgd_info *info, p=
gd_t *trans_pgd,
 		pudp =3D trans_alloc(info);
 		if (!pudp)
 			return -ENOMEM;
-		pgd_populate(&init_mm, pgdp, pudp);
+		pgd_populate(NULL, pgdp, pudp);
 	}
=20
 	pudp =3D pud_offset(pgdp, dst_addr);
@@ -207,7 +207,7 @@ int trans_pgd_map_page(struct trans_pgd_info *info, p=
gd_t *trans_pgd,
 		pmdp =3D trans_alloc(info);
 		if (!pmdp)
 			return -ENOMEM;
-		pud_populate(&init_mm, pudp, pmdp);
+		pud_populate(NULL, pudp, pmdp);
 	}
=20
 	pmdp =3D pmd_offset(pudp, dst_addr);
@@ -215,7 +215,7 @@ int trans_pgd_map_page(struct trans_pgd_info *info, p=
gd_t *trans_pgd,
 		ptep =3D trans_alloc(info);
 		if (!ptep)
 			return -ENOMEM;
-		pmd_populate_kernel(&init_mm, pmdp, ptep);
+		pmd_populate_kernel(NULL, pmdp, ptep);
 	}
=20
 	ptep =3D pte_offset_kernel(pmdp, dst_addr);
--=20
2.23.0


