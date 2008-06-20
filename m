Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5KF2Bg6004340
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 11:02:11 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5KF26TH028854
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 09:02:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5KF25QF028601
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 09:02:06 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 20 Jun 2008 20:31:52 +0530
Message-Id: <20080620150152.16094.76790.sendpatchset@localhost.localdomain>
In-Reply-To: <20080620150132.16094.29151.sendpatchset@localhost.localdomain>
References: <20080620150132.16094.29151.sendpatchset@localhost.localdomain>
Subject: [2/2] memrlimit fix usage of tmp as a parameter name
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Fix the variable tmp being used in write_strategy. This patch replaces tmp
with val, the fact that it is an output parameter can be interpreted from
the pass by reference.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memrlimitcgroup.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN mm/memrlimitcgroup.c~memrlimit-cgroup-simple-cleanup mm/memrlimitcgroup.c
--- linux-2.6.26-rc5/mm/memrlimitcgroup.c~memrlimit-cgroup-simple-cleanup	2008-06-20 20:14:00.000000000 +0530
+++ linux-2.6.26-rc5-balbir/mm/memrlimitcgroup.c	2008-06-20 20:22:08.000000000 +0530
@@ -118,13 +118,13 @@ static u64 memrlimit_cgroup_read(struct 
 					cft->private);
 }
 
-static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)
+static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *val)
 {
-	*tmp = memparse(buf, &buf);
+	*val = memparse(buf, &buf);
 	if (*buf != '\0')
 		return -EINVAL;
 
-	*tmp = PAGE_ALIGN(*tmp);
+	*val = PAGE_ALIGN(*val);
 	return 0;
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
