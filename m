Date: Sat, 12 Jul 2003 02:02:14 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.5.74-mm3
Message-ID: <20030711160214.GH7348@krispykreme>
References: <20030708223548.791247f5.akpm@osdl.org> <200307101821.h6AIL87u013299@turing-police.cc.vt.edu> <20030711082532.GA432@fib011235813.fsnet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030711082532.GA432@fib011235813.fsnet.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Thornber <thornber@sistina.com>
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The v1 ioctl interface passes the dev in as a __kernel_dev_t, so
> unfortunately if you change the size of __kernel_dev_t you will have
> to rebuild the tools.
> 
> The v4 ioctl interface just uses a __u64 which I hope will be future
> proof.

This was the only thing that made the 32bit ioctls different to the 64bit 
ones on ppc64, so changing it to __u64 is a good thing.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
