Date: Tue, 8 Feb 2000 14:48:00 +0000 (GMT)
From: Matthew Kirkwood <weejock@ferret.lmh.ox.ac.uk>
Subject: Re: maximum memory limit
In-Reply-To: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0002081446080.2179-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Lee Chin <leechin@mail.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Feb 2000, Rik van Riel wrote:

> Problem is that libc malloc() appears to use brk() only, so
> it is limited to 900MB. You can fix that by doing the brk()
> and malloc() yourself, but I think that in the long run the
> glibc people may want to change their malloc implementation
> so that it automatically supports the full 3GB...

The glibc manual says that for allocations much greater
than the page size (no, it doesn't quantify "much") it
will use anonymous mmap of /dev/zero.

It's probably a bad idea to allocate over a gigabyte in
1K chunks anyway...

Matthew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
