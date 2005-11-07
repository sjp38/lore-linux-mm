Date: Mon, 7 Nov 2005 13:20:09 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051107122009.GD3609@elte.hu>
References: <20051104010021.4180A184531@thermo.lanl.gov> <Pine.LNX.4.64.0511032105110.27915@g5.osdl.org> <20051103221037.33ae0f53.pj@sgi.com> <20051104063820.GA19505@elte.hu> <Pine.LNX.4.64.0511040725090.27915@g5.osdl.org> <796B585C-CB1C-4EBA-9EF4-C11996BC9C8B@mac.com> <Pine.LNX.4.64.0511060756010.3316@g5.osdl.org> <Pine.LNX.4.64.0511060848010.3316@g5.osdl.org> <20051107080042.GA29961@elte.hu> <1131361258.5976.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131361258.5976.53.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Kyle Moffett <mrmacman_g4@mac.com>, Paul Jackson <pj@sgi.com>, andy@thermo.lanl.gov, mbligh@mbligh.org, Andrew Morton <akpm@osdl.org>, arjan@infradead.org, arjanv@infradead.org, kravetz@us.ibm.com, lhms <lhms-devel@lists.sourceforge.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

* Dave Hansen <haveblue@us.ibm.com> wrote:

> On Mon, 2005-11-07 at 09:00 +0100, Ingo Molnar wrote:
> > * Linus Torvalds <torvalds@osdl.org> wrote:
> > > So remappable kernels are certainly doable, they just have more 
> > > fundamental problems than remappable user space _ever_ has. Both from 
> > > a performance and from a complexity angle.
> > 
> > furthermore, it doesnt bring us any closer to removable RAM. The problem 
> > is still unsolvable (due to the 'how to do you find live pointers to fix 
> > up' issue), even if the full kernel VM is 'mapped' at 4K granularity.
> 
> I'm not sure I understand.  If you're remapping, why do you have to 
> find live and fix up live pointers?  Are you talking about things that 
> require fixed _physical_ addresses?

RAM removal, not RAM replacement. I explained all the variants in an 
earlier email in this thread. "extending RAM" is relatively easy.  
"replacing RAM" while doable, is probably undesirable. "removing RAM" 
impossible.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
