Received: from quake-sv.novare.net (mail@k6-2-350.128m-12.0g-8.4g-5.7g-2.1g-699.60bogo.novare.net [209.176.56.220])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA00536
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 15:19:58 -0500
Date: Mon, 11 Jan 1999 14:20:08 -0600 (CST)
From: Adam Heath <doogie@debian.org>
Reply-To: Adam Heath <doogie@debian.org>
Subject: Re: testing/pre-7 and do_poll()
In-Reply-To: <19990110183356.C262@perlsupport.com>
Message-ID: <Pine.LNX.3.96.990111135357.9558A-100000@quake-sv.novare.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chip Salzenberg <chip@perlsupport.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Chip Salzenberg wrote:

> According to Linus Torvalds:
> > There's a "pre-7.gz" on ftp.kernel.org in testing, anybody interested?
> 
> Got it, like it -- *except* the fix for overflow in do_poll() is a
> little bit off.  Quoting testing/pre-7:
> 
> 	if (timeout) {
> 		/* Carefula about overflow in the intermediate values */
> 		if ((unsigned long) timeout < MAX_SCHEDULE_TIMEOUT / HZ)
> 			timeout = (timeout*HZ+999)/1000+1;
> 		else /* Negative or overflow */
> 			timeout = MAX_SCHEDULE_TIMEOUT;
> 	}
> 
> However, the maximum legal millisecond timeout isn't (as shown)
> MAX_SCHEDULE_TIMEOUT/HZ, but rather MAX_SCHEDULE_TIMEOUT/(1000/HZ).
> So this code will turn some large timeouts into MAX_SCHEDULE_TIMEOUT
> unnecessarily.

A/(B/C) = A * (C / B) = A / B * C (done this way to eliminate overflow)

MAX_SCHEDULE_TIMEOUT / 1000 * HZ

Adam


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
