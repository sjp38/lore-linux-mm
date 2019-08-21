Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 993DAC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C314216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="F5/vglG3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C314216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 311126B0269; Wed, 21 Aug 2019 14:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 272466B026B; Wed, 21 Aug 2019 14:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13C7B6B026C; Wed, 21 Aug 2019 14:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id CEFE96B0269
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:14 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7E7EF8248AC7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:14 +0000 (UTC)
X-FDA: 75847279788.27.milk07_3097948e7c95c
X-HE-Tag: milk07_3097948e7c95c
X-Filterd-Recvd-Size: 5114
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:13 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id m2so2696914qki.12
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Wh9WjFIAkHLcLqaIxEdJCbYPtfUD1HKjJMfvVa6suJE=;
        b=F5/vglG3qyPmeB0JD/AkU7IGnC36OiRKuIbJpU/5z6Qd1GRGZOhFlF4y4Lh2ICo5Fx
         vtQOuW3utAdvtWyr18dzkIZCDVqXJao9VeZUSFJutBJ77JmxNiuLaWJh03JuWREaAQHG
         FUxoecx1zcaDw4ixSBLROQIVxLWli/e9CqYQ6KV/GQnqhUgExJN7sHGLijzlXW3+8H9p
         T1Fy4UosgCEWylhQulEZ68Ue/TEGUq5aaC9Fuso7GsR0u+2KN1F6WA5iq9CXrtN1hbws
         KCspb69kFM10WTEkPeGAYxLiYN2U8KBR4h/dfkNn5EtUCntDKVOFUooIGbuk8QCbibaC
         VDUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Wh9WjFIAkHLcLqaIxEdJCbYPtfUD1HKjJMfvVa6suJE=;
        b=GBC1qLBtPCr2AFHT1M3DX3BFNmy9nQrny+lS7hJUzUdb3bO7A5OTWqJxc85LjyaF5W
         MuqsUkOcBZ0P/v6H/f4oP+8b8ilnSJCbAjmc4BigNlTLKrcDILdPnKOO5rkiz5/H/vkk
         c0kY/3pIUvh0eYAWVZW0I7BZGHN8aKMC+/vjm1Kdq1jc1SboH4/dG6hfDgCUJ39gJL2D
         x6rDWu/P/7LDqn3j+TGZbOPlqzefyIpYIlIx/rzhyFkmyDNNXKZnHlTFeEumAAnw6Bcp
         SCpZA+HG0nfOkxyF29Qz3Dl9MtitTfde+tu7T20bCZVTZfRIrdm/G20pr3Z6a82ufuxg
         sX1Q==
X-Gm-Message-State: APjAAAU4MY9MB6gltNruT2MMkhv+3FECQBiyiuwDky24qQJrooThFWFs
	43KN3kjNgWJYpV1MdaATQrcXlQ==
X-Google-Smtp-Source: APXvYqzVNLy+zlNZt58NDFTFB1VkACqlq5vozOSGre9tQf+0u5mRcMmJRu7ZCEw94OQindIwKWGR9A==
X-Received: by 2002:ae9:eb87:: with SMTP id b129mr31494076qkg.453.1566412333290;
        Wed, 21 Aug 2019 11:32:13 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:12 -0700 (PDT)
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
Subject: [PATCH v3 05/17] arm64, hibernate: check pgd table allocation
Date: Wed, 21 Aug 2019 14:31:52 -0400
Message-Id: <20190821183204.23576-6-pasha.tatashin@soleen.com>
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

There is a bug in create_safe_exec_page(), when page table is allocated
it is not checked that table is allocated successfully:

But it is dereferenced in: pgd_none(READ_ONCE(*pgdp)).

Another issue, is that phys_to_ttbr() uses an offset in page table instea=
d
of pgd directly.

So, allocate page table, check that allocation was successful, and use it
directly to set ttbr0_el1.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index ee34a06d8a35..750ecc7f2cbe 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -199,6 +199,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 				 phys_addr_t *phys_dst_addr)
 {
 	void *page =3D (void *)get_safe_page(GFP_ATOMIC);
+	pgd_t *trans_pgd;
 	pgd_t *pgdp;
 	pud_t *pudp;
 	pmd_t *pmdp;
@@ -210,7 +211,11 @@ static int create_safe_exec_page(void *src_start, si=
ze_t length,
 	memcpy(page, src_start, length);
 	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
=20
-	pgdp =3D pgd_offset_raw((void *)get_safe_page(GFP_ATOMIC), dst_addr);
+	trans_pgd =3D (void *)get_safe_page(GFP_ATOMIC);
+	if (!trans_pgd)
+		return -ENOMEM;
+
+	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
 		pudp =3D (void *)get_safe_page(GFP_ATOMIC);
 		if (!pudp)
@@ -251,7 +256,7 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	 */
 	cpu_set_reserved_ttbr0();
 	local_flush_tlb_all();
-	write_sysreg(phys_to_ttbr(virt_to_phys(pgdp)), ttbr0_el1);
+	write_sysreg(phys_to_ttbr(virt_to_phys(trans_pgd)), ttbr0_el1);
 	isb();
=20
 	*phys_dst_addr =3D virt_to_phys(page);
--=20
2.23.0


