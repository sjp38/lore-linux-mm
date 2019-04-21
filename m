Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54756C282E2
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 01:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 077D220833
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 01:44:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ZcOj6/tW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 077D220833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E93F56B0008; Sat, 20 Apr 2019 21:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E46D06B000A; Sat, 20 Apr 2019 21:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D31756B000C; Sat, 20 Apr 2019 21:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B541D6B0008
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 21:44:37 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o34so8396651qte.5
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 18:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=KL328kJp7uYop/CaXZcmGRKfoBkXK0v1G+nukTp5itg=;
        b=XimIRWqOjAbFTXxpuAQDMSUWE0VSgDT1FLPyCZt6nt5sqr09DcQ9TWGZ3EP6m66A16
         PNUorDf6T9DBtBs+QQvXJ5qkJgSlz6h+qmyF/EJwezOBxrFj9fxB2XcSoR9jYSiFfCUo
         kUO4eO8396iEGmEe1atFhbNJ0pjp6V21qz7m92sz391ogUdRXlyBTdFbY79XFI70grFX
         vf4QMpgd/HPW+wkBHKBm2/AF3owa+sZS/cIrBb8yWJWCqRav+sFUpbbUeUPMmQcPiMOc
         utBog76zyq1Fw4y3xEwjhgxThlr4G/QDCr0VdMvWewiL//oY4vo3wLWUFDY9aUTYdsm6
         g05w==
X-Gm-Message-State: APjAAAWbnFUb3FxEH1YT0B2nhoX99xQuFQvp7kRonvnB8aOkCuBXcgyn
	DExJmEjSm6uzG3aLpNwx8kQ5aToICehRWHGXqotQTIK/hSyrsU/oQC/iN4JMyoGb+OWn3Qcd38/
	p++A98YW28CNKFmMmZP8egN/LiZhs6ysLkmaoMyRkrjgouXVj+9afO3ZsYy4IzUBvHw==
X-Received: by 2002:a37:5ac4:: with SMTP id o187mr9621544qkb.356.1555811077465;
        Sat, 20 Apr 2019 18:44:37 -0700 (PDT)
X-Received: by 2002:a37:5ac4:: with SMTP id o187mr9621501qkb.356.1555811076083;
        Sat, 20 Apr 2019 18:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555811076; cv=none;
        d=google.com; s=arc-20160816;
        b=GwndR9z4AANqaNYAM2KlgV9+OaVOgkFJV0Lo60y0oJrLPugE0yZJ/WLWeNXj7Hro0p
         mIMKsIXrRBmCI2unDpiW8gSTGo7JquHB13QcO2pUQx1FH2403G4c3xNiGsSXtEwMoD0V
         ORenKBNHu90Ku3kdp0Hz/F1mva7wbSbG9+G8v4nT4DcodKb3W1gDOlydsjjkbZqSBIxL
         UUGjLNrYM5e2WkxC3YsL5hXkTozpWHsUyvN5HaSQ8XrrR/qiNX1HLGxU1eLIhHmBJt0r
         7sFEK6DFnXBaVCJKDoBdXiqO4Y0A/KcOPa97z+9PPRdT3jHuVNNv6UaejSwbo5uMCI7P
         8cRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=KL328kJp7uYop/CaXZcmGRKfoBkXK0v1G+nukTp5itg=;
        b=caJAuZ5rD0xCv3UBjrrHJ3JZ/6UUTrrvnztz+zieNBsOwsMDCuKHfJRK6e/jFEc9mq
         WgogqzVktBF5gpk0lZsmsf72uSC6X1Y9Wy+CxySGece9tOdbTF9b5ih49vztKyWIGoAd
         qxFG71sqi6+jQ+7LjhGLWJf8n104IRddfoKY5Qsm1oDJoqS8WK7WhSN1qcnbpX3aGY4F
         Tz7CJ3lb1Xw8h6BEZdFMwa8P+1Kfi1w9OVRWIm6dtbYSXbzVbU5FWS7BmBB+CXcxeW2E
         A+s19UAfqceVoibi7dfDhZhinaA+crRkzd+KB9OGn2nnsxufM42hN5GWJ5D//e2+AAe+
         9x0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="ZcOj6/tW";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor10901215qte.56.2019.04.20.18.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 18:44:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="ZcOj6/tW";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KL328kJp7uYop/CaXZcmGRKfoBkXK0v1G+nukTp5itg=;
        b=ZcOj6/tWBZki8VSTYWIx2hC0zATUWkFU1OTXUPmLys73YN2QUPVmWMkCAzisCIphb4
         lagFcRl0UAa1+nKpZPFW6/ywAODOoC2ElJuMxdMZK+n/MVj6NLUv0dZbEJuUtuqfRbAG
         2vQO7zgIlXc6foQWwNvVaXJ4cmOF6Nv1Mbrym5SdV+qbCVa1vCnbCbAIPeojIxSuiyzv
         alULIAAU7iGCTj9LS/VnbEzAzTbYgUAZW4UQycLNdEUtMMs7BATfDuCFjGJGPJtHwATa
         X1SGiIiiccfzYurY/yFrS0TMcM5+2hTPgZVtuHjsxwv960+2M26QfeQOg2ZSfR+OrX9P
         Nihw==
X-Google-Smtp-Source: APXvYqwLrbFXWXl4ushQLhaJbuTDu4grdgvxRuAMcypo1JTsKGB8Q7Xxy+bv6W6dd9hWBd51O4WhFg==
X-Received: by 2002:ac8:1776:: with SMTP id u51mr436168qtk.151.1555811075671;
        Sat, 20 Apr 2019 18:44:35 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u1sm1385218qtj.50.2019.04.20.18.44.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 18:44:34 -0700 (PDT)
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
	jglisse@redhat.com
Subject: [v2 2/2] device-dax: "Hotremove" persistent memory that is used like normal RAM
Date: Sat, 20 Apr 2019 21:44:29 -0400
Message-Id: <20190421014429.31206-3-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190421014429.31206-1-pasha.tatashin@soleen.com>
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
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
 drivers/dax/kmem.c        | 91 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 89 insertions(+), 4 deletions(-)

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
index 4c0131857133..d4896b281036 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -71,21 +71,104 @@ int dev_dax_kmem_probe(struct device *dev)
 		kfree(new_res);
 		return rc;
 	}
+	dev_dax->dax_kmem_res = new_res;
 
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/*
+ * Check that device-dax's memory_blocks are offline. If a memory_block is not
+ * offline a warning is printed and an error is returned. dax hotremove can
+ * succeed only when every memory_block is offlined beforehand.
+ */
+static int
+offline_memblock_cb(struct memory_block *mem, void *arg)
+{
+	struct device *mem_dev = &mem->dev;
+	bool is_offline;
+
+	device_lock(mem_dev);
+	is_offline = mem_dev->offline;
+	device_unlock(mem_dev);
+
+	if (!is_offline) {
+		struct device *dev = (struct device *)arg;
+		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
+		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
+		phys_addr_t spa = spfn << PAGE_SHIFT;
+		phys_addr_t epa = epfn << PAGE_SHIFT;
+
+		dev_warn(dev, "memory block [%pa-%pa] is not offline\n",
+			 &spa, &epa);
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
+	/*
+	 * dax kmem resource does not exist, means memory was never hotplugged.
+	 * So, nothing to do here.
+	 */
+	if (!res)
+		return 0;
+
+	kmem_start = res->start;
+	kmem_size = resource_size(res);
+	start_pfn = kmem_start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
+
+	/*
+	 * Walk and check that every singe memory_block of dax region is
+	 * offline
+	 */
+	lock_device_hotplug();
+	rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
+	unlock_device_hotplug();
+
+	/*
+	 * If admin has not offlined memory beforehand, we cannot hotremove dax.
+	 * Unfortunately, because unbind will still succeed there is no way for
+	 * user to hotremove dax after this.
+	 */
+	if (rc)
+		return rc;
+
+	/* Hotremove memory, cannot fail because memory is already offlined */
+	remove_memory(dev_dax->target_node, kmem_start, kmem_size);
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

