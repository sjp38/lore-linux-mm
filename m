Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D6D666B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 05:49:02 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so8242353pdj.20
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:49:02 -0700 (PDT)
Received: from psmtp.com ([74.125.245.125])
        by mx.google.com with SMTP id kg8si15410280pad.9.2013.10.29.02.49.01
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 02:49:01 -0700 (PDT)
Received: by mail-ea0-f173.google.com with SMTP id g10so2805340eak.18
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:48:59 -0700 (PDT)
Date: Tue, 29 Oct 2013 10:48:56 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Automatic NUMA balancing patches for tip-urgent/stable
Message-ID: <20131029094856.GA25306@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131024122646.GB2402@suse.de>
 <20131026121148.GC24439@gmail.com>
 <20131029094208.GB2400@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131029094208.GB2400@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > Would be nice if you gave me all the specific SHA1 tags of 
> > sched/core that are required for the fix. We can certainly use a 
> > range to make it all safer to apply.
> 
> Of course. The range of the relevant commits in tip/sched/core is
> ca4be374c5c0ab3d8b84fb2861d663216281e6ac..778ec5247bb79815af12434980164334fb94cc9e
> 
> 904f64a376e663cd459fb7aec4f12e14c39c24b6 mm: numa: Document automatic NUMA balancing sysctls
> 1d649bccc8c1370e402b85e1d345ad24f3f0d1b5 sched, numa: Comment fixlets
> f961cab8d55d55d6abc0df08ce2abec8ab56f2c8 mm: numa: Do not account for a hinting fault if we raced
> 6f2a15fc1df62af3ba3be327877b7e53cb16e878 mm: Wait for THP migrations to complete during NUMA hinting faults
> 4ee547f994c633f2607d222e2c6385b6fe5f07d8 mm: Prevent parallel splits during THP migration
> dd83227f0d93fb37d7621a24e8465b13b437faa6 mm: numa: Sanitize task_numa_fault() callsites
> efeeacf7b94babff85da7e468fc5450fdfab0900 mm: Close races between THP migration and PMD numa clearing
> 778ec5247bb79815af12434980164334fb94cc9e mm: Account for a THP NUMA hinting update as one PTE update

These commits don't exist in -tip :-/

Some of these don't even exist as patch titles under different 
sha1's - such as "sched, numa: Comment fixlets".

So I'm really confused about what to pick up. What tree are you 
looking at?

-tip is at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
