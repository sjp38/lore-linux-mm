Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA25031
	for <linux-mm@kvack.org>; Tue, 12 May 1998 21:45:38 -0400
Subject: Q: Swap Locking Reinstatement
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 12 May 1998 20:57:05 -0500
Message-ID: <m1somf2arx.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Recently the swap lockmap has been readded.

Was that just as a low cost sanity check, to use especially while
there were bugs in some of the low level disk drivers?

Was there something that really needs the swap lockmap?

The reason I am asking is that this causes conflicts with my shmfs
kernel patches.  I directly read/write swap pages through a variation
of rw_swap_page, and during I/O they must stay in the page cache, but
_not_ on the swapper inode, and the way the swap lockmap is currently
implemented causes a problem.

Eric
