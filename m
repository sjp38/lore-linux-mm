Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA00469
	for <Linux-MM@kvack.org>; Mon, 17 May 1999 12:11:24 -0400
Date: Mon, 17 May 1999 09:11:19 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kanoj-mm2.0-2.2.9 unneccesary page force in by munlock
In-Reply-To: <199905170616.XAA97025@google.engr.sgi.com>
Message-ID: <Pine.LNX.3.95.990517091025.10344C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 16 May 1999, Kanoj Sarcar wrote:
> 
> Hmm, my logic was a little bit different. Note that you can call munlock()
> on a range even when a previous mlock() has not been done on the range (I
> think that's not an munlock error in POSIX). In 2.2.9, this would end up
> faulting in the pages, which doesn't need to happen ... (haven't really
> thought whether "root" can erroneously force memory deadlocks this way)

Well, if you look closely, the mlock_fixup() routine tests whether
lockedness has changed and returns early if it hasn't.. So in your case
nothing at all would have been done..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
