Date: Thu, 23 Dec 1999 16:36:08 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <14433.38570.874925.968449@liveoak.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9912231624470.1341-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 1999, William J. Earl wrote:

>in the extent.  If the page cache were indexed by a per-inode AVL tree

Some month ago I did some research in putting the pagecache into a
per-inode RB-tree. AVL would be overkill because insert/removal can be the
only operation done on the tree (with cache pollution going on).

Unfortunately if the inode size gets very large the RB-tree won't scale
:(. With an hash you can say "ok, enlarge the hash 200mbyte and get rid of
the complexity paying with memory", while with an rbtree you have to
always pay O(N*log(N)) for each query/insert/removal... Chuck's  bench
generated nice numbers with the pagecache in the per-inode RB though
(without considering your "ordering" needs of course).

The interesting code should be here (or nearby, just search for the
filename in the ftp area if it's not exactly there):

	ftp://ftp.suse.com/pub/people/andrea/kernel/2.2.6_andrea5.bz2

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
