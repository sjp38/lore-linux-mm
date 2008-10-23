Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N91Svv025057
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Oct 2008 18:01:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AB792AC025
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:01:28 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 417A012C04A
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:01:28 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 2763C1DB803F
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:01:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id CFA1E1DB803B
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:01:27 +0900 (JST)
Date: Thu, 23 Oct 2008 18:00:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/11] cgroup: make cgroup kconfig as submenu
Message-Id: <20081023180057.791eeba4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Making CGROUP related configs to be submenu.

This patch will making CGROUP related confings to be submenu and
makeing 1st level configs of "General Setup" shorter.

 including following additional changes 
  - add help comment about CGROUPS and GROUP_SCHED.
  - moved MM_OWNER config to the bottom.
    (for good indent in menuconfig)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 init/Kconfig |  117 ++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 61 insertions(+), 56 deletions(-)

Index: mmotm-2.6.27+/init/Kconfig
===================================================================
--- mmotm-2.6.27+.orig/init/Kconfig
+++ mmotm-2.6.27+/init/Kconfig
@@ -271,59 +271,6 @@ config LOG_BUF_SHIFT
 		     13 =>  8 KB
 		     12 =>  4 KB
 
-config CGROUPS
-	bool "Control Group support"
-	help
-	  This option will let you use process cgroup subsystems
-	  such as Cpusets
-
-	  Say N if unsure.
-
-config CGROUP_DEBUG
-	bool "Example debug cgroup subsystem"
-	depends on CGROUPS
-	default n
-	help
-	  This option enables a simple cgroup subsystem that
-	  exports useful debugging information about the cgroups
-	  framework
-
-	  Say N if unsure
-
-config CGROUP_NS
-        bool "Namespace cgroup subsystem"
-        depends on CGROUPS
-        help
-          Provides a simple namespace cgroup subsystem to
-          provide hierarchical naming of sets of namespaces,
-          for instance virtual servers and checkpoint/restart
-          jobs.
-
-config CGROUP_FREEZER
-        bool "control group freezer subsystem"
-        depends on CGROUPS
-        help
-          Provides a way to freeze and unfreeze all tasks in a
-	  cgroup.
-
-config CGROUP_DEVICE
-	bool "Device controller for cgroups"
-	depends on CGROUPS && EXPERIMENTAL
-	help
-	  Provides a cgroup implementing whitelists for devices which
-	  a process in the cgroup can mknod or open.
-
-config CPUSETS
-	bool "Cpuset support"
-	depends on SMP && CGROUPS
-	help
-	  This option will let you create and manage CPUSETs which
-	  allow dynamically partitioning a system into sets of CPUs and
-	  Memory Nodes and assigning tasks to run only within those sets.
-	  This is primarily useful on large SMP or NUMA systems.
-
-	  Say N if unsure.
-
 #
 # Architectures with an unreliable sched_clock() should select this:
 #
@@ -337,6 +284,8 @@ config GROUP_SCHED
 	help
 	  This feature lets CPU scheduler recognize task groups and control CPU
 	  bandwidth allocation to such task groups.
+	  For allowing to make a group from arbitrary set of processes, use
+	  CONFIG_CGROUPS. (See Control Group support.)
 
 config FAIR_GROUP_SCHED
 	bool "Group scheduling for SCHED_OTHER"
@@ -379,6 +328,60 @@ config CGROUP_SCHED
 
 endchoice
 
+menu "Control Group supprt"
+config CGROUPS
+	bool "Control Group support"
+	help
+	  This option will let you use process cgroup subsystems
+	  such as Cpusets
+
+	  Say N if unsure.
+
+config CGROUP_DEBUG
+	bool "Example debug cgroup subsystem"
+	depends on CGROUPS
+	default n
+	help
+	  This option enables a simple cgroup subsystem that
+	  exports useful debugging information about the cgroups
+	  framework
+
+	  Say N if unsure
+
+config CGROUP_NS
+        bool "Namespace cgroup subsystem"
+        depends on CGROUPS
+        help
+          Provides a simple namespace cgroup subsystem to
+          provide hierarchical naming of sets of namespaces,
+          for instance virtual servers and checkpoint/restart
+          jobs.
+
+config CGROUP_FREEZER
+        bool "control group freezer subsystem"
+        depends on CGROUPS
+        help
+          Provides a way to freeze and unfreeze all tasks in a
+	  cgroup.
+
+config CGROUP_DEVICE
+	bool "Device controller for cgroups"
+	depends on CGROUPS && EXPERIMENTAL
+	help
+	  Provides a cgroup implementing whitelists for devices which
+	  a process in the cgroup can mknod or open.
+
+config CPUSETS
+	bool "Cpuset support"
+	depends on SMP && CGROUPS
+	help
+	  This option will let you create and manage CPUSETs which
+	  allow dynamically partitioning a system into sets of CPUs and
+	  Memory Nodes and assigning tasks to run only within those sets.
+	  This is primarily useful on large SMP or NUMA systems.
+
+	  Say N if unsure.
+
 config CGROUP_CPUACCT
 	bool "Simple CPU accounting cgroup subsystem"
 	depends on CGROUPS
@@ -393,9 +396,6 @@ config RESOURCE_COUNTERS
           infrastructure that works with cgroups
 	depends on CGROUPS
 
-config MM_OWNER
-	bool
-
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
 	depends on CGROUPS && RESOURCE_COUNTERS
@@ -419,6 +419,11 @@ config CGROUP_MEM_RES_CTLR
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
 
+config MM_OWNER
+	bool
+
+endmenu
+
 config SYSFS_DEPRECATED
 	bool
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
