Received: from squid.netplus.net (squid.netplus.net [206.250.192.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA18179
	for <linux-mm@kvack.org>; Thu, 31 Dec 1998 19:17:09 -0500
Message-ID: <368C13D7.6B153DB3@netplus.net>
Date: Thu, 31 Dec 1998 18:16:23 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
References: <Pine.LNX.3.96.981231193257.330B-100000@laser.bogus>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> On Thu, 31 Dec 1998, Andrea Arcangeli wrote:
> 
> > Comments?
> >
> > Ah, the shrink_mmap limit was wrong since we account only not referenced
> > pages.
> >
> > Patch against 2.2.0-pre1:
> 
> whoops in the last email I forget to change a bit the subject (adding
> [patch]) and this printk:

Hi,

I just tried out the patch and got very disappointing results on my
128MB AMD K6-3.  I tested by loading 117 good sized images all at once. 
This kicks it ~ 165MB into the swap (~ 293 MB mem total).  The standard
2.2.0-pre1 kernel streamed out to swap at an average of >1MB/sec and
finished in 184 seconds.  WIth the patched kernel I stopped at 280 sec. 
At that time it had about 65 mb swapped out or < 250K/sec.  I then
rebooted, brought up X and an xterm and went to compile the 2.1.131-ac11
patch (still running under the patched 2.2.0-pre1) and noted that during
the compile I had 17MB in the swap with nothing else going on.  Bringing
up netscape put it up to 25MB.   Suggestions? Requests?  Let me know if
you want me to try anything else.

Thanks,
Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
