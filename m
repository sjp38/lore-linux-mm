Date: Sat, 13 Jul 2002 06:30:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <20020713133058.GU23693@holomorphy.com>
References: <20810000.1026311617@baldur.austin.ibm.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au> <E17TMqy-0003IY-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <E17TMqy-0003IY-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>>> (5)  enables cooperative offlining of memory for friendly guest instance
>>>         behavior in UML and/or LPAR settings

On Wednesday 10 July 2002 22:01, Andrew Morton wrote:
>> Vapourware

On Sat, Jul 13, 2002 at 03:22:28PM +0200, Daniel Phillips wrote:
> See "enables" above.  Though I agree we want the thing at parity or
> better on its own merits, I don't see the point of throwing tomatoes at
> the "enables" points.  Recommendation: separate the list into "improves"
> and "enables".

The direction has been set and I'm following it. These things are now
off the roadmap entirely regardless, or at least I won't pursue them
until the things needing to be done now are addressed.

Say, we could use a number of helpers with the quantitative measurement
effort, Is there any chance you could help out here as well? It'd
certainly help get the cost/benefit analysis of rmap going for the
merge, and maybe even pinpoint things needing to be addressed.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
