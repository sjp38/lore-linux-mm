Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 1B2526B0036
	for <linux-mm@kvack.org>; Tue, 21 May 2013 03:18:11 -0400 (EDT)
Date: Tue, 21 May 2013 17:18:00 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 00/34] kmemcg shrinkers
Message-ID: <20130521071800.GN24543@dastard>
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
 <519B1C45.5090201@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519B1C45.5090201@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, hughd@google.com

On Tue, May 21, 2013 at 11:03:33AM +0400, Glauber Costa wrote:
> On 05/20/2013 12:06 AM, Glauber Costa wrote:
> > Initial notes:
> > ==============
> > 
> > Please pay attention to new patches that are debuting in this series. Patch1
> > changes our unused countries for int to long, since Dave noticed that it wasn't
> > being enough in some cases. Aside from that, the major change is that we now
> > compute and keep deferred work per-node (Patch13). The biggest effect of this,
> > is that to avoid storing a new nodemask in the stack, I am passing only the
> > node id down to the API. This means that the lru API *does not* take a nodemask
> > any longer, which in turn, makes it simpler.
> > 
> > I deeply considered this matter, and decided this would be the best way to go.
> > It is not different from what I have already done for memcgs: Only a single one
> > is passed down, and the complexity of scanning them is moved upwards to the
> > caller, where all the scanning logic should belong anyway.
> > 
> > If you want, you can also grab from branch "kmemcg-lru-shrinker" at:
> > 
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
> > 
> > I hope the performance problems are all gone. My testing now shows a smoother
> > and steady state for the objects during the lifetime of the workload, and
> > postmark numbers are closer to base, although we do deviate a bit.
> > 
> 
> Mel, Dave, et. al.
> 
> I have applied some more fixes for things I have found here and there as
> a result of a new round of testing. I won't post the result here until
> Thursday or Friday, to avoid patchbombing you guys. In the meantime I
> will be merging comments I receive from this version.
> 
> My git tree is up to date, so if you want to test it further, please
> pick that up.

Will do. I hope to do some testing of it tommorrow.

> I am attaching the result of my postmark run. I think the results look
> really good now.

What's version and command line you are using - I'll see if i can
reproduce the same results on my test system....

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
