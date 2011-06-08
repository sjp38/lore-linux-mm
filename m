Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0709A6B00E9
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 05:03:56 -0400 (EDT)
Date: Wed, 8 Jun 2011 10:03:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-ID: <20110608090349.GQ5247@suse.de>
References: <20110607084530.8ee571aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20110607084530.GI5247@suse.de>
 <20110607174355.fde99297.kamezawa.hiroyu@jp.fujitsu.com>
 <20110607090900.GK5247@suse.de>
 <20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
 <20110607101857.GM5247@suse.de>
 <20110608084034.29f25764.kamezawa.hiroyu@jp.fujitsu.com>
 <20110608094219.823c24f7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110608074350.GP5247@suse.de>
 <20110608174505.e4be46d6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110608174505.e4be46d6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Wed, Jun 08, 2011 at 05:45:05PM +0900, KAMEZAWA Hiroyuki wrote:
> > > <SNIP>
> > > +			/*
> > > +			 * Nodes can be overlapped
> > > +			 * We know some arch can have nodes layout as
> > > +			 * -------------pfn-------------->
> > > +			 * N0 | N1 | N2 | N0 | N1 | N2 |.....
> > > +			 */
> > > +			if (pfn_to_nid(pfn) != node)
> > > +				continue;
> > > +			fail = init_section_page_cgroup(pfn, node);
> > > +		}
> > >  	}
> > >  	if (fail) {
> > >  		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
> > > 
> > 
> > FWIW, overall I think this is heading in the right direction.
> > 
> Thank you. and I noticed I misunderstood what ALIGN() does.
> 

And I missed it :/

> This patch is made agaisnt the latest mainline git tree.
> Tested on my host, at least.
> ==
> From 0485201fec6a9bbfabc4c2674756360c05080155 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 8 Jun 2011 17:13:37 +0900
> Subject: [PATCH] [BUGFIX] Avoid getting nid from invalid struct page at page_cgroup allocation.
> 
> With sparsemem, page_cgroup_init scans pfn from 0 to max_pfn.
> But this may scan a pfn which is not on any node and can access
> memmap which is not initialized.
> 
> This makes page_cgroup_init() for SPARSEMEM node aware and remove
> a code to get nid from page->flags. (Then, we'll use valid NID
> always.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

I do not see any problems now. Thanks!

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
