Date: Tue, 10 Oct 2000 10:28:02 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <200010101441.QAA11537@cave.bitwizard.nl>
Message-ID: <Pine.LNX.4.10.10010101022430.1791-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rogier Wolff <R.E.Wolff@BitWizard.nl>
Cc: Jim Gettys <jg@pa.dec.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Tue, 10 Oct 2000, Rogier Wolff wrote:
> 
> So if Netscape can "pump" 40 extra megabytes of memory out of X, this
> can be exploited. 
> 
> Now we're back to the point that a heuristic can never be right all
> the time......

I agree. In fact, we never left that.

Nothing is perfect.

In fact, a lot of engineering is _recognizing_ that you can never achieve
"perfect", and you're much better off not even trying - and having a
simple system that is "good enough".

This is the old adage of "perfect is the enemy of good" - trying too hard
is actually _detrimental_ in 99% of all cases. We should have simple
heuristics that work most of the time, instead of trying to cajole a
complex system like X to help us do some complicated resource management
system.

Complexity will just result in the OOM killer failing in surprising ways.

A simple heuristic will mean that the OOM killer will still fail, but at
least it won't be be in subtle and surprising ways.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
