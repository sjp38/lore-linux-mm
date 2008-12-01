Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB14VJnk017052
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 13:31:19 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FB0B45DE58
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 13:31:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EEA8645DE4F
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 13:31:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C55981DB8040
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 13:31:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C9C71DB8043
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 13:31:18 +0900 (JST)
Date: Mon, 1 Dec 2008 13:30:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Unused check for thread group leader in
 mem_cgroup_move_task
Message-Id: <20081201133030.0a330c7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200812010951.36392.knikanth@suse.de>
References: <200811291259.27681.knikanth@suse.de>
	<20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
	<200812010951.36392.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikanth Karthikesan <knikanth@suse.de>, balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, xemul@openvz.org, linux-mm@kvack.org, nikanth@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008 09:51:35 +0530
Nikanth Karthikesan <knikanth@suse.de> wrote:

> Ok. Then should we remove the unused code which simply checks for thread group 
> leader but does nothing?
>  
> Thanks
> Nikanth
> 
Hmm, it seem that code is obsolete. thanks.
Balbir, how do you think ?

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Anyway we have to visit here, again.


> Remove the unused test for thread group leader in mem_cgroup_move_task.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> 
> ---
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 866dcc7..8e9287d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1151,14 +1151,6 @@ static void mem_cgroup_move_task(struct cgroup_subsys 
> *ss,
>  	mem = mem_cgroup_from_cont(cont);
>  	old_mem = mem_cgroup_from_cont(old_cont);
>  
> -	/*
> -	 * Only thread group leaders are allowed to migrate, the mm_struct is
> -	 * in effect owned by the leader
> -	 */
> -	if (!thread_group_leader(p))
> -		goto out;
> -
> -out:
>  	mmput(mm);
>  }
>  
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
