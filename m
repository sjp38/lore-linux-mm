Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA07247
	for <linux-mm@kvack.org>; Sat, 23 Jan 1999 14:16:38 -0500
Date: Sat, 23 Jan 1999 19:16:11 GMT
Message-Id: <199901231916.TAA04383@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <Pine.LNX.3.96.990121200340.1387C-100000@laser.bogus>
References: <199901211447.OAA01170@dax.scot.redhat.com>
	<Pine.LNX.3.96.990121200340.1387C-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, John Alvord <jalvo@cloud9.net>, Nimrod Zimerman <zimerman@deskmail.com>, Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 21 Jan 1999 20:32:32 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On Thu, 21 Jan 1999, Stephen C. Tweedie wrote:
>> No.  The algorithm should react to the current *load*, not to what it
>> thinks the ideal parameters should be.  There are specific things you

> Obviously when the system has a lot of freeable memory in fly there are
> not constraints. When instead the system is very low on memory you have to
> choose what to do.

> Two choices:

> 1. You want to give the most of available memory to the process that is
>    trashing the VM, in this case you left the balance percentage of
>    freeable pages low.

> 2. You leave the number of freeable pages more high, this way other
>    iteractive processes will run smoothly even if with the trashing proggy
>    in background. 

Note that if you have a thrashing process, then by far the most
important factor to tune is the aggressiveness with which that process
charges through new pages.  It doesn't matter how many pages you try to
keep free: if you have any process which is trying to gobble them all,
then it is far more important to throttle the rate at which they can do
so than to have any hard and fast limits on freeable pages.  Otherwise,
you just end up freeing lots of pages for the thrashing task(s) to
reclaim them straight back.

This is what I mean by being tuned by the load, not by predetermined
limits.

--Stephen
--
To unsubscribe, send a message witch 'unsubscribe linux-mm my@address' in
the body to majordomo@kvack.org.
For more info on Linux MM, see: http://humbolt.geo.uu.nl/Linux-MM/
