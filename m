Received: from squid.netplus.net (squid.netplus.net [206.250.192.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA26356
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 03:34:51 -0500
Message-ID: <368DD9EE.D19A4D61@netplus.net>
Date: Sat, 02 Jan 1999 02:33:50 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
References: <Pine.LNX.3.95.990101225111.16066K-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Cc: Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Fri, 1 Jan 1999, Steve Bergman wrote:
> >
> > I got the patch and I must say I'm impressed.  I ran my "117 image" test
> > and got these results:
> >
> > 2.1.131-ac11                         172 sec  (This was previously the best)
> > 2.2.0-pre1 + Arcangeli's 1st patch   400 sec
> > test1-pre  + Arcangeli's 2nd patch   119 sec (!)
> 
> Would you care to do some more testing? In particular, I'd like to hear
> how basic 2.2.0pre3 works (that's essentially the same as test1-pre, with
> only minor updates)? I'd like to calibrate the numbers against that,
> rather than against kernels that I haven't actually ever run myself.
> 
> The other thing I'd like to hear is how pre3 looks with this patch, which
> should behave basically like Andrea's latest patch 

Hi Linus,

Andrea sent another patch to correct a problem with i/o bound processes,
which he also posted to linux-kernel.  The performance in this test is
unchanged.

Here are the results:


2.1.131-ac11                                    172 sec  

2.2.0-pre1 + Arcangeli's 1st patch              400 sec
test1-pre  + Arcangeli's 2nd patch              119 sec 
test1-pre  + Arcangeli's 3rd patch              119 sec
test1-pre  + Arcangeli's 3rd patch              117 sec 
(changed to priority = 9 in mm/vmscan.c)

2.2.0-pre3                                      175 sec
2.2.0-pre3 + Linus's patch                      129 sec

RH5.2 Stock (2.0.36-0.7)                        280 sec



I noticed that in watching the 'vmstat 1' during the test that
'2.2.0+Linus patch' was not *quite* as smooth as the Archangeli patches,
in that there were periods of 2 or 3 seconds in which the swap out rate
would fall to ~800k/sec and then jump back up to 1.8-2.5MB/sec.  I have
only run your patch once though.  I'll check it further tomorrow to
confirm that that is really the case.  Note how much better 2.2 is doing
compared to 2.0.36-0.7 in this situation.

I should be available for a good part of this weekend for further
testing; Just let me know.

As a reference:

AMD K6-2 300
128MB ram
2GB seagate scsi2 dedicated to swap
Data drive is 6.5GB UDMA


Steve Bergman
steve@netplus.net
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
