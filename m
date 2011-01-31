Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 927958D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 04:03:47 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id p0V93fDK017840
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 14:33:41 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0V93e723629308
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 14:33:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0V93dhZ022502
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:03:40 +1100
Date: Mon, 31 Jan 2011 13:11:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH 3/4] mecg: fix oom flag at THP charge
Message-ID: <20110131074142.GG5054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128122729.1f1c613e.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128080213.GC2213@cmpxchg.org>
 <20110128172146.940751a5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110128172146.940751a5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-28 17:21:46]:

> On Fri, 28 Jan 2011 09:02:13 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Fri, Jan 28, 2011 at 12:27:29PM +0900, KAMEZAWA Hiroyuki wrote:
> > > 
> > > Thanks to Johanns and Daisuke for suggestion.
> > > =
> > > Hugepage allocation shouldn't trigger oom.
> > > Allocation failure is not fatal.
> > > 
> > > Orignal-patch-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  mm/memcontrol.c |    4 +++-
> > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > > 
> > > Index: mmotm-0125/mm/memcontrol.c
> > > ===================================================================
> > > --- mmotm-0125.orig/mm/memcontrol.c
> > > +++ mmotm-0125/mm/memcontrol.c
> > > @@ -2369,11 +2369,14 @@ static int mem_cgroup_charge_common(stru
> > >  	struct page_cgroup *pc;
> > >  	int ret;
> > >  	int page_size = PAGE_SIZE;
> > > +	bool oom;
> > >  
> > >  	if (PageTransHuge(page)) {
> > >  		page_size <<= compound_order(page);
> > >  		VM_BUG_ON(!PageTransHuge(page));
> > > -	}
> > > +		oom = false;
> > > +	} else
> > > +		oom = true;
> > 
> > That needs a comment.  You can take the one from my patch if you like.
> > 
> 
> How about this ?
> ==
> Hugepage allocation shouldn't trigger oom.
> Allocation failure is not fatal.
>

 
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
