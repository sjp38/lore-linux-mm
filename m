Received: from atlas.cs.uga.edu (atlas [128.192.251.4])
	by ajax.cs.uga.edu (8.9.3/8.9.3) with ESMTP id NAA29447
	for <linux-mm@kvack.org>; Thu, 19 Jun 2003 13:41:54 -0400 (EDT)
Received: (from cashin@localhost)
	by atlas.cs.uga.edu (8.9.3/8.9.3) id NAA26055
	for linux-mm@kvack.org; Thu, 19 Jun 2003 13:47:31 -0400 (EDT)
Date: Thu, 19 Jun 2003 13:47:31 -0400
From: Ed L Cashin <ecashin@uga.edu>
Subject: why current->mm in mm/mmap.c's dup_mmap?
Message-ID: <20030619134731.A25935@atlas.cs.uga.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.  In mm/mmap.c there's a static inline function, 
dup_mmap, that only has one caller, namely copy_mm.

copy_mm provides dup_mmap with an oldmm parameter
with a value from current->mm.

I'd expect dup_mmap to use that parameter instead
of ever using current->mm, but instead, dup_mmap
does semaphore down and up on oldmm but otherwise
uses current->mm.

Why does dup_mmap use current->mm at all?

-- 
--Ed L Cashin            |   PGP public key:
  ecashin@uga.edu        |   http://noserose.net/e/pgp/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
