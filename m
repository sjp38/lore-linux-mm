Date: Wed, 22 Dec 2004 11:38:00 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
Message-ID: <20041222103800.GC15894@wotan.suse.de>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain> <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org> <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de> <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org> <20041221201927.GD15643@wotan.suse.de> <41C8B678.40007@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41C8B678.40007@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> I understand you'd be frustrated if 4level wasn't in 2.6.11, but as I
> said, I don't think the choice of pud over pml4 would necessarily cause
> such a delay.

It would require a longer testing cycle in -mm* again, at least
several weeks and probably some support from the arch maintainers again.
That may push it too late.

> 
> As far as I understand, you don't have any problem with the 'pud'
> implementation in principle?

I don't have anything directly against the name (although I'm still not sure
what it actually stands for) or the location (top level or mid level), 
but I'm worried about the delay of redoing the testing cycle completely.

I don't see any technical advantages of your approach over mine, eventually
all the work has to be done anyways, so in the end it boils down
what names are prefered. However I suspect you could use your time
better, Nick, than redoing things that have been already done ;-) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
