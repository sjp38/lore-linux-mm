Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1223451433.1378.29.camel@lappy.programming.kicks-ass.net>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <1223441190.13453.459.camel@calx>
	 <200810081554.33651.nickpiggin@yahoo.com.au>
	 <200810081611.30897.nickpiggin@yahoo.com.au>
	 <1223442947.13453.462.camel@calx>
	 <1223448220.1378.13.camel@lappy.programming.kicks-ass.net>
	 <84144f020810080025o348ae189vab83f1620b2e9560@mail.gmail.com>
	 <1223451433.1378.29.camel@lappy.programming.kicks-ass.net>
Date: Wed, 08 Oct 2008 10:39:52 +0300
Message-Id: <1223451592.31490.11.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-08 at 09:37 +0200, Peter Zijlstra wrote:
> On Wed, 2008-10-08 at 10:25 +0300, Pekka Enberg wrote:
> > Hi Peter,
> > 
> > On Wed, 2008-10-08 at 00:15 -0500, Matt Mackall wrote:
> > >> Damnit, how many ways can we get confused by these little details? I'll
> > >> spin a final version and run it against the test harness shortly.
> > 
> > On Wed, Oct 8, 2008 at 9:43 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > So I'll wait with testing for the next version?
> > 
> > AFAICT, this should be fine:
> > 
> > http://lkml.org/lkml/2008/10/7/436
> > 
> > You need to revert the patch Linus already committed before applying
> > that though.
> 
> Or not have pulled it yet ;-)
> 
> Anyway, that patch seems to be good on 4 boots.

Thanks for testing, Peter!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
