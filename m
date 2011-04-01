Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4905A8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 01:31:20 -0400 (EDT)
Date: Fri, 1 Apr 2011 16:31:02 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
Message-ID: <20110401053102.GB6957@dastard>
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
 <20110331214033.GA2904@dastard>
 <20110401030811.GP2879@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110401030811.GP2879@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

On Fri, Apr 01, 2011 at 08:38:11AM +0530, Balbir Singh wrote:
> * Dave Chinner <david@fromorbit.com> [2011-04-01 08:40:33]:
> 
> > On Wed, Mar 30, 2011 at 11:00:26AM +0530, Balbir Singh wrote:
> > > 
> > > The following series implements page cache control,
> > > this is a split out version of patch 1 of version 3 of the
> > > page cache optimization patches posted earlier at
> > > Previous posting http://lwn.net/Articles/425851/ and analysis
> > > at http://lwn.net/Articles/419713/
> > > 
> > > Detailed Description
> > > ====================
> > > This patch implements unmapped page cache control via preferred
> > > page cache reclaim. The current patch hooks into kswapd and reclaims
> > > page cache if the user has requested for unmapped page control.
> > > This is useful in the following scenario
> > > - In a virtualized environment with cache=writethrough, we see
> > >   double caching - (one in the host and one in the guest). As
> > >   we try to scale guests, cache usage across the system grows.
> > >   The goal of this patch is to reclaim page cache when Linux is running
> > >   as a guest and get the host to hold the page cache and manage it.
> > >   There might be temporary duplication, but in the long run, memory
> > >   in the guests would be used for mapped pages.
> > 
> > What does this do that "cache=none" for the VMs and using the page
> > cache inside the guest doesn't acheive? That avoids double caching
> > and doesn't require any new complexity inside the host OS to
> > acheive...
> >
> 
> There was a long discussion on cache=none in the first posting and the
> downsides/impact on throughput. Please see
> http://www.mail-archive.com/kvm@vger.kernel.org/msg30655.html 

All there is in that thread is handwaving about the differences
between cache=none vs cache=writeback behaviour and about the amount
of data loss/corruption when failures occur.  There is only one real
example provided about real world performance in the entire thread,
but the root cause of the performance difference is not analysed,
determined and understood.  Hence I'm not convinced from this thread
that using cache=write* and using this functionality is
anything other than papering over some still unknown problem....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
