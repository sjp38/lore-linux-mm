Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 73D1C6B004D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 00:59:35 -0400 (EDT)
Date: Thu, 6 Jun 2013 14:59:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 13/35] vmscan: per-node deferred work
Message-ID: <20130606045907.GY29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-14-git-send-email-glommer@openvz.org>
 <20130605160815.fb69f7d4d1736455727fc669@linux-foundation.org>
 <20130606033742.GS29338@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130606033742.GS29338@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Thu, Jun 06, 2013 at 01:37:42PM +1000, Dave Chinner wrote:
> On Wed, Jun 05, 2013 at 04:08:15PM -0700, Andrew Morton wrote:
> > On Mon,  3 Jun 2013 23:29:42 +0400 Glauber Costa <glommer@openvz.org> wrote:
> > 
> > > We already keep per-node LRU lists for objects being shrunk, but the
> > > work that is deferred from one run to another is kept global. This
> > > creates an impedance problem, where upon node pressure, work deferred
> > > will accumulate and end up being flushed in other nodes.
> > 
> > This changelog would be more useful if it had more specificity.  Where
> > do we keep these per-node LRU lists (names of variables?).
> 
> In the per-node LRU lists the shrinker walks ;)
> 
> > Where do we
> > keep the global data? 
> 
> In the struct shrinker
> 
> > In what function does this other-node flushing
> > happen?
> 
> Any shrinker that is run on a different node.
> 
> > Generally so that readers can go and look at the data structures and
> > functions which you're talking about.
> > 
> > > In large machines, many nodes can accumulate at the same time, all
> > > adding to the global counter.
> > 
> > What global counter?
> 
> shrinker->nr
> 
> > >  As we accumulate more and more, we start
> > > to ask for the caches to flush even bigger numbers.
> > 
> > Where does this happen?
> 
> The shrinker scan loop ;)

Answers which doesn't really tell you more than you already knew :/

To give you more background, Andrew, here's a pointer to the
discussion where we analysed the problem that lead to this patch:

http://marc.info/?l=linux-fsdevel&m=136852512724091&w=4

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
