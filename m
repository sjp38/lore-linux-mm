Date: Fri, 11 Apr 2003 01:25:04 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
Message-ID: <20030410152504.GA18082@krispykreme>
References: <20030410122421.A17889@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030410122421.A17889@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@zip.com.au, davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>   This is a performance speed up and some minor indendation fixups.
> 
>   The problem is that the bootmem code is (a) hugely slow and (b) has
>   execution that grow quadratically with the size of the bootmap bitmap.
>   This causes noticable slowdowns, especially on machines with (relatively)
>   large holes in the physical memory map.  Issue (b) is addressed by
>   maintaining the "last_success" cache, so that we start the next search
>   from the place where we last found some memory (this part of the patch
>   could stand additional reviewing/testing).  Issue (a) is addressed by
>   using find_next_zero_bit() instead of the slow bit-by-bit testing.

FYI I have some ppc64 machines with a memory layout of

1GB MEM
3GB IO
63GB MEM

And see the same problem.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
