Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98CC1C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:53:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5350120665
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:53:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y0+6yg5u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5350120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0B056B0003; Mon, 15 Jul 2019 15:52:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBBB16B0005; Mon, 15 Jul 2019 15:52:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD18F6B0006; Mon, 15 Jul 2019 15:52:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88FB86B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:52:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so8802457plf.16
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:52:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=VvTFFsjpspmxJg0Zk+lQCOkMvx372OdaubqDPGmaJoo=;
        b=EHvFlukOaRgnWAcbB6RuBaeJe02gUs1XLCvw29Mxc9N2jfqTh3NmOHUHXbrgaujh8n
         nPU/nbKu5xMd0rcE7S/jz62Pqii8mQDJPGbd2Q8vhUH9vFwx62ly2CBrlRECj4Siund9
         8YqACi0DBKg6Iqj+W2w39SwFHPQ5Ik3cIUgpFZ4SrD+Y9S4OPcmrnlA0IVPKXGyN/IMY
         2qkH9o+1RzhtVtcB+7XGsO3njn29DZBodHmSiA8hzqG+QCJlAePVlH7xsWhAizYI/0Au
         Y3dhrYmfffESuKq9oJMM2WCNrIX44Hq//5A0r7oXc9zvNFA4oz7ofVbNHVgfWBp0UofW
         PbaA==
X-Gm-Message-State: APjAAAUeQe0luZpyUFOcTslQz3RhSbhlNSX27rvuPOq2v3CZVm23I1D2
	GmazNH1mIJhGOCZvN3GEddLscrxOu2SdkDwxeEA/SomsxaIUBQphM+01qdkOemQgnEG1NZ7xY5n
	ItNz1KiDM300tp+ep2fwCVc+eJRfdgFCmROqVA93NlIMVC1y/M/SMm/R9OOAejCPSTg==
X-Received: by 2002:a63:2f44:: with SMTP id v65mr28273411pgv.185.1563220379023;
        Mon, 15 Jul 2019 12:52:59 -0700 (PDT)
X-Received: by 2002:a63:2f44:: with SMTP id v65mr28273340pgv.185.1563220377842;
        Mon, 15 Jul 2019 12:52:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563220377; cv=none;
        d=google.com; s=arc-20160816;
        b=XTD1ZRbDhxnEk1TJLjNAUaT+AkzlwCB5FgFHweSYsgmpybNSLrsUBp+/GlvIVlD1sO
         7lYGDNcvhOxhMUtX5Uf03uFsF9STTuV7VZ1ClGqMV3ERbB3WrTSrl3r6+bmzGR8OIHoR
         pKsIMZT8H5pJ7ffY82b4ctFGEGRuK/1WXTiHw5zQ1dIPEyM8v9QwUkl+dNaT+igoWeCP
         ZYVvvPkfxkvGZenwCwSYS4yxiDYYhrm+glzB1ixRT0XNG6tVTIBTrwRAfsAL+3oeRg2r
         RmbLevBxyjtIzcP0QcZYraleOEubgLHW6359Lxde2sBJQZi4kB0snliiqF5jmL0zS6LL
         0s3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date:dkim-signature;
        bh=VvTFFsjpspmxJg0Zk+lQCOkMvx372OdaubqDPGmaJoo=;
        b=07a7/WIcmvFnM12ghzT+JmAswxiWBVTSlWCb1lLSRIeTS2ONY5cLSN0O2zUW+WhtIK
         tZ7FcKj8fCcZTSnexnPdxlKyFk9D8MHbTdQZcxZNHPsIcpzj1uZUs/HZUmkhcWor8GOU
         dCMRBAmJjh9OhKMIbhPvGfz3/uNy8I6wbJDH+I5UXKbBjNs/qmeMA1QS8dyoym843hLX
         nAZZohfiMB9U80sa7/hALrtaAC3syxx1LUW9AYQTYBUiG99SUnhyLeH9y+DnA7lj3dE/
         XBeWY1W7PGt0SswTce53dPyr74vAbsL64rRagpXLvVQ/fYTxi+yCoBAlzqQMbw3NK0Bx
         lrRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y0+6yg5u;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u13sor22503329pjx.25.2019.07.15.12.52.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 12:52:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y0+6yg5u;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=VvTFFsjpspmxJg0Zk+lQCOkMvx372OdaubqDPGmaJoo=;
        b=Y0+6yg5uqNAPdQD+ah/uXtJodBiOu7qXGUZsamO3dQTNlZJzjg4Ek26PN9sH6cPymb
         yvR0TfhEiZSxvEWJREY4WRbKyM9hxRYvEyrRK+nFIVTjd5wGPQeM30hJAvFss33qjOr6
         a5lf0Z0h0i0GZU8VbvfaF5gPmTNLiJIByg5+vUiVbxaIVScuLtuDWJCmBENGOlV8KHVP
         myqNj9DcwuUhbVYJHd/itZBOFC97cVLWqm1lHnGNzPoaLmMwYpW6KTiRNUSyzsRHwMI3
         QJzx5hp785DtFA36ySOTX7rwRUUC/c5ya6BCZiOXxIALW7dYtFG/We6ISxZhV9/cZeit
         dtwg==
X-Google-Smtp-Source: APXvYqxtbt1CwITtkPLgUNHbiaJHv2JbNvwx/AC2tPpYW32s+HW5FL1w8utKSmIMyppuIpJFC7FuGg==
X-Received: by 2002:a17:90a:5288:: with SMTP id w8mr31337291pjh.61.1563220377447;
        Mon, 15 Jul 2019 12:52:57 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id u3sm15869368pjn.5.2019.07.15.12.52.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 12:52:56 -0700 (PDT)
Date: Tue, 16 Jul 2019 01:22:48 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: ira.weiny@intel.com, jhubbard@nvidia.com, gregkh@linuxfoundation.org,
	Matt.Sickler@daktronics.com, jglisse@redhat.com
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
Message-ID: <20190715195248.GA22495@bharath12345-Inspiron-5559>
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

There have been issues with get_user_pages and filesystem writeback.
The issues are better described in [1].

The solution being proposed wants to keep track of gup_pinned pages which will allow to take furthur steps to coordinate between subsystems using gup.

put_user_page() simply calls put_page inside for now. But the implementation will change once all call sites of put_page() are converted.

I currently do not have the driver to test. Could I have some suggestions to test this code? The solution is currently implemented in [2] and
it would be great if we could apply the patch on top of [2] and run some tests to check if any regressions occur.

[1] https://lwn.net/Articles/753027/
[2] https://github.com/johnhubbard/linux/tree/gup_dma_core

Cc: Matt Sickler <Matt.Sickler@daktronics.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org
Cc: devel@driverdev.osuosl.org

Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/staging/kpc2000/kpc_dma/fileops.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
index 6166587..82c70e6 100644
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
@@ -229,9 +227,7 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
 	
 	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
 	
-	for (i = 0 ; i < acd->page_count ; i++){
-		put_page(acd->user_pages[i]);
-	}
+	put_user_pages(acd->user_pages, acd->page_count);
 	
 	sg_free_table(&acd->sgt);
 	
-- 
1.8.3.1

