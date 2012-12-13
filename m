Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 44BC66B0070
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 09:44:43 -0500 (EST)
Date: Thu, 13 Dec 2012 14:44:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/8] mm: memcg: only evict file pages when we have plenty
Message-ID: <20121213144438.GC9887@suse.de>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-2-git-send-email-hannes@cmpxchg.org>
 <50C8FCE0.1060408@redhat.com>
 <20121212222844.GA10257@cmpxchg.org>
 <20121213100704.GV1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121213100704.GV1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 13, 2012 at 10:07:04AM +0000, Mel Gorman wrote:
> On Wed, Dec 12, 2012 at 05:28:44PM -0500, Johannes Weiner wrote:
> > On Wed, Dec 12, 2012 at 04:53:36PM -0500, Rik van Riel wrote:
> > > On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> > > >dc0422c "mm: vmscan: only evict file pages when we have plenty" makes
> 
> You are using some internal tree for that commit. Now that it's upstream
> it is commit e9868505987a03a26a3979f27b82911ccc003752.
> 
> > > >a point of not going for anonymous memory while there is still enough
> > > >inactive cache around.
> > > >
> > > >The check was added only for global reclaim, but it is just as useful
> > > >for memory cgroup reclaim.
> > > >
> > > >Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > >---
> > > >  mm/vmscan.c | 19 ++++++++++---------
> > > >  1 file changed, 10 insertions(+), 9 deletions(-)
> > > >
> > > <SNIP>
> > > 
> > > I believe the if() block should be moved to AFTER
> > > the check where we make sure we actually have enough
> > > file pages.
> > 
> > You are absolutely right, this makes more sense.  Although I'd figure
> > the impact would be small because if there actually is that little
> > file cache, it won't be there for long with force-file scanning... :-)
> > 
> 
> Does it actually make sense? Lets take the global reclaim case.
> 
> <stupidity snipped>

I made a stupid mistake that Michal Hocko pointed out to me. The goto
out means that it should be fine either way.

> I'm not being super thorough because I'm not quite sure this is the right
> patch if the motivation is for memcg to use the same logic. Instead of
> moving this if, why do you not estimate "free" for the memcg based on the
> hard limit and current usage? 
> 

I'm still curious about this part.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
