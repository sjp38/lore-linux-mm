Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no>
	<yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
	<14619.16278.813629.967654@charged.uio.no>
	<ytt1z38acqg.fsf@vexeta.dc.fi.udc.es> <391BEAED.C9313263@sympatico.ca>
	<yttg0ro6lt8.fsf@vexeta.dc.fi.udc.es> <shs7ld0dj8x.fsf@charged.uio.no>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Trond Myklebust's message of "12 May 2000 14:51:26 +0200"
Date: 12 May 2000 15:30:07 +0200
Message-ID: <yttaehv7v6o.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:
Hi

trond>    Could you please look into changing the name of
trond> invalidate_inode_pages() to invalidate_pages_noblock() or something
trond> like that? Since NFS is the only place where this function is used, a
trond> change of name should not break any other code.

We was talking about that in IRC just now....
I will do the patch later today.

trond> The reason I think this is necessary, is that this is the second time
trond> the 2.3.x kernel is broken because somebody has misunderstood, and has
trond> added wait_on_page() functionality to the same function.
trond> Alternatively, please make sure that we add explicit comments to that
trond> effect.

In my last patch there are a comment indicating that, that if you want
to wail for the *locked* pages also, you need to call truncate inode
pages.  I will study truncate_inode_pages and their use later today,
came here with a comment for the semantic of both functions, and
people can told me if they agree/disagree.

>> Notice: that will be my first trip to /proc land....

trond> Ugh. Sounds like an extremely complex "solution" to something which
trond> has not yet been demonstrated to be a problem.

I think the same. I will preffer to tune the number to be *not too
much time* and nothing else.

Later, Juan.



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
