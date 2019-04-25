Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF31FC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88C01214C6
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88C01214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 099566B0005; Wed, 24 Apr 2019 21:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 049136B0006; Wed, 24 Apr 2019 21:42:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA2866B0007; Wed, 24 Apr 2019 21:42:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B32B26B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:42:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b12so12991745pfj.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=cah/q1jvVVujCnwnWh0QHWDEt4UM1VYQ6RdhbZoS3MQ=;
        b=oYlNuWuDHQumYMZpxo85tMjHfdNLBOj5jbiXtwplgnJF/9I/sP4+tjT83X8RSd9wQF
         UUohMTaUm9g0LEBj8XKmdAnr6VbeO+b0pr0MUYG3WCIzgjyzD+F7vQ7fb9+StgkWdr+3
         kI2bNpwenHciJRGayulNl3g6Sn4gcKnx0eVWjMNertYa8pi5XGfMZXEyhDZ8YjVukZw+
         dDyayC0axW5AYIQsSWar2yXVoDsVSlatIpQVgAzB/AcLJf22/F1s0Y7wxdfh7GvlOLK2
         DG0my93D28czm4TNz0pAVRkdkj9tl2lZQ3h7EnJ40Xb2aaz5tHqei380gRD030zRIZvj
         SJaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUKbJoBdNhz9/X0UL91O3+MgHSzvU6fMWcKzGufAtu6WHxJtYkp
	P33jFH8OVEIHHKBqFiVjsl/BA3FwYL7IUGwzKZkQOyEH0497vgrQhvu1vHxbd8fZjHEiU60VDx7
	HD5yRfFRUh4SdGwxOypaiJWXXHXWQMoJq5ZsCvePrlPRriHTdBFKOItdPeDXdhksWbw==
X-Received: by 2002:a62:5582:: with SMTP id j124mr37111874pfb.53.1556156563382;
        Wed, 24 Apr 2019 18:42:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmTTZqcIue+Xfhdg8s8+YTzsTfUbv7VmuOa6mAl9umqHti+ruw4Y6zRhZXK5/3Zmdik6cx
X-Received: by 2002:a62:5582:: with SMTP id j124mr37111820pfb.53.1556156562547;
        Wed, 24 Apr 2019 18:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156562; cv=none;
        d=google.com; s=arc-20160816;
        b=IyFOPIAoxwlK/x4YXL4y9kZ16TR03/jOX5L0YqmEvaYFFZbOsQnFDgZa2Zg0a3T64w
         phJF5h3ik/fkHQa2ya+z7SvheYytqEEB0qF4jU3Hgd7WkIFhLfLc6Ij2Cnnp0Ex7vN9h
         aneLBVfoSNr3QrJyMmYwbQX35RVzWA2a/dM6lOGDQY0bF/aN3QE9PpCt2TgIiJ9tFiYH
         any6lmDe61jjmUsbE9dWIgUgKNRMepD0EAIF57XvodGgnQvOGJ40lVAL6xbNSAv79LsC
         LYfcEEvQEsWhHBl7UVS5i0RDBZFMK7XEX5tIuzDu+xyYlZCf8dGrGF2oqQIJl+POdAJR
         Ahkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=cah/q1jvVVujCnwnWh0QHWDEt4UM1VYQ6RdhbZoS3MQ=;
        b=Ddh9pRe+p44EF1WMpWktkbpDchUnNg8WnwNF1cfMm2XTy7m3QApXtCD6I/JfwAyEiu
         bU905lOKPloQrlmcEC4vJRMPZmnB5tNceu7aXwzeLVVDu9p8TD5UdjKj78Zkel2Pp1W6
         +JxgFcrGgTqtZBUjEZEiEGPn8L1JzSLzFluk8Ktmq9rc2b8PgVZxlcXJiNv5mgbaejbs
         XuvDM7FCAlJvXA3UPqkb2xkCif1pg068t2UQZc0Sy1+GsM1lDufXMyfz6GpKj/zSex6f
         rFaaBYgMJB72We+lDU8nze1QmaatYjolbmABAqMzAvLidrH7FiKkFGCvKxSvFqemrvno
         sVsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si21134661pfc.278.2019.04.24.18.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:42:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 18:42:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,391,1549958400"; 
   d="scan'208";a="152134204"
Received: from zz23f_aep_wp03.sh.intel.com ([10.239.85.39])
  by FMSMGA003.fm.intel.com with ESMTP; 24 Apr 2019 18:42:40 -0700
From: Fan Du <fan.du@intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	fengguang.wu@intel.com,
	dan.j.williams@intel.com,
	dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com,
	ying.huang@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Fan Du <fan.du@intel.com>
Subject: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory system
Date: Thu, 25 Apr 2019 09:21:30 +0800
Message-Id: <1556155295-77723-1-git-send-email-fan.du@intel.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is another approach of building zonelist based on patch #10 of
patchset[1].

For systems with heterogeneous DRAM and PMEM (persistent memory),

1) change ZONELIST_FALLBACK to first fallback to same type nodes,
   then the other types

2) add ZONELIST_FALLBACK_SAME_TYPE to fallback only same type nodes.
   To be explicitly selected by __GFP_SAME_NODE_TYPE.

For example, a 2S DRAM+PMEM system may have NUMA distances:
node   0   1   2   3 
  0:  10  21  17  28 
  1:  21  10  28  17 
  2:  17  28  10  28 
  3:  28  17  28  10

Node 0,1 are DRAM nodes, node 2, 3 are PMEM nodes.

ZONELIST_FALLBACK
=================
Current zoned fallback lists are based on numa distance only,
which means page allocation request from node 0 will iterate zone order
like: DRAM node 0 -> PMEM node 2 -> DRAM node 1 -> PMEM node 3.

However PMEM has different characteristics from DRAM,
the more reasonable or desirable fallback style would be:
DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3.
When DRAM is exhausted, try PMEM then. 

ZONELIST_FALLBACK_SAME_TYPE
===========================
Some cases are more suitable to fit PMEM characteristics, like page is
read more frequently than written. Other cases may prefer DRAM only.
It doesn't matter page is from local node, or remote.

Create __GFP_SAME_NODE_TYPE to request page of same node type,
either we got DRAM(from node 0, 1) or PMEM (from node 2, 3), it's kind
of extension to the nofallback list, but with the same node type. 

This patchset is self-contained, and based on Linux 5.1-rc6.

[1]:
https://lkml.org/lkml/2018/12/26/138

Fan Du (5):
  acpi/numa: memorize NUMA node type from SRAT table
  mmzone: new pgdat flags for DRAM and PMEM
  x86,numa: update numa node type
  mm, page alloc: build fallback list on per node type basis
  mm, page_alloc: Introduce ZONELIST_FALLBACK_SAME_TYPE fallback list

 arch/x86/include/asm/numa.h |  2 ++
 arch/x86/mm/numa.c          |  3 +++
 drivers/acpi/numa.c         |  5 ++++
 include/linux/gfp.h         |  7 ++++++
 include/linux/mmzone.h      | 35 ++++++++++++++++++++++++++++
 mm/page_alloc.c             | 57 ++++++++++++++++++++++++++++++++-------------
 6 files changed, 93 insertions(+), 16 deletions(-)

-- 
1.8.3.1

