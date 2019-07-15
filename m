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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60534C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 195882171F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:49:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lSaOVEZx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 195882171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADF0E6B0003; Mon, 15 Jul 2019 17:49:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8FF86B0006; Mon, 15 Jul 2019 17:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97F1F6B0007; Mon, 15 Jul 2019 17:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE816B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:49:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so8956365plo.10
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=oinAVDdEDGtey1Xr7e/GPvK2Adfq62yyiXEFUaR6hwI=;
        b=g8/MLkH+Qbdrod6mKWLy6XxBmt4U/qO2RZlrn9n190KpvL/VRlAAsxsrILsWlY1fPP
         c21hWfMtuuwi6z1s+gu4LgYDrtBwQrKzP4HoG1nIMlZwdRCOLcFWMR7nKr8LkkWKaf/E
         XEwkU4XcVncbbqQsWmh7PqQg1N7k2X9cxEKB0iqRkpxlJGdQtCHAM60VW2HbAeQtcyio
         08bpNbk1/BELVRSFAvgXjA5oXOTig6zBfzQyNmU5DsbhfDfUB36rPSs7eJWw//4lpB9+
         zqznNqyxgUjJlHcfSMhaaAxZOf7j2EJHvh294W9AxuwV7zYvG+z9fdPhVWrPAWGXFBku
         7gLA==
X-Gm-Message-State: APjAAAUotvBQ5rxwyClnc8n3DZf7egJDXVm6FvWC6rfIoStusbwKMJSM
	lOZIicGtkIS3Z4GWqstFlP6y4INxu/hcBFW07n2bGLGbbctqSX5Rwv7UOsXOpHM91BBv/eB+Op5
	twmgAcLNRHSmkLFP0EQwzEeNMJl0at711bX+z8s7aUFPIwnjrqrzT8IcquyJN+OzCnA==
X-Received: by 2002:a63:d30f:: with SMTP id b15mr28950838pgg.341.1563227375791;
        Mon, 15 Jul 2019 14:49:35 -0700 (PDT)
X-Received: by 2002:a63:d30f:: with SMTP id b15mr28950771pgg.341.1563227374498;
        Mon, 15 Jul 2019 14:49:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563227374; cv=none;
        d=google.com; s=arc-20160816;
        b=Xwsn43NHGPj0shGr9+evOVfx3xDaly8bfG7/XCCr3zpJBKGzyFJvkEBetQrcEW4Xey
         JoZuVIx4j5F00cyMRlG/ylnUPJQTEJPoFRKFJainNC54DO+EALm6MnU26th3UGLhMhyL
         jC01hb2UzwwYKeD+U1SxAhCZtZSfA8RlOARqJJDmmGYnPH+fUgutiPzMyvzrgrcR5Lw+
         hR1t3htNNxfObC47nofzeNaRkdF0Q32hvGg+yIjUKpsEi1v76iGnFZbuGhftw7LiC4qp
         80j5WuEP0todrql+VtaGPt62PSjYQNsO6AFla+HNQbBBUJ8EcyyPc5W9UdBDVsPG7EXk
         0a4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date:dkim-signature;
        bh=oinAVDdEDGtey1Xr7e/GPvK2Adfq62yyiXEFUaR6hwI=;
        b=PgZ9scUKQXzPi7bo+9aG6nyLyHNElKS0ZXgEBp6W98OEpyThV4bh82mnF/62fPoQMe
         zvGExX47gLRzflmNuS5Nyqe67Ipx4uecQm7DBRzjnt6732tWzqc9pqNntNtJBDg0lLIe
         /6KwUvrfG5px6KqEIjd+W3kEDNsicHe01n38bMWlhKkpIJIcYlMbdGzcg+0wkjjaj8Sm
         xGV+1feKm/0WqaAfF8HAb5cf0AFOlZwX8YiPe974COocslKbwbLN8g0QUg1FfmkOhuJv
         kos6sI8EHE1tgOSsHCGLgYsAk7UzdzVzpvJPbyJqxAqOKgPyKDYoJDTUz7gcHbjLsyW7
         EN6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lSaOVEZx;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor22327264plf.60.2019.07.15.14.49.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 14:49:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lSaOVEZx;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=oinAVDdEDGtey1Xr7e/GPvK2Adfq62yyiXEFUaR6hwI=;
        b=lSaOVEZxxYEquXCqQBG9SYGwG6t1vNg5IwoDUHqEvVIVJhOJlwBY9FugfmiKkRP4f9
         bXyF67J6jg2jl8nfMgv1KWkCx6N17R7M+dlEe5Z43adeIJaqjWjFfqTiLZUywXyLNHlK
         7MYSlSRi8Y0ZlGG9OjlxUoyEB5dRd33OkmEmCOeSVcrNzEnaZhjMNtoQ5rp+VHiYpo8l
         5OXqZqytZ+NvLskxl+Sy/353FjNs/uWn8ngNxEqq1K84N7F4EHUaX51GrZVgm8AqHYmG
         BNOH1MlAf/PKQmF3h2Y1vn/leJyYbowl0Kt6aloRxdGUd1csJequKM4S+3/jQc8TzyeM
         8TkA==
X-Google-Smtp-Source: APXvYqxWZCB5othLdOpAzVbLNid2vDo95VYJQsCqTTyT13mpLHDfYQvvAWW2OmRXbPSMrSLgUWUbVg==
X-Received: by 2002:a17:902:a606:: with SMTP id u6mr28487937plq.275.1563227374215;
        Mon, 15 Jul 2019 14:49:34 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id b3sm27375833pfp.65.2019.07.15.14.49.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 14:49:33 -0700 (PDT)
Date: Tue, 16 Jul 2019 03:19:26 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Matt.Sickler@daktronics.com, gregkh@linuxfoundation.org,
	jglisse@redhat.com, ira.weiny@intel.com, jhubbard@nvidia.com
Cc: linux-mm@kvack.org, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] staging: kpc2000: Convert put_page() to put_user_page*()
Message-ID: <20190715214926.GA29665@bharath12345-Inspiron-5559>
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

The solution being proposed wants to keep track of gup_pinned pages
which will allow to take furthur steps to coordinate between subsystems
using gup.

put_user_page() simply calls put_page inside for now. But the
implementation will change once all call sites of put_page() are
converted.

[1] https://lwn.net/Articles/753027/

Cc: Matt Sickler <Matt.Sickler@daktronics.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org
Cc: devel@driverdev.osuosl.org

Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
Changes since v1
	- Added John's reviewed-by tag
	- Moved para talking about testing below
	the '---'
	- Moved logic of set_page_diry below dma_unmap_sg
	as per John's suggestion

I currently do not have the driver to test. Could I have some
suggestions to test this code? The solution is currently implemented
in https://github.com/johnhubbard/linux/tree/gup_dma_core and it would be great 
if we could apply the patch on top of the repo and run some 
tests to check if any regressions occur.
---
 drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
index 48ca88b..3d1a00a 100644
--- a/drivers/staging/kpc2000/kpc_dma/fileops.c
+++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
@@ -190,9 +190,7 @@ static int kpc_dma_transfer(struct dev_private_data *priv,
 	sg_free_table(&acd->sgt);
  err_dma_map_sg:
  err_alloc_sg_table:
-	for (i = 0 ; i < acd->page_count ; i++) {
-		put_page(acd->user_pages[i]);
-	}
+	put_user_pages(acd->user_pages, acd->page_count);
  err_get_user_pages:
 	kfree(acd->user_pages);
  err_alloc_userpages:
@@ -211,16 +209,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
 	BUG_ON(acd->ldev == NULL);
 	BUG_ON(acd->ldev->pldev == NULL);
 
-	for (i = 0 ; i < acd->page_count ; i++) {
-		if (!PageReserved(acd->user_pages[i])) {
-			set_page_dirty(acd->user_pages[i]);
-		}
-	}
-
 	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
 
-	for (i = 0 ; i < acd->page_count ; i++) {
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

