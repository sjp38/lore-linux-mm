Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8386E6B004D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 12:30:46 -0400 (EDT)
Date: Fri, 29 May 2009 18:37:57 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [1/16] HWPOISON: Add page flag for poisoned pages
Message-ID: <20090529163757.GX1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201226.CCCBB1D028F@basil.firstfloor.org> <20090527221510.5e418e97@lxorguk.ukuu.org.uk> <20090528075416.GY1065@one.firstfloor.org> <4A2008F0.1070304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A2008F0.1070304@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 29, 2009 at 12:10:24PM -0400, Rik van Riel wrote:
> Andi Kleen wrote:
> >On Wed, May 27, 2009 at 10:15:10PM +0100, Alan Cox wrote:
> >>On Wed, 27 May 2009 22:12:26 +0200 (CEST)
> >>Andi Kleen <andi@firstfloor.org> wrote:
> >>
> >>>Hardware poisoned pages need special handling in the VM and shouldn't be 
> >>>touched again. This requires a new page flag. Define it here.
> >>Why can't you use PG_reserved ? That already indicates the page may not
> >>even be present (which is effectively your situation at that point).
> >
> >Right now a page must be present with PG_reserved, otherwise /dev/mem, 
> >/proc/kcore
> >lots of other things will explode.
> 
> Could we use a combination of, say PG_reserved and
> PG_writeback to keep /dev/mem and /proc/kcore from
> exploding ?

They should just check for poisoned pages. Fengguang has some patches
to add checks, but they need more work before they can be merged.

The interesting part is also fixing vmcore, as in memory outside
your memory.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
