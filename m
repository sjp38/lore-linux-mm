Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2027A6B02CF
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 13:53:40 -0400 (EDT)
Date: Sat, 23 Jun 2012 19:50:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm v2 10/11] mm: remove ARM arch_get_unmapped_area
 functions
Message-ID: <20120623175007.GQ27816@cmpxchg.org>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
 <1340315835-28571-11-git-send-email-riel@surriel.com>
 <20120622222756.GF30087@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120622222756.GF30087@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Fri, Jun 22, 2012 at 11:27:56PM +0100, Russell King - ARM Linux wrote:
> On Thu, Jun 21, 2012 at 05:57:14PM -0400, Rik van Riel wrote:
> > Remove the ARM special variants of arch_get_unmapped_area since the
> > generic functions should now be able to handle everything.
> > 
> > ARM only needs page colouring if cache_is_vipt_aliasing; leave
> > shm_align_mask at PAGE_SIZE-1 unless we need colouring.
> > 
> > Untested because I have no ARM hardware.
> 
> And I'll need other bits of the patch set to be able to test this for you...

I also prefer getting 10 mails to make sense of that one change in a
series over getting that one without context.  Subjects are usually
obvious enough to quickly find out which stuff was meant for you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
