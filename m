Message-ID: <3D73C3C3.B48FE419@zip.com.au>
Date: Mon, 02 Sep 2002 13:02:11 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: Fwd: Re: slablru for 2.5.32-mm1
References: <200209021137.41132.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> ...
> The pages which back slab objects may be manually marked as referenced
> via kmem_touch_page(), which simply sets PG_referenced.  It _could_ use
> mark_page_accessed(), but doesn't.  So slab pages will always remain on
> the inactive list.
> 
> --
> Since shrinking a slab is a much lower cost operation than a swap we keep
> the slab pages in inactive where they age faster.  Note I did test with slabs
> following the normal active/inactive cycle - we swapped more.
> --

It worries me that we may be keeping a large number of unfreeable
slab pages on the inactive list.  These will churn around creating 
extra work, but more significantly they will revent refill_inactive
from bringing down really-reclaimable pages.
 
> ...
> Actually the BUG_ON conversion were done by Craig Kulesa.   It would be a
> good idea to credit him with the initial port to 2.5 - he did to the work.

OK.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
