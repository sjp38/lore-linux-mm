Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ECDE26B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 04:34:02 -0400 (EDT)
Date: Tue, 7 Jul 2009 11:17:22 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/3] fs: convert ext2,tmpfs to new truncate
Message-ID: <20090707091722.GZ2714@wotan.suse.de>
References: <20090706165438.GQ2714@wotan.suse.de> <20090706165629.GS2714@wotan.suse.de> <20090706172838.GC26042@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090706172838.GC26042@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 06, 2009 at 01:28:38PM -0400, Christoph Hellwig wrote:
> On Mon, Jul 06, 2009 at 06:56:29PM +0200, Nick Piggin wrote:
> > 
> > Convert filemap_xip.c, buffer.c, and some filesystems to the new truncate
> > convention. Converting generic helpers is using some ugly code (testing
> > for i_op->ftruncate) to distinguish new and old callers... better
> > alternative might be just define a new function for these guys.
> 
> Splitting generic preparations, ext2 and shmem into separate patch would
> be a tad cleaner I think.

I actually reworked this so callers of those functions should do the
i_size update and truncate_pagecache (which gives more flexibility
anyway). And so no further changes required there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
