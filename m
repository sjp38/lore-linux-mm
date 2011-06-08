Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1920D6B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 19:51:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CDED63EE0AE
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:51:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4DF945DEA1
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:51:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AA6445DE83
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:51:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F5BD1DB803C
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:51:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B8C91DB802C
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 08:51:18 +0900 (JST)
Date: Thu, 9 Jun 2011 08:44:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
Message-Id: <20110609084422.1b285cf3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608140951.115ab1dd.akpm@linux-foundation.org>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
	<20110601123913.GC4266@tiehlicka.suse.cz>
	<4DE6399C.8070802@redhat.com>
	<20110601134149.GD4266@tiehlicka.suse.cz>
	<4DE64F0C.3050203@redhat.com>
	<20110601152039.GG4266@tiehlicka.suse.cz>
	<4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
	<4DE8D50F.1090406@redhat.com>
	<BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
	<4DEE26E7.2060201@redhat.com>
	<20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608140951.115ab1dd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Igor Mammedov <imammedo@redhat.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

On Wed, 8 Jun 2011 14:09:51 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> The original patch:
> 
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4707,7 +4707,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  	if (!pn)
>  		return 1;
>  
> -	mem->info.nodeinfo[node] = pn;
>  	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  		mz = &pn->zoneinfo[zone];
>  		for_each_lru(l)
> @@ -4716,6 +4715,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  		mz->on_tree = false;
>  		mz->mem = mem;
>  	}
> +	mem->info.nodeinfo[node] = pn;
>  	return 0;
>  }
> 
> looks like a really good idea.  But it needs a new changelog and I'd be
> a bit reluctant to merge it as it appears that the aptch removes our
> only known way of reproducing a bug.
> 
> So for now I think I'll queue the patch up unchangelogged so the issue
> doesn't get forgotten about.
> 

Hmm, queued as clean up ? If so, I'll Ack.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
