Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A36416B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:17:59 -0500 (EST)
Date: Mon, 18 Jan 2010 11:17:57 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume
 (was: Re: Memory allocations in .suspend became very unreliable)
In-Reply-To: <201001180853.31446.oliver@neukum.org>
Message-ID: <Pine.LNX.4.44L0.1001181116340.6554-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oliver Neukum <oliver@neukum.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-pm@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jan 2010, Oliver Neukum wrote:

> Am Montag, 18. Januar 2010 00:00:23 schrieb Rafael J. Wysocki:
> > On Sunday 17 January 2010, Benjamin Herrenschmidt wrote:
> > > On Sun, 2010-01-17 at 14:27 +0100, Rafael J. Wysocki wrote:
> > ...
> > > However, it's hard to deal with the case of allocations that have
> > > already started waiting for IOs. It might be possible to have some VM
> > > hook to make them wakeup, re-evaluate the situation and get out of that
> > > code path but in any case it would be tricky.
> > 
> > In the second version of the patch I used an rwsem that made us wait for these
> > allocations to complete before we changed gfp_allowed_mask.
> 
> This will be a very, very hot semaphore. What's the impact on performance?

Can it be replaced with something having lower overhead, such as SRCU?

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
