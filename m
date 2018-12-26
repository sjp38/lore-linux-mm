Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D53FC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C6A3218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C6A3218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 616008E0001; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46C868E0007; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15D5B8E0002; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0ECC8E0003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s22so15223468pgv.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=MbMZBCdGS9vCEzO7ug9k7Oryi7M/ui4d6Yz4YrcaGK4=;
        b=EvSwkfgu4jd5asNg8PfI7l6gmciEvKbsdsz7fcn52FSw9kcaZlpzl6q71M+PjjMXcK
         vqzymaSapE7FHHPNu9XTWaQM7Sf9IFCe3OAFudB0yHZ5Tlw4JJH9tNhqUxsZuC6HjoUl
         L4/uJIqgFJeevMXIJVttkSxDabduyn9NJOGaO3iGZ8SvMXp9+vqgp7UWBPxED/1q03zQ
         Mn/kkVokP6KtVwRImUl97uAL/gNRmJas0x9iM8ukREQ7sUWi5sK+4UBbNHfLUACBo/eS
         eQ67zAFbSN4jj9PTxzssiWS8RWN0nIBxEISt1MwSl0TCv72FcFP+PIU8V8xZZs6hztBX
         po5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfy8ycToCIEf77fqXzflXE8kZPYNd2ZRCxU5KJXdOd6BCRdah8E
	GZkPR/GgRxChsPu8vvOin6cSq1YhM7lDZcxWCIdjdykH4at1zqNyds+QOMq2jA/FnYqqWQMrk0G
	fgXYf/wRGlvOKNEg/iHZsxk9eWBn2dQH4ECHedzE5fQAiIcSX0MWnz7sQ4vJSAyIJFw==
X-Received: by 2002:a63:4926:: with SMTP id w38mr18228264pga.353.1545831426409;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4codTF3hEdwVYFfmniwG2c4uN7ge+istjc7etBiL/IfxyoGS2C9mfhPwdK9PgAu0gQRQRp
X-Received: by 2002:a63:4926:: with SMTP id w38mr18228227pga.353.1545831425841;
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831425; cv=none;
        d=google.com; s=arc-20160816;
        b=K3tlKPpNhqmPkuiAM1PqyR7DqrByUESkqVRaBEvspM6xn+PptTZuV+S4nj2VfgML4/
         7YJqgNi1bdNrQvOw50pzByLVUy0nN8hLvHQLoyveKrYAQSodYEZ4Rp+QbDTFURJiylAa
         nvTCrXCMVOnfZHqSnHHwtoD9jt3Bick8/Ua9RPTeV/uUK6i9ESRYKs6gRsyMJ/udkWHk
         c0fJZmaO57Uz2/F2RM65M3TgWst2CAa7ypf/4s47VTV3EwsXM2iMJmcjnDcPujvQleb1
         /SmcuX4tL8JvXcmYiopd8yiWyTIkK4wB8D+PgdWJxskMCS8Pwi6QJTgieu+VvTeBiIQD
         2K+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=MbMZBCdGS9vCEzO7ug9k7Oryi7M/ui4d6Yz4YrcaGK4=;
        b=Fd5Qxn2GZ9c7dZvebrOqaiDYxNx8/bkvrerAj3Es7T/Ce/9Sq/VYk28xhubu4tuuGs
         XeHEfGHssvnqGW9KV4/G1YUjU7+xusovijpN4/x5PdGud0+QIZpRLnUBXKqS1IgnJt3b
         h0x5fBifwOS4jsBtSQKhKSSdA1bjt0SRW8hfAis8baIDX40GQzz7TfxWCrhnKBQgXuUe
         J8TO7d8v7RUfrdXOSeMn2CMxUPb4anoSQseiY8BR8MOJVyAwXn/9pkXoQRhrgJsdE+/t
         pZ+iEGXhERX52UCPsiy1RMu+064gVds21be+vg9J7SlVbBbwdNiFhy6SdplcvsvJ1rsE
         rHLA==
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
   d="scan'208";a="121185457"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:01 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005ON-BS; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.463947436@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:53 +0800
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
Subject: [RFC][PATCH v2 07/21] mm: export node type {pmem|dram} under /sys/bus/node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0005-Export-node-type-pmem-ram-in-sys-bus-node.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131453.7mMHJVZKU1psMOie5LWBhPvR_M_O_-nwiWuA1tX8P0I@z>

From: Fan Du <fan.du@intel.com>

User space migration daemon could check
/sys/bus/node/devices/nodeX/type for node type.

Software can interrogate node type for node memory type and distance
to get desirable target node in migration.

grep -r . /sys/devices/system/node/*/type
/sys/devices/system/node/node0/type:dram
/sys/devices/system/node/node1/type:dram
/sys/devices/system/node/node2/type:pmem
/sys/devices/system/node/node3/type:pmem

Along with next patch which export `peer_node`, migration daemon
could easily find the memory type of current node, and the target
node in case of migration.

grep -r . /sys/devices/system/node/*/peer_node
/sys/devices/system/node/node0/peer_node:2
/sys/devices/system/node/node1/peer_node:3
/sys/devices/system/node/node2/peer_node:0
/sys/devices/system/node/node3/peer_node:1

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/base/node.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- linux.orig/drivers/base/node.c	2018-12-23 19:39:04.763414931 +0800
+++ linux/drivers/base/node.c	2018-12-23 19:39:04.763414931 +0800
@@ -233,6 +233,15 @@ static ssize_t node_read_distance(struct
 }
 static DEVICE_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
+static ssize_t type_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+
+	return sprintf(buf, is_node_pmem(nid) ? "pmem\n" : "dram\n");
+}
+static DEVICE_ATTR(type, S_IRUGO, type_show, NULL);
+
 static struct attribute *node_dev_attrs[] = {
 	&dev_attr_cpumap.attr,
 	&dev_attr_cpulist.attr,
@@ -240,6 +249,7 @@ static struct attribute *node_dev_attrs[
 	&dev_attr_numastat.attr,
 	&dev_attr_distance.attr,
 	&dev_attr_vmstat.attr,
+	&dev_attr_type.attr,
 	NULL
 };
 ATTRIBUTE_GROUPS(node_dev);


