Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 7E8156B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 15:32:53 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so2549763oag.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 12:32:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121115100805.GS8218@suse.de>
References: <20121112160451.189715188@chello.nl> <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 15 Nov 2012 12:32:32 -0800
Message-ID: <CA+55aFyEJwRvQezg3oKg71Nk9+1QU7qwvo0BH4ykReKxNhFJRg@mail.gmail.com>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive affinity"
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

Ugh.

According to these numbers, the latest sched-numa actually regresses
against mainline on Specjbb.

No way is this even close to ready for merging in the 3.8 timeframe.

I would ask the invilved people to please come up with a set of
initial patches that people agree on, so that we can at least start
merging some of the infrastructure, and see how far we can get on at
least getting *started*. As I mentioned to Andrew and Mel separately,
nobody seems to disagree with the TLB optimization patches. What else?
Is Mel's set of early patches still considered a reasonable starting
point for everybody?

Ingo? Andrea? With the understanding that we're not going to merge the
actual full schednuma/autonuma, what are the initial parts we can
*agree* on?

                  Linus

On Thu, Nov 15, 2012 at 2:08 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> SPECJBB BOPS
>                           3.7.0                 3.7.0                 3.7.0
>                 rc4-stats-v2r34    rc4-schednuma-v2r3  rc4-autonuma-v28fast
> Mean   1      25034.25 (  0.00%)     20598.50 (-17.72%)     25192.25 (  0.63%)
> Mean   2      53176.00 (  0.00%)     43906.50 (-17.43%)     55508.25 (  4.39%)
> Mean   3      77350.50 (  0.00%)     60342.75 (-21.99%)     82122.50 (  6.17%)
> Mean   4      99919.50 (  0.00%)     80781.75 (-19.15%)    107233.25 (  7.32%)
> Mean   5     119797.00 (  0.00%)     97870.00 (-18.30%)    131016.00 (  9.37%)
> Mean   6     135858.00 (  0.00%)    123912.50 ( -8.79%)    152444.75 ( 12.21%)
> Mean   7     136074.00 (  0.00%)    126574.25 ( -6.98%)    157372.75 ( 15.65%)
> Mean   8     132426.25 (  0.00%)    121766.00 ( -8.05%)    161655.25 ( 22.07%)
> Mean   9     129432.75 (  0.00%)    114224.25 (-11.75%)    160530.50 ( 24.03%)
> Mean   10    118399.75 (  0.00%)    109040.50 ( -7.90%)    158692.00 ( 34.03%)
> Mean   11    119604.00 (  0.00%)    105566.50 (-11.74%)    154462.00 ( 29.14%)
> Mean   12    112742.25 (  0.00%)    101728.75 ( -9.77%)    149546.00 ( 32.64%)
> Mean   13    109480.75 (  0.00%)    103737.50 ( -5.25%)    144929.25 ( 32.38%)
> Mean   14    109724.00 (  0.00%)    103516.00 ( -5.66%)    143804.50 ( 31.06%)
> Mean   15    109111.75 (  0.00%)    100817.00 ( -7.60%)    141878.00 ( 30.03%)
> Mean   16    105385.75 (  0.00%)     99327.25 ( -5.75%)    140156.75 ( 32.99%)
> Mean   17    101903.50 (  0.00%)     96464.50 ( -5.34%)    138402.00 ( 35.82%)
> Mean   18    103632.50 (  0.00%)     95632.50 ( -7.72%)    137781.50 ( 32.95%)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
