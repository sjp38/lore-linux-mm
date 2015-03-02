Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 62D666B0072
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 23:00:07 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id h136so24922831oig.1
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 20:00:07 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id e125si5211844oid.131.2015.03.01.20.00.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 01 Mar 2015 20:00:06 -0800 (PST)
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH 2/2] mem-hotplug: add description of sysfs `range' attribute
Date: Mon, 2 Mar 2015 04:05:00 +0000
Message-ID: <1425269100-15842-2-git-send-email-shengyong1@huawei.com>
In-Reply-To: <1425269100-15842-1-git-send-email-shengyong1@huawei.com>
References: <1425269100-15842-1-git-send-email-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, nfont@austin.ibm.com
Cc: linux-mm@kvack.org, zhenzhang.zhang@huawei.com

Add description of sysfs `range' attribute, which is designed to show the
memory holes in a memory section.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 Documentation/ABI/testing/sysfs-devices-memory |    8 ++++++++
 Documentation/memory-hotplug.txt               |   12 ++++++++----
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
index deef3b5..15629f5 100644
--- a/Documentation/ABI/testing/sysfs-devices-memory
+++ b/Documentation/ABI/testing/sysfs-devices-memory
@@ -69,6 +69,14 @@ Description:
 		read-only and is designed to show which zone this memory
 		block can be onlined to.
 
+What:           /sys/devices/system/memory/memoryX/range
+Date:           Feb 2015
+Contact:	Sheng Yong <shengyong1@huawei.com>
+Description:
+		The file /sys/devices/system/memory/memoryX/range is
+		read-only and is designed to show memory holes in one
+		memory section.
+
 What:		/sys/devices/system/memoryX/nodeY
 Date:		October 2009
 Contact:	Linux Memory Management list <linux-mm@kvack.org>
diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index ea03abf..d59724b 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -140,22 +140,22 @@ is described under /sys/devices/system/memory as
 
 For the memory block covered by the sysfs directory.  It is expected that all
 memory sections in this range are present and no memory holes exist in the
-range. Currently there is no way to determine if there is a memory hole, but
-the existence of one should not affect the hotplug capabilities of the memory
-block.
+range. However, if there is a memory hole, the existence of one should not
+affect the hotplug capabilities of the memory block.
 
 For example, assume 1GiB memory block size. A device for a memory starting at
 0x100000000 is /sys/device/system/memory/memory4
 (0x100000000 / 1Gib = 4)
 This device covers address range [0x100000000 ... 0x140000000)
 
-Under each memory block, you can see 4 files:
+Under each memory block, you can see 6 files:
 
 /sys/devices/system/memory/memoryXXX/phys_index
 /sys/devices/system/memory/memoryXXX/phys_device
 /sys/devices/system/memory/memoryXXX/state
 /sys/devices/system/memory/memoryXXX/removable
 /sys/devices/system/memory/memoryXXX/valid_zones
+/sys/devices/system/memory/memoryXXX/range
 
 'phys_index'      : read-only and contains memory block id, same as XXX.
 'state'           : read-write
@@ -180,6 +180,10 @@ Under each memory block, you can see 4 files:
 		    "memory7/valid_zones: Movable Normal" shows this memoryblock
 		    can be onlined to ZONE_MOVABLE by default and to ZONE_NORMAL
 		    by online_kernel.
+'range'           : read-only: designed to show memory holes in a memory
+                    section.
+                    Each line shows the start and end physical address of a
+                    memory area.
 
 NOTE:
   These directories/files appear after physical memory hotplug phase.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
