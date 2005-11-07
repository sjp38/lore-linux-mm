Date: Mon, 7 Nov 2005 09:00:42 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051107080042.GA29961@elte.hu>
References: <20051104010021.4180A184531@thermo.lanl.gov> <Pine.LNX.4.64.0511032105110.27915@g5.osdl.org> <20051103221037.33ae0f53.pj@sgi.com> <20051104063820.GA19505@elte.hu> <Pine.LNX.4.64.0511040725090.27915@g5.osdl.org> <796B585C-CB1C-4EBA-9EF4-C11996BC9C8B@mac.com> <Pine.LNX.4.64.0511060756010.3316@g5.osdl.org> <Pine.LNX.4.64.0511060848010.3316@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0511060848010.3316@g5.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Kyle Moffett <mrmacman_g4@mac.com>, Paul Jackson <pj@sgi.com>, andy@thermo.lanl.gov, mbligh@mbligh.org, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Linus Torvalds <torvalds@osdl.org> wrote:

> > You could do it today, although at a pretty high cost. And you'd have to 
> > forget about supporting any hardware that really wants contiguous memory 
> > for DMA (sound cards etc). It just isn't worth it.
> 
> Btw, in case it wasn't clear: the cost of these kinds of things in the 
> kernel is usually not so much the actual "lookup" (whether with hw 
> assist or with another field in the "struct page").
[...]

> So remappable kernels are certainly doable, they just have more 
> fundamental problems than remappable user space _ever_ has. Both from 
> a performance and from a complexity angle.

furthermore, it doesnt bring us any closer to removable RAM. The problem 
is still unsolvable (due to the 'how to do you find live pointers to fix 
up' issue), even if the full kernel VM is 'mapped' at 4K granularity.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
