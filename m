Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B3F7C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAC4420823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ECnGDtm9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAC4420823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0678E0004; Mon,  4 Mar 2019 14:46:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E5E8E0001; Mon,  4 Mar 2019 14:46:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF1C48E0004; Mon,  4 Mar 2019 14:46:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B21EB8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:46:53 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d128so5884790pgc.8
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:46:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yWPRKNbSliuixUwjxdom69EEKs5phLvSHf5FsoV2aEo=;
        b=EBiM3jpEzWkCMSoT5jd/x250cdTGjL+hnI0e1msp5RwFf0yKub8xQi0YzatLOjib6r
         eyS3OySMrWRsocHWTQzXecGd+T1ox9KpNYxBkQfJcMTHyozkt3dpFFxMnmVR/NQotXC6
         LAbV5M6k5l/94j6vYDdJ+Rv3Z74b6/CGktU1wCk52Lpt8Vyd+0U+H2PlT/0GWRZMHYgH
         y4nvfJySQjJstTamEFvY6vhCdfy9PgYwP/LRYrFrKcVkOQaDwbnf6I6fYvTGnd9SB8FW
         SeoIpGDq9gtsNbuD8Q+mu6Yr8/aia4XrnzI2Fw3c5dueM0OZKNYIz7SQbbpH9UPabrOk
         Eq7w==
X-Gm-Message-State: APjAAAWgkN3gMvO7OjzGCOquCE5qRQa4pFpbNIb92/7MU69UtvUv7RTg
	iKoICP5Ak3c0xAvWn0r6SUfG3FT4W7VHSIoz0dtOqnrB/R5GnBYh5v9jtATXF2oLfwyAWyUmrib
	kHs7q9+X4tQtM0k5bsLBor2KVxpXyUJmKWJ49VVuyZrt4OIsFFeM8Bp5qL0twYr7H4U0wC7sx9K
	hYAt6HTbD6YCy6mieF/Vm5qIHw1d+pAhqct9udki635AAiPuAdtAltw3f5bBfnbAH+5CYpOmAFX
	oZOFc8NXdLRID6YT+hgDA6z4OMqJFWkr0InPTCoRrmU3uaDYBH3KOME1CVNnLrNuCnAvcHkzbZl
	EXT97HU923qhH0Su1bThWOjonio7jo88gQRbX1cBWgz4OSid3N2pyNNat0IIDvFQIdxz3EJgKo5
	U
X-Received: by 2002:a63:aa46:: with SMTP id x6mr20050220pgo.452.1551728813418;
        Mon, 04 Mar 2019 11:46:53 -0800 (PST)
X-Received: by 2002:a63:aa46:: with SMTP id x6mr20050140pgo.452.1551728812404;
        Mon, 04 Mar 2019 11:46:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551728812; cv=none;
        d=google.com; s=arc-20160816;
        b=JEn/kOfMLLbXD43CApJtpiK/SDmeu7nwIbmnAZYAKqJRWTK1jxsDQ4Tw2PYN7sEKSC
         lsIOE5e9FVV1GmgUgosmSNIy5bBFwmD1OT2hceEU6JdBywYEN2lusWqnhJP0WtJL0SYL
         98vPZT8CNoHjTC1A18MtgcsbHijX3DETfhjPI+ls5aHR3FeprPfONtLiBXviivo1qEJw
         kENVD8F6W2koj/6WcDzsgiPh94WHPbB45n5w+HcRfn229iw6bEh9lKVQt+dSIJRMrIb5
         m3uhP8czWnni7K3I4HRMx2FRjcEbOY/2n4OTgcPOM4EkHYrRasiWouafXZ475mT66xoC
         uytA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=yWPRKNbSliuixUwjxdom69EEKs5phLvSHf5FsoV2aEo=;
        b=mkg7IdPw2S27XkcPe/vTsL0t+6oRmFVM+GMcOQTkM9x4DrF+vwS07rMJO/wvWX3hSl
         VVxXyGb5nWlR1MP4I8TDxquMLtXdYIa89tdzDJI6W2EAfyEjZhJikbCOiJoKWHRVL2Vw
         8JiJSk6XPpOnmJeL0XHae04gFHL3fS92TJpId6kmGaisgR+TJh5A2Gpj59le84Rt+L7c
         eJ3u10s5dLiZ2PFHpl1w64NXyjUHygPQi3AZq2FP2448fjxHQTSyDgCmgIkOwIxGJ8Lu
         usmJjypTIVh8/vWzrt8DCcjv07QCDXYUkfmwVh5zOO/Ww+3vAS9E7iKJgrRI0CgVt4PN
         wh+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ECnGDtm9;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v71sor10242017pgd.13.2019.03.04.11.46.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 11:46:52 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ECnGDtm9;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=yWPRKNbSliuixUwjxdom69EEKs5phLvSHf5FsoV2aEo=;
        b=ECnGDtm9cT/1TS0hga7uq1dImBkB33/g5+7V1GOXCCs/Yt+K4CqbeFR0maB0yAWfmx
         OGvTGBlvqHzJdo6kne4anwU3a0JczgPqPNgOg4gKDfmhFFUEotESymMSQyJfbg/UfTSf
         l4cOObIj/5hvWKYLS/pAibqGoIYL6rOWMBzGChGZFVuHr5J78wmzDeIuY3fkm/t0zpIp
         GHIq22p2TtNsZcxskMnXP2L2Nc9gATr4p0vzqKwE8TZIATUO1JvW7CLGDNLGCfBgERbk
         n33OEotkzz2iw8dZTCUYkkj4teFKAtTlwwGsjg376QodkL9GxL0Sn2xcoMBaCWcVF4GQ
         NYXg==
X-Google-Smtp-Source: AHgI3IZSNVVgZkq3mua2IfnTVSH5c4pymivIQDquRL4FBmKmT/1O2mVsk1WF6COcf+CmMvOOA6e+aQ==
X-Received: by 2002:a62:41cc:: with SMTP id g73mr21187821pfd.145.1551728811727;
        Mon, 04 Mar 2019 11:46:51 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id v15sm13499604pfa.75.2019.03.04.11.46.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:46:51 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Leon Romanovsky <leon@kernel.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	linux-rdma@vger.kernel.org
Subject: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Date: Mon,  4 Mar 2019 11:46:45 -0800
Message-Id: <20190304194645.10422-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190304194645.10422-1-jhubbard@nvidia.com>
References: <20190304194645.10422-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

1. Bug fix: fix an off by one error in the code that
cleans up if it fails to dma-map a page, after having
done a get_user_pages_remote() on a range of pages.

2. Refinement: for that same cleanup code, release_pages()
is better than put_page() in a loop.

Cc: Leon Romanovsky <leon@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Doug Ledford <dledford@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/infiniband/core/umem_odp.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index acb882f279cb..d45735b02e07 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -40,6 +40,7 @@
 #include <linux/vmalloc.h>
 #include <linux/hugetlb.h>
 #include <linux/interval_tree_generic.h>
+#include <linux/pagemap.h>
 
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_umem.h>
@@ -684,9 +685,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 		mutex_unlock(&umem_odp->umem_mutex);
 
 		if (ret < 0) {
-			/* Release left over pages when handling errors. */
-			for (++j; j < npages; ++j)
-				put_page(local_page_list[j]);
+			/*
+			 * Release pages, starting at the the first page
+			 * that experienced an error.
+			 */
+			release_pages(&local_page_list[j], npages - j);
 			break;
 		}
 	}
-- 
2.21.0

