Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA29490
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 12:37:16 -0500
Date: Thu, 7 Jan 1999 09:35:41 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
In-Reply-To: <36942ACA.3F8C055D@netplus.net>
Message-ID: <Pine.LNX.3.95.990107093240.4270F-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Wed, 6 Jan 1999, Steve Bergman wrote:
> 
> Here are my latest numbers.  This is timing a complete kernel compile  (make
> clean;make depend;make;make modules;make modules_install)  in 16MB memory with
> netscape, kde, and various daemons running.  I unknowningly had two more daemons
> running in the background this time than last so the numbers can't be compared
> directly with my last test (Which I think I only sent to Andrea).  But all of
> these numbers are consistent with *each other*.
> 
> 
> kernel		Time	Maj pf	Min pf  Swaps
> ----------	-----	------	------	-----
> 2.2.0-pre5		18:19	522333	493803	27984
> arcavm10		19:57	556299	494163	12035
> arcavm9		19:55	553783	494444	12077
> arcavm7		18:39	538520	493287	11526

Don't look too closely at the "swaps" number - I think pre-5 just changed
accounting a bit. A lot of the "swaps" are really just dropping a virtual
mapping (that is later picked up again from the page cache or the swap
cache). 

Basically, pre-5 uses the page cache and the swap cache more actively as a
"victim cache", and that inflates the "swaps" number simply due to the
accounting issues. 

I guess I shouldn't count the simple "drop_pte" operation as a swap at
all, because it doesn't involve any IO.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
