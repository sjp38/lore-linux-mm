Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA22345
	for <linux-mm@kvack.org>; Fri, 1 Jan 1999 12:17:55 -0500
Date: Fri, 1 Jan 1999 18:16:35 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
In-Reply-To: <368C13D7.6B153DB3@netplus.net>
Message-ID: <Pine.LNX.3.96.990101180941.1463A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Dec 1998, Steve Bergman wrote:

> I just tried out the patch and got very disappointing results on my
> 128MB AMD K6-3.  I tested by loading 117 good sized images all at once. 

The point of my patch is to balance the VM and improve performance for not
memory trashing proggy. It make sense that the trashing program is been
slowed down... Once the proggy will stop allocating RAM but it will
continue to use only pages just allocated (eventually in swap) performance
should return normal.

> patch (still running under the patched 2.2.0-pre1) and noted that during
> the compile I had 17MB in the swap with nothing else going on.  Bringing
> up netscape put it up to 25MB.   Suggestions? Requests?  Let me know if

I am going to still change something for sure. But please don't care the
size of the SWAP, care only performances. The pages in the swap right now
are likely to be present also in the swap cache so you' ll handle both
aging and a little cost in a swapin using more the swap cache. Really
there's also the cost of an async swapout to disk but it seems to not harm
here.

> you want me to try anything else.

Yes you should tell me if the performances decreased with normal usage
(like netscape + kernel compile). 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
