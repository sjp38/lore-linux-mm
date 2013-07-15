Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 9F8A36B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 16:14:19 -0400 (EDT)
Date: Mon, 15 Jul 2013 22:14:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA
 balancing V5
Message-ID: <20130715201412.GP17211@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 04:20:02PM +0100, Mel Gorman wrote:
> 
> specjbb
>                         3.9.0               3.9.0                 3.9.0                 3.9.0
>                       vanilla          accountload-v5       retrymigrate-v5          swaptasks-v5  
> TPut 1      24474.00 (  0.00%)      24303.00 ( -0.70%)     23529.00 ( -3.86%)     26110.00 (  6.68%)
> TPut 7     186914.00 (  0.00%)     179962.00 ( -3.72%)    183667.00 ( -1.74%)    185912.00 ( -0.54%)
> TPut 13    334429.00 (  0.00%)     327558.00 ( -2.05%)    336418.00 (  0.59%)    334563.00 (  0.04%)
> TPut 19    422820.00 (  0.00%)     451359.00 (  6.75%)    450069.00 (  6.44%)    426753.00 (  0.93%)
> TPut 25    456121.00 (  0.00%)     533432.00 ( 16.95%)    504138.00 ( 10.53%)    503152.00 ( 10.31%)
> TPut 31    438595.00 (  0.00%)     510638.00 ( 16.43%)    442937.00 (  0.99%)    486450.00 ( 10.91%)
> TPut 37    409654.00 (  0.00%)     475468.00 ( 16.07%)    427673.00 (  4.40%)    460531.00 ( 12.42%)
> TPut 43    370941.00 (  0.00%)     442169.00 ( 19.20%)    387382.00 (  4.43%)    425120.00 ( 14.61%)
> 
> It's interesting that retrying the migrate introduced such a large dent. I
> do not know why at this point.  Swapping the tasks helped and overall the
> performance is all right with room for improvement.

I think it means that our direct migration scheme is creating too much
imbalance and doing it more often results in more task movement to fix
it up again, hindering page migration efforts to settle on a node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
