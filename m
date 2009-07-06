Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 62DD66B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 02:57:06 -0400 (EDT)
Date: Mon, 6 Jul 2009 09:31:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: handle_mm_fault() calling convention cleanup..
Message-ID: <20090706073148.GJ2714@wotan.suse.de>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain> <1246664107.7551.11.camel@pasglop> <alpine.LFD.2.01.0907040937040.3210@localhost.localdomain> <1246741718.7551.22.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246741718.7551.22.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 07:08:38AM +1000, Benjamin Herrenschmidt wrote:
> On Sat, 2009-07-04 at 09:44 -0700, Linus Torvalds wrote:
> 
> > Just a tiny word of warning: right now, the conversion I did pretty much 
> > depended on the fact that even if I missed a spot, it wouldn't actually 
> > make any difference. If somebody used "flags" as a binary value (ie like 
> > the old "write_access" kind of semantics), things would still all work, 
> > because it was still a "zero-vs-nonzero" issue wrt writes.
> 
>  .../...
> 
> Right. Oh well.. we'll see when I get to it. I have a few higher
> priority things on my pile at the moment.

I have no problems with that. I'd always intended to have flags
go further up the call chain like Linus did (since we'd discussed
perhaps making faults interruptible and requiring an extra flag
to distinguish get_user_pages callers that were not interruptible).

So yes adding more flags to improve code or make things simpler
is fine by me :)

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
