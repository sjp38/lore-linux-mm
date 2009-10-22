Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 067F76B0085
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 00:15:31 -0400 (EDT)
Subject: [PATCH v2 5/5] Documentation: ABI: /sys/devices/system/cpu/cpu#/node
From: Alex Chiang <achiang@hp.com>
Date: Wed, 21 Oct 2009 22:15:30 -0600
Message-ID: <20091022041530.15705.29051.stgit@bob.kio>
In-Reply-To: <20091022040814.15705.95572.stgit@bob.kio>
References: <20091022040814.15705.95572.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

Describe NUMA node symlink created for CPUs when CONFIG_NUMA is set.

Cc: Greg KH <greg@kroah.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 Documentation/ABI/testing/sysfs-devices-system-cpu |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-devices-system-cpu b/Documentation/ABI/testing/sysfs-devices-system-cpu
index b400c34..67813ae 100644
--- a/Documentation/ABI/testing/sysfs-devices-system-cpu
+++ b/Documentation/ABI/testing/sysfs-devices-system-cpu
@@ -79,6 +79,21 @@ Description:	Discover and change the online state of a CPU.
 
 		For more information, please read Documentation/cpu-hotplug.txt
 
+
+What:		/sys/devices/system/cpu/cpu#/node
+Date:		October 2009
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	Discover NUMA node a CPU belongs to
+
+		When CONFIG_NUMA is enabled, a symbolic link that points
+		to the corresponding NUMA node directory.
+
+		For example, the following symlink is created for cpu42
+		in NUMA node 2:
+
+		/sys/devices/system/cpu/cpu42/node2 -> ../../node/node2
+
+
 What:		/sys/devices/system/cpu/cpu#/topology/core_id
 		/sys/devices/system/cpu/cpu#/topology/core_siblings
 		/sys/devices/system/cpu/cpu#/topology/core_siblings_list

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
