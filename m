Date: Sat, 6 Nov 2004 02:50:51 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
Message-ID: <20041106015051.GU8229@dualathlon.random>
References: <20041105200118.GA20321@logos.cnet> <200411051532.51150.jbarnes@sgi.com> <20041106012018.GT8229@dualathlon.random> <418C2861.6030501@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418C2861.6030501@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2004 at 12:26:57PM +1100, Nick Piggin wrote:
> need to be performed and have no failure path. For example __GFP_REPEAT.

all allocations should have a failure path to avoid deadlocks. But in
the meantime __GFP_REPEAT is at least localizing the problematic places ;)

> I think maybe __GFP_REPEAT allocations at least should be able to
> cause an OOM. Not sure though.

probably it should because this is also a case where no fail path exists.

My point was only that when a fail path exists, it's more reliable not
to invoke the oom killer and let userspace handle the failure.

> Also, I think it would do the wrong thing on NUMA machines because
> that has a per-node kswapd.

yep.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
