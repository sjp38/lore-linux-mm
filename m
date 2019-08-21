Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4511DC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED793216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="J7ncVAC/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED793216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5FA76B0270; Wed, 21 Aug 2019 14:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C11946B0271; Wed, 21 Aug 2019 14:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB4C66B0272; Wed, 21 Aug 2019 14:32:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 828266B0270
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:20 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 376DB55FB5
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:20 +0000 (UTC)
X-FDA: 75847280040.21.pets05_3175927e95263
X-HE-Tag: pets05_3175927e95263
X-Filterd-Recvd-Size: 5484
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:19 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id 201so2707226qkm.9
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=p2ZmPVW3GUksitLyy9jJ27m49TkI76nwQzxdL+NJyyg=;
        b=J7ncVAC/Ks/EVDWP1J6BghzJOVmI27MTR8joZZ9iGqN0eTRjFtj/eaN0Or61tK1y/4
         cpAOw5K8hLE3U5xetVDyi5wH1tGqXtzvQig9a2h9kkbrHAtcKIGjwURANE/QY+b8pvou
         enG2wH3J21xePJ0Bvbz8TyQP3ccy4TUVnry1I2OhVy+vOCKmvac2ZH+UrNh+P9qPYwT2
         UMFpaqOKsTMyOk2zzKuNIIRuWAHUxsJESpJ5QBAM77U0vMzOpdQFzb17OTpOcKe+muBB
         EB/JFZ9nEpIu9UtWXT3FlFKU7k5VuIWmAx2Ui4GDgJaTUSlEIrYzNQZXiE6ikxkq1vtM
         Hr9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=p2ZmPVW3GUksitLyy9jJ27m49TkI76nwQzxdL+NJyyg=;
        b=oAdyfLV8cWR2rXxPCsfaBI05NOMiXsU6dXJLIwVC7SKnohZggWYcAEmmFuqDbR9pBk
         eiMu1Gmi+XskP0i2C5vHb2FNsoSCmh2f3fF1MT09luMvIkQRAw0gaKgfPaf4i/u5HVYk
         OvyEWa0bpM3EVi+ki1vKQq7/0xK2jJfg5/FBEZDYwpyG3Yi6tvNfsVoZvoJ0psWOQjDb
         ZsZbb3OFvSa/GIK/qpUW6rIWhy/CS/oLcZDnBwKPKlZdQdUsQ/T8aM+pFbvtryKGqmmd
         SVKebmnMf2M1g2GyLk7KbV/pTi08Ff1eSXmFykM40asbqvuoNHbfBZ6oxiKUVGEI4pDZ
         F18g==
X-Gm-Message-State: APjAAAUfdTbN++01aQuxy/uIZyimWIVxZPmkHBPcRSfaQA+phc3w7xUT
	tky1m8pgGtTv8CNZPXNTUxYJsA==
X-Google-Smtp-Source: APXvYqw7OKOPFGZGP2ShGpR47tsdJdXKOSIYQ93+AeAvfCBSHBXQT7Xapz16QlTiFuqHRCuJi7i9nA==
X-Received: by 2002:a37:9c0c:: with SMTP id f12mr33218821qke.442.1566412339244;
        Wed, 21 Aug 2019 11:32:19 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:18 -0700 (PDT)
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
Subject: [PATCH v3 09/17] arm64, trans_pgd: add trans_pgd_create_empty
Date: Wed, 21 Aug 2019 14:31:56 -0400
Message-Id: <20190821183204.23576-10-pasha.tatashin@soleen.com>
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

This functions returns a zeroed trans_pgd using the allocator that is
specified in the info argument.

trans_pgds should be created by using this function.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_pgd.h |  3 +++
 arch/arm64/kernel/hibernate.c      |  6 +++---
 arch/arm64/mm/trans_pgd.c          | 12 ++++++++++++
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/trans_pgd.h b/arch/arm64/include/asm/=
trans_pgd.h
index e3d022b1b526..26e5a63676b5 100644
--- a/arch/arm64/include/asm/trans_pgd.h
+++ b/arch/arm64/include/asm/trans_pgd.h
@@ -40,6 +40,9 @@ struct trans_pgd_info {
 	unsigned long trans_flags;
 };
=20
+/* Create and empty trans_pgd page table */
+int trans_pgd_create_empty(struct trans_pgd_info *info, pgd_t **trans_pg=
d);
+
 int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
 			  unsigned long end);
=20
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 17426dc8cb54..8c2641a9bb09 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -216,9 +216,9 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	memcpy(page, src_start, length);
 	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
=20
-	trans_pgd =3D (void *)get_safe_page(GFP_ATOMIC);
-	if (!trans_pgd)
-		return -ENOMEM;
+	rc =3D trans_pgd_create_empty(&trans_info, &trans_pgd);
+	if (rc)
+		return rc;
=20
 	rc =3D trans_pgd_map_page(&trans_info, trans_pgd, page, dst_addr,
 				PAGE_KERNEL_EXEC);
diff --git a/arch/arm64/mm/trans_pgd.c b/arch/arm64/mm/trans_pgd.c
index dbabccd78cc4..ece797aa1841 100644
--- a/arch/arm64/mm/trans_pgd.c
+++ b/arch/arm64/mm/trans_pgd.c
@@ -164,6 +164,18 @@ static int copy_page_tables(pgd_t *dst_pgdp, unsigne=
d long start,
 	return 0;
 }
=20
+int trans_pgd_create_empty(struct trans_pgd_info *info, pgd_t **trans_pg=
d)
+{
+	pgd_t *dst_pgdp =3D trans_alloc(info);
+
+	if (!dst_pgdp)
+		return -ENOMEM;
+
+	*trans_pgd =3D dst_pgdp;
+
+	return 0;
+}
+
 int trans_pgd_create_copy(pgd_t **dst_pgdp, unsigned long start,
 			  unsigned long end)
 {
--=20
2.23.0


