Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 4721B6B016E
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 05:03:17 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9621798pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:03:15 -0700 (PDT)
Date: Tue, 26 Jun 2012 02:03:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 05/11] Add a __GFP_KMEMCG flag
In-Reply-To: <4FE95FF0.3000300@parallels.com>
Message-ID: <alpine.DEB.2.00.1206260202190.16020@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252123230.26640@chino.kir.corp.google.com> <4FE95FF0.3000300@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, 26 Jun 2012, Glauber Costa wrote:

> > > >This flag is used to indicate to the callees that this allocation will be
> > > >serviced to the kernel. It is not supposed to be passed by the callers
> > > >of kmem_cache_alloc, but rather by the cache core itself.
> > > >
> > Not sure what "serviced to the kernel" means, does this mean that the
> > memory will not be accounted for to the root memcg?
> > 
> In this context, it means that is a kernel allocation, not a userspace one
> (but in process context, of course), *and* it is to be accounted a
> specific memcg.
> 

Ah, that makes sense.  I think it would help if this was included in the 
changelog as well as a specifying that it is accounted to current's memcg 
at the time of the allocation in a comment in the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
