From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001132148.NAA32035@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 13:48:29 -0800 (PST)
In-Reply-To: <Pine.LNX.3.96.1000113161742.1295B-100000@kanga.kvack.org> from "Benjamin C.R. LaHaise" at Jan 13, 2000 04:34:15 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On Thu, 13 Jan 2000, Kanoj Sarcar wrote:
> 
> > No, I am referring to a different problem that I mentioned in the
> > doc. If you have a large number of free regular pages, and the dma
> > zone is completely exhausted, the 2.2 decision of balacing the dma
> > zone might never fetch an "yes" answer, because it is based on total
> > number of free pages, not also the per zone free pages. Right? Things 
> > will get worse the more non-dma pages there are.
> 
> Kanoj, you're wrong.  2.2 works quite well because of the fact that the
> low memory mark will tend to consist almost entirely of DMAable pages.
> The only allocations that regularly eat into them on a loaded machine are
> interrupts, which tend to be short term allocations anyways.  But as soon
> as DMAable memory is freed, it tends not to be allocated until interrupts
> consume all memory again.

Okay, you are telling me what _mostly_ happens, the problem I have pointed
out is one that can _probably_ happen under the right conditions of
temperature and pressure. Its a good idea to design against boundary 
conditions, and then improve the design ...

> 
> > Oh, okay I see. There is nothing about the dma zone then, you could 
> > make the balancing more aggressive for the other zones too. Basically,
> > these kinds of tuning should be controlled by sysctls (instead of 
> > >>7, do >> N), so while most sites will prefer to run with the least
> > aggressive balancing, there may be sites with drivers that need 
> > many high-order pages, they would be willing to sacrifice some 
> > performance by doing more aggressive balancing. Comes under finetuning 
> > in the doc.
> 
> Whoa, hold on here.  Last time we tried to do more aggresive balancing, it
> was a complete and total disaster that resulted in completely random swap
> storms, resulting in spectacularly unusable systems on the lower end
> (iirc 64mb was around the breakeven point).  Before harder limits are
> placed on memory types and orders, the behaviour of both kswapd and the
> allocator need to be tweaked.  so put in the mechanism, but don't start
> enforcing it too aggresively.

Absolutely. I am _not_ suggesting doing anything much different than 
in 2.2. All I am saying is that we can provide sysctls (with their 
default values to mimic 2.2 behavior), then individual developers
can tweak those and do performance experiments. 

Kanoj

> 
> 		-ben
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
