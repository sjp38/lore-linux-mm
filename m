Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CE1166B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 04:44:34 -0400 (EDT)
Date: Fri, 12 Oct 2012 10:44:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 14/14] Add documentation about the kmem controller
Message-ID: <20121012084431.GF10110@dhcp22.suse.cz>
References: <1349690780-15988-1-git-send-email-glommer@parallels.com>
 <1349690780-15988-15-git-send-email-glommer@parallels.com>
 <20121011143559.GJ29295@dhcp22.suse.cz>
 <5077CC73.80504@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5077CC73.80504@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>

On Fri 12-10-12 11:53:23, Glauber Costa wrote:
> On 10/11/2012 06:35 PM, Michal Hocko wrote:
> > On Mon 08-10-12 14:06:20, Glauber Costa wrote:
[...]
> >>  Kernel memory limits are not imposed for the root cgroup. Usage for the root
> >> -cgroup may or may not be accounted.
> >> +cgroup may or may not be accounted. The memory used is accumulated into
> >> +memory.kmem.usage_in_bytes, or in a separate counter when it makes sense.
> > 
> > Which separate counter? Is this about tcp kmem?
> > 
> 
> So far, yes, this is the only case that makes sense, and the fewer the
> better. In any case it exists, and I wanted to be generic.

Add (currently tcp) or something similar
 
[...]
> >> +    Kernel memory is effectively set as a percentage of the user memory. This
> > 
> > not a percentage it is subset of the user memory
> > 
> Well, this is semantics. I can change, but for me it makes a lot of
> sense to think of it in terms of a percentage, because it is easy to
> administer. You don't actually write a percentage, which I tried to
> clarify by using the term "effective set as a percentage".

I can still see somebody reading this and wondering why echo 50 > ...limit
didn't set a percentage...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
