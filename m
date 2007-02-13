Date: Tue, 13 Feb 2007 06:52:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try 3)
Message-ID: <20070213055229.GB18792@wotan.suse.de>
References: <20070210001844.21921.48605.sendpatchset@linux.site> <1171147495.31563.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1171147495.31563.5.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 10, 2007 at 11:44:55PM +0100, Martin Schwidefsky wrote:
> On Sat, 2007-02-10 at 03:31 +0100, Nick Piggin wrote:
> > SetNewPageUptodate does not do the S390 page_test_and_clear_dirty, so
> > I'd like to make sure that's OK.
> 
> An I/O operation on s390 will set the dirty bit for a page. That is the

Oh, OK.

> reason to have SetPageUptodate clear the per page dirty bit when the
> page is made uptodate the first time. Otherwise we end up writing each
> page back to its backing device at least once. If SetNewPageUptodate is
> used on new anonymous pages exclusively I don't see a problem in
> omitting the page_test_clear_dirty.

Thanks for the confirmation.

I'll obviously have to resend a new patchset because I made a silly
paper-bag bug with this one. May I say that the s390 specific part of
the change is acked-by: you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
