Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5328E000D
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:59:49 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c14so4255338pls.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:59:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d18si6701527pgm.212.2019.01.16.09.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:59:41 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv4 08/13] Documentation/ABI: Add node performance attributes
Date: Wed, 16 Jan 2019 10:57:59 -0700
Message-Id: <20190116175804.30196-9-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-1-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Add descriptions for memory class initiator performance access attributes.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index a9c47b4b0eee..2217557f29d3 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -114,3 +114,31 @@ Description:
 		The node list of memory targets that this initiator node has
 		class "Y" access. Memory accesses from this node to nodes not
 		in this list may have differet performance.
+
+What:		/sys/devices/system/node/nodeX/classY/read_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read bandwidth in MB/s available to memory
+		initiators in nodes found in this class's initiators_nodelist.
+
+What:		/sys/devices/system/node/nodeX/classY/read_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read latency in nanoseconds available to memory
+		initiators in nodes found in this class's initiators_nodelist.
+
+What:		/sys/devices/system/node/nodeX/classY/write_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write bandwidth in MB/s available to memory
+		initiators in nodes found in this class's initiators_nodelist.
+
+What:		/sys/devices/system/node/nodeX/classY/write_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write latency in nanoseconds available to memory
+		initiators in nodes found in this class's initiators_nodelist.
-- 
2.14.4
