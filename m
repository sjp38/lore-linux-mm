Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE14DC282C5
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9214218A2
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 23:21:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9214218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D22458E00AE; Thu, 24 Jan 2019 18:21:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD4B78E00AC; Thu, 24 Jan 2019 18:21:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFEB8E00AE; Thu, 24 Jan 2019 18:21:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDDF8E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:54 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s27so5058908pgm.4
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=G4UBwBK1ygZOCj9EDaFANslJEVjpXrkdAT+76ni7PnA=;
        b=P3K1IdEjIp5akXGC046HzrZgDd7dw97WYBNr0WhcYOO6Bvoh1r5LWfrpWe7Pp7cEPz
         rxZbgp1P8alLk2hh2HyluNS7GkN9gvfELWCS3DQLA7rK/xSFa+U981wOhk8Gl741UQdG
         8hV+XgjbZ/pw4Jc5X9iRW1GHsUoi6qKCfj844fK3p9CvLTokvGLqCNnKKJQfJ5qyuer3
         BNe3ODQ9FgSQKFzzRuG978Vfvbkp/bczWNxK4FTmwq+mJ/UDwuGUqMAnAtPziJKGA7GM
         QnRefTSVdUX4PvpZ7J2noOffQEH4GASle5EYsthN8svfumxnvt3qd7mZtzspJqS/6sB2
         DvRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdsibMeibkEGsGwql7dU3x8iFoqexH9QRhNluBuy9skenoeg+R5
	+QMhmM1OHefUMgDEQkZ925Mv/u44i1Ypf/2kV1a56J2wxFd1BsCPGlWaY/YRcufKWqpwF4QwBR0
	jhhXeQ+YJM8IjDFMKHxv7e2DdnVWoPkBekvn8mcq1jTek5bu8uglc5V0Hdy1i0ftBTw==
X-Received: by 2002:a63:66c6:: with SMTP id a189mr7790953pgc.167.1548372114157;
        Thu, 24 Jan 2019 15:21:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6FiJUjR7SGOjihYXyG2Dhrg8/SkTZ/N0VVvJqV4dAEeYIlAlhF7aBwD3GDXosi2DhgmBeS
X-Received: by 2002:a63:66c6:: with SMTP id a189mr7790903pgc.167.1548372113011;
        Thu, 24 Jan 2019 15:21:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548372112; cv=none;
        d=google.com; s=arc-20160816;
        b=K7w2jUM1ADQFHj/Bv4ZelZbKseX0iwQc7A0oLwGnFll4l8DyRXilS2csJPcozwLgM8
         o7DZjg+204QOl0RxDJs2ohFP2vMUy/jIOqEuXaP7jB3wR3da5R+nB+ru4su0r3ndS89p
         rsSb8HEHJ/Nl+Jw52sXTxb2sUwuRXsLoHmijXEMNnNywhSj4mP6YONaeYz42bphplFiX
         cWwQffaaZpy1+2QHeVZqM55dKm5rx9MrWBBPA1zCvZczC3sd3XE4mM4VIXWWl7q1sOq5
         D6C47fl45tcenLmBBof0vnAikLjmMIIhoqgyLKV/Z2RzjxvYBzvOOheBhvNrIYzrk5zt
         lNUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=G4UBwBK1ygZOCj9EDaFANslJEVjpXrkdAT+76ni7PnA=;
        b=WmY6/Ryf6Z/h+aL6P1kgtxalwjMZT/XGSR86NA5r3RAY2PyaAMXfpBmD3mYDbTRTk+
         9rFxB2F7vLZe0zbGlkW8XRKVhI1ouV14p76NWNPjALxHoa6ZJWbzgV2/91QRMZ4cHRns
         mZ32vcYp8nxmdm/dWI0T8t6oOgThXzP4J0KwdgA4CesmpxruQGwrbrQgDx8jiwFyju5n
         S8/FgEoNp4uaM8nuzh084qDG419VrHo9PB8z6BlDsLMWpuZBNwWCcJfa6Pg59lXW+9FA
         hLhevRuikR1RyadzNMu9RPgSJMmxuSI5/OQcium5Lha7qtEnqGpGzgheUvDjaH2L3HuW
         mxog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q24si23382216pls.325.2019.01.24.15.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jan 2019 15:21:52 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,518,1539673200"; 
   d="scan'208";a="121111369"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga003.jf.intel.com with ESMTP; 24 Jan 2019 15:21:52 -0800
Subject: [PATCH 1/5] mm/resource: return real error codes from walk failures
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:42 -0800
References: <20190124231441.37A4A305@viggo.jf.intel.com>
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Message-Id: <20190124231442.EFD29EE0@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190124231442.nxK9Q5skw9xYfDEBEqPCW-ZSrdnirOyL_2UVFLDC-a8@z>


From: Dave Hansen <dave.hansen@linux.intel.com>

walk_system_ram_range() can return an error code either becuase *it*
failed, or because the 'func' that it calls returned an error.  The
memory hotplug does the following:

        ret = walk_system_ram_range(..., func);
        if (ret)
		return ret;

and 'ret' makes it out to userspace, eventually.  The problem is,
walk_system_ram_range() failues that result from *it* failing (as
opposed to 'func') return -1.  That leads to a very odd -EPERM (-1)
return code out to userspace.

Make walk_system_ram_range() return -EINVAL for internal failures to
keep userspace less confused.

This return code is compatible with all the callers that I audited.

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

 b/kernel/resource.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
--- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1	2019-01-24 15:13:13.950199540 -0800
+++ b/kernel/resource.c	2019-01-24 15:13:13.954199540 -0800
@@ -375,7 +375,7 @@ static int __walk_iomem_res_desc(resourc
 				 int (*func)(struct resource *, void *))
 {
 	struct resource res;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
@@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
 	unsigned long flags;
 	struct resource res;
 	unsigned long pfn, end_pfn;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	start = (u64) start_pfn << PAGE_SHIFT;
 	end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
_

