Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1B5806B0068
	for <linux-mm@kvack.org>; Sun, 30 Sep 2012 20:57:27 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so4358114pad.14
        for <linux-mm@kvack.org>; Sun, 30 Sep 2012 17:57:26 -0700 (PDT)
Date: Mon, 1 Oct 2012 09:57:17 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20121001005717.GM10383@mtj.dyndns.org>
References: <20120927142822.GG3429@suse.de>
 <20120927144942.GB4251@mtj.dyndns.org>
 <50646977.40300@parallels.com>
 <20120927174605.GA2713@localhost>
 <50649EAD.2050306@parallels.com>
 <20120930075700.GE10383@mtj.dyndns.org>
 <20120930080249.GF10383@mtj.dyndns.org>
 <1348995388.2458.8.camel@dabdike.int.hansenpartnership.com>
 <20120930103732.GK10383@mtj.dyndns.org>
 <1349004352.2458.34.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349004352.2458.34.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Glauber Costa <glommer@parallels.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, James.

On Sun, Sep 30, 2012 at 12:25:52PM +0100, James Bottomley wrote:
> But you've got to ask yourself who cares about accurate accounting per
> container of dentry and inode objects? They're not objects that any
> administrator is used to limiting.  What we at parallels care about
> isn't accurately accounting them, it's that one container can't DoS
> another by exhausting system resources.  That's achieved equally well by
> first charge slab accounting, so we don't really have an interest in
> pushing object accounting code for which there's no use case.

Isn't it more because the use cases you have on mind don't share
dentries/inodes too much?  Wildly incorrect accounting definitely
degrades container isolation and can lead to unexpected behaviors.

> All we need kernel memory accounting and limiting for is DoS prevention.
> There aren't really any system administrators who care about Kernel
> Memory accounting (at least until the system goes oom) because there are
> no absolute knobs for it (all there is are a set of weird and wonderful
> heuristics, like dirty limit ratio and drop caches).  Kernel memory

I think that's because the mechanism currently doesn't exist.  If one
wants to control how memory is distributed across different cgroups,
it's logical to control kernel memory too.  The resource in question
is the actual memory after all.  I think at least google would be
interested in it, so, no, I don't agree that nobody wants it.  If that
is the case, we're working towards the wrong direction.

> usage has a whole set of regulatory infrastructure for trying to make it
> transparent to the user.
> 
> Don't get me wrong: if there were some easy way to get proper memory
> accounting for free, we'd be happy but, because it has no practical
> application for any of our customers, there's a limited price we're
> willing to pay to get it.

Even on purely technical ground, it could be that first-use is the
right trade off if other more accurate approaches are too difficult
and most workloads are happy with such approach.  I'm still a bit
weary to base userland interface decisions on that tho.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
