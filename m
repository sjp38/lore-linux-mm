Date: Mon, 26 Jul 2004 21:01:34 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Locking optimization for cache_reap
Message-ID: <20040727020134.GA23967@sgi.com>
References: <20040723190555.GB16956@sgi.com> <20040726180104.62c480c6.akpm@osdl.org> <20040727014757.GA23937@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040727014757.GA23937@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2004 at 08:47:57PM -0500, Dimitri Sivanich wrote:
> 
> While you've got irq's disabled, drain_array() (the function my patch removes)
> acquires the cache spin_lock, then releases it.  Cache_reap then acquires
> it again (with irq's having been off the entire time).  My testing has found
> that simply acquiring the lock once while irq's are off results in fewer
> excessively long latencies.
> 
> Results probably vary somewhat depending on the circumstance.

Of course, I should add that all of this is from the perspective of the
cpu doing the cache_reap.  If others feel that this may add too much
latency to other paths, other solutions may be in order.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
