Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C5E3C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D2632133D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:37:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D2632133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E41306B000A; Mon,  1 Apr 2019 11:37:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF06B6B000C; Mon,  1 Apr 2019 11:37:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D06E66B000D; Mon,  1 Apr 2019 11:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA73D6B000A
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 11:37:13 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id j202so3376030oih.23
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 08:37:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=61stFUUPLpdAiuhmZhpg/q03iwVZnrncM5USLAYyWqw=;
        b=LafUuX8gmyPaaqsjB39tV9wn7gk1KxlVdzEj3R+sLS00NnaOMg6tM3+fVBhNFwHpzk
         s8pxMTQWyFT9o1OO4lk7AwAUzIap7VeBLagblAOfnHqpLzrjHJMgR0OODt797Ik4MBYR
         WXd9IuyXcc2DngZ/niGR1DM7bF88gzN4GNfhebIxkTlkeGkVvAPTD95Sk5883lejfVml
         bbt6Bb8BuEwodTxqC/mRgTo3rROIVefTQypJ4Nrl9SLalpV29MCXm6xhmaYvawrqDNfh
         pJ5e/TCnd5sLL5jwd17jYsIcuUCFbwcNvxiv+qfn3saj763RtMkvuUKev7pYqCB6s3M9
         12Ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWToRKwU0HZY4Fre3TKX1dnfc9eu2Ehnpqe0uUqf34miBqJPLXE
	ocfpuif7XsbzsIAekDidQwt9kzK5SDyTy8oRHGEsLCe8fxz5PuU/Z8EAV4g+mzDaOH7XPP0WD0q
	uHHrhUTt4Ku6YHrA5GeSoDybMGsvs7ITY+71cISbTZKt7YLt9vRx6Osox9FLl43JQoQ==
X-Received: by 2002:aca:7592:: with SMTP id q140mr13202450oic.152.1554133033272;
        Mon, 01 Apr 2019 08:37:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDqEacVzJNv8T0AIrBlFKn+9phUlfUUnmoynhECj/UWAbaIvnJZTh5ce49RzoAXODFUKmA
X-Received: by 2002:aca:7592:: with SMTP id q140mr13202365oic.152.1554133032052;
        Mon, 01 Apr 2019 08:37:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554133032; cv=none;
        d=google.com; s=arc-20160816;
        b=tXIodQ0z+ZPgHlj2eFzkON80PkpTBTe/Toc0boUn029cl73iHrmRJEqj1ZCPbq17CM
         CeNzJIrPc3tE8Z/2rz9njMj2Q34s1yJU+dBp483tDVtlgeYcmMjVedihx6nPxkrXo4uz
         sNNxQNbM1CSC8Jv5PlpKoGc9sCmK/c4Ib88GS+tfLR+A199Cly8h4uTNrQvd1NOtw4jQ
         fylOwAwrseIPktXy7vTZTGmT6wNWGB9mCyS49yUlc92uJcDofGJiqXDRQpwn//93GqjG
         Y1h5304Nui7g/FXXgRezBfqDKOqshRjnzl624qt8bus0RDozm8X4GY3BtB18yW8fXx+2
         uvxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=61stFUUPLpdAiuhmZhpg/q03iwVZnrncM5USLAYyWqw=;
        b=hxqgQgxonoSrhh8pL/DZMOtULkuPh2ms4oCWvdND2O6wV5xXj1i5PF2D1rH4/Kmi5L
         zkwN7zWUrFJpOoJJ1pgEeFeuADUmxDPfmVWb86jyhitPXnDmOpbM8algUCdYnyzTagnn
         SWl3BA5jBlHpzN1Jz4FaRuoMiO10CAd5up3Y1GfFcwqbOCMzJeA6skFa4YWdxLbzqXh+
         tN6TaHzg9+x+qY3vwR0vJH8JXYvPYjr+CNRUfA+0Mne6nePG6CgJ/k3V6cmZlNy1Wfgy
         B2xyMBB8wohap69T1A0EY9pDma2qrgEC6mhsvWH3+isxeMmlD6atPsjXU0wm/zhUYNBl
         zkuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id h61si4370629otb.149.2019.04.01.08.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 08:37:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [10.3.19.214])
	by Forcepoint Email with ESMTP id 8A316E99E30CD57CC18A;
	Mon,  1 Apr 2019 23:37:06 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Mon, 1 Apr 2019 23:36:57 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
CC: <rjw@rjwysocki.net>, <keith.busch@intel.com>, <linuxarm@huawei.com>,
	<jglisse@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [RFC PATCH v2 2/3] arm64: Support Generic Initiator only domains
Date: Mon, 1 Apr 2019 23:36:02 +0800
Message-ID: <20190401153603.67775-3-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
References: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
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
I plan to test on x86 qemu, but if anyone has hardware where this makes sense then that
would be even better.

 arch/arm64/kernel/smp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 824de7038967..7c419bf92374 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -731,6 +731,7 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
 {
 	int err;
 	unsigned int cpu;
+	unsigned int node;
 	unsigned int this_cpu;
 
 	init_cpu_topology();
@@ -769,6 +770,13 @@ void __init smp_prepare_cpus(unsigned int max_cpus)
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

