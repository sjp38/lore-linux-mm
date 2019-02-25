Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E903C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DEE42084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DEE42084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 518948E000C; Mon, 25 Feb 2019 14:02:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C63F8E0004; Mon, 25 Feb 2019 14:02:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B79E8E000C; Mon, 25 Feb 2019 14:02:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0D1E8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:02:41 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so7699412pgc.3
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:02:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=XiMqr0hWyG/rAB1cGp/Q4giXGgzO5P9hGJu2yp7i+yw=;
        b=dfDxn7DAPLDvaDVRTJ4G2gRtpIFqnUUhDTWErftiitD7SDgtktU6FmRqKzvcvayPTI
         VGiuYuq/wIE0xFAOpkhfpyZ3ofLBrX5SpkpNUvbLnyA3UGcDou9g6A6Zn081MxLMjPAA
         QBeG5eSsx8dqIvu5VQ1UanzFJZgkbMp+yQnYSmj3hwLOq1EMVZ/27tbkZYnmiqVnI8w+
         vWsv74844LYQFytbFj+vAcIMFWiwR0A9h60sVqooI5uVNLJzXOxgxAbFhmGcaEJfP1ZT
         cqar26bZtDnxoAgm1wdBaYuBCPx6mljCkRhiOjplJqf4Gvcnv1MiGw1IAmunc1+G8tGu
         llKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaLuaOmylF1+wPrQGzt8HVz4zZw85PyAf24vgwy7pRUfzgjFdKp
	nKquk02MMNml++jjhObQh9nwy/FJ5QO8ftAxR9b6EGLT5Pf2tha4HAaISLoaeYO63ajVTT/A2fK
	oQaGnOktvQo00mBtGjzovFzNIlYdnaj4RWX5gfm9CajUHppiFb8UOAeDYzAxhxZ3yaQ==
X-Received: by 2002:a63:4e05:: with SMTP id c5mr20701741pgb.393.1551121361618;
        Mon, 25 Feb 2019 11:02:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVmv84sItNYVXG83rZxg7ubJH/g1t9nG009JEoLjFTizWsSBKvCxqf9wgcIAzRG5jUQDTQ
X-Received: by 2002:a63:4e05:: with SMTP id c5mr20701674pgb.393.1551121360708;
        Mon, 25 Feb 2019 11:02:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551121360; cv=none;
        d=google.com; s=arc-20160816;
        b=EzbF9CifXSfMdow648d6f8dhqYhY+7idmyOc6UYyCVFzzEgeJGjgG+eHE1FaG1wNs2
         fYih86eKaGxtRutRxSCSOH/YQHDFgVL64Cr7LHhVS+3C+6VS/TTMocSjhsrvfaqeQPdf
         ggsTNHeD10zkTVZVkPJrlkfPN/+Uurn2XNIsOPiljw82YJO3Os0h0cuAOEYZZ/1zfVtq
         XGlG2ZygotUVfq5EHlvaq+ho3plTOIQrP9zaGInqi7wTNM6Cgdo1iNAk9jgjPA/jxDLv
         AhaHOhAFbbHvhg7MAWKItYX7sFYbfIPksOdMNMiZNRq8+9tL8KhFmvCC6MbRXgcpjkIz
         rIoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=XiMqr0hWyG/rAB1cGp/Q4giXGgzO5P9hGJu2yp7i+yw=;
        b=0SjX1aNsXWgWrR6PSiUCn1A3kkwWIkx4Lwv3TJHSujxyHl7P5Q7tu7KOH+AinjLEOs
         pj5D3nN+TdiEsT1UYakILt4o3DUrZls5YGiOc/bzzCTiOIXkUuW5QGfgEk+BPMkK8kJD
         MW9r3oUr6i2M1Q0o+SrFFJf0D8rvMxQ5G9+WpUcvlXkD5TTeWETAh7FOe/Yx/MzxhghM
         VAKJqJzCBv+hT5bJ+JMpBwQcwkOr9lwpGRHuCsjAfjx/4ldXlWIetP+Ps306LkqzqIib
         D2VXEmch9dEdek4+XX6feYIsK0I/IlgSecXa3K17ssVcssrIGdY+yX1kmOjQPH0Pw4Xh
         +bAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id i3si9605563pgq.282.2019.02.25.11.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:02:40 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 11:02:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,412,1544515200"; 
   d="scan'208";a="302443100"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga005.jf.intel.com with ESMTP; 25 Feb 2019 11:02:40 -0800
Subject: [PATCH 3/5] mm/memory-hotplug: allow memory resources to be children
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,vishal.l.verma@intel.com,dave.jiang@intel.com,zwisler@kernel.org,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com,keith.busch@intel.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 25 Feb 2019 10:57:36 -0800
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
In-Reply-To: <20190225185727.BCBD768C@viggo.jf.intel.com>
Message-Id: <20190225185736.7B4711BC@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


From: Dave Hansen <dave.hansen@linux.intel.com>

The mm/resource.c code is used to manage the physical address
space.  The current resource configuration can be viewed in
/proc/iomem.  An example of this is at the bottom of this
description.

The nvdimm subsystem "owns" the physical address resources which
map to persistent memory and has resources inserted for them as
"Persistent Memory".  The best way to repurpose this for volatile
use is to leave the existing resource in place, but add a "System
RAM" resource underneath it. This clearly communicates the
ownership relationship of this memory.

The request_resource_conflict() API only deals with the
top-level resources.  Replace it with __request_region() which
will search for !IORESOURCE_BUSY areas lower in the resource
tree than the top level.

We *could* also simply truncate the existing top-level
"Persistent Memory" resource and take over the released address
space.  But, this means that if we ever decide to hot-unplug the
"RAM" and give it back, we need to recreate the original setup,
which may mean going back to the BIOS tables.

This should have no real effect on the existing collision
detection because the areas that truly conflict should be marked
IORESOURCE_BUSY.

00000000-00000fff : Reserved
00001000-0009fbff : System RAM
0009fc00-0009ffff : Reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c97ff : Video ROM
000c9800-000ca5ff : Adapter ROM
000f0000-000fffff : Reserved
  000f0000-000fffff : System ROM
00100000-9fffffff : System RAM
  01000000-01e071d0 : Kernel code
  01e071d1-027dfdff : Kernel data
  02dc6000-0305dfff : Kernel bss
a0000000-afffffff : Persistent Memory (legacy)
  a0000000-a7ffffff : System RAM
b0000000-bffdffff : System RAM
bffe0000-bfffffff : Reserved
c0000000-febfffff : PCI Bus 0000:00

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Vishal Verma <vishal.l.verma@intel.com>
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
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Keith Busch <keith.busch@intel.com>
---

 b/mm/memory_hotplug.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff -puN mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child	2019-02-25 10:56:49.707908029 -0800
+++ b/mm/memory_hotplug.c	2019-02-25 10:56:49.711908029 -0800
@@ -100,19 +100,21 @@ void mem_hotplug_done(void)
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
-	struct resource *res, *conflict;
-	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
-	if (!res)
-		return ERR_PTR(-ENOMEM);
+	struct resource *res;
+	unsigned long flags =  IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
+	char *resource_name = "System RAM";
 
-	res->name = "System RAM";
-	res->start = start;
-	res->end = start + size - 1;
-	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
-	conflict =  request_resource_conflict(&iomem_resource, res);
-	if (conflict) {
-		pr_debug("System RAM resource %pR cannot be added\n", res);
-		kfree(res);
+	/*
+	 * Request ownership of the new memory range.  This might be
+	 * a child of an existing resource that was present but
+	 * not marked as busy.
+	 */
+	res = __request_region(&iomem_resource, start, size,
+			       resource_name, flags);
+
+	if (!res) {
+		pr_debug("Unable to reserve System RAM region: %016llx->%016llx\n",
+				start, start + size);
 		return ERR_PTR(-EEXIST);
 	}
 	return res;
_

