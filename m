Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA20791
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 10:49:04 -0500
Date: Tue, 24 Nov 1998 15:48:57 GMT
Message-Id: <199811241548.PAA01047@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Linux-2.1.129..
In-Reply-To: <m13e79eha7.fsf@flinx.ccr.net>
References: <Pine.LNX.3.96.981123215719.6004B-100000@mirkwood.dummy.home>
	<m13e79eha7.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 24 Nov 1998 00:28:16 -0600, ebiederm+eric@ccr.net (Eric
W. Biederman) said:

> Imagine a machine with 1 Gigabyte of RAM and 8 Gigabyte of swap,
> in heavy use.  Swapping but not thrashing.

> You can't swap out several hundred megabytes all at once.  

Sure you can!  It's a tradeoff between moment-to-moment predictability
and overall throughput.  Swapping loads at once gives unpredictable
short-term behaviour but great throughput.  Performance is nearly
always about trading of throughput for things like predictability or
fairness.

> You can handle a suddne flurry of network traffic much better this way
> for example.

As long as you have got enough clean pages around, you can deal with
this anyway: kswapd can find free memory very rapidly as long as it
doesn't have to spend time writing things to swap.

> As far as fixed percentages.  It's a loose every time, and I won't
> drop a working feature for an older lesser design.  Having tuneable
> fixed percentages is only a win on a 1 application, 1 load pattern
> box.

<Nods head vigorously.>  Try running with a big ramdisk on a 2.1.125
box, for example: the precomputed page cache limits no longer work and
performance falls apart.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
