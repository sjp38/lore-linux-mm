Date: Mon, 20 Dec 2004 10:08:29 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
In-Reply-To: <20041220174357.GB4316@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
References: <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au>
 <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au>
 <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au>
 <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au>
 <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org>
 <20041220174357.GB4316@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Andi Kleen wrote:
> > 
> > Because it used to be broken as hell. The code it generated was absolute 
> > and utter crap.
> 
> I disagree. It generated significantly smaller code and the SUSE 
> kernel has been shipping with it for several releases and I'm not
> aware of any bug report related to unit-at-a-time.

You didn't answer my question: have you checked anything but your recent 
version of gcc?

The fact is, there _were_ lots of complaints about unit-at-a-time. There 
was a reason that thing got disabled. Maybe they got fixed, BUT THAT 
DOESN'T HELP, if people are still using the old compilers that support 
the notion, but do crap for it.

We still support gcc-2.95. By implication, that pretty much means that we 
support all the early unit-at-a-time compilers too. Not just the 
potentially fixed ones.

Thus your "it works for SuSE" argument is totally pointless, and totally 
misses the issue.

> The right fix in that case would have been to add a few "noinline"s
> to these cases (should be easy to check for if it really happens 
> by grepping assembly code for large stack frames), not penalize code quality
> of the whole kernel.

No. The right fix is _always_ to make sure that we are conservative enough 
that we don't have to depend on getting compiler-specific details really 
really right. 

The thing is, performance (even when unit-at-a-time works) comes second to 
stability. And I don't say that as a user (although it's obviously true 
for users too), I say that as a _developer_. The amount of effort needed 
to chase down strange problem reports due to compiler issues is just not 
worth it.

I would suggest that if you want unit-at-a-time, you make it a config 
option, and you mark it very clearly as requiring a new enough compiler 
that it's worth it and stable. That way if people have problems, we can 
ask them "did you have unit-at-a-time enabled?" and see if the problem 
goes away.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
