Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 3FC3A6B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 01:39:56 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Sun, 30 Jun 2013 23:39:55 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 012DE19D8043
	for <linux-mm@kvack.org>; Sun, 30 Jun 2013 23:39:42 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r615dqOj158672
	for <linux-mm@kvack.org>; Sun, 30 Jun 2013 23:39:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r615dpbU013386
	for <linux-mm@kvack.org>; Sun, 30 Jun 2013 23:39:52 -0600
Date: Mon, 1 Jul 2013 11:09:47 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Message-ID: <20130701053947.GQ8362@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <20130628135422.GA21895@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130628135422.GA21895@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Srikar Dronamraju <srikar@linux.vnet.ibm.com> [2013-06-28 19:24:22]:

> * Mel Gorman <mgorman@suse.de> [2013-06-26 15:37:59]:
> 
> > It's several months overdue and everything was quiet after 3.8 came out
> > but I recently had a chance to revisit automatic NUMA balancing for a few
> > days. I looked at basic scheduler integration resulting in the following
> > small series. Much of the following is heavily based on the numacore series
> > which in itself takes part of the autonuma series from back in November. In
> > particular it borrows heavily from Peter Ziljstra's work in "sched, numa,
> > mm: Add adaptive NUMA affinity support" but deviates too much to preserve
> > Signed-off-bys. As before, if the relevant authors are ok with it I'll
> > add Signed-off-bys (or add them yourselves if you pick the patches up).
> 
> 
> Here is a snapshot of the results of running autonuma-benchmark running on 8
> node 64 cpu system with hyper threading disabled. Ran 5 iterations for each
> setup
> 
> 	KernelVersion: 3.9.0-mainline_v39+()
> 				Testcase:      Min      Max      Avg
> 				  numa01:  1784.16  1864.15  1800.16
> 				  numa02:    32.07    32.72    32.59
> 
> 	KernelVersion: 3.9.0-mainline_v39+() + mel's patches
> 				Testcase:      Min      Max      Avg  %Change
> 				  numa01:  1752.48  1859.60  1785.60    0.82%
> 				  numa02:    47.21    60.58    53.43  -39.00%
> 
> So numa02 case; we see a degradation of around 39%.
> 

I reran the tests again 

KernelVersion: 3.9.0-mainline_v39+()
                        Testcase:      Min      Max      Avg
                          numa01:  1784.16  1864.15  1800.16
             numa01_THREAD_ALLOC:   293.75   315.35   311.03
                          numa02:    32.07    32.72    32.59
                      numa02_SMT:    39.27    39.79    39.69

KernelVersion: 3.9.0-mainline_v39+() + your patches
                        Testcase:      Min      Max      Avg  %Change
                          numa01:  1720.40  1876.89  1767.75    1.83%
             numa01_THREAD_ALLOC:   464.34   554.82   496.64  -37.37%
                          numa02:    52.02    58.57    56.21  -42.02%
                      numa02_SMT:    42.07    52.64    47.33  -16.14%


-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
