Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 198C46B0082
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 19:23:01 -0400 (EDT)
Date: Sat, 20 Jun 2009 01:23:37 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
Message-ID: <20090619232336.GA2442@elf.ucw.cz>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090619145913.GA1389@ucw.cz> <1245450449.16880.10.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245450449.16880.10.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat 2009-06-20 08:27:29, Benjamin Herrenschmidt wrote:
> On Fri, 2009-06-19 at 16:59 +0200, Pavel Machek wrote:
> > 
> > Ok... GFP_KERNEL allocations normally don't fail; now they
> > will. Should we at least force access to atomic reserves in such case?
> 
> No. First, code that assumes GFP_KERNEL don't fail is stupid. Any
> allocation should always be assumed to potentially fail.

Stupid, yes. Uncommon? Not sure.

> Then, if you start failing allocations at boot time, then you aren't
> going anywhere are you ?

Exactly. So boot code should have access to all the memory, right?
Setting some aside for GFP_ATOMIC does not make sense in that context.
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
