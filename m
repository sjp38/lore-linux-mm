Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37FF2C43444
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBECB206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:26:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBECB206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18B3F8E0016; Wed, 16 Jan 2019 13:25:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10ED08E0004; Wed, 16 Jan 2019 13:25:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA2818E0016; Wed, 16 Jan 2019 13:25:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8DBE8E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:43 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id q62so4395703pgq.9
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=Cw56qJD87uy/pg1Cu85XBjBCwAnxWxaIy0eAzSm3c2Q=;
        b=GtMc/KHbdMjTrqsuPy1LxkL2x3fOM3zrwW0zLLPtgvZ2lK71afEhWlxY3D1U0VYiyS
         prFcn7/GLpfp6lypfE3I3vh5azjE6GhB9Uo+fRGzk7kH8eGpHnMOzZhlngp/SyuZJTdY
         MWK2bmlUQufvdBwtU4VxJzicl0q/Dzw2f1SBx+pz6xocESmWTPDXef3zxblbstZiZs9i
         9gaTkjP/qrGItIbrC3uBWrunBMeY0nvmuZzv9ar3MsUIse80WxWjhjLH1gWHwuCDUZ1D
         a9BJ2B4Pj0b1CURPKzwV1Ryn13SVNed7mwrNAXJ72Avhhlvc70AYilFEZZODYtCcbsZM
         AXzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcYsONShj/ZAsXLJuhmXNOGLs4l3ldeQK5cZXpZriAsJeQjEySV
	SkSGIs1hfC99RwYORMv6KyzvCY4eSyxjXkUuYjntgc3dn9BgQnj7jdj9ohPqlDuUb3cQNQ+B6a1
	r2BRJXooF1em3FS4OV38+O1A0cnOI8Rt6Ih+lP6rls3ZkWZjwbyLwra7ISpEo+8oVjg==
X-Received: by 2002:a65:448a:: with SMTP id l10mr10055659pgq.387.1547663143334;
        Wed, 16 Jan 2019 10:25:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6xZiRVyx0HcxbV1FdnxIELbr4jg9BigWRJnMMx7JitARLAJ6m19cssJ/FF7I/Rc9Ws1zjS
X-Received: by 2002:a65:448a:: with SMTP id l10mr10055613pgq.387.1547663142418;
        Wed, 16 Jan 2019 10:25:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547663142; cv=none;
        d=google.com; s=arc-20160816;
        b=G7mF2EVHRS+51kVZlVMw+F/7sMESPheRIHgHoCwCzzn6dknjp17jN/wSoApOUYGiBd
         lM596a29824q1HsvqBgHTG0T2bNzDdLZDcBns7eUObouBQTGNL+RfMuW3XBwKFbKO/Nn
         JcgsLvy/YOsAAvfk+fA4WGMGfoURnKIzpr6Pia9ynsjvJ7Oo71rJWSbZCCTznU4BXYdH
         ZATKdyiOuKjEygxyy46+fW7jm1IUYFo0kIPtp5FoEprPihWmavYFkdlD9nFnRy1O2kdu
         AkFKMCMb/0Z84/pA3swltLQn10dM5r+IHnRvswdE8gMNzBAnpj4sHYaAymhMX62f3Kk+
         oYoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=Cw56qJD87uy/pg1Cu85XBjBCwAnxWxaIy0eAzSm3c2Q=;
        b=Lz/KDA4yElljhMgghx0VgMxWzSlEVc4LjolwuHMSz4MgJs2y/Z9WByCWBpDtdnc3KB
         P2put/K08wja0zFf2/suaolw2gGP808gTzgzZeCYjl/am0fcvQphQuPH8RhJx21dLNy2
         FMWY0PHqEmxpxFnUONdlFWXIBuQDWG2U4yXummPm33JxO519tYyXF7yxbXPkTDK1a1KL
         OEu8dv6F1h7gRG2w3te8Kw7GtYebCjzBKms8rkhCiG/Qyp5TQppmEuhDHfeyUN5L8UXq
         21zezuNSOXb+0X/Y5BCWS4Vuo38RGUyUP/FB5IQPe2mah7ENCgM7ZRmfhySxbv6dkFPa
         5P5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v20si6754250pgk.103.2019.01.16.10.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:25:42 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jan 2019 10:25:41 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,487,1539673200"; 
   d="scan'208";a="292082790"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga005.jf.intel.com with ESMTP; 16 Jan 2019 10:25:41 -0800
Subject: [PATCH 3/4] dax/kmem: let walk_system_ram_range() search child resources
To: dave@sr71.net
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-kernel@vger.kernel.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 16 Jan 2019 10:19:04 -0800
References: <20190116181859.D1504459@viggo.jf.intel.com>
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com>
Message-Id: <20190116181904.D24AF5FE@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190116181904._eqllw-pPrZ5vq7FGIIv1rXlS9xkfwIovNHsXy_c5dI@z>


From: Dave Hansen <dave.hansen@linux.intel.com>

In the process of onlining memory, we use walk_system_ram_range()
to find the actual RAM areas inside of the area being onlined.

However, it currently only finds memory resources which are
"top-level" iomem_resources.  Children are not currently
searched which causes it to skip System RAM in areas like this
(in the format of /proc/iomem):

a0000000-bfffffff : Persistent Memory (legacy)
  a0000000-afffffff : System RAM

Changing the true->false here allows children to be searched
as well.  We need this because we add a new "System RAM"
resource underneath the "persistent memory" resource when
we use persistent memory in a volatile mode.

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

 b/kernel/resource.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN kernel/resource.c~mm-walk_system_ram_range-search-child-resources kernel/resource.c
--- a/kernel/resource.c~mm-walk_system_ram_range-search-child-resources	2018-12-20 11:48:42.824771932 -0800
+++ b/kernel/resource.c	2018-12-20 11:48:42.827771932 -0800
@@ -445,6 +445,9 @@ int walk_mem_res(u64 start, u64 end, voi
  * This function calls the @func callback against all memory ranges of type
  * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
  * It is to be used only for System RAM.
+ *
+ * This will find System RAM ranges that are children of top-level resources
+ * in addition to top-level System RAM resources.
  */
 int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 			  void *arg, int (*func)(unsigned long, unsigned long, void *))
@@ -460,7 +463,7 @@ int walk_system_ram_range(unsigned long
 	flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, IORES_DESC_NONE,
-				    true, &res)) {
+				    false, &res)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)
_

