Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com> <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 12 May 2000 00:34:41 +0200
In-Reply-To: "Juan J. Quintela"'s message of "11 May 2000 23:56:16 +0200"
Message-ID: <shsd7msemwu.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > Linus, I agree with you here, but we do a get_page 5 lines
     > before, I think that if I do a get_page I should do a put_page
     > to liberate it.  But I can be wrong, and then I would like to
     > know if in the future, it could be posible to do a get_page and
     > liberate it with a page_cache_release?  That was my point.
     > Sorry for the bad wording.

That part of the code is broken. We do not want to wait on locked
pages in invalidate_inode_pages(): that's the whole reason for its
existence. truncate_inode_pages() is the waiting version.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
