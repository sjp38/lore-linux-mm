Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA08099
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 09:50:48 -0500
Date: Tue, 12 Jan 1999 15:49:53 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: Zlatko's new vm patch
In-Reply-To: <Pine.LNX.3.95.990111213013.15291A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990112154822.315B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 1999, Linus Torvalds wrote:

> Note that there are very few people who are testing interactive feel. I'd
> be happier with more people giving more subjective comments on how the
> system feels under heavy memory load. 

With my latest free_user_and_cache() (arca-vm >= 16) you can't get bad
iteractive performances. Usually bad iteractive performances are due
unbalaced algorithms in the big try_to_free_pages() path.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
