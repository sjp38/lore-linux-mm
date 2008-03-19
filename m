Date: Wed, 19 Mar 2008 11:34:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg: move_lists
Message-Id: <20080319113448.03688ae8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080318164437.GC24473@balbir.in.ibm.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314190731.b3635ae9.kamezawa.hiroyu@jp.fujitsu.com>
	<20080318164437.GC24473@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 22:14:37 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:07:31]:
> 
> > Modifies mem_cgroup_move_lists() to use get_page_cgroup().
> > No major algorithm changes just adjusted to new locks.
> > 
> > Signed-off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> >  mm/memcontrol.c |   16 +++++++++-------
> >  1 file changed, 9 insertions(+), 7 deletions(-)
> > 
> > Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
> > +++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
> > @@ -309,6 +309,10 @@ void mem_cgroup_move_lists(struct page *
> >  	struct mem_cgroup_per_zone *mz;
> >  	unsigned long flags;
> > 
> > +	/* This GFP will be ignored..*/
> > +	pc = get_page_cgroup(page, GFP_ATOMIC, false);
> > +	if (!pc)
> > +		return;
> 
> Splitting get_page_cgroup will help avoid thse kinds of hacks. Please
> see my earlier comment.
> 
My new version has 2 funcs.

get_page_cgroup(struct page *page)
get_alloc_page_cgroup(struct page *page, gfp_t mask);

I will post after I can get test machine..

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
