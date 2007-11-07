Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id lA7FZCf5032342
	for <linux-mm@kvack.org>; Wed, 7 Nov 2007 10:35:12 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA7GGIUM117832
	for <linux-mm@kvack.org>; Wed, 7 Nov 2007 09:35:45 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA7Fvkaw013961
	for <linux-mm@kvack.org>; Wed, 7 Nov 2007 08:57:46 -0700
Subject: Re: migratepage failures on reiserfs
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071107145619.GA32737@skynet.ie>
References: <20071030135442.5d33c61c@think.oraclecorp.com>
	 <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030185840.48f5a10b@think.oraclecorp.com>
	 <1193847261.17412.13.camel@dyn9047017100.beaverton.ibm.com>
	 <20071031134006.2ecd520b@think.oraclecorp.com>
	 <1193935137.26106.5.camel@dyn9047017100.beaverton.ibm.com>
	 <20071101115103.62de4b2e@think.oraclecorp.com>
	 <1193940626.26106.13.camel@dyn9047017100.beaverton.ibm.com>
	 <20071105102335.GA6272@skynet.ie>
	 <Pine.LNX.4.64.0711051446130.20927@schroedinger.engr.sgi.com>
	 <20071107145619.GA32737@skynet.ie>
Content-Type: text/plain
Date: Wed, 07 Nov 2007 07:58:57 -0800
Message-Id: <1194451138.26782.30.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Chris Mason <chris.mason@oracle.com>, reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-07 at 14:56 +0000, Mel Gorman wrote:
> On (05/11/07 14:46), Christoph Lameter didst pronounce:
> > On Mon, 5 Nov 2007, Mel Gorman wrote:
> > 
> > > The grow_dev_page() pages should be reclaimable even though migration
> > > is not supported for those pages? They were marked movable as it was
> > > useful for lumpy reclaim taking back pages for hugepage allocations and
> > > the like. Would it make sense for memory unremove to attempt migration
> > > first and reclaim second?
> > 
> > Note that a page is still movable even if there is no file system method 
> > for migration available. In that case the page needs to be cleaned before 
> > it can be moved.
> > 
> 
> Badari, do you know if the pages failed to migrate because they were
> dirty or because the filesystem simply had ownership of the pages and
> wouldn't let them go?

>From the debug, it looks like all the buffers are clean and they
have a b_count == 1. So drop_buffers() fails to release the buffer.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
