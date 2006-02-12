Date: Sat, 11 Feb 2006 20:41:10 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Get rid of scan_control
In-Reply-To: <43EEB4DA.6030501@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
 <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org>
 <20060211014649.7cb3b9e2.akpm@osdl.org> <43EEAC93.3000803@yahoo.com.au>
 <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
 <43EEB4DA.6030501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Feb 2006, Nick Piggin wrote:

> > Could we at least pass the number of pages reclaimed back as the return
> > value of the functions? I believe most of the savings that Andrew saw was
> > due to the number of reclaimed pages being processed directly in registers.
> 
> What savings are you interested in, exactly? Your initial patch
> would definitely have slowed down page reclaim on big systems
> due to the read_page_state...

The patch that put the whole calculation into a separate block that 
is only executed for the swap case would have taken care of that.


> I think most of the cost apart from locking (because that will
> depend on contention) is hitting random cachelines of struct pages
> then hitting random radix tree cachelines to remove them. Not
> much you can do about that.
> 
> That said I'm never against microoptimisations provided they
> weigh in on the right side of the (subjective) complexity /
> improvement ratio.

Its a bit strange if you call a function and then access a structure 
member to get the result. Locating parameter in a structure makes it
impossible to see what is passed to a function when it is 
called.

It is also something that will make it difficult for compilers to do
a good job. Flow control is easier to optimize for a local variable
than for a pointer into a struct that may have been modified elsewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
