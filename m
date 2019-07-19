Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F0AC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 20:02:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C41222189F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 20:02:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UGjkJsZM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C41222189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 216AD6B0005; Fri, 19 Jul 2019 16:02:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C7D16B0006; Fri, 19 Jul 2019 16:02:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B6DC8E0001; Fri, 19 Jul 2019 16:02:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C96E46B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 16:02:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so19304236pfj.4
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 13:02:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=5N6LdOFrJjCGue8cmzcmZMQF0A64ylNe67FM2v5UYwc=;
        b=dQXEkhbITPTKRlscQ/f4eOq3U4PbhaGMs+KVobHaeEJ62eQ8LRj+WYPXt0ZQ1AWp66
         pK79ZyjkGPy5iMT0EGmhbFh4Z7n78jJU94B5XGI4CuQpOaDejXDB3vTlwVUG59rcI9tW
         SgdoRCp4dKO996oeuYRpTsR89MR12YQnw3XgyinJqcPI5ad2HJF0P3nO9/c/Oc8Nx74k
         JIzbt0wnMTO8H/eZtklKIUl/Au5Q/YS/mNBGrQcFgpkVmAZ6NwxaxT/Nc5Q6jB7hMVbO
         qO2TfkFEEvf0z954OE8G2ynkiyi+4GWWNv2COEq16gjPF/3O8TANXV+mhy5KAd9aPpZU
         NiNg==
X-Gm-Message-State: APjAAAVWG4CC/XjmWrYGmDY5XH95xTfqBXCXczrpPk5gu6X5F17khz4P
	b6U3/yQ3Hf+VbsqVXsojwIMFqlD/2eeKxfJrNUqj4xfv6krnImP2Gy7vLdtnx6ouU9DuEt0BjVN
	4ig1+KvnouahgaI5mocdBER1lOoiPh/fpYOPJsKG8tN09wPYWbAXX9sH1exeTQS47aQ==
X-Received: by 2002:a63:ec48:: with SMTP id r8mr28401064pgj.387.1563566566146;
        Fri, 19 Jul 2019 13:02:46 -0700 (PDT)
X-Received: by 2002:a63:ec48:: with SMTP id r8mr28400952pgj.387.1563566564595;
        Fri, 19 Jul 2019 13:02:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563566564; cv=none;
        d=google.com; s=arc-20160816;
        b=H1xTrBBVEMBJugza2yC86kQsiZX1ylJmJaikJEjnixrvh+wzUhxu+KK1ZNsNMb8fek
         V/Rb+SzGmgrFERTCCYWNPaDSyJZlGBN/PFjF2eIMNVCSIQYY3LJCJOsAb0ABsuhYjPqG
         jr6G2MbQt/OSjzrXJiRD7T2nplK0HOMYVfxDuTnsVqsQTWrB7ZwQtPJoUUjkn6rCZbNw
         VSRcSgV2eD2MD5HS9S2/+D2Gqimn8Y61/uU2ScGMJ1WXKkzkvPOiEhl+Wxl88vYzECL1
         mZeKt0xrjNRW3xVWyypKMqGMIMYrTfmuHB3scMz65Kz2IOjvfrPST1JSJxpjlpKd+lpl
         EMqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date:dkim-signature;
        bh=5N6LdOFrJjCGue8cmzcmZMQF0A64ylNe67FM2v5UYwc=;
        b=U5vIdf6GZFff72qO0Z1Ahn6h15W9Ij5uQ/wfJsxHSnD3h9cOgwR++5+VW0KPw/t7fR
         SwxPXeumfzpRxpfvqYPR4qUIFM4HQO27n48oZwQm61tBHJbFUQM8YJWeR0iBKudqks2z
         4AmeKSiLPHttn9KhjTSpS7YyASg544dvCyMDHZ+LydGIn5AfOwbAG1m/TI/kmL/0RbSU
         7v+bnbnB1+tRPKyEcD6PVTNIIpHbacZ1kqvxx5/bCg1Es+uxYQ+mu8e71+znS9CBP/J7
         n4PkaekzjJAblyYAbQdZ2PX1vbY/Nrcd7gZClI4fp9gPMBWi3BtfkCUUR6A5zXaXdyIZ
         qQ8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UGjkJsZM;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r202sor17134118pfr.51.2019.07.19.13.02.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jul 2019 13:02:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UGjkJsZM;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=5N6LdOFrJjCGue8cmzcmZMQF0A64ylNe67FM2v5UYwc=;
        b=UGjkJsZMA2fiZtIAfmbFGijLgKyG17B3eQ5YtmodVmWNxm4QJS+OfEyZ+Yx0rDQby2
         gnj1ZAjcG7OI7VSuae91ptxx0prbKEh6VLzS2BftpTlOw7ct6KvfS89UEMgXf3CKrAUm
         VaSB94oa9pL4apBBZkcMyNzGYnpzyBzTuQq30KTDOHMXp7Xb9c9oc9841+wEnQyr+ujd
         Q2anwrvnoScMKEKCNV3+pPM0tIGmNLbdiVFoc3Mc4Omod3QzKFB5m7AZ+WgiGgw39cIs
         N8SknDNp4z08kAzx0YLMPgaREHUUUqxXxTMX9u3ky5Xw4RULICCNa2aGIxbU5/gx3dQE
         NTYw==
X-Google-Smtp-Source: APXvYqyUkjtJ5/kr1NKh5evL+FbdXcRYyIgbQbmLhNrEiZG/igGdTIgx+LqU2x5WMPCYNej1LAZAWw==
X-Received: by 2002:a63:f807:: with SMTP id n7mr57629925pgh.119.1563566564159;
        Fri, 19 Jul 2019 13:02:44 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id c8sm37375979pjq.2.2019.07.19.13.02.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 13:02:43 -0700 (PDT)
Date: Sat, 20 Jul 2019 01:32:35 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: jhubbard@nvidia.com, ira.weiny@intel.com, jglisse@redhat.com,
	gregkh@linuxfoundation.org, Matt.Sickler@daktronics.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org
Subject: [PATCH v3] staging: kpc2000: Convert put_page to put_user_page*()
Message-ID: <20190719200235.GA16122@bharath12345-Inspiron-5559>
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

There have been issues with coordination of various subsystems using
get_user_pages. These issues are better described in [1].

An implementation of tracking get_user_pages is currently underway
The implementation requires the use put_user_page*() variants to release
a reference rather than put_page(). The commit that introduced
put_user_pages, Commit fc1d8e7cca2daa18d2fe56b94874848adf89d7f5 ("mm: introduce
put_user_page*(), placeholder version").

The implementation currently simply calls put_page() within
put_user_page(). But in the future, it is to change to add a mechanism
to keep track of get_user_pages. Once a tracking mechanism is
implemented, we can make attempts to work on improving on coordination
between various subsystems using get_user_pages.

[1] https://lwn.net/Articles/753027/

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Matt Sickler <Matt.Sickler@daktronics.com>
Cc: devel@driverdev.osuosl.org 
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
Changes since v1
	- Improved changelog by John's suggestion.
	- Moved logic to dirty pages below sg_dma_unmap
	and removed PageReserved check.
Changes since v2
	- Added back PageResevered check as suggested by John Hubbard.
	
The PageReserved check needs a closer look and is not worth messing
around with for now.

Matt, Could you give any suggestions for testing this patch?
    
If in-case, you are willing to pick this up to test. Could you
apply this patch to this tree
https://github.com/johnhubbard/linux/tree/gup_dma_core
and test it with your devices?

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

