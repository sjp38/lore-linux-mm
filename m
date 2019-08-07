Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4CFEC32756
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60626217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GqUNc3X3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60626217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12C056B0270; Tue,  6 Aug 2019 21:34:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BCA16B0271; Tue,  6 Aug 2019 21:34:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E264E6B0272; Tue,  6 Aug 2019 21:34:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7D136B0270
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:13 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 191so57157906pfy.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JsaN0a6ImilSblrGqgWWjtVL4aaUVqoBD3LMggUShuU=;
        b=nD/UxsSwPM7ZlrGMJKUpaxlsTGAcw1sz7LngyGCXSCJQ3/nMgK4Q+MYWPPms63Mq8V
         USlIt3ibXztXiZeYjHUA3NlZUNU8nczeRkSnUu4B2Boxerclu227NBPNxxTVMH2TuyCW
         JRfenKKbQrZtqq95IO6kokm+B5trOeOsgHcg4AtJE5yzXVC6WtCRH2gm00LfEf8JLmFg
         aZmTK265qUilz5npYK8JsEcPmCgWee3/59o5kEFfp4ij4hN92O0xtFTdZcE++vrk+yow
         Un3aRLNfWGWIWmYA6r4o9qlIjo8+7pRbtgDg26a2ciYjuSMYhGeGifwoiL2wqo+N5jbR
         3j/A==
X-Gm-Message-State: APjAAAVEuKwgj1fDXTgeAdjirGps5tULzwB5VuwcCOUzMQp/5a2LMRqh
	apVySfXPHuR6rRmuAxg4VH9n1QS5r57glHh8UIZaK/UlDrGjsoF8gws4GlO4WQW40uvv4wmqfKD
	lRGEmAqLLLjtv4zmnPfhlcR97ZQ4rU8uAeM0FHZY0pbNXOT7XvhobXhbPW8lzJaLCYQ==
X-Received: by 2002:a17:902:e2:: with SMTP id a89mr5940829pla.210.1565141653350;
        Tue, 06 Aug 2019 18:34:13 -0700 (PDT)
X-Received: by 2002:a17:902:e2:: with SMTP id a89mr5940770pla.210.1565141652367;
        Tue, 06 Aug 2019 18:34:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141652; cv=none;
        d=google.com; s=arc-20160816;
        b=p3s/15+lpgTqjy0y+wh2ZIXSZQ3m7UoJMIhqifcZ+gtNSxvsktWpfsm6Z7J2OTBlQ5
         B4kwlhYc5xVqatCiPxOAQztUjokPf3NKGKyzQ6QXwYmNwyMVLHECLGwpedzgBvePknv1
         DcjsJ1UJkiIKhgUFC0CCNz4TJkekSCX1RfPk8mHqdgu4yVU0Do9UZQC/Y3ezCdalFZxy
         ptNuHDN5mph5fZNdPM4Fgnwi8jYFAQfym4pPhz7clyK0a5UzjzoVoBdFhOdrfqIC95C+
         E2KOhzEzOyMmqu6qzX9IOOGI4LRq0o9KX2PvCK91tO1Y6WlRO9lqv7wHsLsJAjKK6V5o
         l2rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JsaN0a6ImilSblrGqgWWjtVL4aaUVqoBD3LMggUShuU=;
        b=u5RHBRDFlfbR8P0bD1hnpvDKcUKKA9eclCwUlrJVCk8Iv5qets+ZPKfKyUAbczgDbr
         kocsmK/ceidyt736yL0uL4lofdJ/qhlMashExcMRvsYl/wCnfgfbdV9i8kMIPQNEbuSu
         FUcl+mWbuopKKqDRzNq6rUYySvLodqluGsfcjasF9LN7MDuLM32CMd3v60Wl1MvYVXZR
         0crkSllFXeqgvzUfkyVPUiRr2c+NY07PqP0gc6txlrGaMOKEnOWzoOG5wbWY58L+WP0m
         Ij38AWUML8XAjk+MHtyyi4M0x3v56VEqeqvpv/d9JKf7CjTVVRZ9CMp/apkdOWzyBgO/
         MqJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GqUNc3X3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor7309590pgg.55.2019.08.06.18.34.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GqUNc3X3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JsaN0a6ImilSblrGqgWWjtVL4aaUVqoBD3LMggUShuU=;
        b=GqUNc3X3RUD+fMQ/tQov0eVptsX6vtpAZn07Fz7EwuEqRFmPs6eCUIqWfymN9U5tJQ
         Hp7GWk6oPhSKnPDc9mTSSc0b1ETtX6WZgNyVT9i/ZAc9DVX2wgidQTYQD678snuo6Uld
         OC0AxpA2rwU9kzsgxg4J7222NtI9nwWIQ3kKBxRvKJz1x31XBYs72NYIFgvDtQhOtH6x
         c30ljXQcc0npojtfiU8d5Zil2HhFRjkicdzBOPLsXrn4hkS7yUXDhahjzIOv/1HcFIxR
         8vAP8M1yLlIpgKytXt/GLUCaDmX+n+gX0JAtjCLQsjpUrzEN6iMEgLfOxOdX4VT9I1MD
         gqwg==
X-Google-Smtp-Source: APXvYqxA3xyoDOQ03wz3+MrAsxUgDjCiiP1q/97dVlMDAvCMqLwWlj7LgNPejGHFGrv69vRcUlGBpA==
X-Received: by 2002:a63:3112:: with SMTP id x18mr5571166pgx.385.1565141652072;
        Tue, 06 Aug 2019 18:34:12 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:11 -0700 (PDT)
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Anholt <eric@anholt.net>,
	Stefan Wahren <stefan.wahren@i2se.com>,
	Mihaela Muraru <mihaela.muraru21@gmail.com>,
	Suniel Mahesh <sunil.m@techveda.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sidong Yang <realwakka@gmail.com>,
	Kishore KP <kishore.p@techveda.org>
Subject: [PATCH v3 17/41] staging/vc04_services: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:16 -0700
Message-Id: <20190807013340.9706-18-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Cc: Eric Anholt <eric@anholt.net>
Cc: Stefan Wahren <stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mihaela Muraru <mihaela.muraru21@gmail.com>
Cc: Suniel Mahesh <sunil.m@techveda.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Sidong Yang <realwakka@gmail.com>
Cc: Kishore KP <kishore.p@techveda.org>
Cc: linux-rpi-kernel@lists.infradead.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: devel@driverdev.osuosl.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 .../vc04_services/interface/vchiq_arm/vchiq_2835_arm.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index 61c69f353cdb..ec92b4c50e95 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -336,10 +336,7 @@ cleanup_pagelistinfo(struct vchiq_pagelist_info *pagelistinfo)
 	}
 
 	if (pagelistinfo->pages_need_release) {
-		unsigned int i;
-
-		for (i = 0; i < pagelistinfo->num_pages; i++)
-			put_page(pagelistinfo->pages[i]);
+		put_user_pages(pagelistinfo->pages, pagelistinfo->num_pages);
 	}
 
 	dma_free_coherent(g_dev, pagelistinfo->pagelist_buffer_size,
@@ -454,10 +451,7 @@ create_pagelist(char __user *buf, size_t count, unsigned short type)
 				       __func__, actual_pages, num_pages);
 
 			/* This is probably due to the process being killed */
-			while (actual_pages > 0) {
-				actual_pages--;
-				put_page(pages[actual_pages]);
-			}
+			put_user_pages(pages, actual_pages);
 			cleanup_pagelistinfo(pagelistinfo);
 			return NULL;
 		}
-- 
2.22.0

