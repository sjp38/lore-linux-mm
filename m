Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A66DC3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CA1B2173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Jk5d2DZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CA1B2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A33C16B0270; Fri, 16 Aug 2019 22:46:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91E546B0271; Fri, 16 Aug 2019 22:46:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BF9E6B0272; Fri, 16 Aug 2019 22:46:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id 57E706B0270
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:41 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EC9608248ADA
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:40 +0000 (UTC)
X-FDA: 75830381760.25.quilt29_13f1fdef314
X-HE-Tag: quilt29_13f1fdef314
X-Filterd-Recvd-Size: 5525
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:40 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id i4so8194807qtj.8
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6MXr7ZNXr9pMh8s805CN1W/EkafXMpyZxym4cVvk9wc=;
        b=Jk5d2DZoBShB4ze9idh4b2whUtX/SmRx3TmrhS9c1oewUdCmJEzH/hGw70meFsxow+
         YDVZ3g0EIXKLmKSP1feQTYCGq491WhjWp3qsTbrKER7ArdWIh+EthjCYgIfVGvoygFUV
         tlHsVX4W+sVOY918LixttJyVlaBCZPFsYG/tnp66k+QKq69YlEcdd8RSyu/uuUQ4HzmN
         A2B4BbxV4o4Zdo2HKLL7ZT2tz79MNM8jtjl4cPB7HdLIkuSvqyw1UBAIJzHx9+L9WUOK
         x90PRf3db1rUecDzrbU/GBXEF5jwUHyMjdo64PX/wkrXaBHGfKHryUcwkyGIRw2NodIV
         GEhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=6MXr7ZNXr9pMh8s805CN1W/EkafXMpyZxym4cVvk9wc=;
        b=BGs/6vE5H8HLaMMKZO63DuDUhAyrndwxxyHD6r+Mc/TYcocAInWZJgIAPymJqEjVk9
         hiXPaZWkZhuvUIu7ZH2Fl+011WEvHvJStnRi6zJxJvvHPRpJ9OIfF+hJrKXkbmpBZiNI
         fCNPvoa4p8FCLEwHikzr4FTOLNxZYF1+Ms7vqKEkdCN8tcHmLDLiGEh/IBspLqbT7vQ0
         zMfuHRh0tN4nlh7aHVyRDT9UX5Bl/WaKiX/s9R11ViWjoFODkW5TYrezLITvtMMGbAS2
         jEFenIVLQO8JScfca3dm/+XisxUoK/BDF2Z+2wNLQcNdtw02ezhm4JZ87tzYZEsi2SEn
         5gLw==
X-Gm-Message-State: APjAAAU4AprycKllDP9nO7w0geZUHrJkDkwIAlUMePmKIJL1+0zsXOYu
	t7W0cxkDwBAYDImqp4fq/U7VpQ==
X-Google-Smtp-Source: APXvYqxndPHKSjrYVebk9sscUfiq8znh7MMHnkLzeCbrUekUG7hOvdYEmZRZVAY2SFXWMAuk/MAFdQ==
X-Received: by 2002:ac8:3737:: with SMTP id o52mr11736300qtb.9.1566009999892;
        Fri, 16 Aug 2019 19:46:39 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:39 -0700 (PDT)
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
Subject: [PATCH v2 06/14] arm64, trans_table: add trans_table_create_empty
Date: Fri, 16 Aug 2019 22:46:21 -0400
Message-Id: <20190817024629.26611-7-pasha.tatashin@soleen.com>
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

This functions returns a zeroed trans_table using the allocator that is
specified in the info argument.

trans_tables should be created by using this function.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/trans_table.h |  4 ++++
 arch/arm64/kernel/hibernate.c        |  6 +++---
 arch/arm64/mm/trans_table.c          | 12 ++++++++++++
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/trans_table.h b/arch/arm64/include/as=
m/trans_table.h
index 1a57af09ded5..02d3a0333dc9 100644
--- a/arch/arm64/include/asm/trans_table.h
+++ b/arch/arm64/include/asm/trans_table.h
@@ -40,6 +40,10 @@ struct trans_table_info {
 	unsigned long trans_flags;
 };
=20
+/* Create and empty trans table. */
+int trans_table_create_empty(struct trans_table_info *info,
+			     pgd_t **trans_table);
+
 int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
 			    unsigned long end);
=20
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 524b68ec3233..3a7b362e5a58 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -216,9 +216,9 @@ static int create_safe_exec_page(void *src_start, siz=
e_t length,
 	memcpy(page, src_start, length);
 	__flush_icache_range((unsigned long)page, (unsigned long)page + length)=
;
=20
-	trans_table =3D (void *)get_safe_page(GFP_ATOMIC);
-	if (!trans_table)
-		return -ENOMEM;
+	rc =3D trans_table_create_empty(&trans_info, &trans_table);
+	if (rc)
+		return rc;
=20
 	rc =3D trans_table_map_page(&trans_info, trans_table, page, dst_addr,
 				  PAGE_KERNEL_EXEC);
diff --git a/arch/arm64/mm/trans_table.c b/arch/arm64/mm/trans_table.c
index 12f4b3cab6d6..6deb35f83118 100644
--- a/arch/arm64/mm/trans_table.c
+++ b/arch/arm64/mm/trans_table.c
@@ -164,6 +164,18 @@ static int copy_page_tables(pgd_t *dst_pgdp, unsigne=
d long start,
 	return 0;
 }
=20
+int trans_table_create_empty(struct trans_table_info *info, pgd_t **tran=
s_table)
+{
+	pgd_t *dst_pgdp =3D trans_alloc(info);
+
+	if (!dst_pgdp)
+		return -ENOMEM;
+
+	*trans_table =3D dst_pgdp;
+
+	return 0;
+}
+
 int trans_table_create_copy(pgd_t **dst_pgdp, unsigned long start,
 			    unsigned long end)
 {
--=20
2.22.1


