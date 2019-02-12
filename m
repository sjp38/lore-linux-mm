Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A471C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64ED4217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64ED4217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 171728E0005; Tue, 12 Feb 2019 11:50:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 082948E0001; Tue, 12 Feb 2019 11:50:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E40128E0005; Tue, 12 Feb 2019 11:50:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6E828E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:50:36 -0500 (EST)
Received: by mail-ua1-f70.google.com with SMTP id x1so302802ual.12
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:50:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=1mN7iMooA3KVd0qWi1NHOaj1xqcTLIgTbwO9dW7o6Nw=;
        b=tnV0UbveJuagJOGqJM7Ymwd6skM7ef7HIIcPUaaCOxlL9BJynbBkfW//63GtDV2W5k
         diE5NJnlVRYEP2hOBTG5YAsbzfsLnXZqPDSaaT1ETh38vg4MqvVo1Y8E1xkXLcV4eEQM
         MfSgm/0AwDtJj91Oc5KGdR91joP8skgSoeL+DgB/s7o0yWsXX0xUj1jtxZrvT7YCax/q
         meau3g8JeAQKo0eFLu57RuXj1GmdVlxzpB8zy4aAutv1+vxtnj9jeOkbmZkwY53y8pZM
         /7nkwAakGhNHN8FzoPaIAMjD019JuuDdRARr4DUNLitD5hMA5vn3e/+yxpEBhFWNKGY/
         ckCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAubGzsHRTaIxCXgqjqToBh/0f6HfCV0KI/DziHnFMBEuXEHCyuX4
	TQrETxiXb1s6p8c/pk2g8oiDAAyEAyM8gCw5b3HMrtWYINxMWxCHWG/1wiOp42E94Apt9SpcxHp
	z6EKvnOSifOvJWuokV4vhNBRG1kElgdrZDoYaxaLgcvQoc9S04sMwSdDo5F2hx5uGag==
X-Received: by 2002:a1f:1094:: with SMTP id 20mr1831302vkq.62.1549990236343;
        Tue, 12 Feb 2019 08:50:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib8EIAUpv8EtLeQa6BYdswJOaXs7oIflq1DalGHAkMDiyjaII6x4S2jZhf0uAJexwaD8zF+
X-Received: by 2002:a1f:1094:: with SMTP id 20mr1831277vkq.62.1549990235672;
        Tue, 12 Feb 2019 08:50:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990235; cv=none;
        d=google.com; s=arc-20160816;
        b=ZWYIWQAhO8M/tz2HVMpoItremSLO2ul/KVl7f1WGW21pVpa91d7KK+zLLj/7aMcnLU
         rKv4LWgkjQok8/jxNpzH6ov2mOVbzU17WJIm913oy8PFg70LXCEcFRss0Z41qV6joZAm
         6amB6BtfWVHqp/IOiMczdZZeFa2/nY8msV5azffuKvALD7TGKhhc9HA13+0LaH8UaeER
         aINasJ0uvohdQleaaxCfO8NMkO2ELBl5J9zqyoGbRU/CBY+Vx1eq1GiyBB04VTmHD10x
         45yXVDik/7iAwexMont3zrRRRpApPw9ItIFsFYG9vk9iD/RD3LMRQsmja7deF5bm7z5B
         FFTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=1mN7iMooA3KVd0qWi1NHOaj1xqcTLIgTbwO9dW7o6Nw=;
        b=Kr7QoSQqPJIORWriQpWIIbIZHPoWQlVAi+PPBD3Sri8ngTGYjxFSOSATyfdzXqNyy8
         V/2qWosDXaxAjEjMrpVABKEANYNUhZBeDYPO5mJxYBaYOrYuVzI6H8b5DWdWEqJtLSeP
         4fOuRge4qP/067XW5+RLSVp/ZFoV+58dMVA4YiEUR97yTDeCQpiLmVk7wmalavg/bW+0
         6YeWl0EgpHdRoRmBJtFwpVp5ND/t4awaXt2ZSGz7o/DEe9ZCcg5ikEZgCd7W+VLOEUfn
         93S1nTQlLp4TgZOf8myqSNetF/O8bfM9O7Xp4/WeqpJmxfC4bqi4YUxSUtmGEZvDuMvM
         cjaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r13si2874465uae.23.2019.02.12.08.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:50:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id C2159F346FEF718CFC8E;
	Wed, 13 Feb 2019 00:50:31 +0800 (CST)
Received: from j00421895-HPW10.huawei.com (10.202.226.61) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Wed, 13 Feb 2019 00:50:22 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <jonathan.cameron@huawei.com>, <linux-mm@kvack.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <linuxarm@huawei.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Keith Busch <keith.busch@intel.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, Michal Hocko <mhocko@kernel.org>,
	<jcm@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH 2/3] arm64: Support Generic Initiator only domains
Date: Tue, 12 Feb 2019 16:49:25 +0000
Message-ID: <20190212164926.202-3-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
References: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The one thing that currently needs doing from an architecture
point of view is associating the GI domain with its nearest
memory domain.  This allows all the standard NUMA aware code
to get a 'reasonable' answer.

A clever driver might elect to do load balancing etc
if there are multiple host / memory domains nearby, but
that's a decision for the driver.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 arch/arm64/kernel/smp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 1598d6f7200a..871d2d21afb3 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -698,6 +698,7 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 {
 	int err;
 	unsigned int cpu;
+	unsigned int node;
 	unsigned int this_cpu;
 
 	init_cpu_topology();
@@ -736,6 +737,13 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 		set_cpu_present(cpu, true);
 		numa_store_cpu_info(cpu);
 	}
+
+	/*
+	 * Walk the numa domains and set the node to numa memory reference
+	 * for any that are Generic Initiator Only.
+	 */
+	for_each_node_state(node, N_GENERIC_INITIATOR)
+		set_gi_numa_mem(node, local_memory_node(node));
 }
 
 void (*__smp_cross_call)(const struct cpumask *, unsigned int);
-- 
2.18.0


