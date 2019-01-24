Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 105A9C282C7
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC7B3218A2
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC7B3218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8698B8E00B1; Thu, 24 Jan 2019 18:21:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 820938E00AC; Thu, 24 Jan 2019 18:21:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 693DB8E00B1; Thu, 24 Jan 2019 18:21:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2483B8E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so5005450pgv.23
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=pLfVhbANs+dHRF061J8403dGvp1pUAcAUzYH31HwZOg=;
        b=mm3b22Fcgg04/H4UPIFgiTyFbKSENoRDznhLJ3TPxil62+7/nDN9x50V4uCAFiAx6E
         m2IhNo8fj4PLKmPz7PobMC29fJnfT8CKnJPiF11qV80IJFN40j9SB8OdmNuZzTpFRBrM
         I9C8X4zeKTVbb0LCq5wmx+QvnSWoZ4VihMJzzabfX46E88nv6oouvbVSng+s9qsVK230
         e2yABge7Jvx12St7IAJewHwUdOG6G38Idv4BqkocO1495rWz6IMxNcXQzC5oNcctO44b
         0cJgoxxCSwNrLHls04Fsws8s2V5Bgu9joI7QVCOUctEFAzqk2Bx3T9vxpdRybSvCgPOn
         nHZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfe5kRtRV4JckK46+HceHEhAFQZtWm8StDKSsSpc1Peh3DcBUi8
	qX9QI18c7rVpwpuNLRpkMCXFuvTsltuOwYLrxss3DaR2yCaDOu+l0QhMXlRvc2iw6UlpQZukx2D
	7GQDI+hwG2O1mSmsOvX2DTb3SQLolcHfo/L358roskuiV84E5EHfkY2eWhDzJn6RpHw==
X-Received: by 2002:a65:500c:: with SMTP id f12mr7716383pgo.226.1548372118806;
        Thu, 24 Jan 2019 15:21:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7EU2FLMiD5pySHDmtRDA2OianHm/8sMPaO8/WaqS2rVtajt1DEY/MLSJzD4Oa9/Z33el4X
X-Received: by 2002:a65:500c:: with SMTP id f12mr7716312pgo.226.1548372117239;
        Thu, 24 Jan 2019 15:21:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548372117; cv=none;
        d=google.com; s=arc-20160816;
        b=N5Qmh+/bnC2ysq9oyTDQ5oPkGwo2XzJjGoQtG8fjMM1L1UBSAkd/AbK881dV5loDTc
         ey0LH2wdBQbksXX7sA4apvu2CtAb+84FCHemfPyym1UE5dJtxlbTn+MKhYJNX+1ccr2g
         D8AK1e0nmUnF8dV2SG+at5mHYX2/kGzQTL1+QBP41QxRLyC+F6S1sumQ5yaoeMif1GRP
         4vH36rXKGx2uAMbYYZmg4eFS+xUUE/GxK7wvNKEFpK4kTJi91o8h4NYH2WcfbRGmz3Vy
         eN9ybYbsYUkuLi85t6TLX0ih8PrYawYaTICNrawwd8qbhAeR8iP7GlrStbBaAeVlox/r
         9plA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=pLfVhbANs+dHRF061J8403dGvp1pUAcAUzYH31HwZOg=;
        b=yQphbNOBW9Ql4KxBRyfbzOoUNfhnTiB458ON5aakXzYYOfzY35mLSKaTD4jBR9ifUt
         xf8EsD4r14XAFxT6WqWHPygHYEHjkFw7R0qlFTHERq4wv5B8IWg3PGvIXGLZ6VUXWk0d
         +W0h1uHgyGOm1ZZDgbKjlN0IX2tdowlNL3dYWemX0RG+DTPgCex8jiiDvmCH/ZtolzA1
         zawKU5qHoS4cE3f86UdjJgyaMEl2RTutk99TclHQUJ+ToUZXqbbEGN6lWBOJxmXbQ4N5
         X25ShM9Zy7cCm5CI3HIinNUumE7cTzFeb7GwISP1zBs9JvKjw+m5mu3ynXVPBW8YTDBE
         KkKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h19si12278998pgb.231.2019.01.24.15.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jan 2019 15:21:56 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,518,1539673200"; 
   d="scan'208";a="109574602"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga007.jf.intel.com with ESMTP; 24 Jan 2019 15:21:56 -0800
Subject: [PATCH 4/5] dax/kmem: let walk_system_ram_range() search child resources
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:47 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231447.74358AA5@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190124231447.hFv-EQH2817PrVKB5ykVOxys1jbfFOF8_mbIKOgamFw@z>


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

 b/kernel/resource.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN kernel/resource.c~mm-walk_system_ram_range-search-child-resources kernel/resource.c
--- a/kernel/resource.c~mm-walk_system_ram_range-search-child-resources	2019-01-24 15:13:15.482199536 -0800
+++ b/kernel/resource.c	2019-01-24 15:13:15.486199536 -0800
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

