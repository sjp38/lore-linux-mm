Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA2B0C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:26:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7486A206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:26:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7486A206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68D738E0017; Wed, 16 Jan 2019 13:25:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6680A8E0004; Wed, 16 Jan 2019 13:25:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50D7E8E0017; Wed, 16 Jan 2019 13:25:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F05298E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:45 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so5262773pfi.19
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=zigwy9nXqDX3uU3GGBYYlKvactAnm1EGulzF+98tmsg=;
        b=s42OYGMaAX/eKX5eRQPjVlcynph1QimF7koLVcDe4fxTMC4W3c3y4hMFFlkdLMlcO1
         RBCtRwVaCyKyRlHXXMPZM9fKM4KbuQ+uoMuXgdRCWXi81suvxoj2XHxzClRFCASzkN2a
         qudCET9lT4CULQ+c62V3IzxFviCCYbkbao/jziRqouKwyCSq7WTiWm7nznlXYFBpQ6Yn
         kHVK1JIu+ESaiV9KXYDfJVmk9XoPBz5S/QLBKiipkW1nnhMi4KnqxHKrQH0r0NwoMI0m
         IAYfHU4Vcp/5lVgaZpGS3dhGC1I15PxLhs19/dMUAytKse7psSqbZurYskq/gGTOEXKM
         TKvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUuke6MBnmQJE2BOBl9oNl9FOD43sslJdNyuZu70dKr/SQG9Iqe+5W
	gUt8MQR5z6g5Uy0z9vV/4jTNPcc3cNsimevwSwrh8czQgSX+m3Eb1/uFBBEuQOpWr7wtGhFpZ3/
	kyJDjQhm8AKtZonnwfCN+nY/6qqbc566avErVwUVzo22QcOCWLueiKWKVNsttQMdfAQ==
X-Received: by 2002:a17:902:7296:: with SMTP id d22mr11411410pll.265.1547663145625;
        Wed, 16 Jan 2019 10:25:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7nQLAxtMtu7Vy6Bu9+olAJx//+4cGwrdaDvsPUab3hGnGoCFzZxbAmFtCHEXq99LDQTfe6
X-Received: by 2002:a17:902:7296:: with SMTP id d22mr11411351pll.265.1547663144722;
        Wed, 16 Jan 2019 10:25:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547663144; cv=none;
        d=google.com; s=arc-20160816;
        b=k/V9RkjysvE1qJtJpMBHNSe9TX/n7T3w5xqUgc4CD5NKR20StONZEVxhXqgBB0qC0I
         rwl2E8Pp79wKgUYym6ZHaQyu1uc5pYvfWvcLH1VxxPcksecfk0mKBMeSWKq4DGmAMFa5
         8myC3nJqPf8OyDPuo9/jhB6mA0o807AXHN/rqoUbis00COy65Ncyl3Vi/f0S9ymCTZ+8
         FDv1NMbKKq4EQvdq9aOuBQTLbZvSUM5kWRF6HQFfdg+3BQRhOn8JTEWf4NlAuz0MBod7
         GzKTEo2e9QIfdI2AwV07Uvd6GLR1YC/b7UJq8dASB8iGYI6giJW6PfhWNIw32hKu9qLj
         sTyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=zigwy9nXqDX3uU3GGBYYlKvactAnm1EGulzF+98tmsg=;
        b=xrc3Fr8lEyzqrVUX6sWRsNErXMz+yS3rMKCYl0hI0M8aeCz1jEsnylcwvime6fSVzR
         xqvmdJc0FsDfewdNjnJPHfrn5eZA9jeUXmCwQzg/aTcdq8tMX4lK7jKRWnPxsm4zXFS7
         53/YrI6OKEafPvTSVfR85pc86eyy8T+V+OTENJX0BemkU/xyABr72kyNMAN+GdoecIbv
         PbUQcThHchWTiBtTZs6RxCny42Ubh1SpPZXjsSB+yjehtUdbimhTPgiipBAWvgXNnvcu
         pY8zCjB/8z1OSq53Sr/gUAeqhCWaL6s5spMat/7S4BLNhbUaIreIPQVLjrYrZlqxQN++
         P2CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e6si1674985pgd.428.2019.01.16.10.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:25:44 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jan 2019 10:25:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,487,1539673200"; 
   d="scan'208";a="108759249"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga006.jf.intel.com with ESMTP; 16 Jan 2019 10:25:43 -0800
Subject: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
To: dave@sr71.net
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-kernel@vger.kernel.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 16 Jan 2019 10:19:05 -0800
References: <20190116181859.D1504459@viggo.jf.intel.com>
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com>
Message-Id: <20190116181905.12E102B4@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190116181905.fy-YgM4uwNcH0HfU4eMkPob0AbB02DErgOrdsNG-fZc@z>


From: Dave Hansen <dave.hansen@linux.intel.com>

Currently, a persistent memory region is "owned" by a device driver,
either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
allow applications to explicitly use persistent memory, generally
by being modified to use special, new libraries.

However, this limits persistent memory use to applications which
*have* been modified.  To make it more broadly usable, this driver
"hotplugs" memory into the kernel, to be managed ad used just like
normal RAM would be.

To make this work, management software must remove the device from
being controlled by the "Device DAX" infrastructure:

	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind

and then bind it to this new driver:

	echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
	echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind

After this, there will be a number of new memory sections visible
in sysfs that can be onlined, or that may get onlined by existing
udev-initiated memory hotplug rules.

Note: this inherits any existing NUMA information for the newly-
added memory from the persistent memory device that came from the
firmware.  On Intel platforms, the firmware has guarantees that
require each socket's persistent memory to be in a separate
memory-only NUMA node.  That means that this patch is not expected
to create NUMA nodes, but will simply hotplug memory into existing
nodes.

There is currently some metadata at the beginning of pmem regions.
The section-size memory hotplug restrictions, plus this small
reserved area can cause the "loss" of a section or two of capacity.
This should be fixable in follow-on patches.  But, as a first step,
losing 256MB of memory (worst case) out of hundreds of gigabytes
is a good tradeoff vs. the required code to fix this up precisely.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
---

 b/drivers/dax/Kconfig  |    5 ++
 b/drivers/dax/Makefile |    1 
 b/drivers/dax/kmem.c   |   93 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 99 insertions(+)

diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
--- a/drivers/dax/Kconfig~dax-kmem-try-4	2019-01-08 09:54:44.051694874 -0800
+++ b/drivers/dax/Kconfig	2019-01-08 09:54:44.056694874 -0800
@@ -32,6 +32,11 @@ config DEV_DAX_PMEM
 
 	  Say M if unsure
 
+config DEV_DAX_KMEM
+	def_bool y
+	depends on DEV_DAX_PMEM   # Needs DEV_DAX_PMEM infrastructure
+	depends on MEMORY_HOTPLUG # for add_memory() and friends
+
 config DEV_DAX_PMEM_COMPAT
 	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
 	depends on DEV_DAX_PMEM
diff -puN /dev/null drivers/dax/kmem.c
--- /dev/null	2018-12-03 08:41:47.355756491 -0800
+++ b/drivers/dax/kmem.c	2019-01-08 09:54:44.056694874 -0800
@@ -0,0 +1,93 @@
+// SPDX-License-Identifier: GPL-2.0
+/* Copyright(c) 2016-2018 Intel Corporation. All rights reserved. */
+#include <linux/memremap.h>
+#include <linux/pagemap.h>
+#include <linux/memory.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/pfn_t.h>
+#include <linux/slab.h>
+#include <linux/dax.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include "dax-private.h"
+#include "bus.h"
+
+int dev_dax_kmem_probe(struct device *dev)
+{
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct resource *res = &dev_dax->region->res;
+	resource_size_t kmem_start;
+	resource_size_t kmem_size;
+	struct resource *new_res;
+	int numa_node;
+	int rc;
+
+	/* Hotplug starting at the beginning of the next block: */
+	kmem_start = ALIGN(res->start, memory_block_size_bytes());
+
+	kmem_size = resource_size(res);
+	/* Adjust the size down to compensate for moving up kmem_start: */
+        kmem_size -= kmem_start - res->start;
+	/* Align the size down to cover only complete blocks: */
+	kmem_size &= ~(memory_block_size_bytes() - 1);
+
+	new_res = devm_request_mem_region(dev, kmem_start, kmem_size,
+					  dev_name(dev));
+
+	if (!new_res) {
+		printk("could not reserve region %016llx -> %016llx\n",
+				kmem_start, kmem_start+kmem_size);
+		return -EBUSY;
+	}
+
+	/*
+	 * Set flags appropriate for System RAM.  Leave ..._BUSY clear
+	 * so that add_memory() can add a child resource.
+	 */
+	new_res->flags = IORESOURCE_SYSTEM_RAM;
+	new_res->name = dev_name(dev);
+
+	numa_node = dev_dax->target_node;
+	if (numa_node < 0) {
+		pr_warn_once("bad numa_node: %d, forcing to 0\n", numa_node);
+		numa_node = 0;
+	}
+
+	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
+	if (rc)
+		return rc;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dev_dax_kmem_probe);
+
+static int dev_dax_kmem_remove(struct device *dev)
+{
+	/* Assume that hot-remove will fail for now */
+	return -EBUSY;
+}
+
+static struct dax_device_driver device_dax_kmem_driver = {
+	.drv = {
+		.probe = dev_dax_kmem_probe,
+		.remove = dev_dax_kmem_remove,
+	},
+};
+
+static int __init dax_kmem_init(void)
+{
+	return dax_driver_register(&device_dax_kmem_driver);
+}
+
+static void __exit dax_kmem_exit(void)
+{
+	dax_driver_unregister(&device_dax_kmem_driver);
+}
+
+MODULE_AUTHOR("Intel Corporation");
+MODULE_LICENSE("GPL v2");
+module_init(dax_kmem_init);
+module_exit(dax_kmem_exit);
+MODULE_ALIAS_DAX_DEVICE(0);
diff -puN drivers/dax/Makefile~dax-kmem-try-4 drivers/dax/Makefile
--- a/drivers/dax/Makefile~dax-kmem-try-4	2019-01-08 09:54:44.053694874 -0800
+++ b/drivers/dax/Makefile	2019-01-08 09:54:44.056694874 -0800
@@ -1,6 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
+obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
 
 dax-y := super.o
 dax-y += bus.o
_

