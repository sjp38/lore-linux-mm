Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EB01C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:27:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B223206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:27:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B223206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9626F6B0005; Wed, 17 Apr 2019 10:27:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E87B6B0006; Wed, 17 Apr 2019 10:27:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B0566B0007; Wed, 17 Apr 2019 10:27:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4874C6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:27:20 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q15so12693268otl.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:27:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=cZ5rqjVAbfj6trFuO4jGD+Zf8mcEGnDZRq7eDQ4AUSk=;
        b=HTlpi4tSQ0SpIGAUSjSUIV8c8sRFUWLIMdyqW63WV173u+YiokaiDG8QTbY7I8oEny
         olXVpn16y/l4489H3zkbE0EiFsQzxo6YkPkb8L9LOXXw1Q6SBRnf8HS6tbdjw3F8LnA0
         Te5BZzwXri7GLMPCh0oPRe+KJCxOCSsG5nChIr5Ua8IuHO+/dMYwC7bCy201hXg3nuSA
         oE3GvpN9Fl0377tZ//46eNPQruR3wEaEmwh1J6mKuFZM6kUEhHMs0zqtYYBizrcyRPiT
         fS37QTchmPyfEdjnXzREBRLgDqy+WmtlETimKf0ZnI+T/0YAKNWLqkYALDghLlySOff9
         F5lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
X-Gm-Message-State: APjAAAVKDiBcXdxvS3T23trTKAafyKaLvGVMOoaoZ5l3MkPJVJO7zbKk
	mQnLfvzk1QIh2QAs66Jj7zS8w2oH/SqkMbc6TSlW1b5giaCOyPGwXDc3CvFckxq/Oy5F1gKDyHw
	dvQRwMB/TixargDWDz7UMUr2Klxtcaj+iF7c+PyyBZEEomRYURmmCWni2AdhyVg67/w==
X-Received: by 2002:aca:61c3:: with SMTP id v186mr28277003oib.27.1555511239830;
        Wed, 17 Apr 2019 07:27:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNFjvaDACovKO1jYQZUDSXr2mmmK0gGZ4tIZh0pPWTLxjjDBECVOqiSNbuQ7aNNJRjzCIw
X-Received: by 2002:aca:61c3:: with SMTP id v186mr28276955oib.27.1555511239114;
        Wed, 17 Apr 2019 07:27:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555511239; cv=none;
        d=google.com; s=arc-20160816;
        b=UImAn6gf25X2PfdC0l76rhR0iMZfbsha5+BZOVejOhDjFyobW9N3llhvR0MIgQySK8
         e+d+Fn4QVMdJpuF5ofq+6Zoa5xjTqiTMa7tXzb2uK3hKiqpzEg35TWSH9M8Kt+A6t8SN
         2SfTrS1RC+epu6vaiqG+TZAY0HVN4VAWqXczueTcNk/4+dqt0jq3crt02dxbal/veGfm
         R21HbeMpeoXP3xiSOudNaasUKDrNWaAeyzcZc3a4BFS85ksqsRvKuImXH+kou1lMyEtz
         albR0A0/YICW/a4LGA47/CoXI3YVaFV3zuavQK5Qrvpeaq8/YHzjRvmL/7UeUYofsz0U
         bSJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=cZ5rqjVAbfj6trFuO4jGD+Zf8mcEGnDZRq7eDQ4AUSk=;
        b=wh/OHqcPM1/Lpji6wMmGO2ssOQ2KZgAzxTr3uHlzHNBOLYKKo+5flg+CDZCVGkY9bZ
         hORj3WMmgxmn1nmWsQMpjiYrQayetn4LHGg9Dv1Svs3VaF1jJmz7Pn5Cz2VbEpMTjoiv
         4a8XgHEZH7hvonjRtrPWaNFa1N6elVaqisL6gkKHgiA4vfB4Xa5/0FRs+St/8hTO6T/O
         9jKVmUbJ3nNuwb/vGU9huZ7t3th70FWMeVCsHx2g4aAfhO+7Ma6b1CgPxTnj5wZdiho0
         C8SaoICflomCCCWBPiXKrb8Rc2tZVO0UJCmV9O2wQCH/aksM7cGWgHu+IND6vjTT+OWO
         qXpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id m7si23350590otc.6.2019.04.17.07.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 07:27:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 78F162AAB16E820BD67A;
	Wed, 17 Apr 2019 22:27:13 +0800 (CST)
Received: from localhost (10.177.31.96) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Wed, 17 Apr 2019
 22:27:03 +0800
From: Yue Haibing <yuehaibing@huawei.com>
To: <bskeggs@redhat.com>, <airlied@linux.ie>, <daniel@ffwll.ch>,
	<jglisse@redhat.com>, <jgg@mellanox.com>, <rcampbell@nvidia.com>,
	<leonro@mellanox.com>, <akpm@linux-foundation.org>, <sfr@canb.auug.org.au>
CC: <linux-kernel@vger.kernel.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-mm@kvack.org>, YueHaibing
	<yuehaibing@huawei.com>
Subject: [PATCH] drm/nouveau: Fix DEVICE_PRIVATE dependencies
Date: Wed, 17 Apr 2019 22:26:32 +0800
Message-ID: <20190417142632.12992-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.10.2.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.177.31.96]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: YueHaibing <yuehaibing@huawei.com>

During randconfig builds, I occasionally run into an invalid configuration

WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
  Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
  Selected by [y]:
  - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=y] && STAGING [=y]

mm/memory.o: In function `do_swap_page':
memory.c:(.text+0x2754): undefined reference to `device_private_entry_fault'

commit 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring from device memory")
split CONFIG_DEVICE_PRIVATE dependencies from
ARCH_HAS_HMM to ARCH_HAS_HMM_DEVICE and ZONE_DEVICE,
so enable DRM_NOUVEAU_SVM will trigger this warning,
cause building failed.

Reported-by: Hulk Robot <hulkci@huawei.com>
Fixes: 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring from device memory")
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 drivers/gpu/drm/nouveau/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 00cd9ab..99e30c1 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -74,7 +74,8 @@ config DRM_NOUVEAU_BACKLIGHT
 
 config DRM_NOUVEAU_SVM
 	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
-	depends on ARCH_HAS_HMM
+	depends on ARCH_HAS_HMM_DEVICE
+	depends on ZONE_DEVICE
 	depends on DRM_NOUVEAU
 	depends on STAGING
 	select HMM_MIRROR
-- 
2.7.4


