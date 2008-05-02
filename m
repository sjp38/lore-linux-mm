Date: Thu, 1 May 2008 18:33:45 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] data race in page table setup/walking?
In-Reply-To: <20080502012006.GD30768@wotan.suse.de>
Message-ID: <alpine.LFD.1.10.0805011832010.5994@woody.linux-foundation.org>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site> <20080430060340.GE27652@wotan.suse.de> <alpine.LFD.1.10.0804300848390.2997@woody.linux-foundation.org> <20080501002955.GA11312@wotan.suse.de>
 <alpine.LFD.1.10.0804302020050.5994@woody.linux-foundation.org> <20080502012006.GD30768@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>


On Fri, 2 May 2008, Nick Piggin wrote:
> 
> I guess it is possible. But at least in the case of write address, you'd
> have to wait for later stores anyway in order to do the alias detection,
> which might be the most common case.

No, just the *address*. The data for the second store may not be ready, 
but the address may have been resolved (and checked that it doesn't fault 
etc) and the previous store may complete.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
