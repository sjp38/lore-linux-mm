Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08CC4C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0F2A218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0F2A218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D21BE8E0004; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA7B98E0001; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B60DB8E0004; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5CC8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so17813346pfa.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=R9KC6ubzg8F3Mp0v0KkgZ134RXbUulmpW2HiMrvB4P4=;
        b=DBwEWiW/quyFhddexUKVpvjN32gbakBMwgDoI780AH6XOMS2rmoRrYfEWCM4pysjhP
         SiibwqlLzwBEqouJoW15g60flNc9nTB2qkSAgt7TW7owWm/Urbyx5903BUNeoFSJs5H7
         hCpT5rhT0DJ1CqC8v4SgiQjJlyuEWP1IvTQGknqgpYPXATK+pFXSsaChHb3UkDjQ+ucr
         vKSCMckKhbSkelWUJJBluHnYaff9u3W4Lafa+JxnwLgvc7D5N7kiH3cQ0n9BttvsvCLc
         Ca1fjuFVwu86M+67JDDvm7xB7cUqNPelzhIYd+R9edH7gwxXzY6ngSPQk4OSphYr7CHw
         pxWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfRK8prjtFWAIsH+J8mePs3Q//svvPSso03TsGYaCZXZE1S5Yxh
	fHSZPxMq3+ds2L7TofNloK7We81l4Dg+XIh4N1bqOvRyRImEkrAtEFozJKyD5L7fhPr8MZkWOAq
	3oCMT4T1K7/3YyHDD8wbjv3r6IYlNo9esjJrffs7nvLXbVFPpCv0bAM5CTH16wsp7uA==
X-Received: by 2002:a63:170c:: with SMTP id x12mr18382384pgl.364.1545831426106;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN48XhIm5jcIjUeEA/TMABCJ2XGs/RXrrQcDTJFhjoEOfKble9GtJY18l7oXuhH47v+b40SJ
X-Received: by 2002:a63:170c:: with SMTP id x12mr18382348pgl.364.1545831425562;
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831425; cv=none;
        d=google.com; s=arc-20160816;
        b=Bl17Gs1l+CCZDwKma+jqj6faPDwBl377pm2T82xuPMDniu8Rpg4jlkrgCDOaZXvkOd
         xOoFq1ZoserJhq7HP5oSu0x/fUkMPeFMBkTUtHK7Mh1JhQs5rpUkas8jQE0f1gN2HfmX
         SsygvACRRQzk+Y/vVxrsGbV0S+2koG2fkZFTUxWJfeTtuhIwkrS8aFoJPX1zLnpT0v+H
         h8C8iRtcc7CgbVaCu6XgLMMTtg1klE5DP29EpL/8N96rgbuvIhcJ95FIo/0V0qQ8kczW
         YJsoHpDi4N1GomIqMc+SnH23HIrXJurGglFiX5MlaTVVzo1hKjpRXYV+oSwTnXSJbMcF
         KcrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=R9KC6ubzg8F3Mp0v0KkgZ134RXbUulmpW2HiMrvB4P4=;
        b=IMXXNA8BIHabHTdBdh0otQ+z+WBxmKhh9ALpNmDowMU4+lAOylxoI9UcyAUi210snt
         BazGnb22Iddv8uVITjxCbH+wYCmWFIsJ4yxOTS1HMBMzbju+kkl3D7T2X2JkKT/SOtBr
         JTpzTFzhKjHCngP+V5xrPkijv8nJh3DsQrPsEnYtqSA84SE236ZL5bl8At9ijwZljI8R
         y0QBJBaJ0ypQ7h3Rz32dXgwMuhcvDfxn6tTxQfZIN7qf/yqUkV5Wno6FiYlp8X8ruPm8
         7j9KEWcmEyy5C7jYx79SX5MZK3xeIW7kztdDjD2TmVmEutsuMRpGKhcco0WdDh6c8q33
         EbGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185455"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Nv-69; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.106676005@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:47 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0001-e820-Force-PMEM-entry-as-RAM-type-to-enumerate-NUMA-.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131447.UUU7UxxpcxOW_okyJHIAzVEkFj2JuU-587rVTd3rz1I@z>

From: Fan Du <fan.du@intel.com>

This is a hack to enumerate PMEM as NUMA nodes.
It's necessary for current BIOS that don't yet fill ACPI HMAT table.

WARNING: take care to backup. It is mutual exclusive with libnvdimm
subsystem and can destroy ndctl managed namespaces.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kernel/e820.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/kernel/e820.c	2018-12-23 19:20:34.587078783 +0800
+++ linux/arch/x86/kernel/e820.c	2018-12-23 19:20:34.587078783 +0800
@@ -403,7 +403,8 @@ static int __init __append_e820_table(st
 		/* Ignore the entry on 64-bit overflow: */
 		if (start > end && likely(size))
 			return -1;
-
+		if (type == E820_TYPE_PMEM)
+			type = E820_TYPE_RAM;
 		e820__range_add(start, size, type);
 
 		entry++;


