Message-ID: <3D48639C.E0EF9B71@zip.com.au>
Date: Wed, 31 Jul 2002 15:24:28 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: throttling dirtiers
References: <3D485775.14A8B483@zip.com.au> <Pine.LNX.4.44L.0207311853150.23404-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Benjamin LaHaise <bcrl@redhat.com>, William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 31 Jul 2002, Andrew Morton wrote:
> 
> > > These ingredients are already in 2.4-rmap.
> >
> > It doesn't seem to work.  The -ac kernel has weird stalls on
> > storms of ext3 writeback.
> 
> Maybe you shouldn't have cut off the other line from my
> 2-line mail ;)))
> 
> The most probable reason for the stalls is the fact that
> page_launder (like shrink_cache) will try to write out
> the complete inactive list if it's almost full of dirty
> pages, so the system will still be stuck in __get_request_wait
> seconds after the first few megabytes of the paged out
> inactive pages have been cleaned already.

I doubt if it's that, although it might be.

It happens just during a kernel build, 768M of RAM.  And/or
during big CVS operations.  Possibly it's due to ext3 checkpointing.
In ordered data mode with these workloads, kupdate should normally
be doing that, so it may be a kupdate problem, or a missing
wakeup_bdflush.

It's not a big issue - people would be unlikely to notice unless
they were switching between kernels, and were ravingly impatient,
like me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
