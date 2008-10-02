Date: Thu, 2 Oct 2008 16:04:23 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 0/4] Reclaim page capture v4
Message-ID: <20081002150423.GG11089@brain>
References: <1222864261-22570-1-git-send-email-apw@shadowen.org> <28c262360810011946p443350d3hcb271720892e7b85@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360810011946p443350d3hcb271720892e7b85@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 02, 2008 at 11:46:12AM +0900, MinChan Kim wrote:
> Hi, Andy.
> 
> I tested your patch in my desktop.
> The test is just kernel compile with single thread.
> My system environment is as follows.
> 
> model name	: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
> MemTotal:        2065856 kB
> 
> When I tested vanilla, compile time is as follows.
> 
> 2433.53user 187.96system 42:05.99elapsed 103%CPU (0avgtext+0avgdata
> 0maxresident)k
> 588752inputs+4503408outputs (127major+55456246minor)pagefaults 0swaps
> 
> When I tested your patch, as follows.
> 
> 2489.63user 202.41system 44:47.71elapsed 100%CPU (0avgtext+0avgdata
> 0maxresident)k
> 538608inputs+4503928outputs (130major+55531561minor)pagefaults 0swaps
> 
> Regresstion almost is above 2 minutes.
> Do you think It is a trivial?
> 
> I know your patch is good to allocate hugepage.
> But, I think many users don't need it, including embedded system and
> desktop users yet.
> 
> So I suggest you made it enable optionally.

Hmmm.  I would not expect to see any significant impact for this kind of
workload as we should not be triggering capture for the lower order
allocations at all.  Something screwey must be occuring.  I will go and
reproduce this here and see if I can figure out just what causes this.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
