From: Peter Chubb <peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16140.51447.73888.717087@wombat.chubb.wattle.id.au>
Date: Thu, 10 Jul 2003 12:01:27 +1000
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307100059.57398.phillips@arcor.de>
References: <20030703023714.55d13934.akpm@osdl.org>
	<200307082027.13857.phillips@arcor.de>
	<20030709222426.GA24923@mail.jlokier.co.uk>
	<200307100059.57398.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Jamie Lokier <jamie@shareable.org>, Davide Libenzi <davidel@xmailserver.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "Daniel" == Daniel Phillips <phillips@arcor.de> writes:


Daniel> I like your idea of allowing normal users to set SCHED_RR, but
Daniel> automatically placing some bound on cpu usage.  It's
Daniel> guaranteed not to break any existing programs.

I suspect that what's really wanted here is not SCHED_RR but
guaranteed rate-of-forward progress.  A dynamic-window-constrained
scheduler (that guarantees not that you'll run until you sleep, but
that in any (settable) time period you'll get the opportunity to run
for at least (a smaller settable period)) is closer to what's wanted.

See http://www.cs.bu.edu/fac/richwest/dwcs.html

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
