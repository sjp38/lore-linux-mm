Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A45DFC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54F12214AF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:56:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54F12214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E11788E000C; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D981F8E0009; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C84A38E000C; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 879358E0009
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y8so178623pgk.2
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=0PPS7dbHDTw5KQbfYs/X5r7EMR4rAtyIuWGSoX9+BsA=;
        b=FYM3RohPXbksQTTO4AFcYZwBn674ko6IDgtZm7L8bYbcQ6r8Bfnjan42+E1wmAthQM
         joUoM2OH8Alu+lxJzc/q1MRP7ClFCD304y2LmoKylIGcldfMryjO2ow5tPo9P8YWIDrc
         5UYxtMokxStW7XXd+OJlzGx/9h4yB+oGejNGBcKMbrMwSvk2hPgsV2D2PRBqN5f+LIyU
         vFCZLdHNLsUVkJNkAv3c1a9XhOMRMosB3Yig3gAn/Uo4nbpmbOgzRj6IQPusSqT5rpNO
         3Z/8/uLMqVHT0I1u2oMIuvB+Pc9NBe7TUcPnh1V0KDRro+BQgYgfntsyvEGlp63Eh2YW
         9mOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVnN7U7n1sNs7oJ+dMVtgaC36iMMNZ7F7Z4q1qseI9sw+LcU5UJ
	sBCEZoN314yHAnRT+cHsWKTW0ynL2YO0CIs3IIOaY0dwb7ndogzUdp2QPuSl75UK1daKuAmCU4a
	U5lqJJ+A2xJqsCt3dDaEJ5gY13xodiaxCP+dIcgTL2qtj9j4oVXR7RxdE0Klu037Xyw==
X-Received: by 2002:a62:e204:: with SMTP id a4mr34570451pfi.225.1552337746203;
        Mon, 11 Mar 2019 13:55:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfIt1AUrCvqudRyeHkGvW8T3LzOHgTWgjDe4PGLjX67IDseKWwyIfaX6LxJgoA8oxq4uOE
X-Received: by 2002:a62:e204:: with SMTP id a4mr34570375pfi.225.1552337744829;
        Mon, 11 Mar 2019 13:55:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337744; cv=none;
        d=google.com; s=arc-20160816;
        b=iy0WyEvul76sji96uIie+8ipHZXC1IBBAsqlI4PCs9D+h18eo2EOeDRUITcoXOWgJC
         iZhk1Hs2wTAUZswic/O0zXdBSq25pZdiEIWjuUqawO70/reROodnt2z0xBbjSBLCbR0Z
         oEulmJpph7fTVW8xmTyNcVF/FtpMI47vVKU9G9of7UfPJDKO8+BjiJfCA9XehGIYDLWl
         +5P8cspmjRcF1UnuAUyDvDvd6SsCRyXtlXwq0rKBkfwbTMJKpD4LokMkfsin2d7awf3n
         f7Ei67vhOrYyt9NM7+C2WnglSgAtUdfDMciFw+92Ziygp3RJg+LxbPxaRUgriOg+i3qR
         NdIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=0PPS7dbHDTw5KQbfYs/X5r7EMR4rAtyIuWGSoX9+BsA=;
        b=NY7fInCxPGZKVpArKUqNMkBPMmLVYl2l6AoBnH+a90H+afnWL6OL2+iYE55GUlqCK1
         mvrfFQ2PWcMygXzsKxBIw2FGivU85fIV73u2IU+LjCgdL6X/lp99hK2GR+PLtkyayUXl
         A7qC55KJj+nZQfUi/mZdskCTl04ZzRkahpJ71pbrH/c8fobE5+ErkOpyIdNBaQd6fB4M
         g5syghyvZ3n+2Fpkuf4vqmEFP7KvFuLJGqYITHbOHSf8lHtGThJZF+YyMjXRDtYZtW9k
         l42HZdsNHS1bfhXCHSnbYAK7kuNqkLuuNV4NUAc0Q8gWqWeUB9mQpsjrkGCIvcdxu4pk
         31fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910199"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:44 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 10/10] doc/mm: New documentation for memory performance
Date: Mon, 11 Mar 2019 14:56:06 -0600
Message-Id: <20190311205606.11228-11-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Platforms may provide system memory where some physical address ranges
perform differently than others, or is cached by the system on the
memory side.

Add documentation describing a high level overview of such systems and the
perforamnce and caching attributes the kernel provides for applications
wishing to query this information.

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/admin-guide/mm/numaperf.rst | 169 ++++++++++++++++++++++++++++++
 1 file changed, 169 insertions(+)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst

diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
new file mode 100644
index 000000000000..b79f70c04397
--- /dev/null
+++ b/Documentation/admin-guide/mm/numaperf.rst
@@ -0,0 +1,169 @@
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
+relationship for the access class "0" memory initiators and targets::
+
+	# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
+	relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
+
+	# symlinks -v /sys/devices/system/node/nodeY/access0/initiators/
+	relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
+
+A memory initiator may have multiple memory targets in the same access
+class. The target memory's initiators in a given class indicate the
+nodes' access characteristics share the same performance relative to other
+linked initiator nodes. Each target within an initiator's access class,
+though, do not necessarily perform the same as each other.
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
+L1, L2, L3) uses the CPU-side view where each increased level is lower
+performing. In contrast, the memory cache level is centric to the last
+level memory, so the higher numbered cache level corresponds to  memory
+nearer to the CPU, and further from far memory.
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
+	|   |-- indexing
+	|   |-- line_size
+	|   |-- size
+	|   `-- write_policy
+
+The "indexing" will be 0 if it is a direct-mapped cache, and non-zero
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

