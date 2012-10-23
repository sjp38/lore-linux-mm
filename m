Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 7D5276B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:44:11 -0400 (EDT)
Date: Tue, 23 Oct 2012 20:44:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 16/18] slab: propagate tunables values
In-Reply-To: <5084FA31.4060709@parallels.com>
Message-ID: <0000013a8f5e3876-25f4d815-cf0a-4574-a321-60ad7a337aa7-000000@email.amazonses.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-17-git-send-email-glommer@parallels.com> <0000013a7a94c439-825659cc-8e6a-4905-909c-db1b230a4086-000000@email.amazonses.com> <5084FA31.4060709@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Mon, 22 Oct 2012, Glauber Costa wrote:

> On 10/19/2012 11:51 PM, Christoph Lameter wrote:
> > On Fri, 19 Oct 2012, Glauber Costa wrote:
> >
> >> SLAB allows us to tune a particular cache behavior with tunables.
> >> When creating a new memcg cache copy, we'd like to preserve any tunables
> >> the parent cache already had.
> >
> > SLAB and SLUB allow tuning. Could you come up with some way to put these
> > things into slab common and make it flexible so that the tuning could be
> > used for future allocators (like SLAM etc)?
> >
> They do, but they also do it very differently. Like slub uses sysfs,
> while slab don't.

Well yes that is something that I also want to make more general so that
all allocators support sysfs style display of status and tuning.

> I of course fully support the integration, I just don't think this
> should be a blocker for all kinds of work in the allocators. Converting
> slab to sysfs seems to be a major work, that you are already tackling.
> Were it simple, I believe it would be done already. Without it, this is
> pretty much a fake integration...

Well there is quite a bit of infrastructure that needs to be common in
order to get this done properly. I hope we will get around to that
someday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
