Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0426B0269
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 18:11:18 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id h21-v6so6108030oib.16
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 15:11:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r18si3043717ote.203.2018.10.04.15.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 15:11:16 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w94M9Flp124074
	for <linux-mm@kvack.org>; Thu, 4 Oct 2018 18:11:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mwrs9g1hr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Oct 2018 18:11:15 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Oct 2018 23:11:13 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/2] docs: move memory hotplug description into admin-guide/mm
Date: Fri,  5 Oct 2018 01:11:00 +0300
In-Reply-To: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1538691061-31289-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The memory hotplug description in Documentation/memory-hotplug.txt is
already formatted as ReST and can be easily added to admin-guide/mm
section.

While on it, slightly update formatting to make it consistent with the
doc-guide.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/admin-guide/mm/index.rst             |  1 +
 .../mm/memory-hotplug.rst}                         | 73 +++++++++++-----------
 2 files changed, 38 insertions(+), 36 deletions(-)
 rename Documentation/{memory-hotplug.txt => admin-guide/mm/memory-hotplug.rst} (92%)

diff --git a/Documentation/admin-guide/mm/index.rst b/Documentation/admin-guide/mm/index.rst
index ceead68..8edb35f 100644
--- a/Documentation/admin-guide/mm/index.rst
+++ b/Documentation/admin-guide/mm/index.rst
@@ -29,6 +29,7 @@ the Linux memory management.
    hugetlbpage
    idle_page_tracking
    ksm
+   memory-hotplug
    numa_memory_policy
    pagemap
    soft-dirty
diff --git a/Documentation/memory-hotplug.txt b/Documentation/admin-guide/mm/memory-hotplug.rst
similarity index 92%
rename from Documentation/memory-hotplug.txt
rename to Documentation/admin-guide/mm/memory-hotplug.rst
index 7f49ebf..a33090c 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/admin-guide/mm/memory-hotplug.rst
@@ -1,3 +1,5 @@
+.. _admin_guide_memory_hotplug:
+
 ==============
 Memory Hotplug
 ==============
@@ -9,10 +11,12 @@ This document is about memory hotplug including how-to-use and current status.
 Because Memory Hotplug is still under development, contents of this text will
 be changed often.
 
+.. contents:: :local:
+
 .. CONTENTS
 
   1. Introduction
-    1.1 purpose of memory hotplug
+    1.1 Purpose of memory hotplug
     1.2. Phases of memory hotplug
     1.3. Unit of Memory online/offline operation
   2. Kernel Configuration
@@ -35,13 +39,13 @@ be changed often.
 
     (1) x86_64's has special implementation for memory hotplug.
         This text does not describe it.
-    (2) This text assumes that sysfs is mounted at /sys.
+    (2) This text assumes that sysfs is mounted at ``/sys``.
 
 
 Introduction
 ============
 
-purpose of memory hotplug
+Purpose of memory hotplug
 -------------------------
 
 Memory Hotplug allows users to increase/decrease the amount of memory.
@@ -57,7 +61,6 @@ hardware which supports memory power management.
 
 Linux memory hotplug is designed for both purpose.
 
-
 Phases of memory hotplug
 ------------------------
 
@@ -92,7 +95,6 @@ phase by hand.
 (However, if you writes udev's hotplug scripts for memory hotplug, these
 phases can be execute in seamless way.)
 
-
 Unit of Memory online/offline operation
 ---------------------------------------
 
@@ -107,10 +109,9 @@ unit upon which memory online/offline operations are to be performed. The
 default size of a memory block is the same as memory section size unless an
 architecture specifies otherwise. (see :ref:`memory_hotplug_sysfs_files`.)
 
-To determine the size (in bytes) of a memory block please read this file:
-
-/sys/devices/system/memory/block_size_bytes
+To determine the size (in bytes) of a memory block please read this file::
 
+  /sys/devices/system/memory/block_size_bytes
 
 Kernel Configuration
 ====================
@@ -119,22 +120,22 @@ To use memory hotplug feature, kernel must be compiled with following
 config options.
 
 - For all memory hotplug:
-    - Memory model -> Sparse Memory  (CONFIG_SPARSEMEM)
-    - Allow for memory hot-add       (CONFIG_MEMORY_HOTPLUG)
+    - Memory model -> Sparse Memory  (``CONFIG_SPARSEMEM``)
+    - Allow for memory hot-add       (``CONFIG_MEMORY_HOTPLUG``)
 
 - To enable memory removal, the following are also necessary:
-    - Allow for memory hot remove    (CONFIG_MEMORY_HOTREMOVE)
-    - Page Migration                 (CONFIG_MIGRATION)
+    - Allow for memory hot remove    (``CONFIG_MEMORY_HOTREMOVE``)
+    - Page Migration                 (``CONFIG_MIGRATION``)
 
 - For ACPI memory hotplug, the following are also necessary:
-    - Memory hotplug (under ACPI Support menu) (CONFIG_ACPI_HOTPLUG_MEMORY)
+    - Memory hotplug (under ACPI Support menu) (``CONFIG_ACPI_HOTPLUG_MEMORY``)
     - This option can be kernel module.
 
 - As a related configuration, if your box has a feature of NUMA-node hotplug
   via ACPI, then this option is necessary too.
 
     - ACPI0004,PNP0A05 and PNP0A06 Container Driver (under ACPI Support menu)
-      (CONFIG_ACPI_CONTAINER).
+      (``CONFIG_ACPI_CONTAINER``).
 
      This option can be kernel module too.
 
@@ -145,10 +146,11 @@ sysfs files for memory hotplug
 ==============================
 
 All memory blocks have their device information in sysfs.  Each memory block
-is described under /sys/devices/system/memory as:
+is described under ``/sys/devices/system/memory`` as::
 
 	/sys/devices/system/memory/memoryXXX
-	(XXX is the memory block id.)
+
+where XXX is the memory block id.
 
 For the memory block covered by the sysfs directory.  It is expected that all
 memory sections in this range are present and no memory holes exist in the
@@ -157,7 +159,7 @@ the existence of one should not affect the hotplug capabilities of the memory
 block.
 
 For example, assume 1GiB memory block size. A device for a memory starting at
-0x100000000 is /sys/device/system/memory/memory4::
+0x100000000 is ``/sys/device/system/memory/memory4``::
 
 	(0x100000000 / 1Gib = 4)
 
@@ -165,11 +167,11 @@ This device covers address range [0x100000000 ... 0x140000000)
 
 Under each memory block, you can see 5 files:
 
-- /sys/devices/system/memory/memoryXXX/phys_index
-- /sys/devices/system/memory/memoryXXX/phys_device
-- /sys/devices/system/memory/memoryXXX/state
-- /sys/devices/system/memory/memoryXXX/removable
-- /sys/devices/system/memory/memoryXXX/valid_zones
+- ``/sys/devices/system/memory/memoryXXX/phys_index``
+- ``/sys/devices/system/memory/memoryXXX/phys_device``
+- ``/sys/devices/system/memory/memoryXXX/state``
+- ``/sys/devices/system/memory/memoryXXX/removable``
+- ``/sys/devices/system/memory/memoryXXX/valid_zones``
 
 =================== ============================================================
 ``phys_index``      read-only and contains memory block id, same as XXX.
@@ -207,13 +209,15 @@ Under each memory block, you can see 5 files:
   These directories/files appear after physical memory hotplug phase.
 
 If CONFIG_NUMA is enabled the memoryXXX/ directories can also be accessed
-via symbolic links located in the /sys/devices/system/node/node* directories.
+via symbolic links located in the ``/sys/devices/system/node/node*`` directories.
+
+For example::
 
-For example:
-/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
+	/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
 
-A backlink will also be created:
-/sys/devices/system/memory/memory9/node0 -> ../../node/node0
+A backlink will also be created::
+
+	/sys/devices/system/memory/memory9/node0 -> ../../node/node0
 
 .. _memory_hotplug_physical_mem:
 
@@ -240,7 +244,6 @@ If firmware supports NUMA-node hotplug, and defines an object _HID "ACPI0004",
 calls hotplug code for all of objects which are defined in it.
 If memory device is found, memory hotplug code will be called.
 
-
 Notify memory hot-add event by hand
 -----------------------------------
 
@@ -251,8 +254,9 @@ CONFIG_ARCH_MEMORY_PROBE and can be configured on powerpc, sh, and x86
 if hotplug is supported, although for x86 this should be handled by ACPI
 notification.
 
-Probe interface is located at
-/sys/devices/system/memory/probe
+Probe interface is located at::
+
+	/sys/devices/system/memory/probe
 
 You can tell the physical address of new memory to the kernel by::
 
@@ -263,7 +267,6 @@ memory_block_size] memory range is hot-added. In this case, hotplug script is
 not called (in current implementation). You'll have to online memory by
 yourself.  Please see :ref:`memory_hotplug_how_to_online_memory`.
 
-
 Logical Memory hot-add phase
 ============================
 
@@ -301,7 +304,7 @@ This sets a global policy and impacts all memory blocks that will subsequently
 be hotplugged. Currently offline blocks keep their state. It is possible, under
 certain circumstances, that some memory blocks will be added but will fail to
 online. User space tools can check their "state" files
-(/sys/devices/system/memory/memoryXXX/state) and try to online them manually.
+(``/sys/devices/system/memory/memoryXXX/state``) and try to online them manually.
 
 If the automatic onlining wasn't requested, failed, or some memory block was
 offlined it is possible to change the individual block's state by writing to the
@@ -334,8 +337,6 @@ available memory will be increased.
 
 This may be changed in future.
 
-
-
 Logical memory remove
 =====================
 
@@ -418,7 +419,7 @@ Memory hotplug event notifier
 
 Hotplugging events are sent to a notification queue.
 
-There are six types of notification defined in include/linux/memory.h:
+There are six types of notification defined in ``include/linux/memory.h``:
 
 MEM_GOING_ONLINE
   Generated before new memory becomes available in order to be able to
@@ -485,7 +486,7 @@ The third argument (arg) passes a pointer of struct memory_notify::
 
 The callback routine shall return one of the values
 NOTIFY_DONE, NOTIFY_OK, NOTIFY_BAD, NOTIFY_STOP
-defined in include/linux/notifier.h
+defined in ``include/linux/notifier.h``
 
 NOTIFY_DONE and NOTIFY_OK have no effect on the further processing.
 
-- 
2.7.4
