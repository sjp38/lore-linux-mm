Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C17BDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 04:01:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E60E2086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 04:01:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="slI1ohXT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E60E2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 090D38E005C; Wed, 20 Feb 2019 23:01:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB5788E0002; Wed, 20 Feb 2019 23:01:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65098E005C; Wed, 20 Feb 2019 23:01:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83D8F8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 23:01:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 23so8565721pgr.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:01:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=auu7sPoqnYOjV0cCzT/qrL11WOBRgRd5ITVHRQ8h3zo=;
        b=CqzGzgFdAbqWjwHrSHnIk0VL+a7gDdxcw6QsR40nLOB+D77L78usfR8u8kGyqtci7K
         sCbuI41lZtmZVarezkuk7UhuzOJAvYw7pd6CNHxp9pxFqK9HCfhSh+SJFuXxdYq9Qq8T
         ZR3B/ZRe+/wQ3n5EKm2dEFlI8yigBeEkNvxmhl2hhG16Fyk0FEEFf3z4gAZqUusvqMaP
         wgS3ZQw2Oyfm5ciHwlIJyMhcnH7IXH0tRF7bRKoT+UCKhtSBz7VKoms1KDfoqzeH/Lop
         +Q6IrhI+maiHZqhbMBooyNK9dU5D38vHTntsEqu+jSplg2eR0lEbfjjxiBXuSTmel1EU
         PeCA==
X-Gm-Message-State: AHQUAuZO0j3YDr+sFNivfKwuNvGL+6g3NyjbXvw2C/oyHN2c9cNCkdCq
	1D91Ryk5DyYgq2ZzvJhz+0FSaQo/ELcgXrJ9JLD5SOCo5JbkGTI3trEcMsS/rOmCmi4VjbnbtIg
	18BZkCPjUBFo+2mAwDCM9deKdTt2NdjwTstYSvAEEciGeKe9jh7eaDfaeeXiYgxl28OKCIrWSz+
	Wuq/tPA6Gv9z43dF3TUpmcDRCCxz/iGZAzH73+NW5GvupMuj5eZ9FkEWK1lO5hJYONfpru3MFZI
	cOeBsRpvEiIr50aINvBftb+6Sq6+ST9MN9PHwdtFAn4q+NrT1Dej37ELnstt5XNO34NIxpoHmkx
	QzV+OI7JxRtkswjA5TBHY0RXtjce2r8mSaomlOrkT3Kujhy3MOjYHXZxsGFoyvcqsqvo9bXxbYb
	1
X-Received: by 2002:a17:902:1:: with SMTP id 1mr38329903pla.276.1550721716235;
        Wed, 20 Feb 2019 20:01:56 -0800 (PST)
X-Received: by 2002:a17:902:1:: with SMTP id 1mr38329766pla.276.1550721714493;
        Wed, 20 Feb 2019 20:01:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550721714; cv=none;
        d=google.com; s=arc-20160816;
        b=KscScpugjrEFrF/ahbhXiJbtJqWRkOgsbu1xm/Rdkl5smedSG7Cg9OwhnrTnyNKvDI
         HNlR1z52TK56vc1pT2ZfDMzAr4SgXv6fKA7RYMqMOevJb3HHJjAEcUrDRr9xTIH4zYle
         ToDyK0lDx31cl7AM7ulLB0bO8rjnxe/Y6/WFtbYwlg90BESO93owR7wQ4UGwYceJqpcU
         C2xsMpYCG/UYgaZDLyStNLxer6zK2HOvJ7aDTQ6spcrOviNtlvHYnjuEILBm4PUpMwm/
         +rxJ0AOrti/uDCKk9r5mbISdN8An6QXbobln5CyhRrQtYAJSF1Z573a9KQ6d8fNgf2Xh
         jKYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=auu7sPoqnYOjV0cCzT/qrL11WOBRgRd5ITVHRQ8h3zo=;
        b=s7kg7sfiuNFf78Y3JUinGyGBEEVHh2u1u+FqDRqtQ7V9ydSuAr6ZkZ7dLkhA5AU11V
         taf1UoQlgyRO4nuaJcwwyt9tWsfWHwD8gHaQHiVcrXYyU29Eek0uTM4b2ICRzX16jNNm
         554tEqdaQJXApdQRv3yHh5tvSPa3iVg5CJLo4qN2qsEtpkg8T1AiYJOaRo2ThfOJ4p51
         l2NG2Ih2xC8hqYco6yOeVBPbErVfIwZC2frRB94OwJey08F3iW7zWwthDhjEA97ggxYk
         +VikUkYLKAeDnnw+wQQOkOODcyMyaJho8FuKWLQnpUWZanwOcM75daVgulfgyk12l9NM
         evlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=slI1ohXT;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q26sor33558586pfa.16.2019.02.20.20.01.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 20:01:54 -0800 (PST)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=slI1ohXT;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=auu7sPoqnYOjV0cCzT/qrL11WOBRgRd5ITVHRQ8h3zo=;
        b=slI1ohXTh/xsmYYMHV64QPy2RBdZPwCB45eg01Tz1FkJAN29lre1/lsTzcrkb92T65
         +wN+B+xAtPBmjvKmPtn8RZnqjZU1Ue/17qeS9TE9kek7EevHqrfDe76Eb21R5bz5wUbq
         ie9/0tvopdsyVxM1i6bL4K2VIVg8nz2eEBuh0TlcMGrOeRPwtnTCmp4boIdLcZNkGUm1
         j3Ssg+jLJv20L1pt61eLU00ewLRDe8uQVArMMd0nKuyX0jgDJdXye1k2XN4wXm5lJwAA
         ha4aLfpajRtPmDrt5dXHzBazCywIZ5Wln5bWPOnvu54k0mTNxoikfb557RYnFDEz0PTA
         Qc5A==
X-Google-Smtp-Source: AHgI3IZ4AFFJXmbpIjIrZunHa4CkehfYlISghECHg2aZiI6bpwojNPXg4a6uU19VtC2ztipHnekhVA==
X-Received: by 2002:a62:a9b:: with SMTP id 27mr38021830pfk.223.1550721714199;
        Wed, 20 Feb 2019 20:01:54 -0800 (PST)
Received: from huyue2.ccdomain.com ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id e9sm48836730pfb.52.2019.02.20.20.01.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 20:01:53 -0800 (PST)
From: Yue Hu <zbestahu@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	rientjes@google.com,
	joe@perches.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	huyue2@yulong.com
Subject: [PATCH] mm/cma_debug: Check for null tmp in cma_debugfs_add_one()
Date: Thu, 21 Feb 2019 12:01:30 +0800
Message-Id: <20190221040130.8940-2-zbestahu@gmail.com>
X-Mailer: git-send-email 2.17.1.windows.2
In-Reply-To: <20190221040130.8940-1-zbestahu@gmail.com>
References: <20190221040130.8940-1-zbestahu@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

If debugfs_create_dir() failed, the following debugfs_create_file()
will be meanless since it depends on non-NULL tmp dentry and it will
only waste CPU resource.

Signed-off-by: Yue Hu <huyue2@yulong.com>
---
 mm/cma_debug.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 2c2c869..3e9d984 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -169,6 +169,8 @@ static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
 	scnprintf(name, sizeof(name), "cma-%s", cma->name);
 
 	tmp = debugfs_create_dir(name, root_dentry);
+	if (!tmp)
+		return;
 
 	debugfs_create_file("alloc", 0200, tmp, cma, &cma_alloc_fops);
 	debugfs_create_file("free", 0200, tmp, cma, &cma_free_fops);
-- 
1.9.1

