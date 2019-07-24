Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B95C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:26:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C8012253D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:26:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OWgPLaU3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C8012253D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEFFD6B0007; Tue, 23 Jul 2019 21:26:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC8F56B0008; Tue, 23 Jul 2019 21:26:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDCDB8E0002; Tue, 23 Jul 2019 21:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A84156B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:26:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y66so27404400pfb.21
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:26:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=SpXyQZf9+//3OUiezyy1vkPDW1yksgaBfMDZZRyGl+3XM19/blIygBv2oA7uc/p5Qe
         grKwY55ey4BQO/ZgRk+oZ41kro1BVN4i8DMUOAzLVi+njLJk996KiDltyKyVIkFwwVPM
         E6v4TRXb4y/GYEdeI4vd0OdvObvA9lwwlatyUkzMfm12MuEywGQ5/Z5jwNwv3jM+71/s
         CBItiTJ2LqWj38QlWyRfY50X9k6LG8HCxF4sdqlbbsDJwN9bcmnWT7H7A4JZUCLxWm0J
         0QjdiB+Cv2kYysroOmsZG7Vvr1T76iA2bFKGnFlAzLVVk4tRJaoCNB37E//8y3IDqF+f
         GNgw==
X-Gm-Message-State: APjAAAVpjSrQOJhQDs19/nj3Z97KGc2VHvEAs9LxQjC37KKcLs9PldPP
	5X0yD+NKM1x9W3Xj4NhIbETg95wZMcps5M/0Eqz5XAyuzpW0u9H5Srm/2oKkgCjgKLciIoxglvZ
	hJ0h9XrslBknIS9Q3JOIv4O1M0Jw6KSIsfm9n4kUkQC6/C412tcXGaEAbPhL/1VTIbQ==
X-Received: by 2002:a63:4c17:: with SMTP id z23mr40488167pga.167.1563931574086;
        Tue, 23 Jul 2019 18:26:14 -0700 (PDT)
X-Received: by 2002:a63:4c17:: with SMTP id z23mr40488110pga.167.1563931573163;
        Tue, 23 Jul 2019 18:26:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563931573; cv=none;
        d=google.com; s=arc-20160816;
        b=bFRKycKDUjUYCG8t7p+aB9hjBthhSjN5Rb9Nmus01PjBYndYbg74bKFQrxxZTINL4H
         uyHLR7FIz3W0Bb3y4FY1PWtY3qZv7KQDvldZT3b2UiNx7PiS4CIbDTIVb+aDTbP9OpjF
         TxcJGu0A+eZ3haxvIqFITLnU/YvvDCVn34b5ANnQdNi6rAxKa7rbwA4Ums/LmxYRqMEX
         zhDNW+8vbsbfHe+/yd4vW+/c1ihv74TC0GpdYPncv4RVAYfFTUM94ejyGckD+aA+oVbQ
         wgnpMW4UdmlQK5Nmp4bpDaebY4oq7eT26aUUyZNWbksD6lonnDgXiNMs8QwR+0NmCyxN
         MyHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=AKDIYoFwyokBNNUZUOjZE6cgEutrATfhdC8g2XWNddeZlsIlfV9vtAK0V71xZLZHq1
         W/6yC516T4dkwFcv5v2H66jtUfA93gCeYUEL0seY8M7WUvo/s5nQNvrbjSwEda6g6TCv
         l9QUJBRsXJH2nyux6anFTW5t6ePYoeFma+LCyzAE8RQQeSMqYW0OfkozzYXtb22VMbDa
         sH+eLlkSGfvaXLLvt33GUVDt1TUYLT2bYa338q9j6dqYStN1RqokUdxL3xpyu3dwEd84
         Ns36p1WTmbldm8h5Ni7IefwjnzpgGyOwzjXMK31s4eKb2TANzHnx0VoLTBQLN46fj/wK
         o71A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OWgPLaU3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w8sor24875835pgr.42.2019.07.23.18.26.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 18:26:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OWgPLaU3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=OWgPLaU3grtQYfYlP989m4hDqCY0ebI6/NdlbTukxlvyq11BxlHjkqN3hD9v30eXop
         EG5XcRymjdkeuqUefZiFos4WvvjABKFpbsNii0SJgJLYNmAuW/FgFPitHO+2/3McUV+7
         gf56g8I7oolPT/XjyQlyJvxXGT9o0Tu+Faj3GJRN83dbqyEdOZuIUG6zQmH21j9c8JN1
         CA/rkJKw8eGWS4zO87DNqwXtLIaNHKrSMu5zMWSkni8YHEGOTZRgi0t/AK2jYfN3o74B
         SwC/fjv0b2UQOsULLgn4oGhZFx9tErfDTI6/TzoSyDwqgD9ppDPsMbY1I5zyCPDekHFd
         ripQ==
X-Google-Smtp-Source: APXvYqwiARTqBX+BzXGVMSiMYY2ywuebKHgAP9ok+GCLfuKMFIizwJOl34+Vo9ygsJn6Z3ecH0s+Ow==
X-Received: by 2002:a63:490a:: with SMTP id w10mr77642193pga.6.1563931572866;
        Tue, 23 Jul 2019 18:26:12 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id k36sm45950119pgl.42.2019.07.23.18.26.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 18:26:12 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v2 2/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 18:26:05 -0700
Message-Id: <20190724012606.25844-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724012606.25844-1-jhubbard@nvidia.com>
References: <20190724012606.25844-1-jhubbard@nvidia.com>
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

Also reverse the order of a comparison, in order to placate
checkpatch.pl.

Cc: David Airlie <airlied@linux.ie>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 062067438f1d..b5b5bf0ba65e 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -171,7 +171,6 @@ via_map_blit_for_device(struct pci_dev *pdev,
 static void
 via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 {
-	struct page *page;
 	int i;
 
 	switch (vsg->state) {
@@ -186,13 +185,8 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 		kfree(vsg->desc_pages);
 		/* fall through */
 	case dr_via_pages_locked:
-		for (i = 0; i < vsg->num_pages; ++i) {
-			if (NULL != (page = vsg->pages[i])) {
-				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
-					SetPageDirty(page);
-				put_page(page);
-			}
-		}
+		put_user_pages_dirty_lock(vsg->pages, vsg->num_pages,
+					  (vsg->direction == DMA_FROM_DEVICE));
 		/* fall through */
 	case dr_via_pages_alloc:
 		vfree(vsg->pages);
-- 
2.22.0

