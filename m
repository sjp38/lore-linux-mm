Date: Sat, 27 Nov 1999 23:29:33 -0600 (CST)
From: Oliver Xymoron <oxymoron@waste.org>
Subject: Re: AVL trees vs. Red-Black trees
In-Reply-To: <Pine.LNX.4.10.9911280354150.509-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.9911272326150.29377-100000@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Kevin O'Connor <koconnor@cse.Buffalo.EDU>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sun, 28 Nov 1999, Andrea Arcangeli wrote:

> On Sat, 27 Nov 1999, Kevin O'Connor wrote:
> 
> >I was a little surprised to see that the MM code uses an AVL tree - my old
> >textbooks are of the opinion that Red-Black trees are superior.
> 
> You basically do a query for each page fault and an insert for each mmap
> and a remove for each munmap thus AVL gives better performances.
> 
> >Implementing the code to create a stack for performing "bottom-up"
> >insertions/deletions seems like a pain to me.  I would think the "top-down"
> >approach of a Red-Black tree would be more efficient and probably simpler
> >to implement.
> 
> I just implemented RB trees in the kernel with a reusable implementation
> exactly like include/linux/list.h for the lists.
> 
> If somebody find this interesting I can provide a patch to add the
> include/linux/rbtree.h and lib/rbtree.c that will provde rbtree support.

I'd like to take a look at this, I've been looking at putting some more
uniform tree structures in the kernel (post 2.4).

--
 "Love the dolphins," she advised him. "Write by W.A.S.T.E.." 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
