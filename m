Date: Thu, 20 Apr 2000 13:30:17 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: questions on having a driver pin user memory for DMA
Message-ID: <20000420133017.D16473@redhat.com>
References: <38FE3B08.9FFB4C4E@giganet.com> <m1g0shi8cm.fsf@flinx.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1g0shi8cm.fsf@flinx.biederman.org>; from ebiederm+eric@ccr.net on Thu, Apr 20, 2000 at 01:39:53AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Weimin Tchen <wtchen@giganet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Apr 20, 2000 at 01:39:53AM -0500, Eric W. Biederman wrote:
> 
> The rules of thumb on this issue are:
> 1) Don't pin user memory let user space mmap driver memory.

map_user_kiobuf is intended to allow user space buffers to be mapped
the other way safely.

> 2) If you must have access to user memory use the evolving kiobuf
>    interface.  But that is mostly useful for the single shot
>    read/write case.  

There are not many problems with long-lived buffers mapped by kiobufs.
The fork problem is the main one, but we already have patches for that.

> I'm a little dense, with all of the headers and trailers
> that are put on packets how can it be efficient to DMA to/from
> user memory?  You have to look at everything to compute checksums
> etc.  

VIA != IP.

> Your interface sounds like it walks around all of the networking
> code in the kernel.  How can that be good?

VIA != networking.  VIA == messaging.  It provides for very (VERY) 
low latency user-space-to-user-space transfers, bypassing the O/S
entirely by allowing the O/S to grant the application direct, 
limited access to the HW control queues.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
