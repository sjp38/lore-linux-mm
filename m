Date: Mon, 2 Sep 2002 15:50:49 -0400
Mime-Version: 1.0 (Apple Message framework v482)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Subject: About the free page pool
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Message-Id: <47FD65E3-BEAD-11D6-A3BE-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Yet another question as I try to get a clear picture of the nitty-gritty 
details of the VM...

How important is it to maintain a list of free pages?  That is, how 
critical is it that there be some pool of free pages from which the only 
bookkeeping required is the removal of that page from the free list.

In contrast, how awful would the following be:  Keep no free list, but 
instead ensure that some portion of the trailing end of the inactive list 
contains clean pages that are ready to be reclaimed.  When a free page is 
needed, just unmap that clean, inactive page and use *that* as your free 
page.  Clearly some more bookkeeping is required to unmap the page (assume 
that rmap is available to make that a straightforward task) than there 
would be simply to remove the page from the free list.  However, for every 
page on the free list, that unmapping work had to happen previously anyway.
..

(Of course, the above scenario assumes that main memory is full.  If there 
are unused page frames, then certainly you would consult a list of those 
first.)

Are there moments at which pages need to be allocated *so quickly* that 
unmapping the page at allocation time is too costly?  Or is there some 
other reason for maintaining a free list that I'm completely missing?

Also, how large is the free list of pages now?  5% of the main memory 
space?  A fixed number of page frames?

As always, thanks for the feedback and insights.
Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9c8Ed8eFdWQtoOmgRAm3BAJ9q8Fw2v2F2MtuM9xxuwB2FjuN9MgCeO7P/
C6TrxXqNKF07Po0msvHvoKg=
=qAZt
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
