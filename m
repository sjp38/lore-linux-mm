Date: Sat, 11 Feb 2006 22:25:16 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Get rid of scan_control
In-Reply-To: <43EEC136.5060609@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0602112221530.26166@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
 <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org>
 <20060211014649.7cb3b9e2.akpm@osdl.org> <43EEAC93.3000803@yahoo.com.au>
 <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
 <43EEB4DA.6030501@yahoo.com.au> <Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
 <43EEC136.5060609@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Feb 2006, Nick Piggin wrote:

> > Its a bit strange if you call a function and then access a structure member
> > to get the result. Locating parameter in a structure makes it
> > impossible to see what is passed to a function when it is called.
> Sometimes there is more than one result though :\

Well there are basically only two: The number of scanned and the number of 
reclaimed pages. My patch passed the number of scanned as a reference 
parameter.

> > It is also something that will make it difficult for compilers to do
> > a good job. Flow control is easier to optimize for a local variable
> > than for a pointer into a struct that may have been modified elsewhere.
> There are downsides to it. I was basically on the fence with its
> removal from mainline, because the complexity of parameters going
> to/from functions make the improvement borderline.

Yes, that may weigh in on the other side of this.

> But I would have kept it for my internal work, and given Marcelo
> is also interested in it I guess it could stay for now (unless
> you trump that with some performance numbers I guess).

The compiler optimization are mostly interesting for platforms that are 
short on memory or need highly efficient code. So sorry, no performance 
numbers for me on that one. For NUMA platforms the clarity of the code is 
what is of interest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
