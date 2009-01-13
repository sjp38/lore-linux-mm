Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D4CC36B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 06:50:43 -0500 (EST)
Date: Tue, 13 Jan 2009 12:50:29 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Xen-devel] Re: OOPS and panic on 2.6.29-rc1 on xen-x86
Message-ID: <20090113115029.GA12055@elte.hu>
References: <20090112172613.GA8746@shion.is.fushizen.net> <3e8340490901122054q4af2b4cm3303c361477defc0@mail.gmail.com> <1231838731.4823.2.camel@leto.intern.saout.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1231838731.4823.2.camel@leto.intern.saout.de>
Sender: owner-linux-mm@kvack.org
To: Christophe Saout <christophe@saout.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bryan Donlan <bdonlan@gmail.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, xen-devel@lists.xensource.com
List-ID: <linux-mm.kvack.org>


* Christophe Saout <christophe@saout.de> wrote:

> Hi Bryan,
> 
> > I've bisected the bug in question, and the faulty commit appears to be:
> > commit e97a630eb0f5b8b380fd67504de6cedebb489003
> > Author: Nick Piggin <npiggin@suse.de>
> > Date:   Tue Jan 6 14:39:19 2009 -0800
> > 
> >     mm: vmalloc use mutex for purge
> > 
> >     The vmalloc purge lock can be a mutex so we can sleep while a purge is
> >     going on (purge involves a global kernel TLB invalidate, so it can take
> >     quite a while).
> > 
> >     Signed-off-by: Nick Piggin <npiggin@suse.de>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> > 
> > The bug is easily reproducable by a kernel build on -j4 - it will
> > generally OOPS and panic before the build completes.
> > Also, I've tested it with ext3, and it still occurs, so it seems
> > unrelated to btrfs at least :)
> 
> Nice!
> 
> Reverting this also fixes the BUG() I was seeing when testing the Dom0
> patches on 2.6.29-rc1+tip.  It just ran stable for an hour compiling
> gimp and playing music on my notebook (and then I had to leave).

okay - i've reverted it in tip/master so that testing can continue - but 
the upstream fix (or revert) should be done via the MM folks.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
