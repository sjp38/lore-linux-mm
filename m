Received: from mail.cs.tu-berlin.de (root@mail.cs.tu-berlin.de [130.149.17.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA06383
	for <linux-mm@kvack.org>; Mon, 10 May 1999 12:02:59 -0400
Received: from zange.cs.tu-berlin.de (pokam@zange.cs.tu-berlin.de [130.149.31.198])
	by mail.cs.tu-berlin.de (8.9.1/8.9.1) with ESMTP id SAA01613
	for <linux-mm@kvack.org>; Mon, 10 May 1999 18:02:14 +0200 (MET DST)
From: Gilles Pokam <pokam@cs.tu-berlin.de>
Received: (from pokam@localhost)
	by zange.cs.tu-berlin.de (8.9.1/8.9.0) id SAA11187
	for linux-mm@kvack.org; Mon, 10 May 1999 18:02:12 +0200 (MET DST)
Message-Id: <199905101602.SAA11187@zange.cs.tu-berlin.de>
Subject: mmap operation
Date: Mon, 10 May 1999 18:02:10 +0200 (MET DST)
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have implemented a module for buffer management in the 2.0.34 linux kernel.
Now i'm using the write and read method for transfering data between the kernel
and user space. I have noticed that the overhead of these 2 operations are 
quite big, because each time a system call is invoked. So i decided to improve 
my module by implementing the mmap operation. The mmap operation works well
when mapping only one page size. But above this size, for example with an order
of at least 1, the later operation fails to work! I have noticed that above
4096 (one page) bytes the zero page is mapped instead! 
Could someone help mee solve this problem ? (i use the nopage operation in my
mmap method and cluster of 16 pages).

Thanks.
       Gilles 
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
