Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5C46A6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 19:40:48 -0400 (EDT)
Date: Tue, 21 May 2013 09:40:46 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 07/34] shrinker: convert superblock shrinkers to new
 API
Message-ID: <20130520234046.GE24543@dastard>
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
 <1368994047-5997-8-git-send-email-glommer@openvz.org>
 <519A51AC.7010609@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519A51AC.7010609@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, hughd@google.com, Dave Chinner <dchinner@redhat.com>

On Mon, May 20, 2013 at 08:39:08PM +0400, Glauber Costa wrote:
> On 05/20/2013 12:07 AM, Glauber Costa wrote:
> > +static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc)
> > +{
> > +	struct super_block *sb;
> > +	long	total_objects = 0;
> > +
> > +	sb = container_of(shrink, struct super_block, s_shrink);
> > +
> > +	if (!grab_super_passive(sb))
> > +		return -1;
> 
> Dave,
> 
> This is wrong, since mm/vmscan.c will WARN on count returning -1.
> Only scan can return -1, and this is probably a mistake while moving
> code over. Unless you shout, I am fixing this to "return 0" in this case.

That's why the WARN_ON() was put in shrink slab - to catch stuff
like this. ;)

So yes, it should return 0 here.

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
