Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19437
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 14:27:21 -0500
Date: Wed, 13 Jan 1999 20:23:24 +0100 (CET)
From: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m100Vbm-0007U2C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.990113202208.14293B-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, andrea@e-mind.com, Zlatko.Calusic@CARNet.hr, torvalds@transmeta.com, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Alan Cox wrote:

> > "Nobody"?  Oracle uses large shared memory regions for starters.
> 
> All the big databases use large shared memory objects. 

which is _not_ expected to be swapped at all for a correctly set-up Oracle
database installation.

-- mingo

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
