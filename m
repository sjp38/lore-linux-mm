Received: from f04n07.cac.psu.edu (f04s07.cac.psu.edu [128.118.141.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA11003
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 15:24:52 -0500
Message-ID: <369BAD5A.235762CE@psu.edu>
Date: Tue, 12 Jan 1999 15:15:22 -0500
From: Michael K Vance <mkv102@psu.edu>
MIME-Version: 1.0
Subject: Re: Results: Zlatko's new vm patch
References: <Pine.LNX.3.95.990111213013.15291A-100000@penguin.transmeta.com>
		<Pine.LNX.4.05.9901121055350.723-100000@alien.cowboy.net> <199901121816.SAA11120@dax.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Joseph Anthony <jga@cowboy.net>, Linus Torvalds <torvalds@transmeta.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> > Well, sometimes the system writes to swap before I have used half my
> > memory ( in X ) I view this with wmmon in windowmaker..
> 
> Suspect wmmon in that case.  If you can show this happening in a trace
> output from "vmstat 1", then I'll start to worry.

wmmon stuffs both swap and physical mem in its "MEM" area, and also has a
listing for "SWP", ie swap. I assume top is still reliable?

m.

-- 
"We watched her fall over and lay down,
 shouting the poetic truths of high school journal keepers."
 -- Lee Rinaldo, Sonic Youth
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
