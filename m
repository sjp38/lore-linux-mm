Received: (from koconnor@localhost)
	by armstrong.cse.Buffalo.EDU (8.9.3/8.9.3) id HAA10593
	for linux-mm@kvack.org; Sat, 27 Nov 1999 07:59:56 -0500 (EST)
Date: Sat, 27 Nov 1999 07:59:56 -0500
From: "Kevin O'Connor" <koconnor@cse.Buffalo.EDU>
Subject: AVL trees vs. Red-Black trees
Message-ID: <19991127075956.A10530@armstrong.cse.Buffalo.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've been spending the last few days "kicking around" different ideas for
implementing reusable data structures in C.  That is, generic hash tables,
linked lists, trees, etc.

I was planning on hacking up a kernel with a generic tree implementation.
(Right now there are two AVL trees in the kernel - one in the MM code and a
copy in the net/bridge code.)

I was a little surprised to see that the MM code uses an AVL tree - my old
textbooks are of the opinion that Red-Black trees are superior.
Implementing the code to create a stack for performing "bottom-up"
insertions/deletions seems like a pain to me.  I would think the "top-down"
approach of a Red-Black tree would be more efficient and probably simpler
to implement.

So my question is, was there a particular reason AVL trees were chosen, or
would any balanced tree implementation suffice?

-Kevin

-- 
 ------------------------------------------------------------------------
 | Kevin O'Connor                     "BTW, IMHO we need a FAQ for      |
 | koconnor@cse.buffalo.edu            'IMHO', 'FAQ', 'BTW', etc. !"    |
 ------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
