Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2689CC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3F8C206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3F8C206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5092F6B0006; Wed, 24 Apr 2019 21:42:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A47A6B0007; Wed, 24 Apr 2019 21:42:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BC216B0008; Wed, 24 Apr 2019 21:42:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E72356B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:42:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so13000151pfo.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:42:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=0yqiQlK/8S9jDfOWBw0HKH7+HNI4EnlVsdp6B0GH1hI=;
        b=CLhar1HQDlBra7vyNCAJQqaJErNkRC3sOFnwyMoQPFpxtDQ5hbHnLc2EnaXPg6NWkb
         gvUmUrO2+vFE8zwJl5e8ojc1uHBCzLa+X2n1QJm1yIoe2yH/LJjbxqaq+h9TpDuHzJtV
         /d/k9c3/VwY4mabZhEmWXTjVCGdaosBacKH2kx52qhhu/7KANIy0UiNytfhb/JUXKiH1
         jknooz+85T/w+EgiL+dWNU6UlayLMk5o8oV+aPZUk2Fu9MliSDEnt/CdO0ywJIS1n8rW
         ySTEYFll+anMHVCqa/Kar1UBoJOMme5JyJpTj015Xn82BtOeVJPevMl6NBgxhbRPvvk4
         RjwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVas0cKErDljNs1R3+t4S52dAks1adSLIL5Esx6Zn6XodxpEdkz
	+YYDNGqGWonH4kKBFQhOjm5+rMeM3astd/D6g7MHPdH597VIwvfr7hVggLIe4mH1aeXs+AjvsH5
	2LaPV6h7EZljntIIKgpQz7TzdJnc646KitTkAoPZvmn9r04P1NnwsRsVifMThaCi1lQ==
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr19220232pls.11.1556156564639;
        Wed, 24 Apr 2019 18:42:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYTLqyQ5vmw/pfTxog3MShb+qCKhi4nSix5K7NThssNwJ+MsZQVq0bk9MYG79yz9orbNNQ
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr19220180pls.11.1556156563922;
        Wed, 24 Apr 2019 18:42:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156563; cv=none;
        d=google.com; s=arc-20160816;
        b=vPrd2XKBevWe2UERm5JRN4e2IggPlEpHafhGVCxF5cyXa2g/n66tAqtIXAND3gaj+S
         +J0AGc5+DLIludIsqKFeVV4a46uOVDdVa9kbGLuxijI3S/o1sSGVEmfPbgxE9DU01qkz
         BCITgR4Gr416szTyYLjdf5im01AEvTdwMO9jnggaMp1aqMyntaxrVxjyWYIsr6CcVaft
         Tv1T3gyS5V85OID5nq3ysCgaxZU4hv1LAUdPiS/bjLOjiR9OoejX2KwZTvQNuamsT7mY
         bd0Tov13DIOIwQjveuRe17S2Rlg6EiHysJzuWxJ6ACPqIQd9EdklU8v/XnMRs579H9U4
         TYpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=0yqiQlK/8S9jDfOWBw0HKH7+HNI4EnlVsdp6B0GH1hI=;
        b=D2LhsONwX2p7+MUpdKEwJ7eI2kzMBF71ZddbCu5FMYxKg2C5MOBswrInEa4axDOXTh
         iXO2p+kr6kKOsXAiD/p0phrz25Dbmuxp5YUo1NpeTQgHByAjKtqcJ0q6/9rTiROxhMSJ
         15KZDp89WaX4j0j4sQRLZu6zOXv1/S8ygz6A4283H2CiN2uPyxD04vvGL5dXiPz4mXkK
         nLopsAHepqQAxuPoJMgeFvzpg9oKYzaV+il221fcftCZL1fT5FYE9xT1R1nYjT9cwDTq
         rst0wByN0jne7SH8N5aaSqMetCbjB+mQr8kwA71PiqJdjgytn19/TvCdCODOXdztgKCx
         rPfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si21134661pfc.278.2019.04.24.18.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:42:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 18:42:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,391,1549958400"; 
   d="scan'208";a="152134215"
Received: from zz23f_aep_wp03.sh.intel.com ([10.239.85.39])
  by FMSMGA003.fm.intel.com with ESMTP; 24 Apr 2019 18:42:42 -0700
From: Fan Du <fan.du@intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	fengguang.wu@intel.com,
	dan.j.williams@intel.com,
	dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com,
	ying.huang@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Fan Du <fan.du@intel.com>
Subject: [RFC PATCH 1/5] acpi/numa: memorize NUMA node type from SRAT table
Date: Thu, 25 Apr 2019 09:21:31 +0800
Message-Id: <1556155295-77723-2-git-send-email-fan.du@intel.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556155295-77723-1-git-send-email-fan.du@intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mark NUMA node as DRAM or PMEM.

This could happen in boot up state (see the e820 pmem type
override patch), or on fly when bind devdax device with kmem
driver.

It depends on BIOS supplying PMEM NUMA proximity in SRAT table,
that's current production BIOS does.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 arch/x86/include/asm/numa.h | 2 ++
 arch/x86/mm/numa.c          | 2 ++
 drivers/acpi/numa.c         | 5 +++++
 3 files changed, 9 insertions(+)

diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
index bbfde3d..5191198 100644
--- a/arch/x86/include/asm/numa.h
+++ b/arch/x86/include/asm/numa.h
@@ -30,6 +30,8 @@
  */
 extern s16 __apicid_to_node[MAX_LOCAL_APIC];
 extern nodemask_t numa_nodes_parsed __initdata;
+extern nodemask_t numa_nodes_pmem;
+extern nodemask_t numa_nodes_dram;
 
 extern int __init numa_add_memblk(int nodeid, u64 start, u64 end);
 extern void __init numa_set_distance(int from, int to, int distance);
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index dfb6c4d..3c3a1f5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -20,6 +20,8 @@
 
 int numa_off;
 nodemask_t numa_nodes_parsed __initdata;
+nodemask_t numa_nodes_pmem;
+nodemask_t numa_nodes_dram;
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 867f6e3..ec4b7a7e 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -298,6 +298,11 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 
 	node_set(node, numa_nodes_parsed);
 
+	if (ma->flags & ACPI_SRAT_MEM_NON_VOLATILE)
+		node_set(node, numa_nodes_pmem);
+	else
+		node_set(node, numa_nodes_dram);
+
 	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
 		node, pxm,
 		(unsigned long long) start, (unsigned long long) end - 1,
-- 
1.8.3.1

