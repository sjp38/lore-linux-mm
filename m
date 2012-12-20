Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D73AC6B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 02:09:06 -0500 (EST)
Date: Thu, 20 Dec 2012 18:08:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] vmscan: take at least one pass with shrinkers
Message-ID: <20121220070852.GW15182@dastard>
References: <1355906418-3603-1-git-send-email-glommer@parallels.com>
 <1355906418-3603-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355906418-3603-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Dec 19, 2012 at 12:40:18PM +0400, Glauber Costa wrote:
> In very low free kernel memory situations, it may be the case that we
> have less objects to free than our initial batch size. If this is the
> case, it is better to shrink those, and open space for the new workload
> then to keep them and fail the new allocations.
> 
> More specifically, this happens because we encode this in a loop with
> the condition: "while (total_scan >= batch_size)". So if we are in such
> a case, we'll not even enter the loop.
> 
> This patch modifies turns it into a do () while {} loop, that will
> guarantee that we scan it at least once, while keeping the behaviour
> exactly the same for the cases in which total_scan > batch_size.

Looks good to me, seems to work just fine.

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
