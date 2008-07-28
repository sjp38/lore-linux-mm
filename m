Received: from edge04.upc.biz ([192.168.13.239]) by viefep17-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080728171357.GQTF24448.viefep17-int.chello.at@edge04.upc.biz>
          for <linux-mm@kvack.org>; Mon, 28 Jul 2008 19:13:57 +0200
Subject: Re: [PATCH 12/30] mm: memory reserve management
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1217264374.15724.42.camel@calx>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>  <1217241541.6331.42.camel@twins>
	 <1217264374.15724.42.camel@calx>
Content-Type: text/plain; charset=utf-8
Date: Mon, 28 Jul 2008 19:13:46 +0200
Message-Id: <1217265226.18049.24.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 11:59 -0500, Matt Mackall wrote:
> On Mon, 2008-07-28 at 12:39 +0200, Peter Zijlstra wrote:
> > Also, you might have noticed, I still need to do everything SLOB. The
> > last time I rewrote all this code I was still hoping Linux would 'soon'
> > have a single slab allocator, but evidently we're still going with 3 for
> > now.. :-/
> >
> > So I guess I can no longer hide behind that and will have to bite the
> > bullet and write the SLOB bits..
> 
> i>>?I haven't seen the rest of this thread, but I presume this is part of
> your OOM-avoidance for network I/O framework?

Yes indeed.

> SLOB can be pretty easily expanded to handle a notion of independent
> allocation arenas as there are only a couple global variables to switch
> between. i>>?kfree will also return allocations to the page list (and
> therefore arena) from whence they came. That may make it pretty simple
> to create and prepopulate reserve pools.

Right - currently we let all the reserves sit on the free page list. The
advantage there is that it also helps the anti-frag stuff, due to having
larger free lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
