Subject: Re: [rfc] data race in page table setup/walking?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <Pine.LNX.4.64.0804291333540.22025@blonde.site>
References: <20080429050054.GC21795@wotan.suse.de>
	 <Pine.LNX.4.64.0804291333540.22025@blonde.site>
Content-Type: text/plain
Date: Wed, 30 Apr 2008 07:37:39 +1000
Message-Id: <1209505059.18023.193.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-29 at 13:36 +0100, Hugh Dickins wrote:
> 
> Ugh.  It's just so irritating to introduce these blockages against
> such a remote possibility (but there again, that's what so much of
> kernel code has to be about).  Is there any other way of handling it?

Not that much overhead... I think smp_read_barrier_depends() is a nop on
most archs no ? The data dependency between all the pointers takes care
of ordering in many cases. So it boils down to smp_wmb's when setting
which is not that expensive.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
