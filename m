Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F7F46B0062
	for <linux-mm@kvack.org>; Fri, 15 May 2009 11:22:08 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 5/6] PM/Hibernate: Do not release preallocated memory unnecessarily (rev. 2)
Date: Fri, 15 May 2009 16:52:16 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905141952.21267.rjw@sisk.pl> <20090515131115.GC1976@elf.ucw.cz>
In-Reply-To: <20090515131115.GC1976@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905151652.17418.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 15 May 2009, Pavel Machek wrote:
> On Thu 2009-05-14 19:52:20, Rafael J. Wysocki wrote:
> > On Thursday 14 May 2009, Pavel Machek wrote:
> > > Hi!
> > > 
> > > > Since the hibernation code is now going to use allocations of memory
> > > > to make enough room for the image, it can also use the page frames
> > > > allocated at this stage as image page frames.  The low-level
> > > > hibernation code needs to be rearranged for this purpose, but it
> > > > allows us to avoid freeing a great number of pages and allocating
> > > > these same pages once again later, so it generally is worth doing.
> > > > 
> > > > [rev. 2: Take highmem into account correctly.]
> > > 
> > > I don't get it. What is advantage of this patch? It makes the code
> > > more complex... Is it supposed to be faster?
> > 
> > Yes, in some test cases it is reported to be faster (along with [4/6],
> > actually).
> > 
> > Besides, we'd like to get rid of shrink_all_memory() eventually and it is a
> > step in this direction.
> 
> Ok, but maybe we should wait with applying this until we have patches
> that actually get us rid of shrink_all_memory?

Well, the $subject patch is only an optimization of top of [4/6] that you've
just acked. ;-)

In fact [4/6] changes the approach to the memory shrinking and the $subject
one is only to avoid freeing all of the memory we've allocated and allocating
it once again later.

> Maybe it will not be feasible for speed reasons after all, or something...

At least it allows us to drop shrink_all_memory() easily for the sake of
experimentation (it's sufficient to comment out just one line of code for this
purpose).

Besides, after this patchset shrink_all_memory() is _only_ needed for
performance, so it should be possible to get rid of it relatively quckly.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
