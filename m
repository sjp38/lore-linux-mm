Date: Fri, 14 Jan 2000 16:49:00 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 1+ GB support (fwd)
In-Reply-To: <Pine.LNX.4.10.10001140256150.13454-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001141635030.240-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>, kelly@nvidia.com
Cc: Linux MM <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>
>	I've read a bunch of linux news that says that the later kernels
>such as 2.3.35 can support more than 1gb of memory.  I've put together a
>system with 4gb of RAM (dell 6300, 2x PIII 550 xeon CPUs) and can see that

2.2.14aa1 supports 4g of RAM on IA32 and 2Terabyte of RAM on alpha (wihout
per-process limit on alpha) with production quality. Apply the below patch
against 2.2.14 if you can't run an unstable tree.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.14aa1.gz

>processes.  However, I've been unable to malloc and use more than 1gb per
>process.  Is this a limitation or am I doing something wrong?  I've tried to

If you use 2.2.14aa1 you can apply these two incremental patches (they
should go on the top of 2.3.x as well) to allocate more ram per-process
(something like 3.5G). The two incremental patches are _not_ a good idea
if you need a large I/O cache (like for webservers). For scientific
application that only needs lots of RAM they should be fine.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/bigmem-large-mapping-1.gz
	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/patches/v2.2/2.2.14/bigmem-large-task-1.gz

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
