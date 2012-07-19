Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AC6DE6B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 20:21:07 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4298715pbb.14
        for <linux-mm@kvack.org>; Wed, 18 Jul 2012 17:21:07 -0700 (PDT)
Date: Wed, 18 Jul 2012 17:21:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to
 -mm tree
Message-ID: <20120719002102.GN24336@google.com>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120719001002.GA6579@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

(cc'ing Yinghai, hi!)

Hello,

On Thu, Jul 19, 2012 at 09:10:02AM +0900, Minchan Kim wrote:
> On Wed, Jul 18, 2012 at 02:38:10PM -0700, Andrew Morton wrote:
> > On Wed, 18 Jul 2012 10:22:00 +0900
> > Minchan Kim <minchan@kernel.org> wrote:
> > 
> > > > 
> > > > Is this really necessary?  Does the zone start out all-zeroes?  If not, can we
> > > > make it do so?
> > > 
> > > Good point.
> > > It can remove zap_zone_vm_stats and zone->flags = 0, too.
> > > More important thing is that we could remove adding code to initialize
> > > zero whenever we add new field to zone. So I look at the code.
> > > 
> > > In summary, IMHO, all is already initialie zero out but we need double
> > > check in mips.
> > > 
> > 
> > Well, this is hardly a performance-critical path.  So rather than
> > groveling around ensuring that each and every architectures does the
> > right thing, would it not be better to put a single memset() into core
> > MM if there is an appropriate place?
> 
> I think most good place is free_area_init_node but at a glance,
> bootmem_data is set up eariler than free_area_init_node so shouldn't we
> keep that pointer still?

I don't think zapping node_data that late is a good idea.  It's used
from very early in the boot and its usage during early boot is fairly
platform dependent.  Dunno whether there's a good solution for this.
Maybe trigger warning if some fields which have to be zero aren't?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
