Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id F41B06B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:17:28 -0400 (EDT)
Received: by dakp5 with SMTP id p5so579406dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:17:27 -0700 (PDT)
Date: Tue, 26 Jun 2012 15:17:23 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120626221723.GB15811@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626180451.GP3869@google.com>
 <20120626220809.GA4653@tiehlicka.suse.cz>
 <20120626221452.GA15811@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626221452.GA15811@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 26, 2012 at 03:14:52PM -0700, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Jun 27, 2012 at 12:08:09AM +0200, Michal Hocko wrote:
> > According to my experience, people usually create deeper subtrees
> > just because they want to have memcg hierarchy together with other
> > controller(s) and the other controller requires a different topology
> > but then they do not care about memory.* attributes in parents.
> > Those cases are not affected by this change because parents are
> > unlimited by default.
> > Deeper subtrees without hierarchy and independent limits are usually
> > mis-configurations, and we would like to hear about those to help to fix
> > them, or they are unfixable usecases which we want to know about as well
> > (because then we have a blocker for the unified cgroup hierarchy, don't
> > we).
> 
> Yeah, this is something I'm seriously considering doing from cgroup
> core.  ie. generating a warning message if the user nests cgroups w/
> controllers which don't support full hierarchy.

BTW, this is another reason I'm suggesting mount time option so that
cgroup core can be told that the specific controller is
hierarchy-aware.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
