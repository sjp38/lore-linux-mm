Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA10767
	for <linux-mm@kvack.org>; Mon, 10 May 1999 17:19:47 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14135.19821.176947.167396@dukat.scot.redhat.com>
Date: Mon, 10 May 1999 22:19:41 +0100 (BST)
Subject: Re: mmap operation
In-Reply-To: <199905101602.SAA11187@zange.cs.tu-berlin.de>
References: <199905101602.SAA11187@zange.cs.tu-berlin.de>
Sender: owner-linux-mm@kvack.org
To: Gilles Pokam <pokam@cs.tu-berlin.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 10 May 1999 18:02:10 +0200 (MET DST), Gilles Pokam
<pokam@cs.tu-berlin.de> said:

> I have implemented a module for buffer management in the 2.0.34 linux
> kernel.  Now i'm using the write and read method for transfering data
> between the kernel and user space. I have noticed that the overhead of
> these 2 operations are quite big, because each time a system call is
> invoked. So i decided to improve my module by implementing the mmap
> operation. The mmap operation works well when mapping only one page
> size. But above this size, for example with an order of at least 1,
> the later operation fails to work! I have noticed that above 4096 (one
> page) bytes the zero page is mapped instead!  Could someone help mee
> solve this problem ? (i use the nopage operation in my mmap method and
> cluster of 16 pages).

The entire VM works by mapping single pages.  It would be a large task
to change this.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
