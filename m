Date: Fri, 11 Jul 2008 14:15:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Message-Id: <20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080711040657.87AE71E3DF1@siro.lan>
References: <20080711085449.ba7d14dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20080711040657.87AE71E3DF1@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 13:06:57 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> hi,
> 
> > On Wed,  9 Jul 2008 15:00:34 +0900 (JST)
> > yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> > 
> > > hi,
> > > 
> > > the following patch is a simple implementation of
> > > dirty balancing for cgroups.  any comments?
> > > 
> > > it depends on the following fix:
> > > 	http://lkml.org/lkml/2008/7/8/428
> > > 
> > 
> > A few comments  ;)
> 
> thanks for comments.
> 
> >  - This looks simple but, could you merge this into memory resource controller ?
> 
> why?
> 
3 points.
 1. Is this useful if used alone ?
 2. memcg requires this kind of feature, basically.
 3. I wonder I need more work to make this work well under memcg.

If chasing page->cgroup and memcg make this patch much more complex,
I think this style of implimentation is a choice.

 About 3. 
    Does this works well if I changes get_dirty_limit()'s
    determine_dirtyable_memory() calculation under memcg ?
    But to do this seems not valid if dirty_ratio cgroup and memcg cgroup 
    containes different set of tasks.
 
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
