Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B341E6B0088
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 15:55:43 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Mon, 18 Jan 2010 21:56:26 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001180000.23376.rjw@sisk.pl> <201001180853.31446.oliver@neukum.org>
In-Reply-To: <201001180853.31446.oliver@neukum.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001182156.26878.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Oliver Neukum <oliver@neukum.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Monday 18 January 2010, Oliver Neukum wrote:
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

rwsems are highly optimized AFAICT, but this is a good question of course.

I have no data at the moment.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
