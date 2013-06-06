Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 4ECBB6B003B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 00:02:34 -0400 (EDT)
Date: Thu, 6 Jun 2013 14:02:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 03/35] dcache: convert dentry_stat.nr_unused to
 per-cpu counters
Message-ID: <20130606040229.GW29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-4-git-send-email-glommer@openvz.org>
 <20130605160731.91a5cd3ff700367f5e155d83@linux-foundation.org>
 <20130606014509.GN29338@dastard>
 <20130605194801.f9b25abf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605194801.f9b25abf.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Wed, Jun 05, 2013 at 07:48:01PM -0700, Andrew Morton wrote:
> On Thu, 6 Jun 2013 11:45:09 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
> > Andrew, if you want to push the changes back to generic per-cpu
> > counters through to Linus, then I'll write the patches for you.  But
> > - and this is a big but - I'll only do this if you are going to deal
> > with the "performance trumps all other concerns" fanatics over
> > whether it should be merged or not. I have better things to do
> > with my time have a flamewar over trivial details like this.
> 
> Please view my comments as a critique of the changelog, not of the code. 
> 
> There are presumably good (but undisclosed) reasons for going this way,
> but this question is so bleeding obvious that the decision should have
> been addressed up-front and in good detail.

The answer is so bleeding obvious I didn't think it needed to be
documented. ;) i.e. implement it the same way that it's sibling is
implemented because consistency is good....

> And, preferably, with benchmark numbers.  Because it might have been
> the wrong decision - stranger things have happened.

I've never been able to measure the difference in fast-path
performance that can be attributed to the generic CPU counters
having more overhead than the special ones. If you've got any
workload where the fast-path counter overhead shows up in a
profile, I'd be very interested....

Cheers,

dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
