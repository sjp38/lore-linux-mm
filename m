Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 93D486B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 06:24:26 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rq2so7749888pbb.34
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 03:24:26 -0700 (PDT)
Received: from psmtp.com ([74.125.245.197])
        by mx.google.com with SMTP id cj2si14493290pbc.267.2013.10.29.03.24.24
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 03:24:25 -0700 (PDT)
Date: Tue, 29 Oct 2013 10:24:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Automatic NUMA balancing patches for tip-urgent/stable
Message-ID: <20131029102419.GC2400@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131024122646.GB2402@suse.de>
 <20131026121148.GC24439@gmail.com>
 <20131029094208.GB2400@suse.de>
 <20131029094856.GA25306@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131029094856.GA25306@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 29, 2013 at 10:48:56AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > Would be nice if you gave me all the specific SHA1 tags of 
> > > sched/core that are required for the fix. We can certainly use a 
> > > range to make it all safer to apply.
> > 
> > Of course. The range of the relevant commits in tip/sched/core is
> > ca4be374c5c0ab3d8b84fb2861d663216281e6ac..778ec5247bb79815af12434980164334fb94cc9e
> > 
> > 904f64a376e663cd459fb7aec4f12e14c39c24b6 mm: numa: Document automatic NUMA balancing sysctls
> > 1d649bccc8c1370e402b85e1d345ad24f3f0d1b5 sched, numa: Comment fixlets
> > f961cab8d55d55d6abc0df08ce2abec8ab56f2c8 mm: numa: Do not account for a hinting fault if we raced
> > 6f2a15fc1df62af3ba3be327877b7e53cb16e878 mm: Wait for THP migrations to complete during NUMA hinting faults
> > 4ee547f994c633f2607d222e2c6385b6fe5f07d8 mm: Prevent parallel splits during THP migration
> > dd83227f0d93fb37d7621a24e8465b13b437faa6 mm: numa: Sanitize task_numa_fault() callsites
> > efeeacf7b94babff85da7e468fc5450fdfab0900 mm: Close races between THP migration and PMD numa clearing
> > 778ec5247bb79815af12434980164334fb94cc9e mm: Account for a THP NUMA hinting update as one PTE update
> 
> These commits don't exist in -tip :-/
> 

Bah, I have tip as a remote tree but looked at my local copy of the
commits in the incorrect branch. Lets try this again

37bf06375c90a42fe07b9bebdb07bc316ae5a0ce..afcae2655b0ab67e65f161b1bb214efcfa1db415

10fc05d0e551146ad6feb0ab8902d28a2d3c5624 mm: numa: Document automatic NUMA balancing sysctls
c69307d533d7aa7cc8894dbbb8a274599f8630d7 sched/numa: Fix comments
0c3a775e1e0b069bf765f8355b723ce0d18dcc6c mm: numa: Do not account for a hinting fault if we raced
ff9042b11a71c81238c70af168cd36b98a6d5a3c mm: Wait for THP migrations to complete during NUMA hinting faults
b8916634b77bffb233d8f2f45703c80343457cc1 mm: Prevent parallel splits during THP migration
8191acbd30c73e45c24ad16c372e0b42cc7ac8f8 mm: numa: Sanitize task_numa_fault() callsites
a54a407fbf7735fd8f7841375574f5d9b0375f93 mm: Close races between THP migration and PMD numa clearing
afcae2655b0ab67e65f161b1bb214efcfa1db415 mm: Account for a THP NUMA hinting update as one PTE update

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
