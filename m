Date: Wed, 7 May 2008 16:38:51 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
In-Reply-To: <20080507223738.GF8276@duo.random>
Message-ID: <alpine.LFD.1.10.0805071633010.3024@woody.linux-foundation.org>
References: <patchbomb.1210170950@duo.random> <e20917dcc8284b6a07cf.1210170951@duo.random> <20080507130528.adfd154c.akpm@linux-foundation.org> <alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org> <20080507215840.GB8276@duo.random>
 <alpine.LFD.1.10.0805071509270.3024@woody.linux-foundation.org> <20080507222758.GD8276@duo.random> <20080507223738.GF8276@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>


On Thu, 8 May 2008, Andrea Arcangeli wrote:
> 
> At least for mmu-notifier-core given I obviously am the original
> author of that code, I hope the From: of the email was enough even if
> an additional From: andrea was missing in the body.

Ok, this whole series of patches have just been such a disaster that I'm 
(a) disgusted that _anybody_ sent an Acked-by: for any of it, and (b) that 
I'm still looking at it at all, but I am.

And quite frankly, the more I look, and the more answers from you I get, 
the less I like it. And I didn't like it that much to start with, as you 
may have noticed.

You say that "At least for mmu-notifier-core given I obviously am the 
original author of that code", but that is not at all obvious either. One 
of the reasons I stated that authorship seems to have been thrown away is 
very much exactly in that first mmu-notifier-core patch:

	+ *  linux/mm/mmu_notifier.c
	+ *
	+ *  Copyright (C) 2008  Qumranet, Inc.
	+ *  Copyright (C) 2008  SGI
	+ *             Christoph Lameter <clameter@sgi.com>

so I would very strongly dispute that it's "obvious" that you are the 
original author of the code there.

So there was a reason why I said that I thought authorship had been lost 
somewhere along the way.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
