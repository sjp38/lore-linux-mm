Received: from adsl-64-161-28-170.dsl.sntc01.pacbell.net ([64.161.28.170] helo=zip.com.au)
	by www.linux.org.uk with esmtp (Exim 3.33 #5)
	id 17UhaR-0004rR-00
	for linux-mm@kvack.org; Wed, 17 Jul 2002 06:42:55 +0100
Message-ID: <3D3505B5.870E3944@zip.com.au>
Date: Tue, 16 Jul 2002 22:50:45 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: atomic kmap patch for 2.5.26
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I've uploaded the kmap_atomic patch for pagecache reads to
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.26/linus-copy_user-hack.patch
and for pagecache writes and other stuff to
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.26/kmap_atomic_writes.patch

The latter is OK for ext2, ext3 and loop, but I made a mess of
a few other filesystems and need to redo it.

This work is stalled until we understand what's going on.  If
It speeds Hanna's machine up by 15% (I'm expecting 40% with
both patches), but it speeds up all the other machines in the
world by 3%, it won't be getting very far.

It'd be good to get some testing on a wider range of machines,
including fast uniprocessors, if people have time.

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
