Received: from shaeffer by neuralscape.com with local (Exim 4.12)
	id 18hk0h-0003tb-00
	for linux-mm@kvack.org; Sat, 08 Feb 2003 21:28:11 -0800
Date: Sat, 8 Feb 2003 21:28:11 -0800
From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: vmalloc errors in 2.4.20
Message-ID: <20030209052811.GA14948@synapse.neuralscape.com>
References: <20030209043937.7134.qmail@web21309.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030209043937.7134.qmail@web21309.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 08, 2003 at 08:39:37PM -0800, sandeep uttamchandani wrote:
> The linux kernel 2.4.20 seems to have problems with
> vmalloc. Here is what I did:
> 
> In my driver, I try to allocate a buffer of size 512K
> using vmalloc ( kmalloc cannot allocate more than
> 128K). It generates a kernel oops message saying that
> the virtual memory cannot be allocated.
> 
> Thanks,
> Sandeep
---end quoted text---

Hi Sandeep,

I'm running a stock 2.4.20 kernel and put together a little test module that
allocates 512k memory with vmalloc. I have no problems on an Intel X86. I
also ran it allocating 1MByte as well.

cheers,
Karen
-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
