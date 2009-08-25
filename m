Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20C516B00F2
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:51:36 -0400 (EDT)
Date: Wed, 26 Aug 2009 00:50:58 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/vmscan: change generic_file_write() comment to do_sync_write()
Message-ID: <20090825225058.GA28285@lst.de>
References: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca> <20090825222237.GA27240@lst.de> <alpine.DEB.2.00.0908251535070.20886@kernelhack.brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908251535070.20886@kernelhack.brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 03:45:44PM -0700, Vincent Li wrote:
> There is no __generic_file_aio_write, but __generic_file_aio_write_nolock, 
> generic_file_aio_write and generic_file_aio_write_nolock. 

Indeed right now there is, but it gets renamed to
__generic_file_aio_write in a patchset queued up ;-)

> 
> I read the commit 543ade1fc9, it seems it replaced all .write = generic_file_write to 
> .write = do_sync_write. I thought they are the same.

That's true.  But do_sync_write is just a wrapper waiting for the
.aio_write method, for which the generic_file_write equivalent is
generic_file_aio_writev which calls into the above fuction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
