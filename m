Received: from mcfeeley.indusriver.com (mcfeeley.indusriver.com [209.6.112.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA13662
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 08:35:49 -0500
Message-ID: <369214C1.27C65F28@indusriver.com>
Date: Tue, 05 Jan 1999 08:33:53 -0500
From: Ben McCann <bmccann@indusriver.com>
MIME-Version: 1.0
Subject: Re: [patch] new-vm improvement [Re: 2.2.0 Bug summary]
References: <Pine.LNX.3.96.990103034429.312B-100000@laser.bogus>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrea,

My pet VM benchmark is the compilation of a set of about 50 C++
files which regularly grow the EGCS compiler VM size (as shown
by 'top') to 75 to 90 MB. I only have 64MB of RAM so it swaps a lot.

Here are the times (as measured by the 'time' command) for the
compilation of this suite of files (using 'make' and EGCS 1.0.1)
with 2.2.0pre4 and 2.2.0pre4 with your latest VM patch:

 TMS Compile with 2.2.0pre4
 589.830u 68.830s 18:09.88 60.4% 0+0k 0+0io 188062pf+260255w

 TMS Compile with 2.2.0pre4 and Andreas latest patch
 597.840u 71.030s 21:59.36 50.6% 0+0k 0+0io 298514pf+237324w
                  ^^^^^^^^                  ^^^^^^

Note the wall-clock time increases from 18 minutes to almost
22 minutes and the number of page faults increases from 188,000
to 298,500. It seems something is invalidating pages too aggressively
in your patch.

Is there something I can tune to improve this? Is there an experiment
I can run to help fine-tune your VM changes?

-Ben McCann

-- 
Ben McCann                              Indus River Networks
                                        31 Nagog Park
                                        Acton, MA, 01720
email: bmccann@indusriver.com           web: www.indusriver.com 
phone: (978) 266-8140                   fax: (978) 266-8111
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
