Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E76B2C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:18:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E76320651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:18:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="CqskdudS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E76320651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB5E46B0007; Wed,  1 May 2019 15:18:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B69B46B0008; Wed,  1 May 2019 15:18:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E2A36B000A; Wed,  1 May 2019 15:18:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9F96B0007
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:18:54 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id j20so17804751qta.23
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:18:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=XCMEqsTnk0N2iAxyILP6Z/EwAN/LZaWM24sWvUxI210=;
        b=H/KLPy/BMXJO51qPmvn2xuFl3LOTNhXYC3khRfKZRg49F4DAprVt7FF+8u1xAT07Pz
         qQ6EJy0S2YceCWj/IGFDmP8km+814zNQrPBrO+KoTWSYUU07M3bJe6FrG8Heh7+51il7
         5add8BdwEFYl8HtnptUj5e8hoUoDe/VTnSaUvWGT0rxIc/bc00fg+qMfGGkT/kGgvQc5
         sUnZWZrjnhK8ZhouqodRG9kIt3r4PYgB7dGR+nNYmW9HsQAZFJNX305tDI6X8+AA5YFh
         sbi4UHEekMlTj/kxDGQLxJL3Pz/AGsiaI1sGOR1tMQDiM4Mhvi6cdPXiRKdoxkRlW3M1
         kItg==
X-Gm-Message-State: APjAAAXr9LArJ1jkZhpANYKJoKfDNj2bt//IVn0Z32u6nDXPqVeXyJ5x
	ubTS+DRAV0Nj5ETPAHSTnZNnVFbjQYnlwTIiZSEeDjJwdCpvYskF81xYuUo3oXqTAUrcsi7+Uww
	QIV03Mq2Jnppts6Hd2qKBYl4HPxlvO59UK409hkGJtDt9CQdOLFgR19tMjWUBSIxDFQ==
X-Received: by 2002:ac8:25bc:: with SMTP id e57mr60450535qte.167.1556738334171;
        Wed, 01 May 2019 12:18:54 -0700 (PDT)
X-Received: by 2002:ac8:25bc:: with SMTP id e57mr60450440qte.167.1556738332627;
        Wed, 01 May 2019 12:18:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556738332; cv=none;
        d=google.com; s=arc-20160816;
        b=KL8U/fGpLybYtT9KylohPaS/qB5OtQsEnU/JJZXDvMdCQrfQLLhTzt1X8aClptJajL
         OOtWBS7YD8khsyERgk8DEAL5EMQQuTb9rQvA7UPZTmRKOZZbeK936joCkVf8LGGXIF7A
         vlgr/rxGldiCkRxk7GjLGdxHNT7ARRrvZymq48dYqqNtG0Jz1V2nr2OOVZfmEIJgdy/w
         HJei1NPQ2bDWLt322MRDSL6z64V25BT4HQIe6E1znUkdl6cr7/A3wvs7dsJ0Vj2GDGlD
         D5JpNYK73ukyj/vUncCDGJGkvV/iez449TvE3uKvvxw7pPvu46sHUDR/izrYrPZiwLk3
         tPAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=XCMEqsTnk0N2iAxyILP6Z/EwAN/LZaWM24sWvUxI210=;
        b=nFoz6LsIne3nmabQnZx2gehTmjN21wB7+yG0jvzNGRgua1P4UTxcaFG5mWmT/j/OoJ
         Fm3mYeEPjr7baHMYGSBFRIQJzZDEzZ2jfJn5BVPENhsqoZbGPIDpJnI8A1Ckmlwf2osE
         Sfx63gtSOzkq7/NMyDk6knPlCRvKHcj1q+6yG7TslWAh2yu6ZyePl8qSkGSfde4/G9Xi
         XE4lx64dFN2yH2Y70sc7GPVUpEsC9c3TS1IzDKS0poRuj41IrmmDKcHL3VjAGSQvCba5
         uaHf/3KU7cpbOmSI/xUsBJh+OOEvVN2qlAxzPHZInvJuIwsSJlyKbOcE39DY4JqbvZz1
         u07g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=CqskdudS;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor54712105qte.56.2019.05.01.12.18.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 12:18:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=CqskdudS;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XCMEqsTnk0N2iAxyILP6Z/EwAN/LZaWM24sWvUxI210=;
        b=CqskdudS7mwUlxptslgcXZ0QXR8Q/fCHG6QqeM31KcRRrgba1pDwhhpkltcSnQ8E+L
         gVy3qEXIP9svc8iYegEcV/mBtjU32rZrilr/1yEVwo3ZBgQDRnFeooOZWLI8PWqA/aqM
         2/abCp/DzPl3aAXbPZE+wmVPChF1H6i7y2NZdzqN2QTmKPCkeyYfe/ey1dloFGFUYdQ7
         o7Gv4D4ybUKpi4nRzae4TegIE0OMPPpqe7hjxF3DaArCCD0eBslynFzDIPmzA8HLX8iU
         HvG+db1yeo/SI2iFKCPOwjyYWIRzRQ1gJWm58qJrs6DibYEVtfnlNuz1y4juHcc9P8NZ
         f31Q==
X-Google-Smtp-Source: APXvYqzmNaTzzfNQY+U4p8zlZSxKvZsU3NG8OeWx/CjintReZDdamrlUDLJx9jczTgf2Hvh5qF+FYA==
X-Received: by 2002:ac8:3553:: with SMTP id z19mr51949671qtb.146.1556738332321;
        Wed, 01 May 2019 12:18:52 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id x47sm12610946qth.68.2019.05.01.12.18.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:18:51 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v4 2/2] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Wed,  1 May 2019 15:18:46 -0400
Message-Id: <20190501191846.12634-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190501191846.12634-1-pasha.tatashin@soleen.com>
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is now allowed to use persistent memory like a regular RAM, but
currently there is no way to remove this memory until machine is
rebooted.

This work expands the functionality to also allows hotremoving
previously hotplugged persistent memory, and recover the device for use
for other purposes.

To hotremove persistent memory, the management software must first
offline all memory blocks of dax region, and than unbind it from
device-dax/kmem driver. So, operations should look like this:

echo offline > echo offline > /sys/devices/system/memory/memoryN/state
...
echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind

Note: if unbind is done without offlining memory beforehand, it won't be
possible to do dax0.0 hotremove, and dax's memory is going to be part of
System RAM until reboot.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 drivers/dax/dax-private.h |  2 +
 drivers/dax/kmem.c        | 99 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 97 insertions(+), 4 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index a45612148ca0..999aaf3a29b3 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -53,6 +53,7 @@ struct dax_region {
  * @pgmap - pgmap for memmap setup / lifetime (driver owned)
  * @ref: pgmap reference count (driver owned)
  * @cmp: @ref final put completion (driver owned)
+ * @dax_mem_res: physical address range of hotadded DAX memory
  */
 struct dev_dax {
 	struct dax_region *region;
@@ -62,6 +63,7 @@ struct dev_dax {
 	struct dev_pagemap pgmap;
 	struct percpu_ref ref;
 	struct completion cmp;
+	struct resource *dax_kmem_res;
 };
 
 static inline struct dev_dax *to_dev_dax(struct device *dev)
diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index 4c0131857133..72b868066026 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -71,21 +71,112 @@ int dev_dax_kmem_probe(struct device *dev)
 		kfree(new_res);
 		return rc;
 	}
+	dev_dax->dax_kmem_res = new_res;
 
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static int
+check_devdax_mem_offlined_cb(struct memory_block *mem, void *arg)
+{
+	/* Memory block device */
+	struct device *mem_dev = &mem->dev;
+	bool is_offline;
+
+	device_lock(mem_dev);
+	is_offline = mem_dev->offline;
+	device_unlock(mem_dev);
+
+	/*
+	 * Check that device-dax's memory_blocks are offline. If a memory_block
+	 * is not offline a warning is printed and an error is returned.
+	 */
+	if (!is_offline) {
+		/* Dax device device */
+		struct device *dev = (struct device *)arg;
+		struct dev_dax *dev_dax = to_dev_dax(dev);
+		struct resource *res = &dev_dax->region->res;
+		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
+		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr) +
+						       PAGES_PER_SECTION - 1;
+		phys_addr_t spa = spfn << PAGE_SHIFT;
+		phys_addr_t epa = epfn << PAGE_SHIFT;
+
+		dev_err(dev,
+			"DAX region %pR cannot be hotremoved until the next reboot. Memory block [%pa-%pa] is not offline.\n",
+			res, &spa, &epa);
+
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int dev_dax_kmem_remove(struct device *dev)
+{
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct resource *res = dev_dax->dax_kmem_res;
+	resource_size_t kmem_start;
+	resource_size_t kmem_size;
+	unsigned long start_pfn;
+	unsigned long end_pfn;
+	int rc;
+
+	kmem_start = res->start;
+	kmem_size = resource_size(res);
+	start_pfn = kmem_start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
+
+	/*
+	 * Keep hotplug lock while checking memory state, and also required
+	 * during __remove_memory() call. Admin can't change memory state via
+	 * sysfs while this lock is kept.
+	 */
+	lock_device_hotplug();
+
+	/*
+	 * Walk and check that every singe memory_block of dax region is
+	 * offline. Hotremove can succeed only when every memory_block is
+	 * offlined beforehand.
+	 */
+	rc = walk_memory_range(start_pfn, end_pfn, dev,
+			       check_devdax_mem_offlined_cb);
+
+	/*
+	 * If admin has not offlined memory beforehand, we cannot hotremove dax.
+	 * Unfortunately, because unbind will still succeed there is no way for
+	 * user to hotremove dax after this.
+	 */
+	if (rc) {
+		unlock_device_hotplug();
+		return rc;
+	}
+
+	/* Hotremove memory, cannot fail because memory is already offlined */
+	__remove_memory(dev_dax->target_node, kmem_start, kmem_size);
+	unlock_device_hotplug();
+
+	/* Release and free dax resources */
+	release_resource(res);
+	kfree(res);
+	dev_dax->dax_kmem_res = NULL;
+
+	return 0;
+}
+#else
 static int dev_dax_kmem_remove(struct device *dev)
 {
 	/*
-	 * Purposely leak the request_mem_region() for the device-dax
-	 * range and return '0' to ->remove() attempts. The removal of
-	 * the device from the driver always succeeds, but the region
-	 * is permanently pinned as reserved by the unreleased
+	 * Without hotremove purposely leak the request_mem_region() for the
+	 * device-dax range and return '0' to ->remove() attempts. The removal
+	 * of the device from the driver always succeeds, but the region is
+	 * permanently pinned as reserved by the unreleased
 	 * request_mem_region().
 	 */
 	return 0;
 }
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 
 static struct dax_device_driver device_dax_kmem_driver = {
 	.drv = {
-- 
2.21.0

