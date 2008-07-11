Subject: Re: [PATCH][RFC] dirty balancing for cgroups
In-Reply-To: Your message of "Fri, 11 Jul 2008 14:15:11 +0900"
	<20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080711055926.9AF4F5A03@siro.lan>
Date: Fri, 11 Jul 2008 14:59:26 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > >  - This looks simple but, could you merge this into memory resource controller ?
> > 
> > why?
> > 
> 3 points.
>  1. Is this useful if used alone ?

it can be.  why not?

>  2. memcg requires this kind of feature, basically.
> 
>  3. I wonder I need more work to make this work well under memcg.

i'm not sure if i understand these points.  can you explain a bit?

my patch penalizes heavy-writer cgroups as task_dirty_limit does
for heavy-writer tasks.  i don't think that it's necessary to be
tied to the memory subsystem because i merely want to group writers.

otoh, if you want to limit the number (or percentage or whatever) of
dirty pages in a memory cgroup, it can't be done independently from
the memory subsystem, of course.  it's another story, tho.

YAMAMOTO Takashi

> 
> If chasing page->cgroup and memcg make this patch much more complex,
> I think this style of implimentation is a choice.
> 
>  About 3. 
>     Does this works well if I changes get_dirty_limit()'s
>     determine_dirtyable_memory() calculation under memcg ?
>     But to do this seems not valid if dirty_ratio cgroup and memcg cgroup 
>     containes different set of tasks.
>  
> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
