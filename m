Date: Tue, 24 Apr 2007 13:03:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 13/44] mm: restore KERNEL_DS optimisations
Message-ID: <20070424110352.GB32738@wotan.suse.de>
References: <20070424012346.696840000@suse.de> <20070424013434.155713000@suse.de> <20070424104318.GA13268@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070424104318.GA13268@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 24, 2007 at 11:43:18AM +0100, Christoph Hellwig wrote:
> On Tue, Apr 24, 2007 at 11:23:59AM +1000, Nick Piggin wrote:
> > Restore the KERNEL_DS optimisation, especially helpful to the 2copy write
> > path.
> > 
> > This may be a pretty questionable gain in most cases, especially after the
> > legacy 2copy write path is removed, but it doesn't cost much.
> 
> Well, it gets removed later and sets a bad precedence.  Instead of
> adding hacks we should have proper methods for kernel-space read/writes.
> Especially as the latter are a lot simpler and most of the magic
> in this patch series is not needed.  I'll start this work once
> your patch series is in.

It was removed earlier and put back in here. I agree it isn't so
important, but again it does help that the patchset introduces no
obvious regression. You could remove it in your patchset?


> In general there seems to be a lot of stuff in the earlier patches
> that just goes away later and doesn't make much sense in the series.
> Is there a good reason not to simply consolidate out those changes
> completely?

I guess the first half of the patchset -- the slow deadlock fix for
the old prepare_write path -- came about because that's the only
reasonable way I could find to fix it. I initially thought it would
take a lot longer to convert all filesystems and that we might want
to stay compatible for a while, which is why I wanted to ensure that
was working.

Basically I can't really see which ones you think I should merge and
be able retain a working kernel?

Granted there are a couple of bugfixes and some slightly orthogonal
cleanups in there, but I just thought I'd submit them in the same
series because it was a little easier for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
