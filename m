Date: Thu, 19 Jan 2006 21:02:26 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/3] mm: PageActive no testset
Message-ID: <20060119200226.GA1756@wotan.suse.de>
References: <20060118024106.10241.69438.sendpatchset@linux.site> <20060118024139.10241.73020.sendpatchset@linux.site> <20060118141346.GB7048@dmt.cnet> <20060119145008.GA20126@wotan.suse.de> <20060119165222.GC4418@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060119165222.GC4418@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@osdl.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 19, 2006 at 02:52:22PM -0200, Marcelo Tosatti wrote:
> On Thu, Jan 19, 2006 at 03:50:08PM +0100, Nick Piggin wrote:
> 
> > The test-set / test-clear operations also kind of imply that it is
> > being used for locking or without other synchronisation (usually).
> 
> Non-atomic versions such as __ClearPageLRU()/__ClearPageActive() are 
> not usable, though.
> 

Correct. Although I was able to use them in a couple of other places
in a subsequent patch in the series. I trust you don't see a problem
with those usages?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
