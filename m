Date: Wed, 19 Dec 2001 22:56:50 -0500 (EST)
From: Vladimir Dergachev <volodya@mindspring.com>
Reply-To: Vladimir Dergachev <volodya@mindspring.com>
Subject: Re: Allocation of kernel memory >128K
In-Reply-To: <Pine.LNX.4.21.0112121303010.1319-100000@mailhost.tifr.res.in>
Message-ID: <Pine.LNX.4.20.0112192254260.10881-100000@node2.localnet.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Take a look at rvmalloc code in bt848 driver (or a copy of it in km,
http://gatos.sf.net which is somewhat separated out). BT848 and km are 
using it to get large chunks (~300K) of memory which are contiguous in
kernel virtual space but not contiguous physically. Sure makes much
easier to work with buffers than a bunch of separate pages.

                          Vladimir Dergachev

On Wed, 12 Dec 2001, Amit S. Jain wrote:

> 
> Thank u everyone for the response to my question bout allocatin huge
> amount of memeory in kernel space....
> For a few people who wanted to know why I m allocating such a huge memory
> and do i really need contiguous memory...here it is
> 
> ---- Basically what my module is doing is trying to make the communication
> between kernel to kernel in a Linux Cluster transparent tp TCP/IP.
> So to transmit the data I copy the data from the user area to the kernel
> area and then to the n/w buffers.So what I was trying to do is transfer
> the entire data from user to kernel space at one go(allocating huge memory
> at kernel)....since this is not possible I can always divide the data into
> 30K packets and then copy it to the kernel space...
> 
> P.S I am new to the Linux Kernel ...hence please excuse ne naive comments
> in the above ..
> 
> 
> Amit 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
