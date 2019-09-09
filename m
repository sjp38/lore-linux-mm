Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 962E9C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 604BA21924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="RzzD8B3m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 604BA21924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C5EE6B000D; Mon,  9 Sep 2019 14:12:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FEE16B000E; Mon,  9 Sep 2019 14:12:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C7E16B0010; Mon,  9 Sep 2019 14:12:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0231.hostedemail.com [216.40.44.231])
	by kanga.kvack.org (Postfix) with ESMTP id D6D436B000D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:33 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8B83C45C1
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:33 +0000 (UTC)
X-FDA: 75916177386.08.mice15_6d9bd2a0e4d08
X-HE-Tag: mice15_6d9bd2a0e4d08
X-Filterd-Recvd-Size: 5497
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:33 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id r5so17313568qtd.0
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nvbvJVLr4nkLYl4WcL+kdWRjmAFlh6tLMOt4xIPRheI=;
        b=RzzD8B3mcShO+xNiGkp9aYsaF8e5zs36M3yyRXQYZQsScGZadM3wetxdkkMKDwZhAs
         5GJzlnrTMY4MJPkNtxbp/8WWx+DniOE48TA3hKJcCE6INrqeo1R08BOXvZt5dLSWHWsB
         zOvgEgPACr2i4FOe/q+JTl8q1peE4qF6QCX7UoHhJk9RqfV39j8BwniCkwiq49X91qPP
         UJcdsAaV3a8kcF6lg6PpmHzsZP1kspVO4+RTIrnIljy78YcmyNiwhasJjzN4jnpIhnnz
         /wi4yGG6fcN+WwBP4w09/RJqegG5DBYoT4wMjYrFfF+Xj0OaXW86QPLztqCz4NlUf/SC
         3XGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nvbvJVLr4nkLYl4WcL+kdWRjmAFlh6tLMOt4xIPRheI=;
        b=o9BdzEuYsJptEXbr50NuqFwD+5wx8aDM4r1AJeN1ApQyVw0f/w69UOxDLKKaqPvlBG
         IRXOneY/x36xmXyQQoTXmkt7gop5ZWHEZu2uzfZBQ9r22A/H/ahB17FrG/wLGFbDUYBA
         edm9nIaQafmEI7Eaqm+ZZrgzaQVeXsYVLt8hQEbf2aSIOnamRYYeFvwaU7DdEH4dFBpP
         uJdq3WeUfzKZabl83b2m0b2CJiaR8SoWHehczvHoTCs/0yDrxpUh4b9OiuxjpnEsEuwM
         cRZK0JpFp45W/d1/WZzAcrZfyc1EujTtj/reyd265PcTrynJFYZGUmdbkoptDaBICqHM
         ro3g==
X-Gm-Message-State: APjAAAVdhd7Q9D7nbgQQKvhQVOF/ZLhoWZNah4K9ohgRtMj96sLR4Cet
	6ZndifHvhhw6UNNUB8MI6CdIgQ==
X-Google-Smtp-Source: APXvYqxCUUwIn8Crj99uq610NweqGHwoS2Q66TNJxTfkDd8LzzPyrQkWbGkKYuRh3YqV+VdDq9stmg==
X-Received: by 2002:a0c:fc05:: with SMTP id z5mr8555882qvo.128.1568052752590;
        Mon, 09 Sep 2019 11:12:32 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:32 -0700 (PDT)
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
Subject: [PATCH v4 06/17] arm64: hibernate: rename dst to page in create_safe_exec_page
Date: Mon,  9 Sep 2019 14:12:10 -0400
Message-Id: <20190909181221.309510-7-pasha.tatashin@soleen.com>
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

create_safe_exec_page() allocates a safe page and maps it at a
specific location, also this function returns the physical address
of newly allocated page.

The destination VA, and PA are specified in arguments: dst_addr,
phys_dst_addr

However, within the function it uses "dst" which has unsigned long
type, but is actually a pointers in the current virtual space. This
is confusing to read.

Rename dst to more appropriate page (page that is created), and also
change its time to "void *"

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: James Morse <james.morse@arm.com>
---
 arch/arm64/kernel/hibernate.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 7bbeb33c700d..750ecc7f2cbe 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -198,18 +198,18 @@ static int create_safe_exec_page(void *src_start, s=
ize_t length,
 				 unsigned long dst_addr,
 				 phys_addr_t *phys_dst_addr)
 {
+	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
 	pgd_t *trans_pgd;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
 	pte_t *ptep;
-	unsigned long dst =3D get_safe_page(GFP_ATOMIC);
=20
-	if (!dst)
+	if (!page)
 		return -ENOMEM;
=20
-	memcpy((void *)dst, src_start, length);
-	__flush_icache_range(dst, dst + length);
+	memcpy(page, src_start, length);
+	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
=20
 	trans_pgd =3D (void *)get_safe_page(GFP_ATOMIC);
 	if (!trans_pgd)
@@ -240,7 +240,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	}
=20
 	ptep =3D pte_offset_kernel(pmdp, dst_addr);
-	set_pte(ptep, pfn_pte(virt_to_pfn(dst), PAGE_KERNEL_EXEC));
+	set_pte(ptep, pfn_pte(virt_to_pfn(page), PAGE_KERNEL_EXEC));
=20
 	/*
 	 * Load our new page tables. A strict BBM approach requires that we
@@ -259,7 +259,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	write_sysreg(phys_to_ttbr(virt_to_phys(trans_pgd)), ttbr0_el1);
 	isb();
=20
-	*phys_dst_addr =3D virt_to_phys((void *)dst);
+	*phys_dst_addr =3D virt_to_phys(page);
=20
 	return 0;
 }
--=20
2.23.0


