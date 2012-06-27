Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id E1F226B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:51:23 -0400 (EDT)
Date: Wed, 27 Jun 2012 14:51:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120627125119.GE5683@tiehlicka.suse.cz>
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
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue 26-06-12 15:14:52, Tejun Heo wrote:
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

This is a good idea.

> > >   Note that the default should still be flat hierarchy.
> > > 
> > > 2. Mark flat hierarchy deprecated and produce a warning message if
> > >    memcg is mounted w/o hierarchy option for a year or two.
> > 
> > I would agree with you on this with many kernel configurables but
> > this one doesn't fall in. There is a trivial fallback (set root to
> > use_hierarchy=0) so the mount option seems like an overkill - yet
> > another API to keep for some time...
> 
> Just disallow clearing .use_hierarchy if it was mounted with the
> option? 

Dunno, mount option just doesn't feel right. We do not offer other
attributes to be set by them so it would be just confusing. Besides that
it would require an integration into existing tools like cgconfig which
is yet another pain just because of something that we never promissed to
keep a certain way. There are many people who don't work with mount&fs
cgroups directly but rather use libcgroup for that...

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
