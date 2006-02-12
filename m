Message-ID: <43EEC136.5060609@yahoo.com.au>
Date: Sun, 12 Feb 2006 16:01:42 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Get rid of scan_control
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com> <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org> <20060211014649.7cb3b9e2.akpm@osdl.org> <43EEAC93.3000803@yahoo.com.au> <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com> <43EEB4DA.6030501@yahoo.com.au> <Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 12 Feb 2006, Nick Piggin wrote:

>>I think most of the cost apart from locking (because that will
>>depend on contention) is hitting random cachelines of struct pages
>>then hitting random radix tree cachelines to remove them. Not
>>much you can do about that.
>>
>>That said I'm never against microoptimisations provided they
>>weigh in on the right side of the (subjective) complexity /
>>improvement ratio.
> 
> 
> Its a bit strange if you call a function and then access a structure 
> member to get the result. Locating parameter in a structure makes it
> impossible to see what is passed to a function when it is 
> called.
> 

Sometimes there is more than one result though :\

> It is also something that will make it difficult for compilers to do
> a good job. Flow control is easier to optimize for a local variable
> than for a pointer into a struct that may have been modified elsewhere.
> 

There are downsides to it. I was basically on the fence with its
removal from mainline, because the complexity of parameters going
to/from functions make the improvement borderline.

But I would have kept it for my internal work, and given Marcelo
is also interested in it I guess it could stay for now (unless
you trump that with some performance numbers I guess).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
