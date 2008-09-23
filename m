Date: Tue, 23 Sep 2008 11:56:55 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unified tracing buffer
In-Reply-To: <48D93665.8030200@linux-foundation.org>
Message-ID: <alpine.LFD.1.10.0809231154420.3265@nehalem.linux-foundation.org>
References: <33307c790809191433w246c0283l55a57c196664ce77@mail.gmail.com> <1221869279.8359.31.camel@lappy.programming.kicks-ass.net> <20080922140740.GB5279@in.ibm.com> <1222094724.16700.11.camel@lappy.programming.kicks-ass.net> <1222147545.6875.135.camel@charm-linux>
 <1222162270.16700.57.camel@lappy.programming.kicks-ass.net> <20080923181313.GA4947@Krystal> <48D93665.8030200@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mathieu Desnoyers <compudj@krystal.dyndns.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tom Zanussi <zanussi@comcast.net>, prasad@linux.vnet.ibm.com, Martin Bligh <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, od@novell.com, "Frank Ch. Eigler" <fche@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, David Wilder <dwilder@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 23 Sep 2008, Christoph Lameter wrote:

> Mathieu Desnoyers wrote:
> > 
> > I think we should instead try to figure out what is currently missing in
> > the kernel vmap mechanism (probably the ability to vmap from large 4MB
> > pages after boot), and fix _that_ instead (if possible), which would not
> > only benefit to tracing, but also to module support.

No. Don't go there. Piece of absolute shit.

The problem with VMAP is that it's _limited_. We don't have reasonable 
virtual address space holes for x86-32.

The other is that physically contiguos buffers are hard to come by. 
Certainly not an acceptable solution.

The third is that if you have multiple buffers, you need to look them up 
in software anyway, so the whole notion of mis-using the TLB to avoid a 
software lookup is TOTAL CRAP.

Don't do virtual mapping. IT IS BROKEN. IT IS A TOTAL AND UTTER PIECE OF 
SHIT.

I will absolutely not take any general-purpse tracing code if I'm aware of 
it mis-using the TLB to play games.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
