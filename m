Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09035C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 21:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98AFA2082A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 21:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98AFA2082A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F26F26B0006; Tue,  9 Apr 2019 17:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED6236B000A; Tue,  9 Apr 2019 17:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DECC26B000C; Tue,  9 Apr 2019 17:42:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4D366B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 17:42:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m35so226412pgl.6
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 14:42:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=cL0JUJxO/3mKDCDuqT/ytNdR0j/shFGhyZppe5rDFjU=;
        b=iuDcpO8sBqeM7aiNt/50A4Uvk4Wg5+U7IiatB3Xbsy3Qgu2HWmuUfmR5GfHk8vWqBS
         uly5Q5ie9+O5EvnlZlxh4I1ceaagMtb1naO3E7E3tR5KJPY6ACIqhCp4tGC1NyhMLdBC
         su1yLkT2TOLh30ZYz8civLAlfRg4vYmB8a8HdKcinD54nqxIt6ZVWxBON9b7Tck1AWM2
         yIqsalEDPMNRnwHLe8xvJAGQGkLLXTE5K4tRqMZvihxyEodivqrASg5MpF74iH99NuWf
         PxHogslM0dCkPV2eR6qDy2Xq2Ep44DSxmuRpTUFLXQciZcsKaLRIs5khXIrslzwmvXJ9
         hxmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVNf1J4T+H37gPZfMF9Qla94k6AbzxUmGUCjh1gSO7xP/mDDCyp
	P4mzenpraYVlw2UZUClTQ0gIdUMRfqVX5XjleYoRDbJcM8rtm4j+8GTp0NlIDrdGhrY7qJGzI6P
	EMNbC+MpY+KNv+psmuyHpRhi9Am8r/Aieps3ZWMHkPpJGqrG+44PfvYBE2hT7wvFeiA==
X-Received: by 2002:a63:7152:: with SMTP id b18mr36735393pgn.186.1554846160275;
        Tue, 09 Apr 2019 14:42:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIVY8M9Rdg8PpgqnH0M6dNaZYeqxScBKaGRpQuU6cOX7kbYsdQv/QO4MDTAe9k3Uhwwosc
X-Received: by 2002:a63:7152:: with SMTP id b18mr36735308pgn.186.1554846158898;
        Tue, 09 Apr 2019 14:42:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554846158; cv=none;
        d=google.com; s=arc-20160816;
        b=b7J66OccVVIGbcReQv82Hwq3nQpeU+pNM46iIAbA5bLKuYnB7z4jNcmgQbIup6q7dd
         oTQSWek56vJMXMfReGp1kmhjjllMAZYjHdHHpTj2PnII/uHKnaK+Zl25oxjRmsUfpIDk
         QQQg7SltoVYbFxTpxbdUXsCGT/S4qgvJvdwvTFDRx1dZCiYTMiuy84+J1fiFeD2rgk50
         4RMltexxR2VunZJJ4O8L219qktpdszmGQoRhEs5bC3Pici4cHCKGhtj7EM9WZko5DWYi
         leoJHTlchRXh8O7LGW3CSITvqyFLk9N2qhhxrWsAeJ4ZbS0+ehaS/ZaJ/9BelAz0rCTF
         vIIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=cL0JUJxO/3mKDCDuqT/ytNdR0j/shFGhyZppe5rDFjU=;
        b=UhEsnF45qpM0quPDq/EniQPtRia6B3oyM46eo/QtMo98qSavdf0fW1V2nxJZ1SCy3o
         AJAf/ll8IoDW7Lgs3gLQNpyM50FnSxHrLhb6tVkVCkJq6N2Rx+sTobMPLSYTphvTybtJ
         iKyKA/y7XK9R14o9x7+M1mDMLK9yPPgkP7EmZVAf3CwTOp3c9BypbvODHF9O3prb945V
         hDD76KbkHAnVhnE7p5Wvm1VyXPwSdpJHTopKsjo/OA6aYS/qvTXLLdhptumfCoGu9i77
         bfwQjwkj1JJIY/ul6x+AtA8FENTHCVKdsdbgcMxw5/gu9ADc5SBQoyD+LrQeBrnJ0ePS
         tRyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d3si23117334pfc.278.2019.04.09.14.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 14:42:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Apr 2019 14:42:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,330,1549958400"; 
   d="scan'208";a="290150061"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga004.jf.intel.com with ESMTP; 09 Apr 2019 14:42:37 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org
Cc: Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH] hmat: Register attributes for memory hot add
Date: Tue,  9 Apr 2019 15:44:15 -0600
Message-Id: <20190409214415.3722-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some types of memory nodes that HMAT describes may not be online at the
time we initially parse their nodes' tables. If the node should be set
to online later, as can happen when using PMEM as RAM after boot, the
node's attributes will be missing their initiator links and performance.

Regsiter a memory notifier callback and set the memory attributes when
a node is initially brought online with hot added memory, and don't try
to register node attributes if the node is not online during initial
scanning.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 63 ++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 50 insertions(+), 13 deletions(-)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index b275016ff648..cf24b885feb5 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -14,14 +14,15 @@
 #include <linux/init.h>
 #include <linux/list.h>
 #include <linux/list_sort.h>
+#include <linux/memory.h>
 #include <linux/node.h>
 #include <linux/sysfs.h>
 
-static __initdata u8 hmat_revision;
+static u8 hmat_revision;
 
-static __initdata LIST_HEAD(targets);
-static __initdata LIST_HEAD(initiators);
-static __initdata LIST_HEAD(localities);
+static LIST_HEAD(targets);
+static LIST_HEAD(initiators);
+static LIST_HEAD(localities);
 
 /*
  * The defined enum order is used to prioritize attributes to break ties when
@@ -41,6 +42,7 @@ struct memory_target {
 	unsigned int memory_pxm;
 	unsigned int processor_pxm;
 	struct node_hmem_attrs hmem_attrs;
+	bool registered;
 };
 
 struct memory_initiator {
@@ -53,7 +55,7 @@ struct memory_locality {
 	struct acpi_hmat_locality *hmat_loc;
 };
 
-static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
+static struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
 {
 	struct memory_initiator *initiator;
 
@@ -63,7 +65,7 @@ static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
 	return NULL;
 }
 
-static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
+static struct memory_target *find_mem_target(unsigned int mem_pxm)
 {
 	struct memory_target *target;
 
@@ -148,7 +150,7 @@ static __init const char *hmat_data_type_suffix(u8 type)
 	}
 }
 
-static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
+static u32 hmat_normalize(u16 entry, u64 base, u8 type)
 {
 	u32 value;
 
@@ -183,7 +185,7 @@ static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
 	return value;
 }
 
-static __init void hmat_update_target_access(struct memory_target *target,
+static void hmat_update_target_access(struct memory_target *target,
 					     u8 type, u32 value)
 {
 	switch (type) {
@@ -435,7 +437,7 @@ static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
 	return 0;
 }
 
-static __init u32 hmat_initiator_perf(struct memory_target *target,
+static u32 hmat_initiator_perf(struct memory_target *target,
 			       struct memory_initiator *initiator,
 			       struct acpi_hmat_locality *hmat_loc)
 {
@@ -473,7 +475,7 @@ static __init u32 hmat_initiator_perf(struct memory_target *target,
 			      hmat_loc->data_type);
 }
 
-static __init bool hmat_update_best(u8 type, u32 value, u32 *best)
+static bool hmat_update_best(u8 type, u32 value, u32 *best)
 {
 	bool updated = false;
 
@@ -517,7 +519,7 @@ static int initiator_cmp(void *priv, struct list_head *a, struct list_head *b)
 	return ia->processor_pxm - ib->processor_pxm;
 }
 
-static __init void hmat_register_target_initiators(struct memory_target *target)
+static void hmat_register_target_initiators(struct memory_target *target)
 {
 	static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
 	struct memory_initiator *initiator;
@@ -577,22 +579,53 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
 	}
 }
 
-static __init void hmat_register_target_perf(struct memory_target *target)
+static void hmat_register_target_perf(struct memory_target *target)
 {
 	unsigned mem_nid = pxm_to_node(target->memory_pxm);
 	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
 }
 
-static __init void hmat_register_targets(void)
+static void hmat_register_targets(void)
 {
 	struct memory_target *target;
 
 	list_for_each_entry(target, &targets, node) {
+		if (!node_online(pxm_to_node(target->memory_pxm)))
+			continue;
+
 		hmat_register_target_initiators(target);
 		hmat_register_target_perf(target);
+		target->registered = true;
 	}
 }
 
+static int hmat_callback(struct notifier_block *self,
+			 unsigned long action, void *arg)
+{
+	struct memory_notify *mnb = arg;
+	int pxm, nid = mnb->status_change_nid;
+	struct memory_target *target;
+
+	if (nid == NUMA_NO_NODE || action != MEM_ONLINE)
+		return NOTIFY_OK;
+
+	pxm = node_to_pxm(nid);
+	target = find_mem_target(pxm);
+	if (!target || target->registered)
+		return NOTIFY_OK;
+
+	hmat_register_target_initiators(target);
+	hmat_register_target_perf(target);
+	target->registered = true;
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block hmat_callback_nb = {
+	.notifier_call = hmat_callback,
+	.priority = 2,
+};
+
 static __init void hmat_free_structures(void)
 {
 	struct memory_target *target, *tnext;
@@ -658,6 +691,10 @@ static __init int hmat_init(void)
 		}
 	}
 	hmat_register_targets();
+
+	/* Keep the table and structures if the notifier may use them */
+	if (!register_hotmemory_notifier(&hmat_callback_nb))
+		return 0;
 out_put:
 	hmat_free_structures();
 	acpi_put_table(tbl);
-- 
2.14.4

