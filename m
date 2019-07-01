Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 651B0C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15A962146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pj6y6zwW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15A962146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F7478E0009; Mon,  1 Jul 2019 02:20:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75A776B000C; Mon,  1 Jul 2019 02:20:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 583718E0009; Mon,  1 Jul 2019 02:20:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f205.google.com (mail-pl1-f205.google.com [209.85.214.205])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9946B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:51 -0400 (EDT)
Received: by mail-pl1-f205.google.com with SMTP id r7so6761846plo.6
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RrOFns7vEPB9glYGnT15vcTk3dkoPLH+jZ0rXH1XhbY=;
        b=ui8/qx7BuGvxp6kP69YicMCObv6HENOnpeFv4ExRGmlFkl7Uen2BKtGyZ+VDuUaYYR
         dyNhFx2x01xW0vW1XhooHNlAka1OYUxRPlsyMhnZVENEz+LMLDR6BFFJ4yL8dAYy6Eyn
         JoMf2Zb9mThJkknY5QVcuxCmE2unjHtgnk+mW3gujZCqRUJhLSwniZi9AB8OnS2s/Pkj
         xn2O3hpR1dUqca542vve0MRv5WFlYDgwTcK33TQ1GVq9upBTLyciOiOeSS+7akDZ9bMA
         cQ/a5GA2FDjWjlax2qtAXjKYqmOPG61apu/v1D3jQBnlpgnqkkj4olrOLZZPkwrWrCJp
         Kb6Q==
X-Gm-Message-State: APjAAAV2FLwCunaor4JpvKx0xr0s7o27gKUCFb1RT1bj/e1xo6ooOmID
	KT2+INVscMLW+vp/3CeYCAHGtzhRB5MD6lPrHlba1FzNY6cu993Pvnt0VIkwFx+UXArWCy7adkE
	8zMnWrviF5CKReG1iqlodz1w+ViD3zwKhFNzIUen60wVru0a5/rWP+ekpyYx6eIk=
X-Received: by 2002:a17:902:7285:: with SMTP id d5mr9752287pll.23.1561962050749;
        Sun, 30 Jun 2019 23:20:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj+aRrsDx3jpT0lCo9pWH9RG5063+PqUYvLdIxrLKDv1OYW3RhEaY66MWBwO5KSx81fdek
X-Received: by 2002:a17:902:7285:: with SMTP id d5mr9752225pll.23.1561962050104;
        Sun, 30 Jun 2019 23:20:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962050; cv=none;
        d=google.com; s=arc-20160816;
        b=MtiCcV7zyzExCpS2vJY5CSwjNPcxJuvGJcyAu9amwJAsnjpYkGAaiUhCNwniLdfAdN
         lqebgJItbPz38TzqpsboBolxq4mM7oecS8tjk6+dPE8XjfhJjVT1EaoiNsPeNUgY3jPo
         VQEs5CtcTzHL4Odf1JUvDvpP8uk1is/5V2jOKRWHLKB/ttlgOCGkk0/BjqUn7Hefl0kj
         o7ITp6b32oGMvOlICA4kezrndZjZVdp4whjaM1jLu1/24uVsLc3g29n0wPkEGylTxz5d
         8d0dWci8oSDWw/pOnyIqoq0+X842o5alwuHMQmg2IcCdTJE7YceW+E9bOhFoGB93SCyN
         auJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RrOFns7vEPB9glYGnT15vcTk3dkoPLH+jZ0rXH1XhbY=;
        b=pjktZOX1V2YYrJa5D4Qbu16IIsWS8NUZSUcqdyBxzZSIVZAr7VPdgZLVXE7YRCRSeq
         oYi9KbcRCZeJcFBQDGTAEODewvZWqEIiMYDaEhqpLy2dKtfc+FG2jlreV86N3LfWKb90
         cIXShjkoKmM08YnPBbiwMdK6MXUrq7rUY6voePM1aX8dztqugNYAbauXF7g4nfDiGA17
         nGsit3PqUq/DcwbBGNMgDw7NckFlLQG25h4McI+t8Vu1Eo+zZuGI+WJZXuI2T/6HH1TH
         3DTpILPGiImdYhYdUhKrgHwgK+OZh+Fy1dhrjXZq7cYZkdGIwNmOkXw4TUAznserz7mF
         Xfpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pj6y6zwW;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h1si9202945pgc.130.2019.06.30.23.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pj6y6zwW;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RrOFns7vEPB9glYGnT15vcTk3dkoPLH+jZ0rXH1XhbY=; b=pj6y6zwWdYnnlShOohzj0+FeT
	ua95uB5pQbHGN7V1dXDgEO0XeP6NGP6wP9CsUw1MUxCczmfajEPQhpUmNuVemHicYTtOPwEIh4UZj
	haBcU1PuN/lbwsjtaumcMo2KOmzjIEUoauiWhV2s6QwwZAVMRb4f5gzsTcRERX7bZ7spwXs6dcJ43
	sRidW9kePUxliDSVB1n3yeaQo3+ui72nerrRiMi1f6EkTszO9712nLpu1yAs93if+p9DwRqXZ6zCd
	edma9n2V5pe+Luqle1eHfjwGFKvLPdkMzMs3gC2ttY0DPQRzYIJHcaA6t8Npl1EcNh3JUa+mKozuw
	56C4YQTVw==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgF-000304-Cn; Mon, 01 Jul 2019 06:20:47 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Ira Weiny <iweiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 11/22] mm/hmm: Do not use list*_rcu() for hmm->ranges
Date: Mon,  1 Jul 2019 08:20:09 +0200
Message-Id: <20190701062020.19239-12-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

This list is always read and written while holding hmm->lock so there is
no need for the confusing _rcu annotations.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <iweiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 0423f4ca3a7e..73c8af4827fe 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -912,7 +912,7 @@ int hmm_range_register(struct hmm_range *range,
 
 	range->hmm = hmm;
 	kref_get(&hmm->kref);
-	list_add_rcu(&range->list, &hmm->ranges);
+	list_add(&range->list, &hmm->ranges);
 
 	/*
 	 * If there are any concurrent notifiers we have to wait for them for
@@ -942,7 +942,7 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&hmm->lock);
-	list_del_rcu(&range->list);
+	list_del(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-- 
2.20.1

