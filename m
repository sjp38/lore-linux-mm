Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 90A266B0055
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 17:34:37 -0400 (EDT)
Subject: [PATCH 5/5] Documentation: ABI: document /sys/devices/system/cpu/
From: Alex Chiang <achiang@hp.com>
Date: Mon, 19 Oct 2009 15:34:35 -0600
Message-ID: <20091019213435.32729.81751.stgit@bob.kio>
In-Reply-To: <20091019212740.32729.7171.stgit@bob.kio>
References: <20091019212740.32729.7171.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

This interface has been around for a long time, but hasn't been
officially documented.

Since I wanted to extend the ABI, I figured I would document what
already existed.

Cc: Greg KH <greg@kroah.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 Documentation/ABI/testing/sysfs-devices-cpu |   42 +++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-devices-cpu

diff --git a/Documentation/ABI/testing/sysfs-devices-cpu b/Documentation/ABI/testing/sysfs-devices-cpu
new file mode 100644
index 0000000..9070889
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-devices-cpu
@@ -0,0 +1,42 @@
+What:		/sys/devices/system/cpu/
+Date:		October 2009
+Contact:	Linux kernel mailing list <linux-kernel@vger.kernel.org>
+Description:
+		A collection of CPU attributes, including cache information,
+		topology, and frequency. It also contains a mechanism to
+		logically hotplug CPUs.
+
+		The actual attributes present are architecture and
+		configuration dependent.
+
+
+What:		/sys/devices/system/cpu/$cpu/online
+Date:		January 2006
+Contact:	Linux kernel mailing list <linux-kernel@vger.kernel.org>
+Description:
+		When CONFIG_HOTPLUG_CPU is enabled, allows the user to
+		discover and change the online state of a CPU. To discover
+		the state:
+
+		cat /sys/devices/system/cpu/$cpu/online
+
+		A value of 0 indicates the CPU is offline. A value of 1
+		indicates it is online. To change the state, echo the
+		desired new state into the file:
+
+		echo [0|1] > /sys/devices/system/cpu/$cpu/online
+
+		For more information, please read Documentation/cpu-hotplug.txt
+
+
+What:		/sys/devices/system/cpu/$cpu/node
+Date:		October 2009
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:
+		When CONFIG_NUMA is enabled, a symbolic link that points
+		to the corresponding NUMA node directory.
+
+		For example, the following symlink is created for cpu42
+		in NUMA node 2:
+
+		/sys/devices/system/cpu/cpu42/node2 -> ../../node/node2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
