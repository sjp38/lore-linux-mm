Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 969A6C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F3D7206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:25:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F3D7206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30CD88E0015; Wed, 16 Jan 2019 13:25:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E21E8E0004; Wed, 16 Jan 2019 13:25:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D7D48E0015; Wed, 16 Jan 2019 13:25:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAACC8E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:42 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so4392966pgr.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=gIacLjiL8a4UDzqlDrZFybYaz7jh5hj/jgaplHVPsf4=;
        b=gNjR/Ux/sXZFa5n/gYq/kXn5FdASb9QQxc+k9arYrkFuyX7JXnQz+GAEhXaJGcw4Q8
         E5Y6mD4FLW4UmdvNI/yxZbCtXBcj2SKTsLoEx4v9VRTuO14Zh+qGTp0j9suJXwQ3Dk7K
         HJt6sWUBSph4tJn6+VqwL8wuYibHaa9ckOYJRJC2EzFX1C0Na2QcTJpOLSE5D47fVgqG
         UPc0JcM93Z8Dgm1W40oBCVcjdfF59SxtuXn/w+y3rRZ/cvrk9+lCGTHwBXsBde+GVLxy
         H9pNouXnxOib3MTz8CX8cxgvgnEGGD5+xdOThpFqAv1qCYPHWZoXXQmrI4rHdpEW3aVB
         OVjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukf+vj5i3CQDJDwUv5XMGd+Th8tizOauU/xFirDJVXoaaFeHHDmn
	mcgTHVKSPoxLKe264k9AbpVUWuKowNZ/2MZVomPvsdZgafKMIhbgKYtEQGjPhxuxff0fsm83LYf
	JtwkaU2FKxOTPbY7HWRU1GcwJuid1dtbdGRwmrrZS62dXtegyH/wzeTBKl7Mou1beNA==
X-Received: by 2002:a63:3703:: with SMTP id e3mr9970368pga.348.1547663142374;
        Wed, 16 Jan 2019 10:25:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Ibzy9eNFhrmnzcmrrSUL+cMlHp5jL0ccXcrGOTmOffFRkPs8ZFQLVgK2zf55bVd18gHaW
X-Received: by 2002:a63:3703:: with SMTP id e3mr9970318pga.348.1547663141469;
        Wed, 16 Jan 2019 10:25:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547663141; cv=none;
        d=google.com; s=arc-20160816;
        b=AGVPCFZCHr/s2IUZmP1qDWwCvTdU33dvs956H5oKux9m96yUYEvwHztUfZf60IlMlK
         1LBEatBm9aNkF+7nwyPqhesoBb1Avc1Y/EWyAHYRD4Y4RW1txEtJteC7CTerwgtv6Dgf
         jTLvIcm/IOrLhabfCsPJazoUxVcSDuDH8LWUnI7/Mxm40h7r+arcCn+5rLPiZdPVZyyt
         uD8KioeWexI76AnJMOQB/vUDE083YyS6FpsNOGE7filSdYrMTusA2SaHF7/AYtssiw5O
         8z3DQyjMHEkYzjNidtGfGk3730a/dfE5iNQqL2bfd5yT9Co+XpjgkMUU7lHPx5pzP3lF
         8P+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=gIacLjiL8a4UDzqlDrZFybYaz7jh5hj/jgaplHVPsf4=;
        b=Sd6MClKvRscmJpc2nC575Wsi6eSEKAVdxGzf8mzS0sqdnpka1oEAkVXkjSGJ61Gosq
         TcX+L0DuSAx0CeLAnngygs3pR9JsZ5z6xanC9O2RqYdnDE0ESjZA41JyYKopCYjGUO32
         s6ZH9D1Ye/o6yQdVjWAVqjOfJsCsuKXX040aJNXCTa4b59dNrZ2Vfp+D/9pZnfqDfp5p
         rR0fvzhI++dLEFamdsu4JaW3yy8eGRAMfx33A1Z3wtRW7ampuvaNT6GnzWRZgIBe/nF+
         /4IPQwVYPqqdqiTTPAaP1kjGo9WU6LPEsD109eEwYRq7dHAOMJ5RREMP5mm4j7x/tGwS
         fayA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t77si6728408pgb.51.2019.01.16.10.25.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:25:41 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jan 2019 10:25:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,487,1539673200"; 
   d="scan'208";a="119025562"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga003.jf.intel.com with ESMTP; 16 Jan 2019 10:25:40 -0800
Subject: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be children
To: dave@sr71.net
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-kernel@vger.kernel.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 16 Jan 2019 10:19:02 -0800
References: <20190116181859.D1504459@viggo.jf.intel.com>
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com>
Message-Id: <20190116181902.670EEBC3@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190116181902.54St4a_d2OETEE6XDqDnF5WeR1MCw4EFoT6QFAjn74c@z>


From: Dave Hansen <dave.hansen@linux.intel.com>

The mm/resource.c code is used to manage the physical address
space.  We can view the current resource configuration in
/proc/iomem.  An example of this is at the bottom of this
description.

The nvdimm subsystem "owns" the physical address resources which
map to persistent memory and has resources inserted for them as
"Persistent Memory".  We want to use this persistent memory, but
as volatile memory, just like RAM.  The best way to do this is
to leave the existing resource in place, but add a "System RAM"
resource underneath it. This clearly communicates the ownership
relationship of this memory.

The request_resource_conflict() API only deals with the
top-level resources.  Replace it with __request_region() which
will search for !IORESOURCE_BUSY areas lower in the resource
tree than the top level.

We also rework the old error message a bit since we do not get
the conflicting entry back: only an indication that we *had* a
conflict.

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

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/mm/memory_hotplug.c |   31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff -puN mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child	2018-12-20 11:48:42.317771933 -0800
+++ b/mm/memory_hotplug.c	2018-12-20 11:48:42.322771933 -0800
@@ -98,24 +98,21 @@ void mem_hotplug_done(void)
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
-		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
-			pr_debug("Device unaddressable memory block "
-				 "memory hotplug at %#010llx !\n",
-				 (unsigned long long)start);
-		}
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

