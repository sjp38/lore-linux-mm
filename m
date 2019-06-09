Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EF7DC28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 09:16:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0315920868
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 09:16:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0315920868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88B506B0005; Sun,  9 Jun 2019 05:16:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83CD86B0006; Sun,  9 Jun 2019 05:16:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72AC36B0007; Sun,  9 Jun 2019 05:16:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 556136B0005
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 05:16:23 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id c64so1741789oia.22
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 02:16:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=a6ykraZL2w3qugLF8FyjtO6T7aloAveG26BZNEMnWFY=;
        b=M4vtMkOgGOmYUp9P1e5sG80o+vDHF2Ip4NuD4ALGM311Bz51AeMEqHThbADyRoLkTZ
         pcL9uWzBqnr3HPpFwBEivvaVEfGsM4vxXP3Xl1mClOTrDNyhjMyokMFFnOEVAflA9moh
         l5rakRTHFOZS+qOHn/WwAtSgQveyy8hpOVX0FEIi38cax+cnkcqtQ5Hr4ZKwKNfj0Wpu
         G7DOfAd/I0UWZ4wAfFA6riSSbR2+XiclImbQfbppckrM6Bb1T7UNsjqlYIN087MR+AuV
         bE583YamEJIilgCndpkvbHty6sjpuuDBnE4m0r8pStpyzVRyk3UVpPej91vOhVTTTMBH
         KX5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
X-Gm-Message-State: APjAAAWa+fzb4Jn4eZtyA31U98Lpdb+WYX5VnRUskrz0DLCgfsasw2di
	0L9wP0FhWQBNsGI7tZZqXxL/PWoGOEPetYm6sB95bsYe2MQ9HaKp3+XyHKnM4e7i8Gm/zdvzSuN
	jiqo1BZ5NckhGrPSTyY0UOT57o2MNyJKicrh0c3M7EAIP8CPXOhyzQnEAIQwDi5xJPw==
X-Received: by 2002:aca:d846:: with SMTP id p67mr8937893oig.6.1560071782935;
        Sun, 09 Jun 2019 02:16:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH0f90hMiq64tuDv/f9NFdV4iOKCzRS/b2nmGU/a/Uau+TqI5RpPOz52NGI2N7H6ZDawhx
X-Received: by 2002:aca:d846:: with SMTP id p67mr8937884oig.6.1560071782284;
        Sun, 09 Jun 2019 02:16:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560071782; cv=none;
        d=google.com; s=arc-20160816;
        b=0FnTVjgcZoUgctDfitwSya1mYFgHCBLU9gy8muHMFSyoK1GaeVUlvjaF5Ehk/XmN+Y
         q8qwNIQwCn7sMn0DwNcRf6MkHcB3V6dO7PtP/qRRZxEq1VYgCMAk/l+1dGJi07VJMy8+
         VkCDn+4iqehLkKekgj2fEUwxvRyhwn1J6pGtJOGrf6OIPvcul3TRpddq0nYnr6gzg2Es
         oNmRZElfhS4SeGnW+Rz9/AjMDni731rQKS7tGaAZVliuth/XOlMPzWxPuVjHKziR8/oX
         IA6z42eYQqi+Vu67BsY3uGNFl1kwp3BFPZ01bhw4s3E9PBnxKObNEO6Jk3yqdFPPmIkb
         znWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=a6ykraZL2w3qugLF8FyjtO6T7aloAveG26BZNEMnWFY=;
        b=dIc+GgDADhRVzXltGAEwHbPfRD4OcYHfmHmzCVCFj8fTbmRSiXMcaiet3MTt92bMOf
         qXi+oW1Gzr7qeFUeVG87DtItqf1ITbbfsbw3H3WdauxnHH3xbgaYBjRGRE9Yx7nUY4/3
         bG8WmaSsrP+rlHRDCU2FXxmObM5yVUDTM00TshCvKa23ZiWbZfRpjZHZEFPWO3kpq+Qp
         nJt2j7FzsoIiElGujj6jg+5298QjMgahk1sj3fPOtucrcvrHvPyJVqfuExyLYrmE/YlL
         odMnQEBXl93LlZKPpAxPHJ/OL8f1ztmHl6CqjjOulsc4O8TQ2ui2APAIBK9dxDB3FymV
         g6mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id i125si4283898oib.57.2019.06.09.02.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 02:16:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 714EED491E95A3D71315;
	Sun,  9 Jun 2019 17:16:18 +0800 (CST)
Received: from use12-sp2.huawei.com (10.67.188.190) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.439.0; Sun, 9 Jun 2019 17:16:08 +0800
From: ChenGang <cg.chen@huawei.com>
To: <akpm@linux-foundation.org>, <mhocko@suse.com>, <vbabka@suse.cz>,
	<osalvador@suse.de>, <pavel.tatashin@microsoft.com>
CC: <mgorman@techsingularity.net>, <rppt@linux.ibm.com>,
	<richard.weiyang@gmail.com>, <alexander.h.duyck@linux.intel.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, ChenGang
	<cg.chen@huawei.com>
Subject: [PATCH] mm: align up min_free_kbytes to multipy of 4
Date: Sun, 9 Jun 2019 17:10:28 +0800
Message-ID: <1560071428-24267-1-git-send-email-cg.chen@huawei.com>
X-Mailer: git-send-email 1.8.5.6
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.67.188.190]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Usually the value of min_free_kbytes is multiply of 4,
and in this case ,the right shift is ok.
But if it's not, the right-shifting operation will lose the low 2 bits,
and this cause kernel don't reserve enough memory.
So it's necessary to align the value of min_free_kbytes to multiply of 4.
For example, if min_free_kbytes is 64, then should keep 16 pages,
but if min_free_kbytes is 65 or 66, then should keep 17 pages.

Signed-off-by: ChenGang <cg.chen@huawei.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8a..1baeeba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7611,7 +7611,8 @@ static void setup_per_zone_lowmem_reserve(void)
 
 static void __setup_per_zone_wmarks(void)
 {
-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned long pages_min =
+		(PAGE_ALIGN(min_free_kbytes * 1024) / 1024) >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
-- 
1.8.5.6

