Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88188C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BB8421473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ac6u1kwc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BB8421473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618916B026D; Thu, 13 Jun 2019 05:44:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57C946B026E; Thu, 13 Jun 2019 05:44:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F6626B026F; Thu, 13 Jun 2019 05:44:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0070A6B026D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 59so11601271plb.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j5NF6MNZYGnulaE88E08I95IgTMRhrbK2u/HLXeuvXI=;
        b=unE9ZDX8yCR7riuOEuoidQGSmIrjWeXzyo0xPMUYbX0DyHQ6WeQVFcpeHEYaGPw49n
         OD+NVRgOayGD6GoXuc6WwEa2hcD9LkpEnc1qzwa3DTABuE9Af2bXv35HPO3pwhd8R99U
         Fekwg0Krbar2XOmRRcju+YLBcoPJNYZznPvLIxMndrrif1qoPwZf1u04IhV1AmUhAQU1
         AvBr4/PiD0wJOfS5pyDMfn9fuCFB0n3Jpp7GCTgsi94hG3oZ039IYaqhwI4oTpLMtwEV
         IwGrN4L1C1jrXzmAY218uZrcPgW3hqrHEKBanGs6LOq94UIsszZ2A6p0uI54iVPCgZIu
         jlOQ==
X-Gm-Message-State: APjAAAXe5h/Cz5n8Awn7KCFeJ3Wm5/NmtjZlTIWmq2ghu6Xab3PJZxjc
	BibeMgDSjxsqGKHbBFrDHCHvr8RtJAfw1NJgK7VePafA6qbPueIMxvQ+NyOQyjhPgYCfXbpX0wV
	R9v2vwNL1YDhO68mu0friqQX9xDVwk5o7YDRBQHfFy6adE47grXWr2Z0hv5drKOQ=
X-Received: by 2002:a63:f95d:: with SMTP id q29mr23489510pgk.368.1560419053493;
        Thu, 13 Jun 2019 02:44:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyReFvVcK2OolvqCtIMr52biS1hnktu+eWU1jVJjweQacRuRJ3nq9cYDjS81UYofMhR9FH
X-Received: by 2002:a63:f95d:: with SMTP id q29mr23489401pgk.368.1560419052247;
        Thu, 13 Jun 2019 02:44:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419052; cv=none;
        d=google.com; s=arc-20160816;
        b=iwOks5kHrS33MfaDdYMtynU5U27TZaS27guKfLoxcii5IsD/LQWqY1rqqiV/Q/1DQP
         5YqbfJfNYhdZJkj27NNj3SCf7R5TdJPSKqh5nyKtoUxGMZqp3Iiigqz08Jt6YebKgDdH
         AtwoMNGvuLSK2d+IzNXSJT5EBcbSaQI9ENsI5CynGPDURdKQf7UG5yjthIsq0Quj2d2b
         f8Rxt9dOl+fbeSsBI7SEE69E3FPCtDheZVWh8oOaIou4SownnFH7xjMny8TVnAWeyyFL
         iP7pIY7UQf5ZV1CEs1+IgV2XXIexmJnwbHD8Yr3K/xNxaigoB+fPvWFPnU8LnHbdp4c+
         wFgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j5NF6MNZYGnulaE88E08I95IgTMRhrbK2u/HLXeuvXI=;
        b=H5D9K132RhWRNqFXpqY3Vmp+CKeKtOWbZ3FukPHr6aEd95Kpvf/3Uu4rTcaEC6SC91
         RqWaB/TcdtZOlrz8KO5tJlYQ8WOQ4xVz+O/rGS0JWj/kWGlxqS4S5bKXyHL7JeN/jucL
         DGtqvLsYk1Q9DCtoz0/vZul7RjSaX90ctZntcfLgO9n1ENBfjLe69VvMPiWqK7wgU6lC
         ReQCn4udMwPpKwgPVBS/0mtH9mNI+w9Vlvw49zZL0gYi5N30R0sH8Np9ae94qX6KYoE9
         ZGQQiACxx4pj1e3IQj+ulzGltynmVcF+FpIVNkMT1RoW3ZFjykUvoHUbAOteq3UynGYQ
         uCXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ac6u1kwc;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q7si2656229pgp.245.2019.06.13.02.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ac6u1kwc;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=j5NF6MNZYGnulaE88E08I95IgTMRhrbK2u/HLXeuvXI=; b=Ac6u1kwcs5Qa+uMIZP26VzBqh1
	oBc3B77m8cKbTSEIFPsUyGP6G3FUk3c8E+xk2HZWozHXtClsdTiu2RALXiDqDY43JEV1DWM9l1/Du
	GMJh/5UGQizxUaLO1dcsKhrvI14c20vJPjJ7jreMh9910F1WY99XI00fTC0entGgeaSQZLCs86xfW
	52vn6lM51A13Btvh++2O9/BZ39MqDd/CCOhxXr/jPAHEUNdYFrNi3zls/lufPVZvRZbXCwxBGi+w3
	avf91FXeX0uy9xYlvIoYY88p2jQx1BQy8vySwJ/yFSSrfYf9r3j/UGnyKprb+nbDw7XgChANaBwwz
	q7RSMx1Q==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHB-0001sa-6c; Thu, 13 Jun 2019 09:44:09 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 14/22] nouveau: use alloc_page_vma directly
Date: Thu, 13 Jun 2019 11:43:17 +0200
Message-Id: <20190613094326.24093-15-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hmm_vma_alloc_locked_page is scheduled to go away, use the proper
mm function directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 40c47d6a7d78..a50f6fd2fe24 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -148,11 +148,12 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
 			continue;
 
-		dpage = hmm_vma_alloc_locked_page(vma, addr);
+		dpage = alloc_page_vma(GFP_HIGHUSER, vma, addr);
 		if (!dpage) {
 			dst_pfns[i] = MIGRATE_PFN_ERROR;
 			continue;
 		}
+		lock_page(dpage);
 
 		dst_pfns[i] = migrate_pfn(page_to_pfn(dpage)) |
 			      MIGRATE_PFN_LOCKED;
-- 
2.20.1

