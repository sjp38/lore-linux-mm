Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E884C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:08:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ECB222ADA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ECB222ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C66F68E0003; Wed, 24 Jul 2019 10:08:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF0008E0002; Wed, 24 Jul 2019 10:08:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB8638E0003; Wed, 24 Jul 2019 10:08:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 828938E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:08:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w5so28360551pgs.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:08:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=g2zRTwoZ/pVBysAnNKeZxi6wBJAkueOysD7DMBarhWI=;
        b=LDpVCAY7vPlqZ5gbL+TpPe9YgRp+mwf3GFkvP8xuCg8wo9+zzeFf7UckEF2T5Kzls+
         xgyl7hDcvpvFrO/+kW+2AUAkzyC1XaqJchAeq1hIclQwDwdQNg08oaCQ+8XpZvhEKwoL
         mW7kqfi3CljijHVcj2WuMVECg6llCR4XlulK0fTUKmtWaYBieEp5jMgjaejxbihHvWxv
         470P7bNaDa6nTNjA/TunsRqfhnug024y0M46oNVnPRVSbx3w16DWuo+uymU1mjT1ij25
         I2BA2UGcSL5f/HxzOxlVkZPbLHDjdoHcweExbTYKpWx1LTMX8K0elT3hLN39WB2EApJt
         b5RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
X-Gm-Message-State: APjAAAUMD/21RcDLjkHp5Oo7aDDlki64Mfx8dK+pxEaqP3kCdQvT52wQ
	ED6CV2mrMLPSE7zKcCCsxa5R1nbtyR4w9FCq8a7i+kWQJtZopl+un0GXqmSf4eX0OWqTd/RKzHd
	T6hNQS98xnUQUfCtr2t/g7CuYmhCwG1FfqW62af05cpPcnnkr4BGkRAbt5Vw8CTQDgw==
X-Received: by 2002:aa7:843c:: with SMTP id q28mr11776718pfn.152.1563977281163;
        Wed, 24 Jul 2019 07:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsjkGMy3C0IQ8cGJ++tQqU/Y7JU1qf/DVMQxRP6fPUVMdUqJ4pi4OXIsYRQBVwIU5aQK99
X-Received: by 2002:aa7:843c:: with SMTP id q28mr11776660pfn.152.1563977280542;
        Wed, 24 Jul 2019 07:08:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977280; cv=none;
        d=google.com; s=arc-20160816;
        b=pAUZKDTDziaStIGJPVs4vFL3/nJZv/Pjs1BlYWnKl2zROww3thEHyncAyYY+EP81B0
         1WXuouIpjtTEdGrpkFGQqP7teXZhn+X2VBJwwnin5IGixS0lVyk0pW7XgFrt8Im3zdnN
         zj/cUKeBZUqEMMgneZtjnX1koNkG3H9yz5d//ybHa7EfkjtgbQ6xpVuNkNWTpe+Z9dHi
         KRwLXELTmxvbuhL3RAAOKUbUg3kHT6O43agCpBt1+P0522hkjkDGZNzHKdb45OjGBkV1
         eWCoSm13vOKk7H4+UijqSsdYbLjM1i5Xu3F8auuT6nlDOwIXMbG+NCWHedNLOsYgJEeB
         nfzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=g2zRTwoZ/pVBysAnNKeZxi6wBJAkueOysD7DMBarhWI=;
        b=LGGvTv4vbD725jvZPcsmNU/m8FRi5Y+O350X/leStf1ADMhKTB1dAjYl0YulZZnehs
         Mf2q1Bbs3rgc8mMj+K2FCVqPmmGMlISc67l5dHs+goBOwezQt7/yjsGb5+6XwdUB3OUW
         0TNFggHRkLnmt/tR4V4RTB3bzgAkpi48avy7Kx+uf5KnDP18W0XLk6Utsf2YQNtIKsSB
         EdL/Zt8IYDwq1INWFEaT4HjBq/pDZtkGudm+7NIGyxwhYkFCeh7l4OUtsuNkCMTQHzzP
         dNFq/PXn3y4vnemyVvS/p8el13my+HWF9Rz/PJHINEA7Uokpr+xqT1OMfdDsDNh8UE+e
         ei4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b93si14565376plb.11.2019.07.24.07.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:08:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 3FD101BF82E4CB908D9F;
	Wed, 24 Jul 2019 22:07:59 +0800 (CST)
Received: from localhost (10.133.213.239) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Wed, 24 Jul 2019
 22:07:53 +0800
From: YueHaibing <yuehaibing@huawei.com>
To: <akpm@linux-foundation.org>, <kirill.shutemov@linux.intel.com>,
	<mhocko@suse.com>, <vbabka@suse.cz>, <yang.shi@linux.alibaba.com>,
	<jannh@google.com>, <walken@google.com>
CC: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, YueHaibing
	<yuehaibing@huawei.com>
Subject: [PATCH] mm/mmap.c: silence variable 'new_start' set but not used
Date: Wed, 24 Jul 2019 22:07:39 +0800
Message-ID: <20190724140739.59532-1-yuehaibing@huawei.com>
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

'new_start' is used in is_hugepage_only_range(),
which do nothing in some arch. gcc will warning:

mm/mmap.c: In function acct_stack_growth:
mm/mmap.c:2311:16: warning: variable new_start set but not used [-Wunused-but-set-variable]

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index e2dbed3..56c2a92 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2308,7 +2308,7 @@ static int acct_stack_growth(struct vm_area_struct *vma,
 			     unsigned long size, unsigned long grow)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long new_start;
+	unsigned long __maybe_unused new_start;
 
 	/* address space limit tests */
 	if (!may_expand_vm(mm, vma->vm_flags, grow))
-- 
2.7.4


