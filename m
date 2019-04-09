Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E32B8C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:21:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EF9520833
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:21:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EF9520833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 971506B0006; Tue,  9 Apr 2019 03:21:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F94A6B0007; Tue,  9 Apr 2019 03:21:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723456B0008; Tue,  9 Apr 2019 03:21:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 406DB6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 03:21:02 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id t66so7070986oie.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:21:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=V/4ZPsKLpexL5//Y8vfNyh5DxmEh2PT2Q9CiBEnNMOk=;
        b=ShX22W4HwtdkzaFPhoq36nsCH45Xk4MwNKO4ZuGnbLv0arrcNT0Zci07C8hAyJN3MU
         EcOpv60QoBIs0YgxzBO9NDXaUtrxoHBbYt0onczSjciLy6wMtGPRUSa64uZt/tFY+j1X
         Skfou76WyCJU/LAT2lZYzXJZ67uxZM1wPKL151EhlUM0bUb3ErykyThwO2KJANPI8z6C
         vU33MRNoVDasyGRy/HojV1dtatl/izGPmZ0eJU/TM5eqThiWqjECoIlzZh9qPKCTRKq8
         VwaerqVIVLDcXkK+HsUFQoFwLQY4WdDJY8et1GYYYM3S426m8ShQQjo/nWzGXQAOusA4
         9hlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAX/LUEST7KVr4FqAEMKDRtcgAlV76zi1GUCAav+7JeGnw9HKt2z
	+lN7u05ZmtFtvWp1M3nsMyuYiwtzAxsRxzaZWeWi7rQxUN6SBjySbFfCM4VNa7ha0Una1FHdDZu
	WC5h0o4F4PON34ZeQDdIVI13sd54y+Ys+XMjdnjN49+n6+agoyGd7I8fGutxDr6tUCQ==
X-Received: by 2002:aca:4085:: with SMTP id n127mr18571869oia.93.1554794461764;
        Tue, 09 Apr 2019 00:21:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdW8ON565lTZlehr+g5vXZvDID6XWN7104ifKTHxBPj44bH18Vyv2DAb0EZLJyeOJJKeoX
X-Received: by 2002:aca:4085:: with SMTP id n127mr18571842oia.93.1554794460734;
        Tue, 09 Apr 2019 00:21:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554794460; cv=none;
        d=google.com; s=arc-20160816;
        b=jmOstJ0KqXmSEba8h++4iZEIZaVDnSae7wZsZ0iz2fa4BsvPV99DK4+xI9Rt5LsAdG
         YU6mYTljN6yPtS16axM0gqQSQC0D1GHyDcOe2mbHyJ7KxKiqzCZy2lq2HxnLlPIpZKA2
         yXr8uzzX4Y7tIAx2Tw5XdHH2r+JU7+Tu+9Zuku1IMB9wKKmvegUpS0saDpod6+e9eFpP
         gVUB3q4HUvNSOejr6Cn6B2U4fGqNY0K3NQYf7kT34Qq6Raziux2l8eLYfebh0XpzoEHD
         lgXxrv7S26UFbANLzu2XrWu67SlxfZEyEYXKgF7XLeHI6FbfRn2tRSD1vLjhiE0XNGeN
         XWNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=V/4ZPsKLpexL5//Y8vfNyh5DxmEh2PT2Q9CiBEnNMOk=;
        b=HK7MgGrIdPu3O2F66Dbr5UCUKE4SmB9VACa0WeOQvq6W6Z9/ncbgKc468rghvQ2JY8
         OujUi0qWKU1Qslnkr/1847MIddonC73qtJ1ONFD7uWg0VPHfwMJLwjoKgZf5hvjFmgTo
         B0uB37Nrvnk+t6L/QMtRrptnRDc7bj6ubgrTtoeMge3o2skJ9ZBLUHXS1ni7clfN2P0i
         o5M7xOlvxhzxJJUWnyAXVCZtBEYawxqwET3vo24Mn0NDrpslgjcaAr62Y3ImXfkAn0Oh
         X0rRaoCvHcyG7Y0L8BBPGf2w/cy2CISiotlxqB6lRwW6I7XT/tQ5bUOheuK7DLJVTtuT
         zOiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id k206si14572507oif.235.2019.04.09.00.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 00:21:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 7D041955658E41FF5A87;
	Tue,  9 Apr 2019 15:20:55 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 15:20:45 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <rppt@linux.ibm.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v2 0/3] support reserving crashkernel above 4G on arm64 kdump  
Date: Tue, 9 Apr 2019 15:31:40 +0800
Message-ID: <20190409073143.75808-1-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
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

When crashkernel is reserved above 4G in memory, kernel should reserve
some amount of low memory for swiotlb and some DMA buffers. So there may
be two crash kernel regions, one is below 4G, the other is above 4G.

Crash dump kernel reads more than one crash kernel regions via a dtb
property under node /chosen,
linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Besides, we need to modify kexec-tools:
  arm64: support more than one crash kernel regions(see [1])

Changes since [v1]:
- Move common reserve_crashkernel_low() code into kernel/kexec_core.c.
- Remove memblock_cap_memory_ranges() i added in v1 and implement that
  in fdt_enforce_memory_region().
  There are at most two crash kernel regions, for two crash kernel regions
  case, we cap the memory range [min(regs[*].start), max(regs[*].end)]
  and then remove the memory range in the middle.

[1]: http://lists.infradead.org/pipermail/kexec/2019-April/022792.html
[v1]: https://lkml.org/lkml/2019/4/8/628

Chen Zhou (3):
  arm64: kdump: support reserving crashkernel above 4G
  arm64: kdump: support more than one crash kernel regions
  kdump: update Documentation about crashkernel on arm64

 Documentation/admin-guide/kernel-parameters.txt |  4 +-
 arch/arm64/include/asm/kexec.h                  |  3 +
 arch/arm64/kernel/setup.c                       |  3 +
 arch/arm64/mm/init.c                            | 92 +++++++++++++++++++++----
 arch/x86/include/asm/kexec.h                    |  3 +
 arch/x86/kernel/setup.c                         | 66 ++----------------
 include/linux/kexec.h                           |  1 +
 include/linux/memblock.h                        |  6 ++
 kernel/kexec_core.c                             | 53 ++++++++++++++
 mm/memblock.c                                   |  7 +-
 10 files changed, 159 insertions(+), 79 deletions(-)

-- 
2.7.4

