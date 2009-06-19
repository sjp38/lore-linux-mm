Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BD4D56B004D
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 10:57:32 -0400 (EDT)
Date: Fri, 19 Jun 2009 16:59:13 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
Message-ID: <20090619145913.GA1389@ucw.cz>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi!

> 
> As explained by Benjamin Herrenschmidt:
> 
>   Oh and btw, your patch alone doesn't fix powerpc, because it's missing
>   a whole bunch of GFP_KERNEL's in the arch code... You would have to
>   grep the entire kernel for things that check slab_is_available() and
>   even then you'll be missing some.
> 
>   For example, slab_is_available() didn't always exist, and so in the
>   early days on powerpc, we used a mem_init_done global that is set form
>   mem_init() (not perfect but works in practice). And we still have code
>   using that to do the test.
> 
> Therefore, ignore __GFP_WAIT in the slab allocators if we're booting or
> suspending.

Ok... GFP_KERNEL allocations normally don't fail; now they
will. Should we at least force access to atomic reserves in such case?
      	     	   	       	      	 		    	 Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
