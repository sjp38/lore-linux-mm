Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: Your message of "Wed, 20 Feb 2008 10:55:38 +0900"
	<20080220105538.6e7bbaba.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080220105538.6e7bbaba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080220020512.E0BF91E3C5B@siro.lan>
Date: Wed, 20 Feb 2008 11:05:12 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

> Balbir-san,
> 
> On Tue, 19 Feb 2008 16:26:10 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> > @@ -575,9 +532,11 @@ static int mem_cgroup_charge_common(stru
> >  {
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> > +	struct page_cgroup *new_pc = NULL;
> >  	unsigned long flags;
> >  	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> >  	struct mem_cgroup_per_zone *mz;
> > +	int error;
> >  
> >  	/*
> >  	 * Should page_cgroup's go to their own slab?
> > @@ -586,31 +545,20 @@ static int mem_cgroup_charge_common(stru
> >  	 * to see if the cgroup page already has a page_cgroup associated
> >  	 * with it
> >  	 */
> > -retry:
> > +
> >  	if (page) {
> > +		error = 0;
> >  		lock_page_cgroup(page);
> 
> What is !page case in mem_cgroup_charge_xxx() ?

see a hack in shmem_getpage.

YAMAMOTO Takashi

> 
> Thanks
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
