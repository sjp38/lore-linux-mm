Date: Thu, 28 Sep 2000 17:12:34 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: 2.4.0-t9p7 and mmap002 - freeze
In-Reply-To: <Pine.LNX.4.21.0009280710230.1814-100000@duckman.distro.conectiva>
Message-ID: <Pine.Linu.4.10.10009281625130.763-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Rik van Riel wrote:

> On Thu, 28 Sep 2000, Mike Galbraith wrote:
> > On Wed, 27 Sep 2000, Roger Larsson wrote:
> > 
> > > Tried latest patch with the same result - freeze...
> > 
> > Ditto.
> 
> I'm finally back from Linux Kongress and Linux Expo and
> will look at the latest tree and integrate the fixes I
> made while on the road later today (after I get some
> sleep).
> 
> I have fixed this particular bug, which was caused by
> us moving unfreeable pages to the inactive_dirty list
> and back again, while not accomplishing anything useful.
> 
> The fix for this is trivial and I'll post it later
> today (cleaned up and working in the current source
> tree).

Cool!

I've had a tiny bit of success (swptst _passed_ once, and currently
locks with 1 inactive_clean page instead of always 0;) by fiddling
with __alloc_pages() a bit.

One thing that I _think_ may be a problem is using stale information.
direct_reclaim is set once, it's set without checking that a reclaim
is possible, and it's not updated as we proceed although the situation
may change.

Another thing I'm curious about is increasing memory pressure in the
event of an allocation failure (retry).  Why do we do that?

Comments?

	-Mike (down periscope.. ahead dead slow;)

P.S.  in buffer.c, we do a LockPage(), but no UnlockPage() in the
case of no_buffer_head.. is that correct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
