Date: Fri, 27 Jul 2007 09:20:46 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070727082046.GA6301@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070726132336.GA18825@skynet.ie> <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com> <20070726225920.GA10225@skynet.ie> <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (26/07/07 18:22), Christoph Lameter didst pronounce:
> On Thu, 26 Jul 2007, Mel Gorman wrote:
> 
> > Comments?
> 
> Lets go with the unconditional filtering and get rid of some of the per 
> node zonelists?

I would prefer to go with this for 2.6.23 and work on that for 2.6.24.
The patch should be relatively straight-forward (I'll work on it today)
but it would need wider testing than what I can do here, particularly on
the larger machines that needed things like zlcache.

> We could f.e. merge the lists for ZONE_MOVABLE and 
> ZONE_base_of_zone_movable?

That will be fine for freelist management but a mess with respect to
reclaim. I'd rather not go down that rathole.

> That may increase the cacheability of the 
> zonelists and reduce cache footprint.

That should be the case. I'll work on the patch today and see what sort
of results I get.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
