Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 0F1D66B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:29:34 -0400 (EDT)
Received: by yhq56 with SMTP id 56so1128335yhq.31
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 05:29:34 -0700 (PDT)
Date: Wed, 27 Jun 2012 14:29:27 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem
 controller for memcg: stripped down version
Message-ID: <20120627122924.GD20638@somewhere.redhat.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <20120625162745.eabe4f03.akpm@linux-foundation.org>
 <4FE9621D.2050002@parallels.com>
 <20120626145539.eeeab909.akpm@linux-foundation.org>
 <4FEAD260.4000603@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEAD260.4000603@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <lennart@poettering.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kir Kolyshkin <kir@parallels.com>

On Wed, Jun 27, 2012 at 01:29:04PM +0400, Glauber Costa wrote:
> On 06/27/2012 01:55 AM, Andrew Morton wrote:
> >>I can't speak for everybody here, but AFAIK, tracking the stack through
> >>the memory it used, therefore using my proposed kmem controller, was an
> >>idea that good quite a bit of traction with the memcg/memory people.
> >>So here you have something that people already asked a lot for, in a
> >>shape and interface that seem to be acceptable.
> >
> >mm, maybe.  Kernel developers tend to look at code from the point of
> >view "does it work as designed", "is it clean", "is it efficient", "do
> >I understand it", etc.  We often forget to step back and really
> >consider whether or not it should be merged at all.
> >
> >I mean, unless the code is an explicit simplification, we should have
> >a very strong bias towards "don't merge".
> 
> Well, simplifications are welcome - this series itself was
> simplified beyond what I thought initially possible through the
> valuable comments
> of other people.
> 
> But of course, this adds more complexity to the kernel as a whole.
> And this is true to every single new feature we may add, now or in
> the
> future.
> 
> What I can tell you about this particular one, is that the justification
> for it doesn't come out of nowhere, but from a rather real use case that
> we support and maintain in OpenVZ and our line of products for years.

Right and we really need a solution to protect against forkbombs in LXC.
The task counter was more simple but only useful for our usecase and
defining the number of tasks as a resource was considered unnatural.

So limiting kernel stack allocations works for us. This patchset implements
this so I'm happy with it. If this is more broadly useful by limiting
resources others are interested in, that's even better. I doubt we are
interested in a solution that only concerns kernel stack allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
