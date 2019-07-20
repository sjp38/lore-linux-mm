Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DCACC76186
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 17:32:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C39C12084C
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 17:32:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jZwHW5P5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C39C12084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F12E8E0001; Sat, 20 Jul 2019 13:32:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2786B0008; Sat, 20 Jul 2019 13:32:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4917C8E0001; Sat, 20 Jul 2019 13:32:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5316B0007
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 13:32:23 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n23so8809035pgf.18
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 10:32:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=TdusF53r7yLCmYFWdH2/Tx4Y0JTP7HLyZW39DsqTHPo=;
        b=o4VGl33KcKQ/bYYFn4EqoUZwGgd06Jm5Zyy5vMHTQNSLRtrUGVFQq09e9kSAPvPX9T
         wZEXVVZb0GjY11kbOiUqLMXZwFIvsznMSMZl+VsbecAzPlyYgQgnUPq7U5C5jalHLz0j
         U9moOeDNxiMjNAAUjN2gLf9UDvXD7iGxSfv6UxgRv9VUvNBI5Ke71XTVp7gU5GoYGVZ7
         B5ZCCMoQNJOp55STDq9+S/zjtz1mTUk5JXvwFYpotRIxHCan0yq/sUCT+Ea1xMZVRqZ/
         p5O+VoTcCJ4I4DIiMhmnSC/UjZ+2rKVV4hZMXM6W6gvrS3yjJz1IrOY0+C1l597G+uvY
         YS6g==
X-Gm-Message-State: APjAAAWm0hfzy4wIeieyVL3GA1O8c3EXHyBnjXgUMLxtegUeT769GZFr
	jKMer1qu/Lwr4k0XZtCSKaPnqOGWY+6ydy280cjjYp1i2/EwlUsfrFZxpeAaO3wUv5Ov+fQI2tk
	bAjKP2rSI8M29Dgl4yPiWU2xDhOjw45IfZQg1nXhib1IMkdF6ma/45HpLVHBTPL5+KA==
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr64855418plq.218.1563643942687;
        Sat, 20 Jul 2019 10:32:22 -0700 (PDT)
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr64855352plq.218.1563643942022;
        Sat, 20 Jul 2019 10:32:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563643942; cv=none;
        d=google.com; s=arc-20160816;
        b=LGgh9hy7WZGKks8ty06LgIYWf6Lyv0KlPdhfmeAFphQfANfNar832X/pWnzO0kk2Vy
         W846gn8Mx1NBerndUh+JuI2S2Vsm4++dQapQA8/Y1LwYUtn68vGFDUd3LZr/LtuI5EBH
         WAeH+I8rORhnAtNNcHsJQpHUWFp7dsXjptTaepyWQheokQ3BumsR15o4JwkwK/yfHMBK
         udFpbm2Wap9cT3l8EnNqXOcVSJO00bPrFwhWbL+accLVAsD39kxvifbnceiMLRh7vMAk
         uloQjguiJo+UelQhJ3B7Qsg9/XywJQq5PRj4dhAt5lX8nDw72TYNGuyCLlJzhI48UhCt
         Ha8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date:dkim-signature;
        bh=TdusF53r7yLCmYFWdH2/Tx4Y0JTP7HLyZW39DsqTHPo=;
        b=litafnX/+Z7FiocD1TQN5VsU/fOOQpYxFDqCvOp0YWP4D38CeQk7qZVSV6XbAQzSwM
         W7WJz7Kd/+EYE5N8mLYGUQFJzhor66ejqpRnM2EPF2fXKjEbaFFl/7ZKIL8IYJk2F3kr
         uKvoDNbNcDalXivmpCQtVcacmIdHdo+9177WnSiNDZkLkYAGLSoLfqk6HOJFopmDJo8u
         UMPQJdma0JW7A7l1fFOxKoPZaepX8c2YSgzJbUcR9PwlGV/ohIaPzOJdrURlTKnUqx2q
         oc8nR9ryj8w8kvw7KuJWG9rNkeWHiC6FF5Vi5DWxXL7vxndl8riwmFj7SUNvPN1QXs2w
         YYCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jZwHW5P5;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c16sor18321982pfr.5.2019.07.20.10.32.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jul 2019 10:32:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jZwHW5P5;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=TdusF53r7yLCmYFWdH2/Tx4Y0JTP7HLyZW39DsqTHPo=;
        b=jZwHW5P5iF1JlnF80DO5TcIm6+g+ZDUG5S+6/RgtYHw6KLyFLYlVXEl9Z9sEeemBht
         AYzMVLvL3O1rDCMBLgk5oQsBWzZVN5hNiP1d1yvkc+hIb1SfYyj77grFFke4jf+M89gj
         gOXjKJddqkWZIG4l07gU+qGnKbvmbTwg7jyMy1DL01btiBLhboZzNa0mKZWxEczosnB7
         sQgcWCSGwoPOHdX1Ks41hNOl72N9rUE0sMXRSbhtDPDgbglGRTOaR/Xz9OkRXIvF7k0b
         Ah/g+c3esfGzqVES5VRKtJ7p4pPfjSTa2Sb5eLncBfFh4LSw1n8fk72XKKx/03e+N6Aa
         LmGQ==
X-Google-Smtp-Source: APXvYqy1NouX9k2wgafeV1ABXeztSNXyhgk4bnippRUInrONZlwFZn4ypyphRPbcnEpCMfQ+hVo6tw==
X-Received: by 2002:a63:3805:: with SMTP id f5mr28163350pga.272.1563643941385;
        Sat, 20 Jul 2019 10:32:21 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id l44sm30570928pje.29.2019.07.20.10.32.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 10:32:20 -0700 (PDT)
Date: Sat, 20 Jul 2019 23:02:14 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: ira.weiny@intel.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	Matt.Sickler@daktronics.com, jhubbard@nvidia.com
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux.bhar@gmail.com
Subject: [PATCH v4] staging: kpc2000: Convert put_page to put_user_page*()
Message-ID: <20190720173214.GA4250@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d ("mm: introduce put_user_page*(), placeholder versions").

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Matt Sickler <Matt.Sickler@daktronics.com>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
Changes since v1
       - Improved changelog by John's suggestion.
       - Moved logic to dirty pages below sg_dma_unmap
       and removed PageReserved check.
Changes since v2
       - Added back PageResevered check as suggested by John Hubbard.
Changes since v3
       - Changed the commit log as suggested by John.
       - Added John's Reviewed-By tag

---
 drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
index 6166587..75ad263 100644
--- a/drivers/staging/kpc2000/kpc_dma/fileops.c
+++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
@@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
 	sg_free_table(&acd->sgt);
  err_dma_map_sg:
  err_alloc_sg_table:
-	for (i = 0 ; i < acd->page_count ; i++){
-		put_page(acd->user_pages[i]);
-	}
+	put_user_pages(acd->user_pages, acd->page_count);
  err_get_user_pages:
 	kfree(acd->user_pages);
  err_alloc_userpages:
@@ -221,16 +219,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
 	
 	dev_dbg(&acd->ldev->pldev->dev, "transfer_complete_cb(acd = [%p])\n", acd);
 	
-	for (i = 0 ; i < acd->page_count ; i++){
-		if (!PageReserved(acd->user_pages[i])){
-			set_page_dirty(acd->user_pages[i]);
-		}
-	}
-	
 	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
 	
-	for (i = 0 ; i < acd->page_count ; i++){
-		put_page(acd->user_pages[i]);
+	for (i = 0; i < acd->page_count; i++) {
+		if (!PageReserved(acd->user_pages[i]))
+			put_user_pages_dirty(&acd->user_pages[i], 1);
+		else
+			put_user_page(acd->user_pages[i]);
 	}
 	
 	sg_free_table(&acd->sgt);
-- 
2.7.4

