Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0B8BD6B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:52:44 -0400 (EDT)
Date: Wed, 5 Jun 2013 10:52:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130605085239.GF15997@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
 <20130604134523.GH31242@dhcp22.suse.cz>
 <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
 <20130604205426.GI14916@htj.dyndns.org>
 <20130605073728.GC15997@dhcp22.suse.cz>
 <20130605080545.GF7303@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605080545.GF7303@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Wed 05-06-13 01:05:45, Tejun Heo wrote:
> Hey, Michal.
> 
> On Wed, Jun 05, 2013 at 09:37:28AM +0200, Michal Hocko wrote:
> > Tejun, I do not have infinite amount of time and this is barely a
> > priority for the patchset. The core part is to be able to skip
> > nodes/subtrees which are not worth reclaiming, remember?
> >
> > I have already expressed my priorities for inside skipping
> > decisions. You are just throwing "let's try a different way" handwavy
> > suggestions. I have no problem to pull the skip logic outside of
> > iterators if more people think that this is _really_ important. But
> > until then I take it as a really low priority that shouldn't delay the
> > patchset without a good reason.
> > 
> > So please try to focus on the technical parts of the patchset if you
> > want to help with the review. I really appreciate suggestions but please
> > do not get down to bike scheding.
> 
> Well, so, I know I've been pain in the ass but here's the thing.  I
> don't think you've been doing a good job of maintaining memcg.  Among
> the code pieces that I look at, it really ranks very close to the
> bottom in terms of readability and general messiness. 

Something, something, something, something and other similar things....
Is this really an argumentation. Comon' Tejun.

I _really_ do not let this into a flame and I will not respond to any
other emails that are not related to the patchset. I do not care and do
not have time for that!

> One of the core jobs of being a maintainer is ensuring the code stays
> in readable and maintainable state.

As you might know I am playing the maintainer role for around year and a
half and there were many improvemtns merged since then (and some faults
as well of course).
There is a lot of space for improvements and I work at areas as time
permits focusing more at reviews for other people are willing to do.

[...]

Please stop distracting from the main purpose of this discussion with
side tracks and personal things.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
