MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14619.18530.763458.871696@charged.uio.no>
Date: Fri, 12 May 2000 01:55:14 +0200 (CEST)
Subject: Re: PATCH: rewrite of invalidate_inode_pages
In-Reply-To: <ytt1z38acqg.fsf@vexeta.dc.fi.udc.es>
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
	<shsd7msemwu.fsf@charged.uio.no>
	<yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
	<14619.16278.813629.967654@charged.uio.no>
	<ytt1z38acqg.fsf@vexeta.dc.fi.udc.es>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > Trond, I have not an SMP machine (yet), and I can not tell you
     > numbers now.  I put the counter there to show that we *may*
     > want to limit the latency there.  I am thinking in the write of
     > a big file, that can take a lot to free all the pages, but I

I'm pretty SMP-less myself at the moment (I'm visiting in Strasbourg
again), so I'm afraid I cannot run the test for you.

     > By the way, while we are here, the only difference between
     > truncate_inode_pages and invalidate_inode_pages is the one that
     > you told here before?  I am documenting some of the MM stuff,
     > and your comments in that aspect are really wellcome.  (You
     > will have noted now that I am quite newbie here).

Well. As far as NFS and other non-disk based systems are concerned
that is the functional difference between the two. That and the fact
that truncate_inode_pages() takes an offset as an argument.

For disk-based systems, they are very different beasts, since
truncate_inode_pages() will also attempt to invalidate and/or wait on
any pending buffers on the pages it clears out.

Strictly speaking therefore, one should not confuse the two, however
truncate_inode_pages() is (ab)used as a sleeping substitute for
invalidate_inode_pages() by some of the icache pruning code in
fs/inode.c.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
