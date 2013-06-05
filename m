Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 03E306B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 03:37:30 -0400 (EDT)
Date: Wed, 5 Jun 2013 09:37:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130605073728.GC15997@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
 <20130604134523.GH31242@dhcp22.suse.cz>
 <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
 <20130604205426.GI14916@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604205426.GI14916@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Tue 04-06-13 13:54:26, Tejun Heo wrote:
> Hey,
> 
> On Tue, Jun 04, 2013 at 10:48:07PM +0200, Michal Hocko wrote:
> > > I really don't think memcg can afford to add more mess than there
> > > already is.  Let's try to get things right with each change, please.
> > 
> > Is this really about inside vs. outside skipping? I think this is a
> > general improvement to the code. I really prefer not duplicating common
> > code and skipping handling is such a code (we have a visitor which can
> > control the walk). With a side bonus that it doesn't have to pollute
> > vmscan more than necessary.
> > 
> > Please be more specific about _what_ is so ugly about this interface so
> > that it matters so much.
> 
> Can you please try the other approach and see how it looks? 

Tejun, I do not have infinite amount of time and this is barely a
priority for the patchset. The core part is to be able to skip
nodes/subtrees which are not worth reclaiming, remember?

I have already expressed my priorities for inside skipping
decisions. You are just throwing "let's try a different way" handwavy
suggestions. I have no problem to pull the skip logic outside of
iterators if more people think that this is _really_ important. But
until then I take it as a really low priority that shouldn't delay the
patchset without a good reason.

So please try to focus on the technical parts of the patchset if you
want to help with the review. I really appreciate suggestions but please
do not get down to bike scheding.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
