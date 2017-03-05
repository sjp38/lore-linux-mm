Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59A2C6B0038
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 22:34:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 187so14046133pgb.3
        for <linux-mm@kvack.org>; Sat, 04 Mar 2017 19:34:13 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x26si8347217pge.30.2017.03.04.19.34.11
        for <linux-mm@kvack.org>;
        Sat, 04 Mar 2017 19:34:12 -0800 (PST)
Date: Sun, 5 Mar 2017 12:33:50 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170305033350.GB11100@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228134018.GK5680@worktop>
 <20170301054323.GE11663@X58A-UD3R>
 <20170301122843.GF6515@twins.programming.kicks-ass.net>
 <20170302134031.GG6536@twins.programming.kicks-ass.net>
 <20170303001737.GF28562@X58A-UD3R>
 <20170303081416.GT6515@twins.programming.kicks-ass.net>
 <20170303091338.GH6536@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303091338.GH6536@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com, Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>

On Fri, Mar 03, 2017 at 10:13:38AM +0100, Peter Zijlstra wrote:
> On Fri, Mar 03, 2017 at 09:14:16AM +0100, Peter Zijlstra wrote:
> 
> Two boots + a make defconfig, the first didn't have the redundant bit
> in, the second did (full diff below still includes the reclaim rework,
> because that was still in that kernel and I forgot to reset the tree).
> 
> 
>  lock-classes:                         1168       1169 [max: 8191]
>  direct dependencies:                  7688       5812 [max: 32768]
>  indirect dependencies:               25492      25937
>  all direct dependencies:            220113     217512
>  dependency chains:                    9005       9008 [max: 65536]
>  dependency chain hlocks:             34450      34366 [max: 327680]
>  in-hardirq chains:                      55         51
>  in-softirq chains:                     371        378
>  in-process chains:                    8579       8579
>  stack-trace entries:                108073      88474 [max: 524288]
>  combined max dependencies:       178738560  169094640
> 
>  max locking depth:                      15         15
>  max bfs queue depth:                   320        329
> 
>  cyclic checks:                        9123       9190
> 
>  redundant checks:                                5046
>  redundant links:                                 1828
> 
>  find-mask forwards checks:            2564       2599
>  find-mask backwards checks:          39521      39789
> 
> 
> So it saves nearly 2k links and a fair chunk of stack-trace entries, but

It's as we expect.

> as expected, makes no real difference on the indirect dependencies.

It looks that the indirect dependencies increased to me. This result is
also somewhat anticipated.

> At the same time, you see the max BFS depth increase, which is also

Yes. The depth should increase.

> expected, although it could easily be boot variance -- these numbers are
> not entirely stable between boots.
> 
> Could you run something similar? Or I'll take a look on your next spin
> of the patches.

I will check same thing you did and let you know the result at next spin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
