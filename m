Date: Mon, 30 Jul 2007 11:12:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070727232753.GA10311@localdomain>
Message-ID: <Pine.LNX.4.64.0707301111440.743@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@cthulhu.engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007, Ravikiran G Thirumalai wrote:

> Don't go into zone_reclaim if there are no reclaimable pages.
> 
> While using RAMFS as scratch space for some tests, we found one of the
> processes got into zone reclaim, and got stuck trying to reclaim pages
> from a zone.  On examination of the code, we found that the VM was fooled
> into believing that the zone had reclaimable pages, when it actually had
> RAMFS backed pages, which could not be written back to the disk.
> 
> Fix this by adding a zvc "NR_PSEUDO_FS_PAGES" for file pages with no
> backing store, and using this counter to determine if reclaim is possible.

That is another case where we need a counter for unreclaimable pages. The 
other types of pages that need this as mlocked pages and anonymous pages 
if we have no swap. Could you look at Nick's and my work on mlocked pages 
and come up with a general solution that covers all these cases?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
