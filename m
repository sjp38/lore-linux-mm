Date: Wed, 7 May 2008 13:30:39 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
In-Reply-To: <20080507130528.adfd154c.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org>
References: <patchbomb.1210170950@duo.random> <e20917dcc8284b6a07cf.1210170951@duo.random> <20080507130528.adfd154c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>


On Wed, 7 May 2008, Andrew Morton wrote:
> 
> The patch looks OK to me.

As far as I can tell, authorship has been destroyed by at least two of the 
patches (ie Christoph seems to be the author, but Andrea seems to have 
dropped that fact).

> The proposal is that we sneak this into 2.6.26.  Are there any
> sufficiently-serious objections to this?

Yeah, too late and no upside.

That "locking" code is also too ugly to live, at least without some 
serious arguments for why it has to be done that way. Sorting the locks? 
In a vmalloc'ed area?  And calling this something innocuous like 
"mm_lock()"? Hell no. 

That code needs some serious re-thinking.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
