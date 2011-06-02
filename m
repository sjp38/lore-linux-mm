Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DD4B06B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:16:41 -0400 (EDT)
Received: by eyd9 with SMTP id 9so411071eyd.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 07:16:36 -0700 (PDT)
Date: Thu, 2 Jun 2011 22:16:22 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] mm: remove the leftovers of noswapaccount
Message-ID: <20110602141622.GA4416@cr0.redhat.com>
References: <BANLkTinLvqa0DiayLOwvxE9zBmqb4Y7Rww@mail.gmail.com>
 <20110523112558.GC11439@tiehlicka.suse.cz>
 <BANLkTi=2SwKFfwBxrQr3xLYSUzoGOy6oKA@mail.gmail.com>
 <20110530094337.GF20166@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110530094337.GF20166@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Am??rico Wang <xiyou.wangcong@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


In commit a2c8990aed5ab (memsw: remove noswapaccount kernel parameter),
Michal forgot to remove some left pieces of noswapaccount in the tree,
this patch removes them all.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>

---
diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 1a9446b..d27e1c4 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -545,22 +545,6 @@ Files:	net/netfilter/xt_connlimit.c
 
 ----------------------------
 
-What:	noswapaccount kernel command line parameter
-When:	2.6.40
-Why:	The original implementation of memsw feature enabled by
-	CONFIG_CGROUP_MEM_RES_CTLR_SWAP could be disabled by the noswapaccount
-	kernel parameter (introduced in 2.6.29-rc1). Later on, this decision
-	turned out to be not ideal because we cannot have the feature compiled
-	in and disabled by default and let only interested to enable it
-	(e.g. general distribution kernels might need it). Therefore we have
-	added swapaccount[=0|1] parameter (introduced in 2.6.37) which provides
-	the both possibilities. If we remove noswapaccount we will have
-	less command line parameters with the same functionality and we
-	can also cleanup the parameter handling a bit ().
-Who:	Michal Hocko <mhocko@suse.cz>
-
-----------------------------
-
 What:	ipt_addrtype match include file
 When:	2012
 Why:	superseded by xt_addrtype
diff --git a/init/Kconfig b/init/Kconfig
index ebafac4..e657952 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -665,7 +665,7 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  be careful about enabling this. When memory resource controller
 	  is disabled by boot option, this will be automatically disabled and
 	  there will be no overhead from this. Even when you set this config=y,
-	  if boot option "noswapaccount" is set, swap will not be accounted.
+	  if boot option "swapaccount=0" is set, swap will not be accounted.
 	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
 	  size is 4096bytes, 512k per 1Gbytes of swap.
 config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
@@ -680,7 +680,7 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
 	  parameter should have this option unselected.
 	  For those who want to have the feature enabled by default should
 	  select this option (if, for some reason, they need to disable it
-	  then noswapaccount does the trick).
+	  then swapaccount=0 does the trick).
 
 config CGROUP_PERF
 	bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 74ccff6..2eba968 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -502,7 +502,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 nomem:
 	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
 	printk(KERN_INFO
-		"swap_cgroup can be disabled by noswapaccount boot option\n");
+		"swap_cgroup can be disabled by swapaccount=0 boot option\n");
 	return -ENOMEM;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
