Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E16C16B006A
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:37:06 -0500 (EST)
Subject: [PATCH v3 5/5] Documentation: ABI: /sys/devices/system/cpu/cpu#/node
From: Alex Chiang <achiang@hp.com>
Date: Tue, 10 Nov 2009 15:37:04 -0700
Message-ID: <20091110223704.25636.78808.stgit@bob.kio>
In-Reply-To: <20091110223154.25636.48462.stgit@bob.kio>
References: <20091110223154.25636.48462.stgit@bob.kio>
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

 Documentation/ABI/testing/sysfs-devices-system-cpu |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-devices-system-cpu b/Documentation/ABI/testing/sysfs-devices-system-cpu
index 5aace16..1671634 100644
--- a/Documentation/ABI/testing/sysfs-devices-system-cpu
+++ b/Documentation/ABI/testing/sysfs-devices-system-cpu
@@ -94,6 +94,20 @@ Description:	Discover and change the online state of a CPU.
 		For more information, please read Documentation/cpu-hotplug.txt
 
 
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
