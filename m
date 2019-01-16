Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CFEEC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:25:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D9BB206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 18:25:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D9BB206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D4698E0014; Wed, 16 Jan 2019 13:25:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15FB68E0004; Wed, 16 Jan 2019 13:25:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04DCD8E0014; Wed, 16 Jan 2019 13:25:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1AD68E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so5276780pfj.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=v9C2bsdbZKN4wfrid2R3BaL4d2Hl91AmARUTxgFlVyE=;
        b=TckQWhVSiboq7w54iRCv869vihps2PvRaqdWkjyPdLNkLuUkJ0xD3vbP35YP29Bf1w
         GVj6mwFkChHQHyQsxk7t5DguSeNkP93+6l0f8cZ0UEnxpAqJ/FMd50JP1nyWRMQ/+H0t
         fMJyLecn8wLjPGGSfDw3eLlGNuOEOBiUNLR4GzB3Zlh01iKV0TcLIn76ooNrqYMJWtWw
         l1DvMqNK7jE1reNGh0C16qGArF/xehs5RyTqIejXk+SxlwN/O47ORw42e8E1p1ua3sIv
         W6dnuY+a2CKWcpWfFNLSCbaX7MyiMEsrhbY1O7j4kd0Tdb3B8DtBM7yhh4JvXqb9hklw
         1EBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcN2CqLfLxSAJWsrcKvHDpEtM0dxt7sdZ3cf1A2TieMGSZkC7JQ
	zkFt3supHSRYLNZPMGoXVVmkPHyRm2e3Tp78ZmVXOXrzvjSA5LcFi01QltWI3vI17c0OCJRBD8w
	KCyijvUz21xuHn/rvUXn7FZVwyuNbAuN7TUpj0NQvvcSmvJHJBYzmmhYxgZjgbAGgPA==
X-Received: by 2002:a17:902:848d:: with SMTP id c13mr11237536plo.257.1547663140402;
        Wed, 16 Jan 2019 10:25:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6TfulnRb7+MYR9RqgHPOTVORcgC/TArzA2Pq4uQrCBYDI0xz/Ourqc/FsAjANTM8g2Nt4r
X-Received: by 2002:a17:902:848d:: with SMTP id c13mr11237487plo.257.1547663139679;
        Wed, 16 Jan 2019 10:25:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547663139; cv=none;
        d=google.com; s=arc-20160816;
        b=vsJc+4aIDCfuEBDcsyfZ3hGXoYnvMBQa78gSpi4lAh3XTY5WDyRXqqY6sr7iMG1KzD
         jpUtd6bZHB+Nht5aEwVWbk5RAyK3gO8cxkZ/VIUN7o2QuLb54E2uhnO5tsQc/NB04i84
         4yHEfDlcFFKUPuO1pxXB54dhX6Q5a2o7vdGoQ5+WRPFuDqv4vWfP74/toLyMcDUGQrtR
         RRBJLspr6+2KT8M6mSOK6sA9URqCXXAxTcFv9EAK/ecewpUuYIo/f5h8ktLJDeWaUTIR
         KsTSf/ebP+nl5z5R9gPF04mFqBc5xz3g1B1cJNv8HOt2zf7IAQEyxGI7A568J7/cbU64
         fxVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=v9C2bsdbZKN4wfrid2R3BaL4d2Hl91AmARUTxgFlVyE=;
        b=lGvXuLuf9tPjNqyfcLEgXEwxdYTUWP5S73JENMxpGdJQGJ25v07mfFeKdmURqvjJ3d
         ogjwazh9C7p1Kmg5PUy9a0ZRuRt9tfxERz8otpOR98+j4TdMpld1CGUuOu+dl9TI9eS7
         XkAgxHgqkW0ta9Wvtu/h6NplgyXPbsy2QfXDHZ28r4+69uu1zlQkmVYnZ5JpVcXCGA8i
         KZPltSfmbPiv0EyLQ38eZhn/TMdG879O83rjn6m4LM7ETfyM/OaedTD0TQujEkRURWJE
         5Q/jzbUaiSlyzNv1e2XWHiHm3QN9OpDoLpR5bYm4Ir/k6n/4sOAafrJKP1n0lTF5n7Qc
         yPcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l5si7335471pls.423.2019.01.16.10.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:25:39 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jan 2019 10:25:39 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,487,1539673200"; 
   d="scan'208";a="126559961"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by orsmga002.jf.intel.com with ESMTP; 16 Jan 2019 10:25:38 -0800
Subject: [PATCH 1/4] mm/resource: return real error codes from walk failures
To: dave@sr71.net
Cc: Dave Hansen <dave.hansen@linux.intel.com>,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-kernel@vger.kernel.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,bhelgaas@google.com,baiyaowei@cmss.chinamobile.com,tiwai@suse.de
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 16 Jan 2019 10:19:01 -0800
References: <20190116181859.D1504459@viggo.jf.intel.com>
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com>
Message-Id: <20190116181901.CAF85066@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190116181901._ZmlClEe7bosAi5DvfORY3rV11SnpMztQA00h1GcYOg@z>


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

 b/kernel/resource.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
--- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1	2018-12-20 11:48:41.810771934 -0800
+++ b/kernel/resource.c	2018-12-20 11:48:41.814771934 -0800
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

