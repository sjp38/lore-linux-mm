Received: from squid.netplus.net (squid.netplus.net [206.250.192.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA29359
	for <linux-mm@kvack.org>; Sat, 2 Jan 1999 15:05:59 -0500
Message-ID: <368E7BCC.68A75964@netplus.net>
Date: Sat, 02 Jan 1999 14:04:28 -0600
From: Steve Bergman <steve@netplus.net>
MIME-Version: 1.0
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
References: <Pine.LNX.3.95.990101225111.16066K-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> Would you care to do some more testing? In particular, I'd like to hear
> how basic 2.2.0pre3 works (that's essentially the same as test1-pre, with
> only minor updates)? I'd like to calibrate the numbers against that,
> rather than against kernels that I haven't actually ever run myself.
> 

I've done some more testing, this time including the low memory case. 
For low memory testing I built the dhcp server from SRPM in 8MB with X,
xdm, various daemons (sendmail, named, inetd, etc.), and vmstat 1
running.  Swap area stayed at about 8MB usage.  I have also run the
128MB tests some more and have slightly more accurate results.  Here is
the summary:



Kernel                                          128MB              8MB
------------                                    -------           
------
2.1.131-ac11                                    172 sec            260
sec
test1-pre  + Arcangeli's patch                  119 sec            226
sec
2.2.0-pre3                                      175 sec            334
sec
2.2.0-pre3 + Linus's patch                      129 sec            312
sec
RH5.2 Stock (2.0.36-0.7)                        280 sec            N/A



-Steve
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
