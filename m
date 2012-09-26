Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 75D316B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 18:10:52 -0400 (EDT)
Received: by dadi14 with SMTP id i14so268074dad.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 15:10:51 -0700 (PDT)
Date: Wed, 26 Sep 2012 15:10:46 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120926221046.GA10453@mtj.dyndns.org>
References: <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
 <50634105.8060302@parallels.com>
 <20120926180124.GA12544@google.com>
 <50634FC9.4090609@parallels.com>
 <20120926193417.GJ12544@google.com>
 <50635B9D.8020205@parallels.com>
 <20120926195648.GA20342@google.com>
 <50635F46.7000700@parallels.com>
 <20120926201629.GB20342@google.com>
 <50637298.2090904@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50637298.2090904@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Glauber.

On Thu, Sep 27, 2012 at 01:24:40AM +0400, Glauber Costa wrote:
> "kmem_accounted" is not a switch. It is an internal representation only.
> The semantics, that we discussed exhaustively in San Diego, is that a
> group that is not limited is not accounted. This is simple and consistent.
> 
> Since the limits are still per-cgroup, you are actually proposing more
> user-visible complexity than me, since you are adding yet another file,
> with its own semantics.

I was confused.  I thought it was exposed as a switch to userland (it
being right below .use_hierarchy tripped red alert).  This is internal
flag dependent upon kernel limit being set.  My apologies.

So, the proposed behavior is to allow enabling kmemcg anytime but
ignore what happened inbetween?  Where the knob is changes but the
weirdity seems all the same.  What prevents us from having a single
switch at root which can only be flipped when there's no children?

Backward compatibility is covered with single switch and I really
don't think "you can enable limits for kernel memory anytime but we
don't keep track of whatever happened before it was flipped the first
time because the first time is always special" is a sane thing to
expose to userland.  Or am I misunderstanding the proposed behavior
again?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
