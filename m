Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 754846B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 04:17:09 -0400 (EDT)
Date: Fri, 10 May 2013 18:16:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 04/31] dentry: move to per-sb LRU locks
Message-ID: <20130510081641.GS23072@dastard>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-5-git-send-email-glommer@openvz.org>
 <20130510052934.GR23072@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130510052934.GR23072@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Fri, May 10, 2013 at 03:29:34PM +1000, Dave Chinner wrote:
> On Thu, May 09, 2013 at 10:06:21AM +0400, Glauber Costa wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > With the dentry LRUs being per-sb structures, there is no real need
> > for a global dentry_lru_lock. The locking can be made more
> > fine-grained by moving to a per-sb LRU lock, isolating the LRU
> > operations of different filesytsems completely from each other.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> 
> Doesn't apply to a current linus tree. What is this patchset based

No, this is too painful. It doesn't apply to a 3.9 tree, and it
BUG-ONs in the dcache on a current Linus tree, probably because I
didn't resolve one of the 10 or so patches that didn't apply
correctly....

So, I'm going to wait until there's a version that applies to the
current TOT and go from there....

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
