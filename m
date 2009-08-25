Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2634F6B00F0
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:45:52 -0400 (EDT)
Date: Tue, 25 Aug 2009 15:45:44 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm/vmscan: change generic_file_write() comment to
 do_sync_write()
In-Reply-To: <20090825222237.GA27240@lst.de>
Message-ID: <alpine.DEB.2.00.0908251535070.20886@kernelhack.brc.ubc.ca>
References: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca> <20090825222237.GA27240@lst.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Vincent Li <macli@brc.ubc.ca>, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009, Christoph Hellwig wrote:

> On Tue, Aug 25, 2009 at 03:18:08PM -0700, Vincent Li wrote:
> > Commit 543ade1fc9 (Streamline generic_file_* interfaces and filemap cleanups)
> > removed generic_file_write() in filemap. For consistency, change the comment in
> > vmscan pageout() to do_sync_write().
> 
> I think the right replacement would be __generic_file_aio_write.  But

There is no __generic_file_aio_write, but __generic_file_aio_write_nolock, 
generic_file_aio_write and generic_file_aio_write_nolock. 

I read the commit 543ade1fc9, it seems it replaced all .write = generic_file_write to 
.write = do_sync_write. I thought they are the same.

> from a quick glance over the code don't have the slightest idea what it
> is referring to.

I read the code  over and over again, still no clue about the comment :-(. 

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
