Date: Tue, 24 Apr 2007 11:43:18 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 13/44] mm: restore KERNEL_DS optimisations
Message-ID: <20070424104318.GA13268@infradead.org>
References: <20070424012346.696840000@suse.de> <20070424013434.155713000@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070424013434.155713000@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 24, 2007 at 11:23:59AM +1000, Nick Piggin wrote:
> Restore the KERNEL_DS optimisation, especially helpful to the 2copy write
> path.
> 
> This may be a pretty questionable gain in most cases, especially after the
> legacy 2copy write path is removed, but it doesn't cost much.

Well, it gets removed later and sets a bad precedence.  Instead of
adding hacks we should have proper methods for kernel-space read/writes.
Especially as the latter are a lot simpler and most of the magic
in this patch series is not needed.  I'll start this work once
your patch series is in.

In general there seems to be a lot of stuff in the earlier patches
that just goes away later and doesn't make much sense in the series.
Is there a good reason not to simply consolidate out those changes
completely?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
