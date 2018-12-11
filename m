Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 113ED8E006F
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:52 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f125so8652663pgc.20
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:52 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:50 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 07/12] Documentation/ABI: Add node performance attributes
Date: Mon, 10 Dec 2018 18:03:05 -0700
Message-Id: <20181211010310.8551-8-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Add descriptions for primary memory initiator performance access
attributes.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 8430d5b261f6..6cdb0643f9fd 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -123,3 +123,31 @@ Description:
 		The map of memory nodes that this node has primary access.
 		Memory accesses from this node to nodes not in this map may
 		encounter a performance penalty.
+
+What:		/sys/devices/system/node/nodeX/primary_initiator_access/read_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		Read bandwidth in MB/s available to memory initiators found in
+		primary_cpu_nodemask.
+
+What:		/sys/devices/system/node/nodeX/primary_initiator_access/read_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		Read latency in nanosecondss available to memory initiators
+		found in primary_cpu_nodemask.
+
+What:		/sys/devices/system/node/nodeX/primary_initiator_access/write_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		Write bandwidth in MB/s available to memory initiators found in
+		primary_cpu_nodemask.
+
+What:		/sys/devices/system/node/nodeX/primary_initiator_access/write_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		Write latency in nanosecondss available to memory initiators
+		found in primary_cpu_nodemask.
-- 
2.14.4
