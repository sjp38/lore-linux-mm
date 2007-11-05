Date: Mon, 5 Nov 2007 14:46:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: migratepage failures on reiserfs
In-Reply-To: <20071105102335.GA6272@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711051446130.20927@schroedinger.engr.sgi.com>
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
 <20071030135442.5d33c61c@think.oraclecorp.com>
 <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
 <20071030185840.48f5a10b@think.oraclecorp.com>
 <1193847261.17412.13.camel@dyn9047017100.beaverton.ibm.com>
 <20071031134006.2ecd520b@think.oraclecorp.com>
 <1193935137.26106.5.camel@dyn9047017100.beaverton.ibm.com>
 <20071101115103.62de4b2e@think.oraclecorp.com>
 <1193940626.26106.13.camel@dyn9047017100.beaverton.ibm.com>
 <20071105102335.GA6272@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Chris Mason <chris.mason@oracle.com>, reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Nov 2007, Mel Gorman wrote:

> The grow_dev_page() pages should be reclaimable even though migration
> is not supported for those pages? They were marked movable as it was
> useful for lumpy reclaim taking back pages for hugepage allocations and
> the like. Would it make sense for memory unremove to attempt migration
> first and reclaim second?

Note that a page is still movable even if there is no file system method 
for migration available. In that case the page needs to be cleaned before 
it can be moved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
