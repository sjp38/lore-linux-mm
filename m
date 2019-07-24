Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99DF4C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:16:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67A5A22ADB
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:16:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67A5A22ADB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13D6F8E0006; Wed, 24 Jul 2019 10:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C7258E0002; Wed, 24 Jul 2019 10:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA9348E0006; Wed, 24 Jul 2019 10:16:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C48748E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:16:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so28641948pfv.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=EekXmR5Bri93vUaMAziD1lKFG8IDX5FLgIF5eoQD+xA=;
        b=E5n5c/nD0ZGAmLsHmJOrE2AQMZPvubVWQVk7tDggK4ZiTuMWnz+hHCqdp3aDb6R926
         HxDnRsKa3azwo4VAAioNZDmnkADLsw6A/WyxBLe76qlWqkxNfSAg0lTvmZpCXZahky9Q
         J/KOz1mO7ISHwnjh+OigVV+cJTD8ZiAhuZxYk86XLxAeD7YebR63kpJfcP9D/hdSgNJ5
         T+xVp71mL/uS+iw6r+gmA0bHsfcY7JT/Iy2CHoXYoU/4SBDBCiKBKq3PfZh9RYX1N2EB
         ukR9qVLYyjVfInjuGrn1PNFVMzSfH5k18lcu1+J4dUrvKOHi9UzFAsIx0bSrwSl5nzlh
         ngVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
X-Gm-Message-State: APjAAAXoWp/vcpgNwLGRlF4WHVoQrvqp+PnhfIpD4Z/Gp9vonr2rFkSb
	+1ZVZZbufMVxE3pGzJ84Q6nwDgnjliC4ILq1rqcFgrKF1Jmld80dgVbvCWgHIaiuX6wmylYnCOM
	Ypy3uPWcLfk4v4/1+7Da8VoC21DsAmxFUYF/Eefyc8wlJ1EaoiFzs7fzkfH0XxvWtJA==
X-Received: by 2002:aa7:8383:: with SMTP id u3mr11619269pfm.175.1563977770483;
        Wed, 24 Jul 2019 07:16:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAg+z93/9D53a53W4/uGSvsUdLBMKJF/tjLAtToXZcYfETy6cSGC5E6b4l1A6TLRuKi2K4
X-Received: by 2002:aa7:8383:: with SMTP id u3mr11619206pfm.175.1563977769845;
        Wed, 24 Jul 2019 07:16:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977769; cv=none;
        d=google.com; s=arc-20160816;
        b=UaCwRe68JlxqZoKXbRYIbeAN4AH3nhvuS6rtIbB1boxJ7pbrqaPSP3gluwvw0wspV0
         LC8FQgWiMP3P7o9nx660SLS6ZaJmyyLgXNC2BPz9jGCpKeH6of516d5OW+XslpyL+S2F
         elIUcty7qDDEWEgd8s/CZoUoJi+b4HlVJIls2+kH71kDCTgqLlYtmEOVg6kpTTaB3/77
         unO6axxiQ3BjVbNPvaZ7PIhWcH8B9uNzPBjCR0CzGCDXG06wdunvwqRmwEwrfTOZACdM
         v55ypMHG8cf8/u154fz50klLyVAQmUt5zk3tzveYXDW/Y17EP1hxxNHhCgeni2X0L6Xn
         1vtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=EekXmR5Bri93vUaMAziD1lKFG8IDX5FLgIF5eoQD+xA=;
        b=dFK7hDsNk4TF9w0dHAJ5q/9Ol0N1wmXqHj4lzMeUz4SUl5xepL3elRgn17f4J8RbLp
         3FCeVYQIaFCuBPUO9ICsNpd3NrdjDEfsshDR9RIYpQZabj73YqY9c3n9uHXZckNT3KIn
         jL2o8QIchl3fBW3BnhB7TB/b8HqDvL5KfQI28sF5sZnkVl+eejOBHJI68LqJhbdBw1gh
         lRU6bvjZqsJruBx/a1JIP7/ft9u2ZuW06nC3EeB2nRHNnUAd9G7/T23Nemw1Yx2+Fmty
         IlC/6WMUato3G0lRbybt3UzbrsJysl+64hxuC6aPA5YiKKqPajrnjwdaLPC218TqsQk+
         YdLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id 1si15321695ply.180.2019.07.24.07.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:16:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 69C3A31B2A1EFBD16A29;
	Wed, 24 Jul 2019 22:16:08 +0800 (CST)
Received: from localhost (10.133.213.239) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.439.0; Wed, 24 Jul 2019
 22:15:59 +0800
From: YueHaibing <yuehaibing@huawei.com>
To: <akpm@linux-foundation.org>, <jglisse@redhat.com>,
	<kirill.shutemov@linux.intel.com>, <mike.kravetz@oracle.com>,
	<rcampbell@nvidia.com>, <ktkhai@virtuozzo.com>, <colin.king@canonical.com>
CC: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, YueHaibing
	<yuehaibing@huawei.com>
Subject: [PATCH] mm/rmap.c: remove set but not used variable 'cstart'
Date: Wed, 24 Jul 2019 22:14:53 +0800
Message-ID: <20190724141453.38536-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.10.2.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.133.213.239]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fixes gcc '-Wunused-but-set-variable' warning:

mm/rmap.c: In function page_mkclean_one:
mm/rmap.c:906:17: warning: variable cstart set but not used [-Wunused-but-set-variable]

It is not used any more since
commit cdb07bdea28e ("mm/rmap.c: remove redundant variable cend")

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 mm/rmap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index ec1af8b..40e4def 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -903,10 +903,9 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(&range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
-		unsigned long cstart;
 		int ret = 0;
 
-		cstart = address = pvmw.address;
+		address = pvmw.address;
 		if (pvmw.pte) {
 			pte_t entry;
 			pte_t *pte = pvmw.pte;
@@ -933,7 +932,6 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
-			cstart &= PMD_MASK;
 			ret = 1;
 #else
 			/* unexpected pmd-mapped page? */
-- 
2.7.4


