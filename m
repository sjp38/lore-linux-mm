Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
From: Nigel Cunningham <ncunningham@linuxmail.org>
Reply-To: ncunningham@linuxmail.org
In-Reply-To: <41E8F313.4030102@yahoo.com.au>
References: <20050113061401.GA7404@blackham.com.au>
	 <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au>
	 <20050113101426.GA4883@blackham.com.au>  <41E8ED89.8090306@yahoo.com.au>
	 <1105785254.13918.4.camel@desktop.cunninghams>
	 <41E8F313.4030102@yahoo.com.au>
Content-Type: text/plain
Message-Id: <1105786115.13918.9.camel@desktop.cunninghams>
Mime-Version: 1.0
Date: Sat, 15 Jan 2005 21:48:35 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Bernard Blackham <bernard@blackham.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nick.

On Sat, 2005-01-15 at 21:40, Nick Piggin wrote:
> Nigel Cunningham wrote:
> > Hi Nick and Bernard.
> > 
> > On Sat, 2005-01-15 at 21:16, Nick Piggin wrote:
> > 
> >>OK I think the problem is due to swsusp allocating a very large
> >>chunk of memory before suspending. After resuming, kswapd is more
> >>or less in the same state and tries a bit too hard to free things.
> > 
> > 
> > I'm not sure about this theory. The normal case will be that all
> > allocations (maybe one or two order 1 or order 2 allocations if I've
> > forgotten something) are order 0 and processes are thawed after we've
> > freed all the memory we were using. Could that still trigger kswapd?
> > 
> 
> I've seen try to do order 8 allocations or something almost as
> ridiculous. Atomic too.

I believe you. But Bernard and I are dealing with Suspend2.

> Well, correction, I've seen _reports_. Never tried swsusp myself.

:>

> I don't think a few order 0 and 1 allocations would do any harm
> because otherwise every man and his dog would be having problems.

Yes. Suspend2 does allocate a large number of zero order allocations for
submitting I/O, but again, they're all freed prior to thawing frozen
processes.

> > 
> >>Thanks for the report... I'll come up with something for you to try
> >>in the next day or so.
> > 
> > 
> > I'm flying to America on Monday, but I'll try to keep up with the
> > progress in this and do anything I can to help.
> > 
> 
> It is basically a problem with one of my patches. I should be able
> to fix it (although fixing swsusp would be nice too :) ).

:> Nevertheless, if there's something suspend2 related I should fix...

Nigel
-- 
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com

Ph: +61 (2) 6292 8028      Mob: +61 (417) 100 574

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
