Message-Id: <200010101441.QAA11537@cave.bitwizard.nl>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.10.10010091446500.1438-100000@penguin.transmeta.com>
 from Linus Torvalds at "Oct 9, 2000 02:50:51 pm"
Date: Tue, 10 Oct 2000 16:41:17 +0200 (MEST)
From: R.E.Wolff@BitWizard.nl (Rogier Wolff)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Jim Gettys <jg@pa.dec.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> Basically, the only thing _I_ think X can do is to really say "oh, please
> don't count my memory, because everything I do I do for my clients, not
> for myself". 
> 
> THAT is my argument. Basically there is nothing we can reliably account.
> 
> So we might as well fall back on just saying "X is more important than
> some random client", and have a mm niceness level. Which right now is
> obviously approximated by the IO capabilities tests etc.

FYI:

I ran my machine out of memory (without crashing by the way) this
weekend by loading a whole bunch of large images into netscape. I
noticed not being able to open more windows when I saw my swapspace
exhausted. I noticed the large netscape, and killed it. 

At that moment my X was still taking 80Mb of RAM. I manually killed it
and restarted it to get rid of that memory. 

So if Netscape can "pump" 40 extra megabytes of memory out of X, this
can be exploited. 

Now we're back to the point that a heuristic can never be right all
the time......

			Roger. 

-- 
** R.E.Wolff@BitWizard.nl ** http://www.BitWizard.nl/ ** +31-15-2137555 **
*-- BitWizard writes Linux device drivers for any device you may have! --*
*       Common sense is the collection of                                *
******  prejudices acquired by age eighteen.   -- Albert Einstein ********
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
