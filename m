Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C88EC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45C2A20868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45C2A20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7A716B0010; Tue, 16 Apr 2019 07:25:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB0986B0266; Tue, 16 Apr 2019 07:25:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4DC26B0269; Tue, 16 Apr 2019 07:25:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93D4E6B0010
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:25:10 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id u18so10551259otq.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:25:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s3cqLnZ8ikaGliCL7mUmXmKsHQTifOzyfKPhb+L5V7k=;
        b=hgTHdm8qVpy/jkXIFDe5yJ1/TNdt3v/oOdBp2QVygz1z3XDHoSJG+JLMHdoSqcqAE3
         Kl6CSPQcNrelVFT90wlC47nbSoKLmMmmX90zwslkHSPEzI5PD8Hi4OqqHN/0lgeOMfqG
         rAdvXKPsKOMN/QuF6JYxaXrqHUOyRr4vPcQoCDRgQt/HfHVcjv6nmAsW/XhASpCdd7+g
         rWF+3YRtJCEQGNdUmxLnVetYLDnrj9YGEUFQZWt8nbszni3ydzp6S6syJVb22GEyMIlp
         9iaGjb/HoOzH/cy/Tv5j31SBjFrAA45PQnswTO1weYTBhYPZ+lRKvqnaucxs0Baz1ZNB
         dz/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXhiPlTVd2K3pKNkaczPWpJpgMtL+sT7O6QKCnVvubxL/5v+rDz
	4ZSIQfwneYjvE/X8epcBZuMVkkhwhKfLT0V/7HdcEwpieHUKHlfQ5zBLefp0sv8g3W0ah6rvgOo
	1PSpJuzDmpjBDuP0Q0WgUybJQWcDzbYYgDirRYRv80ZXvjkJ/dqICp3pb35k8zbooaQ==
X-Received: by 2002:a9d:6519:: with SMTP id i25mr49658477otl.287.1555413910342;
        Tue, 16 Apr 2019 04:25:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfLcVj1JiLeepRbcleZf9Aa9jj0zCv+RS0JBSGys+GC5oAgrT+q2pVC67JW4BK5vuVMTxi
X-Received: by 2002:a9d:6519:: with SMTP id i25mr49658454otl.287.1555413909715;
        Tue, 16 Apr 2019 04:25:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555413909; cv=none;
        d=google.com; s=arc-20160816;
        b=Ai8zdff/LMRbHCHjS2cVUCueF+40k+kxfqdVdCzABkrGl9Eg3BgT7MGicXAvBFmefR
         K2zPRmoxvvQceTi4TN6jyK9rZzU6h8GaNtPYNfZ4DRwGZ0DblMNcVbcmHP4apoGHDtQF
         S9CvD6oDJZhknVJFaL5TnredsM1/5a1PXfLx/E3cEKQ16UwPeuVxPUgF2qehfwczMgbO
         hziQcWloLs8tZE2s4rX84hDuZ0ddmAsWim/Ri4Xhvn2YIGaPX+XER6mSWqX8k+EDH+pk
         8O1+XoVKZvSE4gLAez6YMKfjoqxxJ38jb277g5He3i7mSmMEISw/YJa/4MS3QwdR4NHe
         pnGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=s3cqLnZ8ikaGliCL7mUmXmKsHQTifOzyfKPhb+L5V7k=;
        b=E6XJrOl9qSvnj1PqMMbR9owp4tNK1byICfd3VAnb7bGVX5ZzjrbSeff0xf+sTyrlTv
         rVrzWpYjWAVFeLEBEeLdkQLISYGkgQe8G6abk3Xjg5t4CWQAzjwheU7Rm47HkpEH8Suk
         bW4Vew7ti6bBPcqjXbQN7cLSXQ81wUyKN4F3GYGIzEjYUmmpbtAA0fWbiCHP1gL0WXaD
         Zl3c0Q4FpwjUxjU8/iglmHpR2jkupY4b9WSbTyWUdSK+dE29vM7cG5ez5w/vLg1Smc0+
         g9bK3ezLdCxDMJl/yWRGtVl38kwTxwT6AapgwlsDNbjs1hdDQMvn9an0osSXn7f0m1Ty
         n/ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id n185si24211991oih.36.2019.04.16.04.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 04:25:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 725CBBCF56F8F71E26B6;
	Tue, 16 Apr 2019 19:25:04 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS413-HUB.china.huawei.com (10.3.19.213) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 19:24:54 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [RESEND PATCH v5 4/4] kdump: update Documentation about crashkernel on arm64
Date: Tue, 16 Apr 2019 19:35:19 +0800
Message-ID: <20190416113519.90507-5-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190416113519.90507-1-chenzhou10@huawei.com>
References: <20190416113519.90507-1-chenzhou10@huawei.com>
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
index 308af3b..a055983 100644
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

