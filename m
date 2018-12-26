Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA37CC43612
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1E3A218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1E3A218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FCD88E000F; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF9D78E000E; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AADE8E0002; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F50F8E000A
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so17734192pfa.18
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=XVqS352sXVaGGtGXOcEdrkWMtHZ0EYY2T97kfIarVBs=;
        b=mXAqGiifjJaupsiaX//203e8PLS97y4o++ALykH+BO5gGhKSO6iZwKwNcLEWawEeLN
         Q+AEEjEQJfSwQtr1R18eYUGO4x6x16vEwHPnUpnvdGpzzdjun2GDfL4TziWefbshtGbM
         aZiVw2LY+3AouOXyxm47fr2txFiyBps/oOCVlQVJ6DEhNAVWJyx2FZJAF2XU/KZ2Uikk
         hZ4cVWrgsUA7MbUO0F1eH233tOqQvE5jlUPnrUviYFrjuNLJSnWB2kmzF6cAL1SOeHZI
         uv0Tzh1Oc0UWV0UF71fV45v2h4/kVzXnCbo/KkXxsPnVN+1EtOgNIEZN1YzkF7edNwsu
         pHfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeb4d4Bb7tlFhaBdUNtHfahtsfaHMzio13ntzcPS3MwrylG8jkd
	/Q9XdcA/GXKXVHZuPfBBOJvEcgJosWVURvpSZ2sebFEWQ5jdmOWw86KqtkCybCzntS57Gb3NdTs
	bBYbBvqX7b9PBDMyhh3KjDCZUnZk3iWz31YdHfrsBSdCnO61sLgGuax9GfBbiIjkIhw==
X-Received: by 2002:a17:902:b118:: with SMTP id q24mr20054525plr.209.1545831427220;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN678uHNuRhloRKs5+4c5h5CAVA4KGg+l9fS3ySVh93nfmkhriCajuxhvfiUcEjbB4ztgvYO
X-Received: by 2002:a17:902:b118:: with SMTP id q24mr20054498plr.209.1545831426662;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=bK/cF/0wLu8e7FCmdfF8b2Cwg3C1L3VE6ci/YSoyvxmVLCV1cHcUMRij9y+BQlT6he
         h2ItS1muMr/n4rE7bLMUcYdM+8AxNP32jSGlo+4wgfd+tCNQyISSym5tyFiXNrdrefWJ
         ukxa37jzckAv/XXGh+35YcE8S+KJSfnW/Nz6ZRq2KJsK4k27JgdtuwfPhgdSYVxGtEK3
         Afl5Aw4geO+UpFpnvZ15L7Yo63/76PmCZ6qyfN86HmVOmf5KdE2E+HfHhzgJ1xpojEU+
         D2zJj0PZxysZ+SsCQBU4pDlP4C+DaD6NJUCd3o8wavpfoB07yIagknq/li52UAXQl1Qk
         g0wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=XVqS352sXVaGGtGXOcEdrkWMtHZ0EYY2T97kfIarVBs=;
        b=UPLb7uYmuI4AaI6v72Et5XsIndAZzlIYWOF13CtgoqqxLB8adKkfLHmcRmzx4tIQpS
         WwovQQViVDwIcqaQZ4eAKQYyTleCadMoRlBYLl68EVQCo9QTL3hxiMtfrZGjNLDXmzWy
         VBwHmo1Gz+8Qknfzzt4x92+k6/9oC+pXQwhkOQViqj8p7hHJ32D4OOS67d/j3Bgjo/xV
         GmWeMsnK0WX15I999bW/MH7fiXfwmEoroJWMgn62nn3bj4qVktwpyj5DMLuipOV/oyNp
         uSgNUnaOePlwuEA1HUEFtB1BUBu1rvlDreapP7rKJ3fmVk8wrrbk6p3R7iIbj5P0V4SC
         BJoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358931"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005O7-8z; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.287359389@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>
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
cc: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 04/21] x86/numa_emulation: pass numa node type to fake nodes
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0021-x86-numa-Fix-fake-numa-in-uniform-case.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131450.EUS3Nh13hIahDiGTGLR6fv5UwhDRvhmys-8BwqH-LIk@z>

From: Fan Du <fan.du@intel.com>

Signed-off-by: Fan Du <fan.du@intel.com>
---
 arch/x86/mm/numa_emulation.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

--- linux.orig/arch/x86/mm/numa_emulation.c	2018-12-23 19:21:11.002206144 +0800
+++ linux/arch/x86/mm/numa_emulation.c	2018-12-23 19:21:10.998206236 +0800
@@ -12,6 +12,8 @@
 
 static int emu_nid_to_phys[MAX_NUMNODES];
 static char *emu_cmdline __initdata;
+static nodemask_t emu_numa_nodes_pmem;
+static nodemask_t emu_numa_nodes_dram;
 
 void __init numa_emu_cmdline(char *str)
 {
@@ -311,6 +313,12 @@ static int __init split_nodes_size_inter
 					       min(end, limit) - start);
 			if (ret < 0)
 				return ret;
+
+			/* Update numa node type for fake numa node */
+			if (node_isset(i, emu_numa_nodes_pmem))
+				node_set(nid - 1, numa_nodes_pmem);
+			else
+				node_set(nid - 1, numa_nodes_dram);
 		}
 	}
 	return nid;
@@ -410,6 +418,12 @@ void __init numa_emulation(struct numa_m
 		unsigned long n;
 		int nid = 0;
 
+		emu_numa_nodes_pmem = numa_nodes_pmem;
+		emu_numa_nodes_dram = numa_nodes_dram;
+
+		nodes_clear(numa_nodes_pmem);
+		nodes_clear(numa_nodes_dram);
+
 		n = simple_strtoul(emu_cmdline, &emu_cmdline, 0);
 		ret = -1;
 		for_each_node_mask(i, physnode_mask) {


