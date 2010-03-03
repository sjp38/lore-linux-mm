Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52C916B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:15:13 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o230F9FT016870
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 16:15:09 -0800
Received: from pxi29 (pxi29.prod.google.com [10.243.27.29])
	by kpbe14.cbf.corp.google.com with ESMTP id o230F11B001926
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 16:15:02 -0800
Received: by pxi29 with SMTP id 29so255407pxi.5
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 16:15:01 -0800 (PST)
Date: Tue, 2 Mar 2010 16:14:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
 allocators
In-Reply-To: <28c262361003012029j1d17a0dch8987c0d6d939959e@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003021610530.14687@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com> <28c262361003010802o7de2a32ci913b3833074af9eb@mail.gmail.com> <28c262361003012029j1d17a0dch8987c0d6d939959e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010, Minchan Kim wrote:

> > Why do you reset nice value which set by set_kswapd_nice?
> 
> My point is that you reset nice value(which is boosted at wakeup_kswapd) to 0
> before calling balance_pgdat. It means kswapd could be rescheduled by nice 0
> before really reclaim happens by balance_pgdat.

wakeup_kswapd() wakes up kswapd at the finish_wait() point so that it has 
the nice value set by set_kswapd_nice() when it calls balance_pgdat(), 
loops, and then sets it back to the default nice level of 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
