Received: from orion.sas.upenn.edu (ORION.SAS.UPENN.EDU [165.123.26.31])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA22338
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 14:24:37 -0500
Date: Sun, 10 Jan 1999 14:23:26 -0500 (EST)
From: Vladimir Dergachev <vdergach@sas.upenn.edu>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <Pine.LNX.3.95.990110105015.7668E-100000@penguin.transmeta.com>
Message-ID: <Pine.GSO.3.96.990110141748.5261A-100000@mail2.sas.upenn.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



> This shows up mainly on small memory machines, because on large memory
> machines we still have a lot of choice about what to free up, so it's not
> all that much of a problem.
> 
> But basically it seems that the reason pre-5 was so good was simply due to
> the bug that allowed it to deadlock. Sad, because there's no way I can
> re-introduce that nice behaviour without re-introducing the bug ;(

Stupid question: is it possible to teach it to recognize the deadlock ?
If I understand things right "nice behaviour" happens when we don't have
the deadlock and the deadlock occurs not very often. So we might check
once a second whether we have been low on memory for a while with a lot of
swap available and if so revert to "bug-proof" behaviour. 

                       Vladimir Dergachev

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
