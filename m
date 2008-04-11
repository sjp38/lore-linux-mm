Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNl04S022476
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:47:00 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNn6GD145138
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:49:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNn5kj011810
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:49:06 -0600
Date: Fri, 11 Apr 2008 16:49:13 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080411234913.GH19078@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411234743.GG19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

/sys/devices/system/node represents the current NUMA configuration of
the machine, but is undocumented in the ABI files. Add bare-bones
documentation for these files.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Greg, is something like this what you'd want? Should I be striving for
more detail? Should the file have a preamble indicating none of it
exists if !NUMA?

diff --git a/Documentation/ABI/testing/sysfs-devices-system-node b/Documentation/ABI/testing/sysfs-devices-system-node
new file mode 100644
index 0000000..97d6145
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-devices-system-node
@@ -0,0 +1,59 @@
+What:		/sys/devices/system/node/has_cpu
+Date:		October 2007
+Contact:	Lee Schermerhorn <Lee.Schermerhonr@hp.com>
+Description:
+		List of nodes which have one ore more CPUs.
+
+What:		/sys/devices/system/node/has_high_memory
+Date:		October 2007
+Contact:	Lee Schermerhorn <Lee.Schermerhorn@hp.com>
+Description:
+		List of nodes which have regular or high memory. This
+		file will not exist if CONFIG_HIGHMEM is off.
+
+What:		/sys/devices/system/node/has_normal_memory
+Date:		October 2007
+Contact:	Lee Schermerhorn <Lee.Schermerhorn@hp.com>
+Description:
+		List of nodes which have regular memory.
+
+What:		/sys/devices/system/node/online
+Date:		October 2007
+Contact:	Lee Schermerhorn <Lee.Schermerhorn@hp.com>
+Description:
+		List of online nodes.
+
+What:		/sys/devices/system/node/possible
+Date:		October 2007
+Contact:	Lee Schermerhorn <Lee.Schermerhorn@hp.com>
+Description:
+		List of nodes which could go online.
+
+What:		/sys/devices/system/node/<node>/<cpu>
+Date:		June 2006
+Contact:	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
+Description:
+		Symlink to the sysfs CPU information for each <cpu> on
+		<node>.
+
+What:		/sys/devices/system/node/<node>/cpumap
+Date:
+Contact:	Christoph Lameter <clameter@sgi.com>
+Description:
+		Hexadecimal mask of which CPUs are on <node>.
+
+What:		/sys/devices/system/node/<node>/meminfo
+Date:
+Contact:	Christoph Lameter <clameter@sgi.com>
+Description:
+		Memory information for <node>.
+		NOTE: This file violates the sysfs rules for one value
+		per file.
+
+What:		/sys/devices/system/node/<node>/numastat
+Date:
+Contact:	Christoph Lameter <clameter@sgi.com>
+Description:
+		NUMA statistics for <node>.
+		NOTE: This file violates the sysfs rules for one value
+		per file.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
