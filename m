Date: Fri, 24 Dec 1999 00:53:49 -0500 (EST)
From: afei@jhu.edu
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-reply-to: <Pine.LNX.4.10.9912231624470.1341-100000@alpha.random>
Message-id: <Pine.GSO.4.05.9912240050140.1337-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

May I ask why the time is O(N*Log(N)) instead of O(Log(N)). We have this
interesting OS class implementing a AVL tree structured directory entry in
ext2 directory file on disk. I always think it is not going to work out.
But the TA and the professor keep telling me the new file system will be
better than ext2 bcause now we have O(Log(N)) time search(ok),
insert/removal(???). I really doubt it but I do not know where they can be
wrong.

Fei

 On Thu, 23 Dec 1999, Andrea Arcangeli wrote:

> On Wed, 22 Dec 1999, William J. Earl wrote:
> 
> >in the extent.  If the page cache were indexed by a per-inode AVL tree
> 
> Some month ago I did some research in putting the pagecache into a
> per-inode RB-tree. AVL would be overkill because insert/removal can be the
> only operation done on the tree (with cache pollution going on).
> 
> Unfortunately if the inode size gets very large the RB-tree won't scale
> :(. With an hash you can say "ok, enlarge the hash 200mbyte and get rid of
> the complexity paying with memory", while with an rbtree you have to
> always pay O(N*log(N)) for each query/insert/removal... Chuck's  bench
> generated nice numbers with the pagecache in the per-inode RB though
> (without considering your "ordering" needs of course).
> 
> The interesting code should be here (or nearby, just search for the
> filename in the ftp area if it's not exactly there):
> 
> 	ftp://ftp.suse.com/pub/people/andrea/kernel/2.2.6_andrea5.bz2
> 
> Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
