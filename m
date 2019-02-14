Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EABCC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19581222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19581222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D0818E000D; Thu, 14 Feb 2019 12:10:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A75F8E000B; Thu, 14 Feb 2019 12:10:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 594528E000D; Thu, 14 Feb 2019 12:10:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1609B8E000B
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so5244728pfd.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=FISFRHY5loySx7Sp6h4qOlLyae/4HSyJM32lOSkvvNc=;
        b=Dyix+dYMY3BVV598L2YURZlidl+HQVzz8uuBQK6Phk9JKTRjztU9ZP5Zpf+rvyhyad
         neeggvWdpetWZGeP9zsk816oLgp0xqi+BWGGT5fJ7fYWedfHxSSlRvQfOyaREOL1w9g9
         ou9toLjiy61abPXGC555sJVNvnrfOSmBJCzO3awhdhd3D682OGoE89MI8HfEVQ2z41Cr
         n8E8TQ6sLXVkDM4g41RQivagmW8h6wZVroHYkGvYhY4roiWR3qxeieiE9/AuJNL2WQ93
         7nQDnm2JxlnoJghV2RnQG6DJ8rAENgAoIHT3Q6SN9knM3hM6+JanWzVCrEB8Whpw2CT2
         QYmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubp1iol+wVavU54NxlMgQ4RKYa0NZLQXmVcBLmyp4NUh4IKSdy2
	Vtg+bEnyLQdD+pUiWep79hMn5E9orQTGhbh0QfzWCX0XuEalZVxEAjMLD6o4crVya9sePyUJRvC
	irVmmQoTdny6JtsOW9CS0cHi3mLQL42bjUfaL01W/vlBzkAMURxyMeA/Lk/MoxtaqJQ==
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr5177928plb.166.1550164246734;
        Thu, 14 Feb 2019 09:10:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaLdRZuMZwPZrHJIZ5SDpSSr/32SQgtc5V8QbkOS0/X2uN9zyJvDuZVRkeDGQA0hZ+g8w7K
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr5177839plb.166.1550164245509;
        Thu, 14 Feb 2019 09:10:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164245; cv=none;
        d=google.com; s=arc-20160816;
        b=Duj6gxa+urEvmfDPJ6aBNqGMkZMfoDWGbkiFq9DzuibJ59ajy9ZV8BTOpOKuNyr6gK
         0xRP3LKKRzjmz6NVuRT+KNC5z6n1paLLo/B6MKA6u+5W2K+kBrQif3Ji8htcGoxx8eP0
         OmxgIU5OrvfrKbJOJVIwyAQmAXvRZ6JROvSh7jJytqyVoOXRf1lYbchW1yr/rurRIpXA
         heaMUHagC4fCVXzmZDTgyc103i/mtvn2qNiKvanfhKYFOnCpiDLymRECWFuOp9hkkKwE
         gEKIoeJvJotDCNEi4IJoF7AcIyOXAQHfPfO53bGL23cPUnjv0Z/xQkKPQxLGTlpQjIjG
         0jww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=FISFRHY5loySx7Sp6h4qOlLyae/4HSyJM32lOSkvvNc=;
        b=Qk5OhDgu8ZEi9ANf5e7NkZ/tVkmFilKtzgknEy+nWn6iPoo06oB4DWOjo2mpBnubRj
         +OCuGpsKlpNv2vAnUKx1PlRLAJwoeMiyL0c0mdCP4kQYRxkUBTUxzHxA94LWJGB1Mh+2
         5HWdBVOVFFqqSCrlF5DkTZOa5TFsW1q1lCGRMqY7IkkuanhCzAy3GN+CKYrpuH1C7ybl
         DJszlXhyZTbh2zHKGA0E4xzuvWk7Rd9bSWThEYfLQH2VdvuW5rB61E9joF3VS7O2KYj3
         QQDk0tyiclKKlYV7NidzTloIotrN2sb3q2Kkx+vrDgLZowSTfSE73xoWS7tkFrML3qxM
         1yFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:45 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:44 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613144"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:44 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv6 10/10] doc/mm: New documentation for memory performance
Date: Thu, 14 Feb 2019 10:10:17 -0700
Message-Id: <20190214171017.9362-11-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Platforms may provide system memory where some physical address ranges
perform differently than others, or is side cached by the system.

Add documentation describing a high level overview of such systems and the
perforamnce and caching attributes the kernel provides for applications
wishing to query this information.

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/admin-guide/mm/numaperf.rst | 164 ++++++++++++++++++++++++++++++
 1 file changed, 164 insertions(+)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst

diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
new file mode 100644
index 000000000000..be8a23bb075d
--- /dev/null
+++ b/Documentation/admin-guide/mm/numaperf.rst
@@ -0,0 +1,164 @@
+.. _numaperf:
+
+=============
+NUMA Locality
+=============
+
+Some platforms may have multiple types of memory attached to a compute
+node. These disparate memory ranges may share some characteristics, such
+as CPU cache coherence, but may have different performance. For example,
+different media types and buses affect bandwidth and latency.
+
+A system supports such heterogeneous memory by grouping each memory type
+under different domains, or "nodes", based on locality and performance
+characteristics.  Some memory may share the same node as a CPU, and others
+are provided as memory only nodes. While memory only nodes do not provide
+CPUs, they may still be local to one or more compute nodes relative to
+other nodes. The following diagram shows one such example of two compute
+nodes with local memory and a memory only node for each of compute node:
+
+ +------------------+     +------------------+
+ | Compute Node 0   +-----+ Compute Node 1   |
+ | Local Node0 Mem  |     | Local Node1 Mem  |
+ +--------+---------+     +--------+---------+
+          |                        |
+ +--------+---------+     +--------+---------+
+ | Slower Node2 Mem |     | Slower Node3 Mem |
+ +------------------+     +--------+---------+
+
+A "memory initiator" is a node containing one or more devices such as
+CPUs or separate memory I/O devices that can initiate memory requests.
+A "memory target" is a node containing one or more physical address
+ranges accessible from one or more memory initiators.
+
+When multiple memory initiators exist, they may not all have the same
+performance when accessing a given memory target. Each initiator-target
+pair may be organized into different ranked access classes to represent
+this relationship. The highest performing initiator to a given target
+is considered to be one of that target's local initiators, and given
+the highest access class, 0. Any given target may have one or more
+local initiators, and any given initiator may have multiple local
+memory targets.
+
+To aid applications matching memory targets with their initiators, the
+kernel provides symlinks to each other. The following example lists the
+relationship for the access class "0" memory initiators and targets, which is
+the of nodes with the highest performing access relationship::
+
+	# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
+	relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
+
+	# symlinks -v /sys/devices/system/node/nodeY/access0/initiators/
+	relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
+
+================
+NUMA Performance
+================
+
+Applications may wish to consider which node they want their memory to
+be allocated from based on the node's performance characteristics. If
+the system provides these attributes, the kernel exports them under the
+node sysfs hierarchy by appending the attributes directory under the
+memory node's access class 0 initiators as follows::
+
+	/sys/devices/system/node/nodeY/access0/initiators/
+
+These attributes apply only when accessed from nodes that have the
+are linked under the this access's inititiators.
+
+The performance characteristics the kernel provides for the local initiators
+are exported are as follows::
+
+	# tree -P "read*|write*" /sys/devices/system/node/nodeY/access0/initiators/
+	/sys/devices/system/node/nodeY/access0/initiators/
+	|-- read_bandwidth
+	|-- read_latency
+	|-- write_bandwidth
+	`-- write_latency
+
+The bandwidth attributes are provided in MiB/second.
+
+The latency attributes are provided in nanoseconds.
+
+The values reported here correspond to the rated latency and bandwidth
+for the platform.
+
+==========
+NUMA Cache
+==========
+
+System memory may be constructed in a hierarchy of elements with various
+performance characteristics in order to provide large address space of
+slower performing memory cached by a smaller higher performing memory. The
+system physical addresses memory  initiators are aware of are provided
+by the last memory level in the hierarchy. The system meanwhile uses
+higher performing memory to transparently cache access to progressively
+slower levels.
+
+The term "far memory" is used to denote the last level memory in the
+hierarchy. Each increasing cache level provides higher performing
+initiator access, and the term "near memory" represents the fastest
+cache provided by the system.
+
+This numbering is different than CPU caches where the cache level (ex:
+L1, L2, L3) uses a CPU-side view where each increased level is lower
+performing. In contrast, the memory cache level is centric to the last
+level memory, so the higher numbered cache level denotes memory nearer
+to the CPU, and further from far memory.
+
+The memory-side caches are not directly addressable by software. When
+software accesses a system address, the system will return it from the
+near memory cache if it is present. If it is not present, the system
+accesses the next level of memory until there is either a hit in that
+cache level, or it reaches far memory.
+
+An application does not need to know about caching attributes in order
+to use the system. Software may optionally query the memory cache
+attributes in order to maximize the performance out of such a setup.
+If the system provides a way for the kernel to discover this information,
+for example with ACPI HMAT (Heterogeneous Memory Attribute Table),
+the kernel will append these attributes to the NUMA node memory target.
+
+When the kernel first registers a memory cache with a node, the kernel
+will create the following directory::
+
+	/sys/devices/system/node/nodeX/memory_side_cache/
+
+If that directory is not present, the system either does not not provide
+a memory-side cache, or that information is not accessible to the kernel.
+
+The attributes for each level of cache is provided under its cache
+level index::
+
+	/sys/devices/system/node/nodeX/memory_side_cache/indexA/
+	/sys/devices/system/node/nodeX/memory_side_cache/indexB/
+	/sys/devices/system/node/nodeX/memory_side_cache/indexC/
+
+Each cache level's directory provides its attributes. For example, the
+following shows a single cache level and the attributes available for
+software to query::
+
+	# tree sys/devices/system/node/node0/memory_side_cache/
+	/sys/devices/system/node/node0/memory_side_cache/
+	|-- index1
+	|   |-- associativity
+	|   |-- line_size
+	|   |-- size
+	|   `-- write_policy
+
+The "associativity" will be 0 if it is a direct-mapped cache, and non-zero
+for any other indexed based, multi-way associativity.
+
+The "line_size" is the number of bytes accessed from the next cache
+level on a miss.
+
+The "size" is the number of bytes provided by this cache level.
+
+The "write_policy" will be 0 for write-back, and non-zero for
+write-through caching.
+
+========
+See Also
+========
+.. [1] https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
+       Section 5.2.27
-- 
2.14.4

