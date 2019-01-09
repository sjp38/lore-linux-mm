Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 003488E00A7
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:48:03 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so4558189plt.7
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:48:02 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c10si25675731pla.173.2019.01.09.09.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:48:02 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 11/13] Documentation/ABI: Add node cache attributes
Date: Wed,  9 Jan 2019 10:43:39 -0700
Message-Id: <20190109174341.19818-12-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-1-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Add the attributes for the system memory side caches.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 34 +++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 74cfc80cabf6..e128464691f0 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -142,3 +142,37 @@ Contact:	Keith Busch <keith.busch@intel.com>
 Description:
 		This node's write latency in nanosecondss available to memory
 		initiators in nodes found in this class's initiators_nodelist.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/associativity
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The caches associativity: 0 for direct mapped, non-zero if
+		indexed.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/level
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This cache's level in the memory hierarchy. Matches 'Y' in the
+		directory name.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/line_size
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The number of bytes accessed from the next cache level on a
+		cache miss.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/size
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The size of this memory side cache in bytes.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/write_policy
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The cache write policy: 0 for write-back, 1 for write-through,
+		2 for other or unknown.
-- 
2.14.4
