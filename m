Subject: Re: madvise(2) MADV_SEQUENTIAL behavior
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1216163022.3443.156.camel@zenigma>
References: <1216163022.3443.156.camel@zenigma>
Content-Type: text/plain
Date: Wed, 16 Jul 2008 14:14:55 +0200
Message-Id: <1216210495.5232.47.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Rannaud <eric.rannaud@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-15 at 23:03 +0000, Eric Rannaud wrote:
> mm/madvise.c and madvise(2) say:
> 
>  *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
>  *		once, so they can be aggressively read ahead, and
>  *		can be freed soon after they are accessed.
> 
> 
> But as the sample program at the end of this post shows, and as I
> understand the code in mm/filemap.c, MADV_SEQUENTIAL will only increase
> the amount of read ahead for the specified page range, but will not
> influence the rate at which the pages just read will be freed from
> memory.

Correct, various attempts have been made to actually implement this, but
non made it through.

My last attempt was:
  http://lkml.org/lkml/2007/7/21/219

Rik recently tried something else based on his split-lru series:
  http://lkml.org/lkml/2008/7/15/465



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
