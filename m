Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BA6BC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42AB920868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:33:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42AB920868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9F786B000C; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAE416B000E; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29AB6B000D; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE956B000A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id f103so10354782otf.14
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 00:33:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s3cqLnZ8ikaGliCL7mUmXmKsHQTifOzyfKPhb+L5V7k=;
        b=tH9oSHMZEJL1UTyOMeZWvDS3zHif0474J9oHp254duzf+NJwwl/NWoEuhrL2TMImYr
         YQXSNtEEbeEL0ndHcTUSmsehOV8pHaxppPcn0SJTLL5OVBNaORlYsqxlkrKanDQMUZ9y
         QEJ4KAcftv7Nj61B0cw928dy52ndudvbzNGyNtBs5PrlWu+8YtivTN9rK2+iU4U41zzL
         NSsgHIQdoAyF4JXuN2PIcMnhSAI1fNKXfdRMAcfnaGCqxyaCXD5R2BM5WhJo1XiO9gMk
         YJK0rGqhkmG+suky77OL8JKUFllTZmUsESJSSPMnyg68zXaNyhHP1670HIOclehsa2FD
         h0YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWK5dghb+pgIh5Nmf93QhPC2uQloRci0zhbF1Ph+lf4sb+E6QI7
	H7s+3jVcdOt7AZrDXkv3LQLQZYJfrsFXo4bA4fzIK47DYcpYezZ91VTSyzeLpYD4P/OhUh1ViZV
	D1wE+Zsabg6P0i2+eVKmz1cYjbpBBgxCIqKb9cZ2u9sp37krFqghbrKdVW5TRSXmwGA==
X-Received: by 2002:a9d:7f0b:: with SMTP id j11mr45774122otq.132.1555400016245;
        Tue, 16 Apr 2019 00:33:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvfWIVWH9odg2quFTxOE2imHpZ2m5svUdRKpVt2pXIuc7fl5yCuWB7omo4TTt9nowW7+Kg
X-Received: by 2002:a9d:7f0b:: with SMTP id j11mr45774093otq.132.1555400015510;
        Tue, 16 Apr 2019 00:33:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555400015; cv=none;
        d=google.com; s=arc-20160816;
        b=VmeG586EQr2BodYaAiFwFUYRfyu9nnEJgNA1FqsuTt+rvSDmcMquK82ptDRZS4Ngv6
         X2Snl+fLkUT4MQjwTrRXcMoE/dFv1Nnf3WBA1DNnrOtCJ/1azerzfS98an9tUpypJnBH
         6Esnyt1nj09w7ADBoAUzeXwfPbsnHvMil58DVlU5cTEMAIW0c0Cuzcz+JeOL8whSXoT9
         Yzqt3dnV7I7hsNIaNg/b3z0fFufJxxDaq7dApOVI4CpPN3P+v+06J9/EnoHBpQbtcOrc
         HAOfINDZxAYe0JgHEWeUESX1nZi1ctZ345Mje4Ib0iRTFF1WcdSG/lXRM+YWGk65DO2T
         tFqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=s3cqLnZ8ikaGliCL7mUmXmKsHQTifOzyfKPhb+L5V7k=;
        b=Pozo7o3Ks9K5uW/QUsr68NqFB5QrfNmZmk0B5ZmSQHFKmEEMjRS9RiEyNRUZ5kSan9
         C5g5KgKiFfv4xHHvFb4KhGeSqVBxeudmevBEJI7/1YFjbkQ0tgjiMYic1zdUbB5O0Y7Z
         bKtNhhTiBvUB1jCkICFOj17HFtF9Xy7MxBDxRCjphxpKobdjC+gEI3syFlyATGK1iP8v
         VwJwO4y/lqeeW5syhu90PYXxQhjTkE/TNs9Jg2oanKfF1J+p82JtYIlvnIE/L41Lrzb5
         JsyqFEJjgPQMLgq/dzDFOGJDh72PLShOgt1r+Z18WfcG8ITWETUb+H/nXDTVUdvzgr5a
         QFVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id k18si24300878oib.274.2019.04.16.00.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 00:33:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id B19C6A9FD6C45F289170;
	Tue, 16 Apr 2019 15:33:28 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 15:33:21 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v5 4/4] kdump: update Documentation about crashkernel on arm64
Date: Tue, 16 Apr 2019 15:43:29 +0800
Message-ID: <20190416074329.44928-5-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190416074329.44928-1-chenzhou10@huawei.com>
References: <20190416074329.44928-1-chenzhou10@huawei.com>
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

