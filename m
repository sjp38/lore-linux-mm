Subject: Re: Aggressive swapout with 2.4.1pre4+
References: <Pine.LNX.4.21.0101160138140.1556-100000@freak.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 16 Jan 2001 19:41:26 +0100
In-Reply-To: Marcelo Tosatti's message of "Tue, 16 Jan 2001 01:57:08 -0200 (BRST)"
Message-ID: <87hf2z731l.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> Hi Linus, 
> 
> Currently swap_out() scans a fixed percentage of each process RSS without
> taking into account how much memory we are out of.
> 
> The following patch changes that by making swap_out() stop when it
> successfully moved the "needed" (calculated by refill_inactive()) amount
> of pages to the swap cache. 
> 
> This should avoid the system to swap out to aggressively. 
> 
> Comments? 
> 

Hm, I didn't notice that 2.4.1-pre4 swaps out aggressively. In fact it
is very well balanced and I would vote for it as the kernel with the
best tuned VM.

Your patch slightly complicates things and I'm not sure if it's
strictly needed.

Now looking at the pre7 (not yet compiled) I see we will have really
impressive 2.4.1. reiserfs, Jens' blk, VM fixed... sheesh... what will
be left for fixing? ;)

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
