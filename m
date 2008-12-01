Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1A2Sn8023353
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 19:02:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DA0745DD7B
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:02:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DF8445DD7D
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:02:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D5961DB803C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:02:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DFAF31DB8038
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:02:24 +0900 (JST)
Date: Mon, 1 Dec 2008 19:01:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/4] memcg: remove unused logic in mem_cgroup_move_task()
Message-Id: <20081201190136.0e8b6ef0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201190021.f3ab1f17.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081201190021.f3ab1f17.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, nickpiggin@yahoo.com.au, knikanth@suse.de, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Remove unnecessary codes (...fragments of not-implemented functionalilty...)

Changelog:
 - removed all unused fragments.
 - added comment.


Reported-by: Nikanth Karthikesan <knikanth@suse.de>
Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: mmotm-2.6.28-Nov30/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov30.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov30/mm/memcontrol.c
@@ -2008,25 +2008,10 @@ static void mem_cgroup_move_task(struct 
 				struct cgroup *old_cont,
 				struct task_struct *p)
 {
-	struct mm_struct *mm;
-	struct mem_cgroup *mem, *old_mem;
-
-	mm = get_task_mm(p);
-	if (mm == NULL)
-		return;
-
-	mem = mem_cgroup_from_cont(cont);
-	old_mem = mem_cgroup_from_cont(old_cont);
-
 	/*
-	 * Only thread group leaders are allowed to migrate, the mm_struct is
-	 * in effect owned by the leader
+	 * FIXME: It's better to move charges of this process from old
+	 * memcg to new memcg. But it's just on TODO-List now.
 	 */
-	if (!thread_group_leader(p))
-		goto out;
-
-out:
-	mmput(mm);
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
