Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 13AC86B006E
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:38:58 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2223963dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:38:57 -0700 (PDT)
Date: Wed, 27 Jun 2012 12:38:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem
 controller for memcg: stripped down version
In-Reply-To: <4FEAD260.4000603@parallels.com>
Message-ID: <alpine.DEB.2.00.1206271233080.22162@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <20120625162745.eabe4f03.akpm@linux-foundation.org> <4FE9621D.2050002@parallels.com> <20120626145539.eeeab909.akpm@linux-foundation.org> <4FEAD260.4000603@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <lennart@poettering.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kir Kolyshkin <kir@parallels.com>

On Wed, 27 Jun 2012, Glauber Costa wrote:

> fork bombs are a way bad behaved processes interfere with the rest of
> the system. In here, I propose fork bomb stopping as a natural
> consequence of the fact that the amount of kernel memory can be limited,
> and each process uses 1 or 2 pages for the stack, that are freed when the
> process goes away.
> 

The obvious disadvantage is that if you use the full-featured kmem 
controller that builds upon this patchset, then you're limiting the about 
of all kmem, not just the stack that this particular set limits.  I hope 
you're not proposing it to go upstream before full support for the kmem 
controller is added so that users who use it only to protect again 
forkbombs soon realize that's no longer possible if your applications do 
any substantial slab allocations, particularly anything that does a lot of 
I/O.

In other words, if I want to run netperf in a memcg with the full-featured 
kmem controller enabled, then its kmem limit must be high enough so that 
it doesn't degrade performance that any limitation on stack allocations 
would be too high to effectively stop forkbombs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
