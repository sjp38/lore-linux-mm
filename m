Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 639F9C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:30:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B2E820830
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:30:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B2E820830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A44286B0010; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A16E06B0266; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF0A6B0269; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 665376B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id x125so7188907oix.17
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:30:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ok8I24TtxuWgDq0ME4RBGiLUC2kWpehBcB4g0fC0unk=;
        b=XdRPcblfBjER5KlZX0KH02b5VpMLlDEu230VMC1ApB3WzvoMxudbYVfu9RsN0aqw1X
         GbNpeiOSldNUfccWq8hP1KwbeiXb2jkGesvwTPocmqs2ChhgrobiTM/pPotBYaxZEs2y
         FKFhX99x17/bW+9jcIxfIYejQ9KaaUZWo1x0cAz8j1s0ByW5RqesIevp8IoDDjvmchgf
         y/jOwzzaETh0bZBP9pfMyw7HzuY7FGzJ46FeKuLC9eU7b1cs3PmjrQbTTFhDEBeFO+tm
         LBsNcd20JILtSYScDVJM9RBXCsmhPb+451JN4e0w2BWKSAgtOuAGl1ZKAVDfaJcSnExA
         kSRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVa5+kMW+QhUEjMUJbmm8SQaEbcTOT0Ucxcb1mRnWcYqRDQJC/C
	KS3h6Ar7uJp8I7EOBNKrBPJezY0sfkY8lxoPTI/6jVC1UQI73mmk/sczDqk1x7+KmeD2nu3Dyds
	bzHQRx4HjGpW5qgYaraafIe+kzLSR83pfeyTM89vzdbKCl1WwEYkrYYyxgtlLTb4dUA==
X-Received: by 2002:a9d:5e02:: with SMTP id d2mr22360817oti.222.1554805829163;
        Tue, 09 Apr 2019 03:30:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKgzVTC78ZdurK6nobLXQUcz/rapzkAEtUtVpzLTiYMzmPjZXUkuqOhezk0ZevKi3REnKv
X-Received: by 2002:a9d:5e02:: with SMTP id d2mr22360783oti.222.1554805828420;
        Tue, 09 Apr 2019 03:30:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554805828; cv=none;
        d=google.com; s=arc-20160816;
        b=Z4VyMk4uAIhTiMHDYAiG5TixRYW4qTqqSKX9XHdCr0MccLjQ+Afu6iHyjC150FJjFU
         TaS/HQG3+32vGM6jq1HLGE8e+kXtdCwdJhcrzHxeMf1sFh2ShhlCa/n3Ihoz9iT/m24U
         +AldtaodoETMVKmwK41skRBMOHwhJ03WcixxiCwKG+O/ypjY/N1jB7TxZvobFPAFrFpg
         YnZVYorYVzzgPUogBoGjxfDUr3+I4HDX600eEGPmnovyvtX2x7MvbOJ1gSxQttimIqzM
         ckeiU4ZOImSO87dsB/+bV3AvqkKfy7enQDDzhbABV8U6cq8WysIXDmgQhk5VJUjAsmx/
         KTHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ok8I24TtxuWgDq0ME4RBGiLUC2kWpehBcB4g0fC0unk=;
        b=pKxVyjZ3c0uDrFnVrNO2xoAuGhFPAJSYQQwvEV33pkR+/0gg0xdsyF5mVZJooy3Xpk
         yGgGElsxlhw5LT0oUd1rZCuNHw/OWXr4EulnSQWXRpgiu6AcXeUFGzrph1JCor9dM8al
         HDAB8kViIIql1KDkU3jn0QQiFB4q+QFY1uRPaejzXtXvcraGnTd2ppi4qjpTarjTuh9q
         rdDNX1DSGPDislidsDdF3ysXxVN50GUUNdEuSVmt8JONAkcvQ97BinJmb4aQcdwvth73
         Hfc891DEhtEZ+0jBv1N1R/uOBYX54SiNR7x9/OYYsO0Tw6p6z7OmOApkV8UZjNbIWB4s
         rVTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id o21si14740688otl.216.2019.04.09.03.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:30:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 6B49190406CAC14DD96D;
	Tue,  9 Apr 2019 18:17:36 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 18:17:28 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v3 4/4] kdump: update Documentation about crashkernel on arm64
Date: Tue, 9 Apr 2019 18:28:19 +0800
Message-ID: <20190409102819.121335-5-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409102819.121335-1-chenzhou10@huawei.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now we support crashkernel=X,[high,low] on arm64, update the
Documentation.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 060482d..d5c65e1 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -715,14 +715,14 @@
 			Documentation/kdump/kdump.txt for an example.
 
 	crashkernel=size[KMG],high
-			[KNL, x86_64] range could be above 4G. Allow kernel
+			[KNL, x86_64, arm64] range could be above 4G. Allow kernel
 			to allocate physical memory region from top, so could
 			be above 4G if system have more than 4G ram installed.
 			Otherwise memory region will be allocated below 4G, if
 			available.
 			It will be ignored if crashkernel=X is specified.
 	crashkernel=size[KMG],low
-			[KNL, x86_64] range under 4G. When crashkernel=X,high
+			[KNL, x86_64, arm64] range under 4G. When crashkernel=X,high
 			is passed, kernel could allocate physical memory region
 			above 4G, that cause second kernel crash on system
 			that require some amount of low memory, e.g. swiotlb
-- 
2.7.4

