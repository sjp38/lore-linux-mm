Date: Fri, 27 Jul 2007 08:21:54 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
In-Reply-To: <20070727055406.GA22581@wotan.suse.de>
Message-ID: <alpine.LFD.0.999.0707270811320.3442@woody.linux-foundation.org>
References: <20070727021943.GD13939@wotan.suse.de>
 <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org>
 <20070727055406.GA22581@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 27 Jul 2007, Nick Piggin wrote:
> 
> What numbers, though? I can make up benchmarks to show that ZERO_PAGE
> sucks just as much. The problem I don't think is finding a situatoin that
> improves without it (we have an extreme case where the Altix livelocked)
> but to get confidence that nothing is going to blow up.

Well, the Altix livelock, for example, would seem to be simply because 
setting up the ZERO_PAGE is so much *faster* that it makes it easier to 
create humongous processes etc so quickly that you don't have time for 
them to be interrupted at setup time.

Is that the "fault" of ZERO_PAGE? Sure. But still..

> > Last time this came up, the logic behind wanting to remove the zero page 
> > was all screwed up, and it was all based on totally broken premises. So I 
> > really want somethign else than just "I don't like it".
> 
> I thought that last time this came up you thought it might be good to
> try out in -mm initially.

I was more thinking about all the churn that we got due to the reference 
counting stuff. That was pretty painful, and removing ZERO_PAGE wasn't the 
right answer then either.

> OK, well what numbers would you like to see? I can always try a few
> things.

Kernel builds with/without this? If the page faults really are that big a 
deal, this should all be visible.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
