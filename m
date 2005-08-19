Date: Fri, 19 Aug 2005 11:39:40 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Preswapping
In-Reply-To: <e692861c05081814582671a6a3@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0508191137350.15836@schroedinger.engr.sgi.com>
References: <e692861c05081814582671a6a3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gregory Maxwell <gmaxwell@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Gregory Maxwell wrote:

> With the ability to measure something approximating least frequently
> used inactive pages now, would it not make sense to begin more
> aggressive nonevicting preswapping?

Maybe. What would be the overhead for cases in which swapping is not 
needed?
 
> For example, if the swap disks are not busy, we scan the least
> frequently used inactive pages, and write them out in nice large
> chunks. The pages are moved to another list, but not evicted from
> memory. The normal swapping algorithm is used to decide when/if to
> actually evict these pages from memory.  If they are used prior to
> being evicted, they can be remarked active (and their blocks on swap
> marked as unused) without a disk seek.

If you write out the pages then one could simply mark them as clean and 
note where the location is in swap space.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
