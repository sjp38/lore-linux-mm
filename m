Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id AAD356B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 21:56:53 -0400 (EDT)
Date: Thu, 6 Jun 2013 11:56:50 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 04/35] dentry: move to per-sb LRU locks
Message-ID: <20130606015650.GO29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-5-git-send-email-glommer@openvz.org>
 <20130605160738.fe46654369044b6d94eadd1b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160738.fe46654369044b6d94eadd1b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Wed, Jun 05, 2013 at 04:07:38PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:33 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > With the dentry LRUs being per-sb structures, there is no real need
> > for a global dentry_lru_lock. The locking can be made more
> > fine-grained by moving to a per-sb LRU lock, isolating the LRU
> > operations of different filesytsems completely from each other.
> 
> What's the point to this patch?  Is it to enable some additional
> development, or is it a standalone performance tweak?

It's the separation of the global lock into locks of the same scope
the generic LRU list requires.

> If the latter then the patch obviously makes this dentry code bloatier
> and straight-line slower.  So we're assuming that the multiprocessor
> contention-avoidance benefits will outweigh that cost.  Got any proof
> of this?

Well, it will do that too for workloads that span multiple
filesytems, but that isn't the point of the patch. it's merely a
setting stone...

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
