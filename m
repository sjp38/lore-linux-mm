Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 56A0A6B004F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 03:46:56 -0400 (EDT)
Date: Thu, 28 May 2009 09:54:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [1/16] HWPOISON: Add page flag for poisoned pages
Message-ID: <20090528075416.GY1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201226.CCCBB1D028F@basil.firstfloor.org> <20090527221510.5e418e97@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090527221510.5e418e97@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 10:15:10PM +0100, Alan Cox wrote:
> On Wed, 27 May 2009 22:12:26 +0200 (CEST)
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > 
> > Hardware poisoned pages need special handling in the VM and shouldn't be 
> > touched again. This requires a new page flag. Define it here.
> 
> Why can't you use PG_reserved ? That already indicates the page may not
> even be present (which is effectively your situation at that point).

Right now a page must be present with PG_reserved, otherwise /dev/mem, /proc/kcore
lots of other things will explode.

> Given lots of other hardware platforms we support bus error, machine
> check, explode or do random undefined fun things when you touch pages
> that don't exist I'm not sure I see why poisoned is different here ?

It's really a special case for lots of things and mixing it up with
PG_reserved is not very useful I think. Also page flags are not 
that tight a resource anymore anyways. I think it's better to have
it separated.

However I would expect that other architectures would use poisoned
pages too for their own similar issues. It's not really a x86 specific
concept.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
