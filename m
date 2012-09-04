Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7448E6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 09:09:10 -0400 (EDT)
Date: Tue, 4 Sep 2012 15:09:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
Message-ID: <20120904130905.GA15683@dhcp22.suse.cz>
References: <1346687211-31848-1-git-send-email-glommer@parallels.com>
 <20120903170806.GA21682@dhcp22.suse.cz>
 <5045BD25.10301@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5045BD25.10301@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Tue 04-09-12 12:34:45, Glauber Costa wrote:
> On 09/03/2012 09:08 PM, Michal Hocko wrote:
> > On Mon 03-09-12 19:46:51, Glauber Costa wrote:
> >> Here is a new attempt to lay down a path that will allow us to deprecate
> >> the non-hierarchical mode of operation from memcg.  Unlike what I posted
> >> before, I am making this behavior conditional on a Kconfig option.
> >> Vanilla users will see no change in behavior unless they don't
> >> explicitly set this option to on.
> > 
> > Which is the reason why I don't like this approach. Why would you enable
> > the option in the first place? If you know the default should be 1 then
> > you would already do that via cgconfig or directly, right?
> > I think we should either change the default (which I am planning to do
> > for the next OpenSUSE) or do it slow way suggested by Tejun.
> > We really want to have as big testing coverage as possible for the
> > default change and config option is IMHO not a way to accomplish this.
> > 
> 
> Not sure you realize, Michal, but you actually agree with me and my
> patch, given your reasoning.

I do agree with the default change, all right, but I really don't like
the config option because that one will not help us that much.

> If you plan to change it in OpenSUSE, you have two ways of doing so:
> You either carry a patch, which as simple as this is, is always
> undesirable, or you add one line to your distro config. Pick my patch,
> and do the later.

I would have to care the patch anyway until the distro kernel moves to
a kernel which has the patch which won't happen anytime soon (at least
from distro POV) and I guess we want the testing coverage as long as
possible.

> This patch does exactly the "do it slowly" thing, but without
> introducing more churn, like mount options.

Not really. Do it slowly means that somebody actually _notices_ that
something is about to change and they have a lot of time for that. This
will be really hard with the config option saying N by default.  People
will ignore that until it's too late.
We are interested in those users who would keep the config default N and
they are (ab)using use_hierarchy=0 in a way which is hard/impossible to
fix. This is where distributions might help and they should IMHO but why
to put an additional code into upstream? Isn't it sufficient that those
who would like to help (and take the risk) would just take the patch?

> Keep in mind that since
> there is the concern that direct upstream users won't see a sudden
> change in behavior, *every* way we choose to do it will raise the same
> question you posed: "Why would you enable this in the first place?" Be
> it a Kconfig, mount option, etc. The solution here is: Direct users of
> upstream kernels won't see a behavior change - as requested - but
> distributors will have a way to flip it without carrying a non-upstream
> patch.

The patch is so small that I do not care having it without being
upstream. Do others care that much?
The consequences of the semantic change is what matters much more to me.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
