Date: Tue, 9 Sep 2008 17:11:54 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
Message-Id: <20080909171154.f3cfdfd6.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp>
	<20080909165608.878d7182.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Sep 2008 16:56:08 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 9 Sep 2008 14:40:07 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > +	/* Double counting race condition ? */
> > > +	VM_BUG_ON(page_get_page_cgroup(page));
> > > +
> > >  	page_assign_page_cgroup(page, pc);
> > >  
> > >  	mz = page_cgroup_zoneinfo(pc);
> > 
> > I got this VM_BUG_ON at swapoff.
> > 
> > Trying to shmem_unuse_inode a page which has been moved
> > to swapcache by shmem_writepage causes this BUG, because
> > the page has not been uncharged(with all the patches applied).
> > 
> > I made a patch which changes shmem_unuse_inode to charge with
> > GFP_NOWAIT first and shrink usage on failure, as shmem_getpage does.
> > 
> > But I don't stick to my patch if you handle this case :)
> > 
> Thank you for testing and sorry for no progress in these days.
> 
> I'm sorry to say that I'll have to postpone this to remove
> page->page_cgroup pointer. I need some more performance-improvement
> effort to remove page->page_cgroup pointer without significant overhead.
> 
No problem. I know about that :)

And, I've started reviewing the radix tree patch and trying to test it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
