Date: Fri, 27 Jun 2003 07:43:50 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC] My research agenda for 2.7
Message-ID: <23430000.1056725030@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.53.0306271345330.14677@skynet>
References: <200306250111.01498.phillips@arcor.de> <200306262100.40707.phillips@arcor.de><Pine.LNX.4.53.0306262030500.5910@skynet> <200306270222.27727.phillips@arcor.de> <Pine.LNX.4.53.0306271345330.14677@skynet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > I also wonder if moving kernel pages is really worth the hassle.
>> 
>> That's the question of course.  The benefit is getting rid of high order
>> allocation failures, and gaining some confidence that larger filesystem
>> blocksizes will work reliably, however the workload evolves.

Oh, BTW ... I suspect you've realised this already, but ....

The buddy allocator is not a good system for getting rid of fragmentation. 
If I group pages together in aligned pairs, and F is free and A is 
allocated, it'll not do anything useful with this:

F A   A F   F A   A F   F A   A F   F A   A F   F A   F A 

because the adjacent "F"s aren't "buddies". It seems that the purpose of
the buddy allocator was to be quick at allocating pages. Now that we stuck
a front end cache on it, in the form of hot & cold pages, that goal no
longer seems paramount - altering it to reduce fragmentation at the source,
rather than actively defrag afterwards would seem like a good goal to me.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
