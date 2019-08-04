Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1CC8C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D9B0217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hu5YrExV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D9B0217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C2556B026C; Sun,  4 Aug 2019 18:49:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4736D6B026E; Sun,  4 Aug 2019 18:49:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5936B026F; Sun,  4 Aug 2019 18:49:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAF936B026C
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k20so51397623pgg.15
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=RjwFJo73q5eamdA7xmZyDGt4cOyWtaEeDnGGKdHAhyPukjGUWAotQCHWGX2PtDayNm
         FQzfcDUPcQVTNr5edomRIpsMMKBfmCmFOl+QijkhiieOXuwg+M+p8Q4ETHo6wWnra2rB
         xQx3nnR0wbrapRCGu5KgfHCZ/FhSHqFMdkJLOLzMCxP1GiuCa20kvRqv8SolCmEiYaRa
         cPRCLvpbGmFAL3NXMyKG2KLrZFJtK4qHqPjobMBiY2udKNQjFGxS7owZNBVMIPQ+W0BT
         idPLFQo1KuxBK5iwNl/VcgxCXg3uTcmFEZjEO5vWMhyHUHCIAijpTaVZ32rpyhfp0RLA
         1+BQ==
X-Gm-Message-State: APjAAAV6kvABecROeljUgEhzXG7x80uZKzTDveAfHw172nu4K9l17+C4
	fMM8IjfTsjKtIJg9h1hiQ/aAhSZISKwFhGXdTUKUmfZNHumG8bULXWyCzP3mkzoYlFr6gmgYSY6
	NGzfrI6YQ+1adVKW4fEoJ0iEGM+sBKq4OSeYMITQIKKqvrmHPRwapOvdj7X3tAg1GpA==
X-Received: by 2002:a62:174a:: with SMTP id 71mr72396391pfx.140.1564958982531;
        Sun, 04 Aug 2019 15:49:42 -0700 (PDT)
X-Received: by 2002:a62:174a:: with SMTP id 71mr72396366pfx.140.1564958981796;
        Sun, 04 Aug 2019 15:49:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958981; cv=none;
        d=google.com; s=arc-20160816;
        b=TUi/2uI0YaIIexbjqQ2jfXdsWFkArWVbNzVL866U273yIwPRSBCn+KCYOjqoknAnYq
         bJMtmpvPvwZFUDY7hWOTEyPLnIIsiPECB49vTU6L94fLm1lFnrFqS45hQb0F/ONWSeF0
         h1KD3bqHS7YBNFt4EMjJqp1SP48E+JFlVlgEJ29FwbZrA+cDHybgsNYuq5OYh9SDG4VH
         wBj7zVQnyjKZ9sp+BYlYBwiY211HFKU597hUkP/MOTzO8vS0McDn0WLueqtLi1Wk1XsZ
         Sxr3+ni14gkG5jCDNVZDEAodXpoWwTrzII5bHg9YeRJZdgabbysHus5bbCzsKyKIvQYY
         otZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=Jvb3QskgAkGlEfDn/CVoCpkEAlRuu8O8jBq8zfzPxs98zhEUMe19u7bK8biovYKWb1
         f/8QrF+heSivQUqh/zAAdhUn9yPcBbbquFP2Vyqei1bS/CMiokITUuPN9m42dkYoKWKn
         WecDyfc6YTEkO7K3uH/wH/6F1LR7IECqBY3dhiqxyRFA/aBuDexAq1xpqlKQso0uvyGE
         /L0jWK2UnnrG1SYD3oIT9497P4+sOkJb3+76KV0SsbbFTAy7kahY4tmMikEvfnd4P3Ko
         mFQZIsprWsVd9sMM8w6+EP+bu6LqS/6DH949CgqyqXPth/FJlmA6B325CXxFEiEX5ASO
         QVsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hu5YrExV;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor55854638pff.7.2019.08.04.15.49.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hu5YrExV;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6zqhiQUR/t5HSZML/x55nFGZKGW5GK1LULKEmO0k7kA=;
        b=hu5YrExV2sbaBMNc30Tq7LBcjGDWN6fA4XsdWSIq37Gwal4TYkzXoLBSc1aN7i+AE1
         bVIm03I7zSnUPoNc0DrhbAQOAdTqkzN/WZ5+3xyT5kplICRjLk7gnM7AiECUFxJQtYf8
         l/vpyueUrdUTa6ElP3ExxKx8ue3ogMcet3zTMrly4eFXGYC31urxAGlYkrOSMCRCSnIc
         Arzc564JY6ON2HabMEPBcS/dFGMN4ODa4koUgN5YXXQfy4c5GL3kiXmJTl6qra2xMUY4
         X0U+ntdMZNCalKgfycF+64XZ+c1uJzhUDj8x9G9dxye9pgPlZzglleDcPGTS1gL3JdjR
         +zXA==
X-Google-Smtp-Source: APXvYqzKlxaRYSDqTrQ5Buu3RAMAQLfm5nyXOzRFCQZdRK9SX2nPkzOnWKnTtQrduQ4tH9q8VfqmlA==
X-Received: by 2002:a62:b408:: with SMTP id h8mr68625605pfn.46.1564958981600;
        Sun, 04 Aug 2019 15:49:41 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:41 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	"David S . Miller" <davem@davemloft.net>,
	Jonathan Helman <jonathan.helman@oracle.com>,
	Rob Gardner <rob.gardner@oracle.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Wei Yongjun <weiyongjun1@huawei.com>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: [PATCH v2 14/34] oradax: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:55 -0700
Message-Id: <20190804224915.28669-15-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: David S. Miller <davem@davemloft.net>
Cc: Jonathan Helman <jonathan.helman@oracle.com>
Cc: Rob Gardner <rob.gardner@oracle.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Wei Yongjun <weiyongjun1@huawei.com>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: sparclinux@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/sbus/char/oradax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/sbus/char/oradax.c b/drivers/sbus/char/oradax.c
index 8af216287a84..029e619992fc 100644
--- a/drivers/sbus/char/oradax.c
+++ b/drivers/sbus/char/oradax.c
@@ -412,7 +412,7 @@ static void dax_unlock_pages(struct dax_ctx *ctx, int ccb_index, int nelem)
 				dax_dbg("freeing page %p", p);
 				if (j == OUT)
 					set_page_dirty(p);
-				put_page(p);
+				put_user_page(p);
 				ctx->pages[i][j] = NULL;
 			}
 		}
-- 
2.22.0

