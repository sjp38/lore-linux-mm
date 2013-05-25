Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8C8F56B0032
	for <linux-mm@kvack.org>; Fri, 24 May 2013 20:28:03 -0400 (EDT)
Date: Sat, 25 May 2013 10:27:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v8 16/34] xfs: convert buftarg LRU to generic code
Message-ID: <20130525002759.GK24543@dastard>
References: <1369391368-31562-1-git-send-email-glommer@openvz.org>
 <1369391368-31562-17-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369391368-31562-17-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Dave Chinner <dchinner@redhat.com>

On Fri, May 24, 2013 at 03:59:10PM +0530, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the buftarg LRU to use the new generic LRU list and take
> advantage of the functionality it supplies to make the buffer cache
> shrinker node aware.
> 
> * v7: Add NUMA aware flag

I know what is wrong with this patch that causes the unmount hang -
it's the handling of the _XBF_LRU_DISPOSE flag no longer being
modified atomically with the LRU lock. Hence there is a race where
we can either lose the _XBF_LRU_DISPOSE or not see it and hence we
can end up with code not detecting what list the buffer is on
correctly.

I haven't had a chance to work out a fix for it yet. If this ends up
likely to hold up the patch set, Glauber, then feel free to drop it
from the series and I'll push a fixed version through the XFS tree
in due course....

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
