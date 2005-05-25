Date: 25 May 2005 07:30:16 -0000
Message-ID: <20050525073016.19981.qmail@science.horizon.com>
From: linux@horizon.com
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If you want to minimize fragmentation, you could do worse than
study Doug Lea's malloc, known commonly as dlmalloc.

It's basically straight best-fit, but with one important heuristic:
FIFO use of free blocks.

This contributes enormously to minimizing fragmentation.
Any time a free block is created, it goes on the *end* of the
available list for that size.

This means that every chunk of free memory gets an approximately-equal
chance to be merged with more free chunks.  The chunks that make it
to the front of the available list are the ones with stable neighbors,
which are the best ones use up.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
