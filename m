From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001132150.NAA28314@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 13:50:53 -0800 (PST)
In-Reply-To: <E128s14-0008DB-00@the-village.bc.nu> from "Alan Cox" at Jan 13, 2000 09:42:49 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> > doc. If you have a large number of free regular pages, and the dma
> > zone is completely exhausted, the 2.2 decision of balacing the dma
> > zone might never fetch an "yes" answer, because it is based on total
> > number of free pages, not also the per zone free pages. Right? Things 
> > will get worse the more non-dma pages there are.
> 
> We might not make good choices to free ISA DMA pages, you are correct yes

And given a huge enough HIGHMEM zone, we might not make good choices to free
regular memory too, right?

My patch would fix this problem. I am going to make the patch bigger to
fix kswapd too, then put it out in the next few hours.

Kanoj

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
