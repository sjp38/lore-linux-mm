Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA31454
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 12:09:25 -0500
Date: Mon, 7 Dec 1998 17:08:46 GMT
Message-Id: <199812071708.RAA06140@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <m1hfva9g1y.fsf@flinx.ccr.net>
References: <Pine.LNX.3.96.981206011441.13041A-100000@mirkwood.dummy.home>
	<m1hfva9g1y.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 05 Dec 1998 20:10:01 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

>>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> RR 	/* Don't allow too many pending pages in flight.. */
> RR-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
> RR+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
> RR 		wait = 1;

> How will this possibly work if we are using a swapfile 
> and we always swap synchronously?

It doesn't make any difference: these lines just put an upper limit on
the amount of asynchronous swapping we can have at any point in time.
If all of our swapping is already synchronous, then the upper limit has
no effect.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
