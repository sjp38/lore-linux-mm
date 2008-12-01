From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH] Unused check for thread group leader in mem_cgroup_move_task
Date: Mon, 1 Dec 2008 09:51:35 +0530
References: <200811291259.27681.knikanth@suse.de> <20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200812010951.36392.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, containers@lists.linux-foundation.org, xemul@openvz.org, linux-mm@kvack.org, nikanth@gmail.com
List-ID: <linux-mm.kvack.org>

On Monday 01 December 2008 06:42:08 KAMEZAWA Hiroyuki wrote:
> On Sat, 29 Nov 2008 12:59:27 +0530
>
> Nikanth Karthikesan <knikanth@suse.de> wrote:
> > Currently we just check for thread group leader in attach() handler but
> > do nothing!  Either (1) move it to can_attach handler or (2) remove the
> > test itself. I am attaching patches for both below.
> >
> > Thanks
> > Nikanth Karthikesan
> >
> > Move thread group leader check to can_attach handler, but this may
> > prevent non thread group leaders to be moved at all!
> >
> > Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
>
> It's allowed.
>
> Nack.
>

Ok. Then should we remove the unused code which simply checks for thread group 
leader but does nothing?
 
Thanks
Nikanth

Remove the unused test for thread group leader in mem_cgroup_move_task.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 866dcc7..8e9287d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1151,14 +1151,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
*ss,
 	mem = mem_cgroup_from_cont(cont);
 	old_mem = mem_cgroup_from_cont(old_cont);
 
-	/*
-	 * Only thread group leaders are allowed to migrate, the mm_struct is
-	 * in effect owned by the leader
-	 */
-	if (!thread_group_leader(p))
-		goto out;
-
-out:
 	mmput(mm);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
