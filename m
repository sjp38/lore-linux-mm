Date: Thu, 26 Jul 2007 22:29:01 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
In-Reply-To: <20070727021943.GD13939@wotan.suse.de>
Message-ID: <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org>
References: <20070727021943.GD13939@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 27 Jul 2007, Nick Piggin wrote:
> 
> I'd like to see if we can get the ball rolling on this again, and try to
> get it in 2.6.24 maybe. Any comments?

I'd really want real performance numbers. I don't like the "remove it 
because I don't like it". I want real numbers for real loads before I'm 
really interested.

Last time this came up, the logic behind wanting to remove the zero page 
was all screwed up, and it was all based on totally broken premises. So I 
really want somethign else than just "I don't like it".

Sorry. In the absense of numbers (and not just some made-up branchmark: 
something real - I can _easily_ make benchmarks that show that ZERO_PAGE 
is wonderful), I'm not at all interested.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
