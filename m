Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9B6616B005D
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 08:22:03 -0400 (EDT)
Date: Sat, 3 Nov 2012 12:21:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/31] numa/core patches
Message-ID: <20121103122157.GH8218@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121030122032.GC3888@suse.de>
 <CAGjg+kHrbjr8T0+TOEKp6Mx4zZBbrh_3VPUt81nWj6u3xi=NNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAGjg+kHrbjr8T0+TOEKp6Mx4zZBbrh_3VPUt81nWj6u3xi=NNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <lkml.alex@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Sat, Nov 03, 2012 at 07:04:04PM +0800, Alex Shi wrote:
> >
> > In reality, this report is larger but I chopped it down a bit for
> > brevity. autonuma beats schednuma *heavily* on this benchmark both in
> > terms of average operations per numa node and overall throughput.
> >
> > SPECJBB PEAKS
> >                                        3.7.0                      3.7.0                      3.7.0
> >                               rc2-stats-v2r1         rc2-autonuma-v27r8         rc2-schednuma-v1r3
> >  Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
> >  Expctd Peak Bops               442225.00 (  0.00%)               596039.00 ( 34.78%)               555342.00 ( 25.58%)
> >  Actual Warehouse                    7.00 (  0.00%)                    9.00 ( 28.57%)                    8.00 ( 14.29%)
> >  Actual Peak Bops               550747.00 (  0.00%)               646124.00 ( 17.32%)               560635.00 (  1.80%)
> 
> It is impressive report!
> 
> Could you like to share the what JVM and options are you using in the
> testing, and based on which kinds of platform?
> 

Oracle JVM version "1.7.0_07"
Java(TM) SE Runtime Environment (build 1.7.0_07-b10)
Java HotSpot(TM) 64-Bit Server VM (build 23.3-b01, mixed mode)

4 JVMs were run, one for each node.

JVM switch specified was -Xmx12901m so it would consume roughly 80% of
memory overall.

Machine is x86-64 4-node, 64G of RAM, CPUs are E7-4807, 48 cores in
total with HT enabled.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
