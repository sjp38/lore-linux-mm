Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 561F06B0035
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 08:48:53 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so4058801pab.0
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 05:48:53 -0700 (PDT)
Received: from psmtp.com ([74.125.245.163])
        by mx.google.com with SMTP id w8si14822773pbi.257.2013.10.29.05.48.51
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 05:48:52 -0700 (PDT)
Date: Tue, 29 Oct 2013 12:48:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Automatic NUMA balancing patches for tip-urgent/stable
Message-ID: <20131029124844.GE2400@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131024122646.GB2402@suse.de>
 <20131026121148.GC24439@gmail.com>
 <20131029094208.GB2400@suse.de>
 <20131029094856.GA25306@gmail.com>
 <20131029102419.GC2400@suse.de>
 <20131029104102.GB26154@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131029104102.GB26154@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 29, 2013 at 11:41:02AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > Bah, I have tip as a remote tree but looked at my local copy of 
> > the commits in the incorrect branch. Lets try this again
> > 
> > 37bf06375c90a42fe07b9bebdb07bc316ae5a0ce..afcae2655b0ab67e65f161b1bb214efcfa1db415
> 
> Ok, these work a lot better and cherry-pick cleanly on top of -rc7.
> 
> > 10fc05d0e551146ad6feb0ab8902d28a2d3c5624 mm: numa: Document automatic NUMA balancing sysctls
> 
> We can certainly leave out this one - the rest still cherry-picks 
> cleanly.
> 
> > c69307d533d7aa7cc8894dbbb8a274599f8630d7 sched/numa: Fix comments
> 
> I was able to leave out this one as well.
> 

Yes, both of those can be left out. They are outside the stable rules and
including them to have comparable documentation in -stable is unnecessary.

> > 0c3a775e1e0b069bf765f8355b723ce0d18dcc6c mm: numa: Do not account for a hinting fault if we raced
> > ff9042b11a71c81238c70af168cd36b98a6d5a3c mm: Wait for THP migrations to complete during NUMA hinting faults
> > b8916634b77bffb233d8f2f45703c80343457cc1 mm: Prevent parallel splits during THP migration
> > 8191acbd30c73e45c24ad16c372e0b42cc7ac8f8 mm: numa: Sanitize task_numa_fault() callsites
> > a54a407fbf7735fd8f7841375574f5d9b0375f93 mm: Close races between THP migration and PMD numa clearing
> > afcae2655b0ab67e65f161b1bb214efcfa1db415 mm: Account for a THP NUMA hinting update as one PTE update
> 
> Ok, these seem essential and cherry-pick cleanly.
> 
> Would be nice to avoid the 'Sanitize task_numa_fault() callsites' 
> change, but the remaining fixes rely on it and are well tested 
> together.
> 

It would have been nice but yes, the combination of patches would not have
been well tested.

> I've stuck these into tip:core/urgent with a -stable tag and will 
> send them to Linus if he cuts an -rc8 (which seems unlikely at this 
> point though).
> 
> If there's no -rc8 then please forward the above list of 6 commits 
> to Greg so that it can be applied to -stable.
> 

Thanks, I'll make sure they get sent to stable when the relevant patches
show up in a mainline tree of some description.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
