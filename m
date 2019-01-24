Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0AABC282C6
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E9CE218D3
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:22:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E9CE218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86D28E00B0; Thu, 24 Jan 2019 18:21:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE8628E00AC; Thu, 24 Jan 2019 18:21:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFDD88E00B0; Thu, 24 Jan 2019 18:21:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 657A58E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:57 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v12so4956627plp.16
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=ILkCP7OxlYRImbbJu2pTk1APDNsU2c8oqx2F1FKKK+8=;
        b=NZbwrM9MknbnZwJ9gSkvY0jW+6QSrUIAalFppUiRzKh7TFVnhjhAsxI+tdhNhOYZmt
         CeIf8PBdMN5JBfxuZC1mNzDik6K1ywb4AAChDVNHOj5u6niWj1+zP/9Mes5uiW3BEsd/
         TOiqp1X4iQQYSRqT3oSyPpGbDzSJXJrLO2cF40v7Gw58UBdMP3UUWPSKKvgMLSGB8oTD
         gpfBH9KN6YA1BfJ8WZM73bn4bIWTnIItrzQzgB02+BxbbFKXMZ/DrN1o8iDoNoLF/aVR
         1M37AC41mOAkWZMHkQHQ2uknLTcZnbF5PxaLczgKf5KwW3CmhOZnF3xALcA9/rlqnooW
         sQRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukflXgk5PAKAQQYPzcgihTefwWixf5DVonhOp4xlK3S9zn19whf1
	jAjvJrz8mos/mjRNYk/YvSrOXM2RvxWg6FqKegOkXmCyODVnhenAGli9upuyLMDmnPdF1SWOy4Z
	qdAkZBj66KdM7jjbqlfs05oLIdrkDDAHCp2+JhXPQMbKG6BbmSkJ6byuZocF2zrpakg==
X-Received: by 2002:a63:5723:: with SMTP id l35mr7514470pgb.228.1548372117048;
        Thu, 24 Jan 2019 15:21:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6/zn1qUDYrSDwsUOKQlZhfom9EOOZQOaZUCEVduQeHGk2wllrvSrPcqHEU+xZyfaX0vbFe
X-Received: by 2002:a63:5723:: with SMTP id l35mr7514426pgb.228.1548372116125;
        Thu, 24 Jan 2019 15:21:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548372116; cv=none;
        d=google.com; s=arc-20160816;
        b=vNEPd+rqodXrJxcWPUWWsvUcZsP85bAhxDvg5lYoZCMLKRElD9vTrfPx/LyVxHfsyW
         2R1efraytM1uzBQVW6ecBIVXj+lwXtyI31kbJGUKNkOE0IO0XPYgFMkHCsqc/Jt25tMN
         kanVznehZgm1N8FjTlJ6JgWSYegcB74EG2Q7ONU3XdxY3kR/D3dhF8X1bJ3b+8RIhoUq
         AqUq/A9KGMhgaDrubGvUwYwOFcCBXWmOhSDWyncGX1HZPWcdfFWv3n0FYHtgadD2l9K5
         9taYm7Jbc4dME3F7hjZL60Y80HZPaXuiecA5lY8dHmXMn5pMjOz0SHZcFfAutONb4785
         TVlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=ILkCP7OxlYRImbbJu2pTk1APDNsU2c8oqx2F1FKKK+8=;
        b=Blj5RxbUoCXYcVGyg6PDYMmK9evRNqchBLL2sqEx9WiZuwBdtSsgldNJ33AnI+4R37
         BELMLI0tjNARoMAXS8ZMrsgs7usVtThwBkyjaiq5t45CsmqRu1PNk72x+iXe/Cb7VI5o
         e8b2+VGYA2VtudVlgkZBtLpiAcmI2tFS7G4n9fwqe7fkikNW7r0kg0ZSU8Dr91hULCYL
         G2J7edf7wtJIc0xAvP2Lm8OJRyu09Nh5z7PFlDNeC1sCrpOANUD0ROVgEtm2IGh8Q7Xu
         b3bOfDewEd7lqzs1h3Ih2KoCakGT91TdB1r4+D2Kw2N7kpZPrEh1iaAvLsP+UEg5X3cY
         pddA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p3si8871042plk.424.2019.01.24.15.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jan 2019 15:21:55 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,518,1539673200"; 
   d="scan'208";a="112454053"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga008.jf.intel.com with ESMTP; 24 Jan 2019 15:21:55 -0800
Subject: [PATCH 3/5] mm/memory-hotplug: allow memory resources to be children
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:45 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231445.5D8EEDAF@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190124231445.qhZUpck7gKND0ub4GrI2SlVdPs3Xl96J-I_s8n2iS3A@z>


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
Cc: Jerome Glisse <jglisse@redhat.com>
---

 b/mm/memory_hotplug.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff -puN mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child	2019-01-24 15:13:14.979199537 -0800
+++ b/mm/memory_hotplug.c	2019-01-24 15:13:14.983199537 -0800
@@ -98,19 +98,21 @@ void mem_hotplug_done(void)
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

