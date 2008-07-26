Date: Sat, 26 Jul 2008 15:14:50 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726131450.GC21820@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random> <20080726030810.GA18896@wotan.suse.de> <20080726113813.GD21150@duo.random> <20080726122826.GA17958@wotan.suse.de> <20080726130202.GA9598@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080726130202.GA9598@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 26, 2008 at 03:02:02PM +0200, Andrea Arcangeli wrote:
> On Sat, Jul 26, 2008 at 02:28:26PM +0200, Nick Piggin wrote:
> 
> > If I had seen even a single number to show the more complex scheme
> 
> Please post a patch that actually works then we'll re-evaluate what is
> the best tradeoff ;).
> 
> In the meantime please merge -mm patches into Linus's tree, this is
> taking forever and if the changes are so small to go Nick's way and
> his future "actually working" patch remains so small, it can be
> applied incrementally without any problem IMHO, infact it is presented
> as an incremental patch in the first place.

BTW. has anyone else actually looked at mmu notifiers or have an
opinion on this? It might be helpful for me to get someone else's
perspective.

I hate to cause conflict but obviously I think I have legitimate
concerns so I have to raise them...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
