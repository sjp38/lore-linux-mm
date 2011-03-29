Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9E06C8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:49:36 -0400 (EDT)
From: Sean Noonan <Sean.Noonan@twosigma.com>
Date: Mon, 28 Mar 2011 22:49:33 -0400
Subject: RE: XFS memory allocation deadlock in 2.6.38
Message-ID: <081DDE43F61F3D43929A181B477DCA95639B534F@MSXAOA6.twosigma.com>
References: <081DDE43F61F3D43929A181B477DCA95639B52FD@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
 <20110324174311.GA31576@infradead.org>
 <AANLkTikwwRm6FHFtEdUg54NvmKdswQw-NPH5dtq1mXBK@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B5349@MSXAOA6.twosigma.com>
 <BANLkTin0jJevStg5P2hqsLbqMzo3o30sYg@mail.gmail.com>
 <081DDE43F61F3D43929A181B477DCA95639B534E@MSXAOA6.twosigma.com>
 <20110329015137.GD3008@dastard>
In-Reply-To: <20110329015137.GD3008@dastard>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Chinner' <david@fromorbit.com>
Cc: 'Michel Lespinasse' <walken@google.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "linux-xfs@oss.sgi.com" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> As it is, the question I'd really like answered is how a machine with
> 48GB RAM can possibly be short of memory when running mmap() on a
> 16GB file.  The error that XFS is throwing indicates that the
> machine cannot allocate a single page of memory, so where has all
> your memory gone, and why hasn't the OOM killer been let off the
> leash?  What is consuming the other 32GB of RAM or preventing it
> from being allocated?=20
Here's meminfo while a test was deadlocking.  As you can see, we certainly =
aren't running out of RAM.
# cat /proc/meminfo=20
MemTotal:       49551548 kB
MemFree:        44139876 kB
Buffers:            5324 kB
Cached:          4970552 kB
SwapCached:            0 kB
Active:            52772 kB
Inactive:        4960624 kB
Active(anon):      37864 kB
Inactive(anon):        0 kB
Active(file):      14908 kB
Inactive(file):  4960624 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:           4914084 kB
Writeback:             0 kB
AnonPages:         37636 kB
Mapped:          4925460 kB
Shmem:               280 kB
Slab:             223212 kB
SReclaimable:     176280 kB
SUnreclaim:        46932 kB
KernelStack:        3968 kB
PageTables:        35228 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    47073968 kB
Committed_AS:      86556 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      380892 kB
VmallocChunk:   34331773836 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        2048 kB
DirectMap2M:     2086912 kB
DirectMap1G:    48234496 kB


> Perhaps the output of xfs_bmap -vvp <file> after a successful vs
deadlocked run would be instructive....

I will try to get this tomorrow.

Sean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
