Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 320FAC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E534A20896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E534A20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C608D8E0004; Thu, 13 Jun 2019 19:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B749F8E0002; Thu, 13 Jun 2019 19:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 928C58E0004; Thu, 13 Jun 2019 19:30:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5B18E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:15 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z10so433004pgf.15
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vaqAMivPZG8zRcB25WGSIeU5u9Z2PotIGlviXE6zM+I=;
        b=nNz/6P+IrONlFH/DD9nL+6nNdvzZi3q6w2vX+S3AH9gIpDpTRIGGoM7cvIOQTizBmZ
         +12zNM7SUwtagdh9KT0xrRljFGbKtnvlfv+K0bpFG8rj95y4DM0+3GI0ANLKli68P6MO
         5IqE3WfAoJeD/4+ivS6UQOfZhIK2uuxQFJC5KxhX+doNqWMfwjvCJGyCdHFZrgysmEmX
         LdqLsPy1EgiI92EFrUv0iWQwBQgJHZ/IoP5FcCD0UjI9PRbVk+D+uFw9oapBk67Z0Njb
         CHf4gYcAZEd6ljSfZ0R8VNhOka8sHP9tWuSWtyp0wiWomN8oA34PXGWQLcGXbkstqRd3
         Iz1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU2MPYG+NJQc3cqqOXh5C/fDMR5qUFOr+8HXJvrxnXEAyQJKE2g
	L5fUAbAuR/0iCgV5JndpmXQNTYDVKr3cwI5Dn9VOeOW/mHz73W42Jw82s8TYR8J08ON9Hccv7Rn
	h/x8/LCzcr2JoiyljwBE6AJMmPXlY2x66q5T/CwUf6FxFMcDMm3OyP4gAoQVbk+RFPg==
X-Received: by 2002:a17:902:1125:: with SMTP id d34mr17968868pla.40.1560468614923;
        Thu, 13 Jun 2019 16:30:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrsJ5EE1+mWH/VJSTag6OW2Pr9fGyGIIfHdZ+vSf2v2tzcuonDET12yXi3njL1LfYLY4nD
X-Received: by 2002:a17:902:1125:: with SMTP id d34mr17968769pla.40.1560468613684;
        Thu, 13 Jun 2019 16:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468613; cv=none;
        d=google.com; s=arc-20160816;
        b=N1a6BXuPf1cNZPWdpV4WRfaE7FdsRI44Um0vF86nB2xG/4yD2seWla7/kzqT8yTJKI
         wd2BWsa9W16ZJ72XuHM6lq/6G8tx/kL18tDx4BFrZpEQfipHE9dfHAs4KETHbUhdhtS2
         ViN+5Ga7ylrxial6/xI8W62+ZBuRefLUKrAJogrYYqYewelqzrpPOv98/86Jg5QhNMSX
         QppAySb1iL7dxgqrsDYJgd0z+vFEqFdVZpxQJhPgSR09Et/erup2+RLSA6U1SMJARng+
         GSXfaYIS6OYnmvbz4f3y0tvIFQQ4CBvn2JOdHTNorWiGf+7WcEbcw3bn+dA05J9GcNow
         eG3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vaqAMivPZG8zRcB25WGSIeU5u9Z2PotIGlviXE6zM+I=;
        b=AzHn8hofvBjMAkmVNaKEvGea1dOJ/BRDKtqKqH/lVPAR+8T431gnhiWMAGikpru+g1
         T3SqQZQeWB0AI5xMjyFjOPfjtF0HR1ExJcgokn8oIcUPtJfm4rBwvV3Kio48jTTmnOzl
         v6EM1Z+nXQSwGJ1H7/P5W+H+TMLJ2uwCI5pf3aWZ0WIR39rzW6RPb5hEnRBJLaE1rfWN
         0qt/s7s6V8gGq4olEhSESXFJkvv38Bahp2rhHP0j2piVbLlHyCLjw/ccRC2OgM5djw74
         9tn0aC4my4JPk4VvGKkEj1YpFx5UwnRKxPuKvEP/LNxqPw/fKUFV1y9YJVfFTjaJUJRm
         57TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id a14si881661pgm.206.2019.06.13.16.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R751e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:29:58 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 1/9] mm: define N_CPU_MEM node states
Date: Fri, 14 Jun 2019 07:29:29 +0800
Message-Id: <1560468577-101178-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kernel has some pre-defined node masks called node states, i.e.
N_MEMORY, N_CPU, etc.  But, there might be cpuless nodes, i.e. PMEM
nodes, and some architectures, i.e. Power, may have memoryless nodes.
It is not very straight forward to get the nodes with both CPUs and
memory.  So, define N_CPU_MEMORY node states.  The nodes with both CPUs
and memory are called "primary" nodes.  /sys/devices/system/node/primary
would show the current online "primary" nodes.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 drivers/base/node.c      |  2 ++
 include/linux/nodemask.h |  3 ++-
 mm/memory_hotplug.c      |  6 ++++++
 mm/page_alloc.c          |  1 +
 mm/vmstat.c              | 11 +++++++++--
 5 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcb..4d80fc8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -984,6 +984,7 @@ static ssize_t show_node_state(struct device *dev,
 #endif
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
+	[N_CPU_MEM] = _NODE_ATTR(primary, N_CPU_MEM),
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -995,6 +996,7 @@ static ssize_t show_node_state(struct device *dev,
 #endif
 	&node_state_attr[N_MEMORY].attr.attr,
 	&node_state_attr[N_CPU].attr.attr,
+	&node_state_attr[N_CPU_MEM].attr.attr,
 	NULL
 };
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 27e7fa3..66a8964 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -398,7 +398,8 @@ enum node_states {
 	N_HIGH_MEMORY = N_NORMAL_MEMORY,
 #endif
 	N_MEMORY,		/* The node has memory(regular, high, movable) */
-	N_CPU,		/* The node has one or more cpus */
+	N_CPU,			/* The node has one or more cpus */
+	N_CPU_MEM,		/* The node has both cpus and memory */
 	NR_NODE_STATES
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 328878b..7c29282 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -709,6 +709,9 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 
 	if (arg->status_change_nid >= 0)
 		node_set_state(node, N_MEMORY);
+
+	if (node_state(node, N_CPU))
+		node_set_state(node, N_CPU_MEM);
 }
 
 static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
@@ -1526,6 +1529,9 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 
 	if (arg->status_change_nid >= 0)
 		node_clear_state(node, N_MEMORY);
+
+	if (node_state(node, N_CPU))
+		node_clear_state(node, N_CPU_MEM);
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b13d39..757db89e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -124,6 +124,7 @@ struct pcpu_drain {
 #endif
 	[N_MEMORY] = { { [0] = 1UL } },
 	[N_CPU] = { { [0] = 1UL } },
+	[N_CPU_MEM] = { { [0] = 1UL } },
 #endif	/* NUMA */
 };
 EXPORT_SYMBOL(node_states);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a7d4933..d876ac0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1905,15 +1905,22 @@ static void __init init_cpu_node_state(void)
 	int node;
 
 	for_each_online_node(node) {
-		if (cpumask_weight(cpumask_of_node(node)) > 0)
+		if (cpumask_weight(cpumask_of_node(node)) > 0) {
 			node_set_state(node, N_CPU);
+			if (node_state(node, N_MEMORY))
+				node_set_state(node, N_CPU_MEM);
+		}
 	}
 }
 
 static int vmstat_cpu_online(unsigned int cpu)
 {
+	int node = cpu_to_node(cpu);
+
 	refresh_zone_stat_thresholds();
-	node_set_state(cpu_to_node(cpu), N_CPU);
+	node_set_state(node, N_CPU);
+	if (node_state(node, N_MEMORY))
+		node_set_state(node, N_CPU_MEM);
 	return 0;
 }
 
-- 
1.8.3.1

