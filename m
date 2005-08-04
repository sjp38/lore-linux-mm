Date: Thu, 4 Aug 2005 08:36:09 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <20050804150053.GA1346@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0508040834400.3258@g5.osdl.org>
References: <Pine.LNX.4.58.0508020911480.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508021809530.5659@goblin.wat.veritas.com>
 <Pine.LNX.4.58.0508021127120.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508022001420.6744@goblin.wat.veritas.com>
 <Pine.LNX.4.58.0508021244250.3341@g5.osdl.org>
 <Pine.LNX.4.61.0508022150530.10815@goblin.wat.veritas.com>
 <42F09B41.3050409@yahoo.com.au> <Pine.LNX.4.58.0508030902380.3341@g5.osdl.org>
 <20050804141457.GA1178@localhost.localdomain> <42F2266F.30008@yahoo.com.au>
 <20050804150053.GA1346@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Nyberg <alexn@telia.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Roland McGrath <roland@redhat.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>


On Thu, 4 Aug 2005, Alexander Nyberg wrote:
> 
> Hardcoding is evil so it's good it gets cleaned up anyway.

Yes.

> > parisc, cris, m68k, frv, sh64, arm26 are also broken. Would you mind
> > resending a patch that fixes them all?
> 
> Remove the hardcoding in return value checking of handle_mm_fault()

I only saw this one when I had already done it myself.

Your arm26 conversion was only partial, btw. Notice how it returns the 
fault number (with a few extensions of its own) and processes it further? 
I think I got that right.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
