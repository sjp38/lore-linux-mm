Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AE98C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60FBD20848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60FBD20848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F40D96B0010; Mon, 15 Apr 2019 13:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED3086B0266; Mon, 15 Apr 2019 13:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1C856B0269; Mon, 15 Apr 2019 13:49:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA5A6B0010
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:49:56 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id r84so8430080oia.9
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:49:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/ctch9BIG/gBXs/UumXXhUGfeedoBTKJpXlhlTSkdIA=;
        b=IFjtM3+yIubz8k+gSsUHmCSI9U1WxP/r9XxHZaWrUlwj9OwboNlJNrPJtfsFd/K2dg
         X6HDQn3FHK7/HP61orkEHEXJHPzCOAM22Zk3dA36g7ud3oH9OUSsQYvoWD3qr34ym0Cm
         b7KvplycWt2rL2m/0P2EQXmqS5uxzRN/0wDOBl23GXyUuzai4VcSFhr56SVHz9PjrM3F
         I9RbWmc56EbAPNO4cQiAIu6+AtLgzOLWzTETzDOSqTSSOon7gfuc9O1vQz3M/bz2V0wB
         IGM0BznWlRjErbT/0ZVtstUVfoBhdSC+ZcuZEF7rdKTh0bF81pdzxzEgxq+QPP4jMrPi
         OkKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAX3DZhviMpj442ojxTChHW2+fxd1PiflentzUh4n1+SucKzPof9
	AlkQRLiuGFogoodWlNsh+HSGnHJBm0q9Gh5bwpbLQRFlBBQdt8FkDa+zdS1VkNxoWUFomyASy/0
	BPj655bQRUYyd3HaVWquZvcXgsZ8ApIoWwzjqYkNhcWN7ib7CI/Bg0tJKSB2953pDxw==
X-Received: by 2002:aca:c4cc:: with SMTP id u195mr20452269oif.40.1555350596312;
        Mon, 15 Apr 2019 10:49:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwco1GY5DB3Ex9PbIYdNImS6/r8UepslI1A/mQVYe4nLnOkxt5H5BnsQaRW7aPFfdSSWa7A
X-Received: by 2002:aca:c4cc:: with SMTP id u195mr20452229oif.40.1555350595552;
        Mon, 15 Apr 2019 10:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555350595; cv=none;
        d=google.com; s=arc-20160816;
        b=mqgW4h4WA0H9nSAWuLH5KjrnuKgnPq+szsy/p0yj45aWq7A9S0evPXKUCuBmL6BrJW
         qRb1EoUOkNZ3wvN2B7lFqdCPt/r0SQP/IMRVFBP2Dy3nFur/rpkY2s0kTMxHORM08uy2
         DaanQMNLWdwMJom7n3v6BDHyCkU1EdTY5S0yBfNQxxEfmt9PpJZmYXGfZ1phtx52JpO5
         FM1Dg2xtMke1VwWF6WWftAZl7gPpp/r/JpiBBA1n9HrU+jzXkmkEy+h1vAQ13n2NXk6j
         MIPORvJW6KFnhpHZF7ubJCC9Iv+J8JdKKwRWdbBkvcE+xbCgqzSQcJXrkny0at130/pZ
         ppjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=/ctch9BIG/gBXs/UumXXhUGfeedoBTKJpXlhlTSkdIA=;
        b=rp+IfqwIcn8WfGHvp8CuZjumfBBhHXWnJSUtSinQbvzydAvzm7jkghF5h3oa0HrgG0
         6YujTbCvFkRFnQlETWHs6yims0bOPpNDNfEOTjBV0/IuWA0a1slLs9bmPNg9rSdwB03c
         rwrWjyP9+jxlzd1tsoRpUhHyooa5Fo1JHaetWfaKpDwjz5CVawmvxhQWMnJHwbwstYAg
         UQ4no/UxLGZagERaOJdTzqJYcFhkj0aG72QKYqgDl3d+meKX3OJt8WGnbcilV8yo/oi4
         7Cs2kQiYJEqAuEutxmvEOTSl+kTmU0/2vVsKQnyhjTr/fzzWF57fIom+RRYt2GpYeBF0
         3AbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id 5si18298242oii.252.2019.04.15.10.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:49:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 02E473ED7A4E7FCD7631;
	Tue, 16 Apr 2019 01:49:52 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS401-HUB.china.huawei.com (10.3.19.201) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 01:49:42 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Keith Busch
	<keith.busch@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "Jonathan
 Cameron" <Jonathan.Cameron@huawei.com>
Subject: [PATCH 4/4 V3] ACPI: Let ACPI know we support Generic Initiator Affinity Structures
Date: Tue, 16 Apr 2019 01:49:07 +0800
Message-ID: <20190415174907.102307-5-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
References: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Until we tell ACPI that we support generic initiators, it will have
to operate in fall back domain mode and all _PXM entries should
be on existing non GI domains.

This patch sets the relevant OSC bit to make that happen.

Note that this currently doesn't take into account whether we have the relevant
setup code for a given architecture.  Do we want to make this optional, or
should the initial patch set just enable it for all ACPI supporting architectures?

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 drivers/acpi/bus.c   | 1 +
 include/linux/acpi.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index eec263c9019e..ef251f454a5b 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -315,6 +315,7 @@ static void acpi_bus_osc_support(void)
 
 	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_HOTPLUG_OST_SUPPORT;
 	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_PCLPI_SUPPORT;
+	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_GENERIC_INITIATOR_SUPPORT;
 
 #ifdef CONFIG_X86
 	if (boot_cpu_has(X86_FEATURE_HWP)) {
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index d5dcebd7aad3..cc68b2ad0630 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -503,6 +503,7 @@ acpi_status acpi_run_osc(acpi_handle handle, struct acpi_osc_context *context);
 #define OSC_SB_PCLPI_SUPPORT			0x00000080
 #define OSC_SB_OSLPI_SUPPORT			0x00000100
 #define OSC_SB_CPC_DIVERSE_HIGH_SUPPORT		0x00001000
+#define OSC_SB_GENERIC_INITIATOR_SUPPORT	0x00002000
 
 extern bool osc_sb_apei_support_acked;
 extern bool osc_pc_lpi_support_confirmed;
-- 
2.19.1

