Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC4D6B0089
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 21:38:22 -0500 (EST)
Date: Sun, 1 Mar 2009 03:38:18 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: new address space calls
Message-ID: <20090301023818.GA16742@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de> <1235595597.32346.77.camel@think.oraclecorp.com> <20090228231956.GA11191@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228231956.GA11191@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Chris Mason <chris.mason@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 28, 2009 at 06:19:56PM -0500, Christoph Hellwig wrote:
> On Wed, Feb 25, 2009 at 03:59:57PM -0500, Chris Mason wrote:
> > One problem I have with the btrfs extent state code is that I might
> > choose to release the extent state in releasepage, but the VM might not
> > choose to free the page.  So I've got an up to date page without any of
> > the rest of my state.
> > 
> > Which of these ops covers that? ;)  I'd love to help better document the
> > requirements for these callbacks, I find it confusing every time.
> 
> releasepage has also another problem.  It only gets called after
> discard_buffer discarded lots of valuable information from the buffers,
> which gets XFS into really bad trouble as that drops information if
> there is a delalloc extent.

Then I think it just needs to provide its own invalidatepage?


> I'd really like to see some major overhaul in that area, and that also
> extende to documentation (or just naming, why is block_invalidatepage
> calling into a method called ->releasepage, but there also is a
> ->invalidatepage that gets called from truncate*page routines..)

Those convoluted call paths are really bloody annoying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
