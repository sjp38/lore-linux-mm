Received: from squid.netplus.net (squid.netplus.net [206.250.192.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA23997
	for <linux-mm@kvack.org>; Fri, 1 Jan 1999 18:48:06 -0500
Message-ID: <368D5E52.FE8B7B8@netplus.net>
Date: Fri, 01 Jan 1999 17:46:26 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
References: <Pine.LNX.3.96.990101203728.301B-100000@laser.bogus>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:


> 
> Please stop and try my new patch against Linus's test1-pre3 (that just
> merge some of my new stuff).

I got the patch and I must say I'm impressed.  I ran my "117 image" test
and got these results:

[Note: This loads 117 different images at the same time using 117
separate instances of 'xv' started in the background and results in ~
165 MB of swap area usage.  The machine is an AMD K6-2 300 with 128MB]


2.1.131-ac11                         172 sec  (This was previously the
best)
2.2.0-pre1 + Arcangeli's 1st patch   400 sec
test1-pre  + Arcangeli's 2nd patch   119 sec (!)

Processor utilization was substantially greater with the new patch
compared to either of the others.  Before it starts using swap, memory
is being consumed at ~ 4MB/sec.  After it starts to swap out, it streams
out at ~ 2MB/sec.

The performance is ~ 45% better than ac11 and ~ 70% better than
2.2.0-pre1 in this test.  

I was going to test the low memory case but got side tracked.


Thanks,
Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
