Date: Wed, 16 Jun 2004 13:02:08 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040616180208.GD6069@sgi.com>
References: <40D08225.6060900@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <40D08225.6060900@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-kernel@vger.kernel.org, lse-tech <lse-tech@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2004 at 07:23:49PM +0200, Manfred Spraul wrote:
> Dimitri wrote:
> 
> >In the process of testing per/cpu interrupt response times and CPU 
> >availability,
> >I've found that running cache_reap() as a timer as is done currently 
> >results
> >in some fairly long CPU holdoffs.
> >
> What is fairly long?
Into the 100's of usec.  I consider anything over 30 usec too long.
I've seen this take longer than 30usec on a small (8p) system.

> If cache_reap() is slow than the caches are too large.
> Could you limit cachep->free_limit and check if that helps? It's right 
> now scaled by num_online_cpus() - that's probably too much. It's 
> unlikely that all 500 cpus will try to refill their cpu arrays at the 
> same time. Something like a logarithmic increase should be sufficient.

I haven't tried this yet, but I'm even seeing this on 4 cpu systems.

> Do you use the default batchcount values or have you increased the values?

Default.

> I think the sgi ia64 system do not work with slab debugging, but please 
> check that debugging is off. Debug enabled is slow.

# CONFIG_DEBUG_SLAB is not set

> 
> --
>    Manfred

Dimitri Sivanich <sivanich@sgi.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
