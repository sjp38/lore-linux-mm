Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA22109
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 18:05:13 -0500
Date: Mon, 25 Jan 1999 00:05:02 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-final
In-Reply-To: <m1iudwo6nd.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990125000116.15685A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 24 Jan 1999, Eric W. Biederman wrote:

> I don't think this is an issue.  Before we get to calling
> swap_out with priority == 0 we have called it with priorities.
> 6,5,4,3,2,1  Which will have travelled a little over 1.5 times over
> the page tables (assuming they can't find anything either).

So you think that also shrink_mmap() could have a weight of nr_physpages
instead of physpages << 1, the point is that we could sleep for a _long_
time in swap_shm() (sync I/O in rw_swap_page_nocache()).

Andrea Arcangeli


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
