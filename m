Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA09665
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 01:33:17 -0500
Subject: Re: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
References: <Pine.LNX.4.04.9901082246490.1183-100000@brookie.inconnect.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 09 Jan 1999 07:32:49 +0100
In-Reply-To: Dax Kelson's message of "Fri, 8 Jan 1999 23:28:16 -0700 (MST)"
Message-ID: <87sodl552m.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Dax Kelson <dkelson@inconnect.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Dax Kelson <dkelson@inconnect.com> writes:

> On 7 Jan 1999, Zlatko Calusic wrote:
> > 
> > 1) Swap performance in pre-5 is much worse compared to pre-4 in
> > *certain* circumstances. I'm using quite stupid and unintelligent
> > program to check for raw swap speed (attached below). With 64 MB of
> > RAM I usually run it as 'hogmem 100 3' and watch for result which is
> > recently around 6 MB/sec. But when I lately decided to start two
> > instances of it like "hogmem 50 3 & hogmem 50 3 &" in pre-4 I got 2 x
> > 2.5 MB/sec and in pre-5 it is only 2 x 1 MB/sec and disk is making
> > very weird and frightening sounds. My conclusion is that now (pre-5)
> > system behaves much poorer when we have more than one thrashing
> > task. *Please*, check this, it is a quite serious problem.
> 
> I just tried this on 2.2.0-pre6 PentiumII 412Mhz, 128MB SDRAM, one IDE
> disk (/ & swap).
> 
> ./hogmem 200 3
> Memory speed: 9.01 MB/sec
> 
> ./hogmem 100 3 & ./hogmem 100 3
> Memory speed: 0.96 MB/sec
> Memory speed: 0.96 MB/sec
> 

I have a fix for this, together with a great improvement in swapping
speed that I'll be sending in few moments, after some final testing.

pre6 is VERY good, and with my changes, we will have fastest MM ever!
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
