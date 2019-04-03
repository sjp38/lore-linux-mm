Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35659C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C304720830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C304720830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48CA06B026D; Tue,  2 Apr 2019 22:54:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43BB96B026F; Tue,  2 Apr 2019 22:54:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32A9A6B0272; Tue,  2 Apr 2019 22:54:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1213B6B026D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 22:54:42 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id u10so5919316oie.10
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 19:54:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=zwThd5CwLofEN1RTW9hVrYp2d0BcTsREWgYpnotZvRU=;
        b=B8e4uuyTuf0jbf6YVTbcW8Aa9/K7GzJPO5BUXdVHbngOGnw2uyQuTwZeGpvjJAppeE
         GWh/EzKszfkcXPGfx8bc4J/g1Wa+ddFUj1XmnqX90lYcRLZByAO9b/jFq7li7yI71oZB
         5mZR9dA3OdrHaEqvaFbGbINg/6S+Fk4bWQGJFoJa5RSd1osbcl1TQdoPvcI8oNP54kMU
         N3s1LEjNVtppQnr6cUQDJ4eRGoa5pGRiUq8qiI4wm0ZEV58FWAoIU7bGiBu+yw1118nZ
         DKbhQghLUw7i7WhzWVvJnRf85qMWbVugyFPg87e0zG94cK37lFy7JU9FvW4wTgr4vNla
         cMaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVLkiDOuF2MNjD5aG8RfCc6GSU6HjX7c0D8SOxw6QT5XwpkOeQN
	Jh598IOihX3Api0aL2HMady7yuVJrg/DL7VHg/FWHRGoJ6eisqRl+ZPE4UHXafpWwVj78MRG9Ll
	uc6QEU8R6VWSNLqsqx2swG4QmA6WRChmQbMBHZQrnMYeYro3GY9CGOG61mWNUzDLJxQ==
X-Received: by 2002:a05:6830:2042:: with SMTP id f2mr44247166otp.89.1554260081738;
        Tue, 02 Apr 2019 19:54:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztv8pkJW3rP8O+q2jcSbkFwPbM01U2+5Bd43rQigzxXlOun0EE2nTNMEqQH3U6OMllqT0r
X-Received: by 2002:a05:6830:2042:: with SMTP id f2mr44247113otp.89.1554260080761;
        Tue, 02 Apr 2019 19:54:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554260080; cv=none;
        d=google.com; s=arc-20160816;
        b=AMHJ8tGpXrXwpXxY+LBAKqQcCbgp3ta5gkqw9K29pHp/gG/bWWEJO1Xifdz4ZuXgIq
         kKHpBcNZ7iINOCFAjabNKtQ0+al6sewUzlRmBB3XZ80sBYj3bWqpse6ea3S+HQmj8Qpn
         58KcYKliHrL2ulp0PFGJzkFPRhBZeSKBBZElIUx4bgHJsL0bMTwryJulUtIzuKRTdkaj
         PYrwQ91Wx6qdTg1z6IZ9caNIO8wa78Sb2wRMHqZY1Tz24Dj++o8wlFYP2yKNU/4cOhTp
         KAv14futW8Xh3IT91laAegS7P2KSkDWSRvNQqnWUCkCZvV9JinwU9N4VqkxqQ9pasCqK
         3XEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=zwThd5CwLofEN1RTW9hVrYp2d0BcTsREWgYpnotZvRU=;
        b=NKRVZy/AkTKzZqoh35EjTnPZdY/gvNYHxaXyiUJFqO8eHOwQpVF6LNWrMEXdlMc3VD
         bOXqB2uadllCjTpxcoFHKEkHVeYCJJ2OSCB6R/dUiFD63u58uVifqmuaJkX8WccpxxWi
         YRZJ1AY3RGU4+9J8oFVWH7FEWZSfTIHG6oaaEAWmjon6kJ7iHpjATdpR9g7LtlwcKVai
         9NWQnQRS3bXFWJOGdDioAjUDdSaHIyrnbFWLfiAZpRGPke4+XKoR2VKao6ja64LTHBXa
         lVPlXeLfIM2U4BBS48/Pye0EkcBWv+VzKF8FlMvP3ZgP7USBnLzhHAEYQufG/B9h/OsY
         Xc/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id x143si7049432oia.182.2019.04.02.19.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 19:54:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [10.3.19.208])
	by Forcepoint Email with ESMTP id F22A69FEC65C9BC8944B;
	Wed,  3 Apr 2019 10:54:36 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Wed, 3 Apr 2019 10:54:28 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<ard.biesheuvel@linaro.org>, <takahiro.akashi@linaro.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 0/3] support reserving crashkernel above 4G on arm64 kdump
Date: Wed, 3 Apr 2019 11:05:43 +0800
Message-ID: <20190403030546.23718-1-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
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
  arm64: support more than one crash kernel regions

Chen Zhou (3):
  arm64: kdump: support reserving crashkernel above 4G
  arm64: kdump: support more than one crash kernel regions
  kdump: update Documentation about crashkernel on arm64

 Documentation/admin-guide/kernel-parameters.txt |   4 +-
 arch/arm64/kernel/setup.c                       |   3 +
 arch/arm64/mm/init.c                            | 108 ++++++++++++++++++++----
 include/linux/memblock.h                        |   1 +
 mm/memblock.c                                   |  40 +++++++++
 5 files changed, 139 insertions(+), 17 deletions(-)

-- 
2.7.4

