Date: Sun, 28 Nov 1999 03:57:03 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: AVL trees vs. Red-Black trees
In-Reply-To: <19991127075956.A10530@armstrong.cse.Buffalo.EDU>
Message-ID: <Pine.LNX.4.10.9911280354150.509-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kevin O'Connor <koconnor@cse.Buffalo.EDU>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sat, 27 Nov 1999, Kevin O'Connor wrote:

>I was a little surprised to see that the MM code uses an AVL tree - my old
>textbooks are of the opinion that Red-Black trees are superior.

You basically do a query for each page fault and an insert for each mmap
and a remove for each munmap thus AVL gives better performances.

>Implementing the code to create a stack for performing "bottom-up"
>insertions/deletions seems like a pain to me.  I would think the "top-down"
>approach of a Red-Black tree would be more efficient and probably simpler
>to implement.

I just implemented RB trees in the kernel with a reusable implementation
exactly like include/linux/list.h for the lists.

If somebody find this interesting I can provide a patch to add the
include/linux/rbtree.h and lib/rbtree.c that will provde rbtree support.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
