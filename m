Date: Tue, 14 Dec 1999 17:41:42 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: 2.3.32-pre4/SMP still doesn't boot on Compaq Proliant 1600
In-Reply-To: <Pine.GSO.4.10.9912141410220.16347-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.3.96.991214171649.16967A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 1999, Alexander Viro wrote:

> On Tue, 14 Dec 1999, Linus Torvalds wrote:
...
> > Sounds like a capital idea. Mind doing the block device pagecache first,
> > though, if you're already looking at this area?
> 
> Frankly, I'ld rather start with massaging bmap() out of existence. I will
> do block device pagecache, all right, but there is one funny detail - we
> have serious code duplication between loopback and swap.

Ah, I see what you're talking about.  In theory we make rw_swap_page use
the page cache operations of the filesystem (or block device) by simply
relabelling the page from its swap cache entry.  Actually, if we use the
page cache for block device access, doesn't that mean that we can get rid
of the swapper_inode completely?  This seems like an obvious way of doing
things, and unless people point out something that I'm missing entirely
here...  It'll mean that brw_page goes away and is replaced by the use of
i_ops->readpage.  That's seems good =)

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
