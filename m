Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA09685
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 13:17:35 -0500
Date: Tue, 12 Jan 1999 18:16:26 GMT
Message-Id: <199901121816.SAA11120@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Results: Zlatko's new vm patch
In-Reply-To: <Pine.LNX.4.05.9901121055350.723-100000@alien.cowboy.net>
References: <Pine.LNX.3.95.990111213013.15291A-100000@penguin.transmeta.com>
	<Pine.LNX.4.05.9901121055350.723-100000@alien.cowboy.net>
Sender: owner-linux-mm@kvack.org
To: Joseph Anthony <jga@cowboy.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 12 Jan 1999 10:58:06 -0600 (CST), Joseph Anthony
<jga@alien.cowboy.net> said:

> Well, sometimes the system writes to swap before I have used half my
> memory ( in X ) I view this with wmmon in windowmaker.. 

Suspect wmmon in that case.  If you can show this happening in a trace
output from "vmstat 1", then I'll start to worry.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
