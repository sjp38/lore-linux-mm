Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B21528D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 20:54:29 -0400 (EDT)
Received: by iyh42 with SMTP id 42so263104iyh.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 17:54:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421161402.GS5611@random.random>
References: <20110415101248.GB22688@suse.de>
	<BANLkTik7H+cmA8iToV4j1ncbQqeraCaeTg@mail.gmail.com>
	<20110421110841.GA612@suse.de>
	<20110421142636.GA1835@barrios-desktop>
	<20110421160057.GA28712@suse.de>
	<20110421161402.GS5611@random.random>
Date: Fri, 22 Apr 2011 09:54:24 +0900
Message-ID: <BANLkTi=+fGe-hrV3c8r2jKzWG2BHU0GsFA@mail.gmail.com>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

Hi Andrea,

On Fri, Apr 22, 2011 at 1:14 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Thu, Apr 21, 2011 at 05:00:57PM +0100, Mel Gorman wrote:
>> If you want to create a new patch with either your comment or mine
>> (whichever you prefer) I'll add my ack. I'm about to drop offline
>> for a few days but if it's still there Tuesday, I'll put together an
>> appropriate patch and submit. I'd keep it separate from the other patch
>> because it's a performance fix (which I'd like to see in -stable) where
>> as this is more of a cleanup IMO.
>
> I think the older patch should have more priority agreed. This one may
> actually waste cpu cycles overall, rather than saving them, it
> shouldn't be a common occurrence.
>
> From a code consistency point of view maybe we should just implement a
> pte_alloc macro (to put after pte_alloc_map) and use it in both
> places, and hide the glory details of the unlikely in the macro. When
> implementing pte_alloc, I suggest also adding unlikely to both, I mean
> we added unlikely to the fast path ok, but __pte_alloc is orders of
> magnitude less likely to fail than pte_none, and it still runs 1 every
> 512 4k page faults, so I think __pte_alloc deserves an unlikely too.
>
> Minchan, you suggested this cleanup, so I suggest you to send a patch,
> but if you're busy we can help.

It's no problem to send a patch but I can do it at out-of-office time.
Maybe weekend. :)
Before doing that, let's clear the point. You mentioned  it shouldn't
be a common occurrence but you are suggesting we should do for code
consistency POV. Am I right?

>
> Thanks!
> Andrea
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
