From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001140622.WAA90687@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 22:22:25 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10001140339450.7241-100000@chiara.csoma.elte.hu> from "Ingo Molnar" at Jan 14, 2000 03:46:55 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On Thu, 13 Jan 2000, Kanoj Sarcar wrote:
> 
> > But as Linus points out, recovering from that is not that costly
> > (the page will be in the swapcache mostly, its just the cost of 
> > the page fault).
> 
> note that i was not worried a bit about swapping performance. Swapping is
> slow, conceptually. I'm worried about the current pte_young() logic and
> the fact that pages can evade swap_out() completely just by being used
> (read access) at least once per scan. This not only makes the system slow
> (which we dont care), but also unusable in certain cases. This is an
> existing problem, Alan got 2.2 reports of frequent GFP_DMA failures on 1GB
> boxes. (weird combination of hardware i agree) The zone rewrite already
> made the situation much better by ordering zones, and i'll be completely
> happy if we make the pte_young() branch in try_to_swap_out() at least
> conditional on memory pressure :-)
> 
> -- mingo
>

Might there be another reason for this possibly? As I point out in
the zone balance doc, if there are way too many non-dma pages, then
even when the dma zone is near empty, it will not be balanced because
the total number of free pages is above the watermark.

Alan did acknowledge this as a theoretical case, although he mentioned
that it was not happening in real life.

Kanoj
 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
