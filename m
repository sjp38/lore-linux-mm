Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA23894
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 16:50:23 -0500
Date: Sun, 10 Jan 1999 13:47:24 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901102141.VAA01398@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990110134530.25373B-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Stephen C. Tweedie wrote:
> 
> The problem with that is what happens if we have a large, active
> write-mapped file with lots of IO activity on it; we become essentially
> unable to swap that file out.  That has really nasty VM death
> implications for things like databases.

Indeed. Maybe we really should use kswapd for this, especially now that
kswapd doesn't really do much else..

Btw, pre-6 had a bug in kswapd that is relevant to this discussion - it
used a 0 argument to try_to_free_pages(), even though kswapd very much is
able to do IO. (So in pre-6, waking up kswapd is the wrong thing to try to
do ;)

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
