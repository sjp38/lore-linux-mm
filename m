Message-ID: <3D7859ED.E6717993@zip.com.au>
Date: Fri, 06 Sep 2002 00:31:57 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: 2.5.33-mm4
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Janet Morgan <janetmor@us.ibm.com>
List-ID: <linux-mm.kvack.org>

url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.33/2.5.33-mm4/

-direct-io-alignment.patch

 Drop this for now.  It's broken.

-config-PAGE_OFFSET.patch

 Still has a few kbuild problems.  Asked for some help from Kai.

+lpp2.patch

 hugetlb fixes from Rohit.

+nonblocking-ext2-preread.patch

 Use the block queue congestion tests in ext2_preread_inode().


I fixed up the readv/writev patch.  My little experiment to see what
happens when you feed tty and socket descriptors into generic_file_foo()
thus comes to an end.  It passes the ltp tests now.

Janet, I lost your patch which fixed a few things in there - had
a disk failure.  Could you please resend?

I tuned up the ll_rw_blk.c changes in queue-congestion.patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
