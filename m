Received: from f04n07.cac.psu.edu (f04s07.cac.psu.edu [128.118.141.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09946
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 13:33:53 -0500
Message-ID: <369B9344.E7BA0203@psu.edu>
Date: Tue, 12 Jan 1999 13:24:04 -0500
From: Michael K Vance <mkv102@psu.edu>
MIME-Version: 1.0
Subject: Re: Results: Zlatko's new vm patch
References: <Pine.LNX.3.95.990111213013.15291A-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
 
> Note that there are very few people who are testing interactive feel. I'd
> be happier with more people giving more subjective comments on how the
> system feels under heavy memory load.

I left my machine today (64mb/80mb swap, running pre6 on an MMX/233) running
netscape, xemacs, a few rxvt's, and xscreensaver. Many times when I get home
after classes, xscreensaver's GL apps will have swapped large portions of
netscape and xemacs out. Today when I came home, I tried to check my mail, and
write a bit of code, but everything was swapping left and right. It wasn't
just that netscape and xemacs got swapped back in, and then that was
that--instead it just continually ground my hard drive as it downloaded email
and I switched around to apps, etc, for a good few minutes. Very unpleasant.

FYI,

m.

-- 
"We watched her fall over and lay down,
 shouting the poetic truths of high school journal keepers."
 -- Lee Rinaldo, Sonic Youth
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
