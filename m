Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 139536B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 02:52:50 -0500 (EST)
From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Mon, 18 Jan 2010 08:53:31 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <1263754684.724.444.camel@pasglop> <201001180000.23376.rjw@sisk.pl>
In-Reply-To: <201001180000.23376.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001180853.31446.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Am Montag, 18. Januar 2010 00:00:23 schrieb Rafael J. Wysocki:
> On Sunday 17 January 2010, Benjamin Herrenschmidt wrote:
> > On Sun, 2010-01-17 at 14:27 +0100, Rafael J. Wysocki wrote:
> ...
> > However, it's hard to deal with the case of allocations that have
> > already started waiting for IOs. It might be possible to have some VM
> > hook to make them wakeup, re-evaluate the situation and get out of that
> > code path but in any case it would be tricky.
> 
> In the second version of the patch I used an rwsem that made us wait for these
> allocations to complete before we changed gfp_allowed_mask.

This will be a very, very hot semaphore. What's the impact on performance?

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
