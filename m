Date: Fri, 27 Jul 2007 07:54:07 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
Message-ID: <20070727055406.GA22581@wotan.suse.de>
References: <20070727021943.GD13939@wotan.suse.de> <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 26, 2007 at 10:29:01PM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 27 Jul 2007, Nick Piggin wrote:
> > 
> > I'd like to see if we can get the ball rolling on this again, and try to
> > get it in 2.6.24 maybe. Any comments?
> 
> I'd really want real performance numbers. I don't like the "remove it 
> because I don't like it". I want real numbers for real loads before I'm 
> really interested.

What numbers, though? I can make up benchmarks to show that ZERO_PAGE
sucks just as much. The problem I don't think is finding a situatoin that
improves without it (we have an extreme case where the Altix livelocked)
but to get confidence that nothing is going to blow up.

 
> Last time this came up, the logic behind wanting to remove the zero page 
> was all screwed up, and it was all based on totally broken premises. So I 
> really want somethign else than just "I don't like it".

I thought that last time this came up you thought it might be good to
try out in -mm initially.

 
> Sorry. In the absense of numbers (and not just some made-up branchmark: 
> something real - I can _easily_ make benchmarks that show that ZERO_PAGE 
> is wonderful), I'm not at all interested.

OK, well what numbers would you like to see? I can always try a few
things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
