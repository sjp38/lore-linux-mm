Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4ED6wag017145
	for <linux-mm@kvack.org>; Wed, 14 May 2008 09:06:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4EDA3nt038980
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:10:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4ED9wpR010263
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:10:00 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 14 May 2008 18:39:39 +0530
Message-Id: <20080514130939.24440.73960.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 3/4] cgroup mm owner callback changes to add task info (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch adds an additional field to the mm_owner callbacks. This field
is required to get to the mm that changed.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/cgroup.h |    3 ++-
 kernel/cgroup.c        |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff -puN include/linux/cgroup.h~cgroup-add-task-to-mm-owner-callbacks include/linux/cgroup.h
--- linux-2.6.26-rc2/include/linux/cgroup.h~cgroup-add-task-to-mm-owner-callbacks	2008-05-14 18:36:59.000000000 +0530
+++ linux-2.6.26-rc2-balbir/include/linux/cgroup.h	2008-05-14 18:36:59.000000000 +0530
@@ -310,7 +310,8 @@ struct cgroup_subsys {
 	 */
 	void (*mm_owner_changed)(struct cgroup_subsys *ss,
 					struct cgroup *old,
-					struct cgroup *new);
+					struct cgroup *new,
+					struct task_struct *p);
 	int subsys_id;
 	int active;
 	int disabled;
diff -puN kernel/cgroup.c~cgroup-add-task-to-mm-owner-callbacks kernel/cgroup.c
--- linux-2.6.26-rc2/kernel/cgroup.c~cgroup-add-task-to-mm-owner-callbacks	2008-05-14 18:36:59.000000000 +0530
+++ linux-2.6.26-rc2-balbir/kernel/cgroup.c	2008-05-14 18:36:59.000000000 +0530
@@ -2772,7 +2772,7 @@ void cgroup_mm_owner_callbacks(struct ta
 			if (oldcgrp == newcgrp)
 				continue;
 			if (ss->mm_owner_changed)
-				ss->mm_owner_changed(ss, oldcgrp, newcgrp);
+				ss->mm_owner_changed(ss, oldcgrp, newcgrp, new);
 		}
 	}
 }
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
