Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8F0C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E69222177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:11:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y4Q/McMK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E69222177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51C628E000C; Wed, 13 Mar 2019 15:11:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A6E08E0001; Wed, 13 Mar 2019 15:11:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346AC8E000C; Wed, 13 Mar 2019 15:11:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E69778E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:11:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v19so1955218pfe.15
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:11:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1CkMolPkO1Q8oEIlqWXm/ypYPiUFq205eIq3aDm0/wc=;
        b=Spk6qtzqdtUyQyQO/Rkg6TJPIQ8x3xArdb8CI4dAG4SejwfTT1Vrz6Q7+OOdU7yPJc
         Cu1f47j7+QnPG4IHbDiX1DVlKK8itmSZDDzWeEO5sA7vOcCOA7czLk/jEFMfPHuS3Qms
         W5FK+NcGp8zo9SgFyc3zx+hkRXEHkjvGUlgWRxL4/k+ivV3/xYMC+QqCUf+nzaJsCDz2
         z9KL38HyNq7xZ2chjlc5u1NJIPU7N0gweU7G8LdE5uyeva91vo/2iepim8AT5YlUpdgU
         gH65jelQ7MI/+ZJ/hM6qUUeJfXpk8ukwibESiseHiSPNvlOlX1xsbwUH4I7ri3vbSo4B
         n1Lw==
X-Gm-Message-State: APjAAAXSU3CXg7k3ft4+/i8KEj8FNWgDYA1tl2KAcMiw7e/gxyro5NkP
	HX+byXVzvVai/6uBiRxE+UyzWzApJtlfIXsxVGIu4VlHFlkvuFHaptj66n35h3ZkQui7kzMEell
	dDkMRXpnXyfCKS4crvSbxXIpqPt0v+7cHByX/iiE1Fet/ReCc3NPfXy02Yve1mQyMjw==
X-Received: by 2002:aa7:85d1:: with SMTP id z17mr44849294pfn.226.1552504308546;
        Wed, 13 Mar 2019 12:11:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYUqdOh3P9cPqfwJol3wKI+WsRdSNcMlXONCHugQ6UGi6GA23BbbtbZ92qG2TlgwJWxNBA
X-Received: by 2002:aa7:85d1:: with SMTP id z17mr44849177pfn.226.1552504307103;
        Wed, 13 Mar 2019 12:11:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504307; cv=none;
        d=google.com; s=arc-20160816;
        b=gh3eiMdmW3TC8LfSWclx/AqzG9P3M95sE9ht2Fz7nZrx3OACZCXBqytLpicpQG3zBh
         TMGh41Pon40rTXmU3naI7AHbPV9NQ7ZFFuKsTIp37goDxpSoNL4DnERMeuCE2pq/zSuD
         5Rap6a5Xw54rW3efou2J1hDXu2zbxTPN4YsZKke1Zv5Yv+iAWSZ9P/V9znDKI7dIxep4
         VRXeRLoUksjbZIgBbIjT4v/3yxqApcgZiSREgWjVatkZv+Gkh0G+QIrboeeAtGpkAQYj
         klrGLz9yGpdp2payvnqn7pz/+ZJe34786UkGX42b0l7z2YeGnHUUQXDdfrwe75FNz7Pc
         TGsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1CkMolPkO1Q8oEIlqWXm/ypYPiUFq205eIq3aDm0/wc=;
        b=IlujXs4OBq197xVzke+cgBahhg5Ld1sLB3kio88IaKCjEqYdTSRSFQzXzUJL6E7dOs
         +dTgoXNTitgWEn//Hb/WDb/VmFgs/D0BSGTplu9a09eXiHb/01cL2fcxwTwRSCKFA3Xi
         Z2acdbympCKFe+iLpLnzdK/lVRGeyr0rNXtjQpwhBRJVXWLdHHWLXUJzvf73phyolUsl
         r35Meaxwx9qqnptMjQrkCF4cGAeYnV3APZdbLcC3wDyCxY2JIznxHROUCoaMyG52Itl2
         PvjevmwXc0tZkgN9MwOQAMQf2PSPLeU/eWoIBdmTKlKsZcJihDsv8y0+y8Gpa/3pMP2T
         XBuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Y4Q/McMK";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f1si6971840plr.55.2019.03.13.12.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:11:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Y4Q/McMK";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4393C21852;
	Wed, 13 Mar 2019 19:11:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504306;
	bh=hNlX4NqqxVp9sR85/OPqvCCwSo47QbbfEdAOHK+6KN8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Y4Q/McMKyeCwApETgo2CJXOPTRK9JufNDdpY/YGIyi5QGJQvSeNJAYh5wcRzRUM0F
	 g75dKDB8dz/fEORAcqdAOyV/xTJDoYavJPIHze9TnIDaQjo/lsr510B5QxOkWEwKLJ
	 qWXDJ3Wrn+F2yT38wovYy2Pn36eM/T0Lfq/4iM1c=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 38/60] kasan, slab: fix conflicts with CONFIG_HARDENED_USERCOPY
Date: Wed, 13 Mar 2019 15:09:59 -0400
Message-Id: <20190313191021.158171-38-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191021.158171-1-sashal@kernel.org>
References: <20190313191021.158171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 219667c23c68eb3dbc0d5662b9246f28477fe529 ]

Similarly to commit 96fedce27e13 ("kasan: make tag based mode work with
CONFIG_HARDENED_USERCOPY"), we need to reset pointer tags in
__check_heap_object() in mm/slab.c before doing any pointer math.

Link: http://lkml.kernel.org/r/9a5c0f958db10e69df5ff9f2b997866b56b7effc.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 9d5de959d9d9..05f21f736be8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4421,6 +4421,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	unsigned int objnr;
 	unsigned long offset;
 
+	ptr = kasan_reset_tag(ptr);
+
 	/* Find and validate object. */
 	cachep = page->slab_cache;
 	objnr = obj_to_index(cachep, page, (void *)ptr);
-- 
2.19.1

