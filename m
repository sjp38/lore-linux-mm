Subject: Re: [PATCH 12/30] mm: memory reserve management
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1217241541.6331.42.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>  <1217241541.6331.42.camel@twins>
Content-Type: text/plain; charset=utf-8
Date: Mon, 28 Jul 2008 11:59:34 -0500
Message-Id: <1217264374.15724.42.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 12:39 +0200, Peter Zijlstra wrote:
> Also, you might have noticed, I still need to do everything SLOB. The
> last time I rewrote all this code I was still hoping Linux would 'soon'
> have a single slab allocator, but evidently we're still going with 3 for
> now.. :-/
>
> So I guess I can no longer hide behind that and will have to bite the
> bullet and write the SLOB bits..

i>>?I haven't seen the rest of this thread, but I presume this is part of
your OOM-avoidance for network I/O framework?

SLOB can be pretty easily expanded to handle a notion of independent
allocation arenas as there are only a couple global variables to switch
between. i>>?kfree will also return allocations to the page list (and
therefore arena) from whence they came. That may make it pretty simple
to create and prepopulate reserve pools.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
