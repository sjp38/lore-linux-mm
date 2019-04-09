Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FA01C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:53:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ECD52077C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:53:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ECD52077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91ABC6B0005; Tue,  9 Apr 2019 13:53:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C8E16B000D; Tue,  9 Apr 2019 13:53:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B7B06B0266; Tue,  9 Apr 2019 13:53:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F56B6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 13:53:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 75so15270911qki.13
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 10:53:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=9YdxBk6Mw/Z7Cac9RuiA6ray9gPpGcdj9217j/mtpLY=;
        b=WQEOjGn8ICbQE4Oc5o5id7HVDKI42+v3JoJZcXiO3Bi1Coi75z56V6DNiC8ZccC1I4
         U+APFXs7CPaQps3y5KEg6NF5uOGgVw/YlclgF3yy5VlFMEC5GXjsKL6V50fcDCmhemF/
         ZYlLO+Q/omgrqEzlLw8klMN9751W9d+bCy7icKf44oOF9ec34h0Q11+pyridgtBsGSD+
         jITOUTuznXKgr+3iHgkWMeOMiWTBm+99fLqClBGt6cejpze0Kf6HnzTD1dp9zn+50iwI
         vJCTTzs085CsEL+agAiysmvjZKAx5hmejyFTOemT8OUobiaDMiOtYtHGS3LBp27dSsjb
         IE4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX4dHPxUttsuKmeTaDD+lrUbp/onMfWJyvQ3oR6Z9TLmME0TkgX
	aXTDzhEnOzoQDXW/m307Cp6HvaVkqMXsjCEmTTd2iTfnbfwgZBWq97RtftJOZ/T9J+Da2PQNv8C
	1X7KIRRMpGayelJJT01hU7fzQk15cMuQaxldApKAMhqeuZhQ0YVWJEGPsGyuBza7ETA==
X-Received: by 2002:ae9:f308:: with SMTP id p8mr27802598qkg.33.1554832428155;
        Tue, 09 Apr 2019 10:53:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTnR5G7k6wI0Ene+aLg0IsZ6munxR+XREkKL9awETnTBIX6j2mXakqQTIuPVHBRZBCS5pm
X-Received: by 2002:ae9:f308:: with SMTP id p8mr27802514qkg.33.1554832427011;
        Tue, 09 Apr 2019 10:53:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554832427; cv=none;
        d=google.com; s=arc-20160816;
        b=iRisrsB/miW5XZ7f3PF43+f6L+PmRfiZo4E16KFdJUvlr3T/BFthYceV7TSIpb+1h3
         lb0btsiZIfSdcWF1B6MRab1lyT3LYdDHZe70X7XtnyplPDDQI+1ekDRmG6ahENu+ZyH9
         l/fyQ/GQCNa8h6+MhbrhMSIdPuNv1+YjoQuREt70tg+1r4f6dAq9GDowmfwyVk94+qrS
         84LTNq4NMhcpGRcMI+45/hY7+qFiHCPXL8PkazjrEPSKpYjGtBnFf9xwahOUPAAaCm+c
         cVaNK3UULUtO59fImDbhzjdCqCsb6vXMeHlpSglamB3zpOUYwvUOnHRGdmg3SQ3bl03X
         J+jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=9YdxBk6Mw/Z7Cac9RuiA6ray9gPpGcdj9217j/mtpLY=;
        b=NzVzjbfkCRid7eyyJs/uu31TEHB/l6YQ/yfKs0hYm5TaQxWsFTsBVIgoVZy3AMPbAI
         UVGa9dtwHhsg+LQ6u42t01JlyTCBCQV7Onbh2YP48XmpHNzM3jtBnUR9X6LNSxIzVOzV
         kGF7LW9Cnd8MjFmikMNlvCh7yqgFZUUKyQ65ub60K/K7962Jjyn5UQhCQBUy/fkGtZ/C
         E5bFFOnUK39/O5biZq0Hocw9JGGDQPK6hFKM/aaYk50d1ww7iRJ+hJ6afSbSB8e3Xyno
         seewgeJg7Mv+wO04Tkc+3EhG9qaom7u3C5wR8Fzq38CaCu8+zkK019Pse7mIh7qmZay3
         tvaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v195si5323970qka.194.2019.04.09.10.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 10:53:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4AC7B88AB7;
	Tue,  9 Apr 2019 17:53:46 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 68FE717AB5;
	Tue,  9 Apr 2019 17:53:45 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH] mm/hmm: fix hmm_range_dma_map()/hmm_range_dma_unmap()
Date: Tue,  9 Apr 2019 13:53:40 -0400
Message-Id: <20190409175340.26614-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 09 Apr 2019 17:53:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Was using wrong field and wrong enum for read only versus read and
write mapping.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 90369fd2307b..ecd16718285e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1203,7 +1203,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 
 	npages = (range->end - range->start) >> PAGE_SHIFT;
 	for (i = 0, mapped = 0; i < npages; ++i) {
-		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		enum dma_data_direction dir = DMA_TO_DEVICE;
 		struct page *page;
 
 		/*
@@ -1227,7 +1227,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 		}
 
 		/* If it is read and write than map bi-directional. */
-		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
+		if (range->pfns[i] & range->flags[HMM_PFN_WRITE])
 			dir = DMA_BIDIRECTIONAL;
 
 		daddrs[i] = dma_map_page(device, page, 0, PAGE_SIZE, dir);
@@ -1243,7 +1243,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 
 unmap:
 	for (npages = i, i = 0; (i < npages) && mapped; ++i) {
-		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		enum dma_data_direction dir = DMA_TO_DEVICE;
 		struct page *page;
 
 		page = hmm_device_entry_to_page(range, range->pfns[i]);
@@ -1254,7 +1254,7 @@ long hmm_range_dma_map(struct hmm_range *range,
 			continue;
 
 		/* If it is read and write than map bi-directional. */
-		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
+		if (range->pfns[i] & range->flags[HMM_PFN_WRITE])
 			dir = DMA_BIDIRECTIONAL;
 
 		dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
@@ -1298,7 +1298,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 
 	npages = (range->end - range->start) >> PAGE_SHIFT;
 	for (i = 0; i < npages; ++i) {
-		enum dma_data_direction dir = DMA_FROM_DEVICE;
+		enum dma_data_direction dir = DMA_TO_DEVICE;
 		struct page *page;
 
 		page = hmm_device_entry_to_page(range, range->pfns[i]);
@@ -1306,7 +1306,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 			continue;
 
 		/* If it is read and write than map bi-directional. */
-		if (range->pfns[i] & range->values[HMM_PFN_WRITE]) {
+		if (range->pfns[i] & range->flags[HMM_PFN_WRITE]) {
 			dir = DMA_BIDIRECTIONAL;
 
 			/*
-- 
2.20.1

