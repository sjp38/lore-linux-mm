Date: Wed, 7 May 2008 15:11:10 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
In-Reply-To: <20080507215840.GB8276@duo.random>
Message-ID: <alpine.LFD.1.10.0805071509270.3024@woody.linux-foundation.org>
References: <patchbomb.1210170950@duo.random> <e20917dcc8284b6a07cf.1210170951@duo.random> <20080507130528.adfd154c.akpm@linux-foundation.org> <alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org> <20080507215840.GB8276@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>


On Wed, 7 May 2008, Andrea Arcangeli wrote:

> > As far as I can tell, authorship has been destroyed by at least two of the 
> > patches (ie Christoph seems to be the author, but Andrea seems to have 
> > dropped that fact).
> 
> I can't follow this, please be more specific.

The patches were sent to lkml without *any* indication that you weren't 
actually the author.

So if Andrew had merged them, they would have been merged as yours.

> > That "locking" code is also too ugly to live, at least without some 
> > serious arguments for why it has to be done that way. Sorting the locks? 
> > In a vmalloc'ed area?  And calling this something innocuous like 
> > "mm_lock()"? Hell no. 
> 
> That's only invoked in mmu_notifier_register, mm_lock is explicitly
> documented as heavyweight function.

Is that an excuse for UTTER AND TOTAL CRAP?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
