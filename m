Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60EDF6B007E
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 18:20:03 -0500 (EST)
Date: Sat, 28 Feb 2009 18:19:56 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch][rfc] mm: new address space calls
Message-ID: <20090228231956.GA11191@infradead.org>
References: <20090225104839.GG22785@wotan.suse.de> <1235595597.32346.77.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235595597.32346.77.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 03:59:57PM -0500, Chris Mason wrote:
> One problem I have with the btrfs extent state code is that I might
> choose to release the extent state in releasepage, but the VM might not
> choose to free the page.  So I've got an up to date page without any of
> the rest of my state.
> 
> Which of these ops covers that? ;)  I'd love to help better document the
> requirements for these callbacks, I find it confusing every time.

releasepage has also another problem.  It only gets called after
discard_buffer discarded lots of valuable information from the buffers,
which gets XFS into really bad trouble as that drops information if
there is a delalloc extent.

I'd really like to see some major overhaul in that area, and that also
extende to documentation (or just naming, why is block_invalidatepage
calling into a method called ->releasepage, but there also is a
->invalidatepage that gets called from truncate*page routines..)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
