Received: from localhost (amitjain@localhost)
	by mailhost.tifr.res.in (8.9.3+3.2W/8.9.3/Debian 8.9.3-21) with ESMTP id NAA02166
	for <linux-mm@kvack.org>; Wed, 12 Dec 2001 13:10:21 +0530
Date: Wed, 12 Dec 2001 13:10:21 +0530 (IST)
From: "Amit S. Jain" <amitjain@tifr.res.in>
Subject: Re: Allocation of kernel memory >128K
In-Reply-To: <m1k7vuujia.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.21.0112121303010.1319-100000@mailhost.tifr.res.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Thank u everyone for the response to my question bout allocatin huge
amount of memeory in kernel space....
For a few people who wanted to know why I m allocating such a huge memory
and do i really need contiguous memory...here it is

---- Basically what my module is doing is trying to make the communication
between kernel to kernel in a Linux Cluster transparent tp TCP/IP.
So to transmit the data I copy the data from the user area to the kernel
area and then to the n/w buffers.So what I was trying to do is transfer
the entire data from user to kernel space at one go(allocating huge memory
at kernel)....since this is not possible I can always divide the data into
30K packets and then copy it to the kernel space...

P.S I am new to the Linux Kernel ...hence please excuse ne naive comments
in the above ..


Amit 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
