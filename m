Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com> <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no> <yttbt2chf46.fsf@vexeta.dc.fi.udc.es> <14619.16278.813629.967654@charged.uio.no> <ytt1z38acqg.fsf@vexeta.dc.fi.udc.es> <391BEAED.C9313263@sympatico.ca> <yttg0ro6lt8.fsf@vexeta.dc.fi.udc.es>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 12 May 2000 14:51:26 +0200
In-Reply-To: "Juan J. Quintela"'s message of "12 May 2000 13:37:55 +0200"
Message-ID: <shs7ld0dj8x.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>, Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > This was a first approach patch, if people like the thing
     > configurable, I can try to do that the weekend.

Juan, Linus,

   Could you please look into changing the name of
invalidate_inode_pages() to invalidate_pages_noblock() or something
like that? Since NFS is the only place where this function is used, a
change of name should not break any other code.

The reason I think this is necessary, is that this is the second time
the 2.3.x kernel is broken because somebody has misunderstood, and has
added wait_on_page() functionality to the same function.
Alternatively, please make sure that we add explicit comments to that
effect.

     > Notice: that will be my first trip to /proc land....

Ugh. Sounds like an extremely complex "solution" to something which
has not yet been demonstrated to be a problem.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
