Date: Tue, 30 May 2006 09:12:53 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [rfc][patch] remove racy sync_page?
Message-ID: <20060530131253.GC1297@filer.fsl.cs.sunysb.edu>
References: <447AC011.8050708@yahoo.com.au> <20060530055115.GD18626@filer.fsl.cs.sunysb.edu> <447BE9E9.4000907@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <447BE9E9.4000907@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Chris Mason <mason@suse.com>, Andrea Arcangeli <andrea@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, Linus Torvalds <torvalds@osdl.org>, mike@halcrow.us, ezk@cs.sunysb.edu
List-ID: <linux-mm.kvack.org>

On Tue, May 30, 2006 at 04:44:57PM +1000, Nick Piggin wrote:
> Josef Sipek wrote:
> >On Mon, May 29, 2006 at 07:34:09PM +1000, Nick Piggin wrote:
> >...
> >
> >>Can we get rid of the whole thing, confusing memory barriers and all?
> >>Nobody uses anything but the default sync_page
> >
> >
> >I feel like I must say this: there are some file systems that live
> >outside the kernel (at least for now) that do _NOT_ use the default
> >sync_page. All the stackable file systems that are based on FiST [1],
> >such as Unionfs [2] and eCryptfs (currently in -mm) [3] (respective
> >authors CC'd). As an example, Unionfs must decide which lower file
> >system page to sync (since it may have several to chose from).
> 
> OK, noted. Thanks. Luckily for them it looks like sync_page might
> stay for other reasons (eg. raid) ;)
> 
> Any good reasons they are not in the tree?

eCryptfs got recently into -mm, my guess would be that Mike Halcrow will
try to get it into vanilla in the coming months.

Unionfs is into process of getting ready for a review by the fs-devel &
linux-kernel crowd.

Josef "Jeff" Sipek.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
