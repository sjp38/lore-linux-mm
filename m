Message-ID: <48E4F6EC.7010500@linux-foundation.org>
Date: Thu, 02 Oct 2008 11:29:32 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for	allocation
 by the reclaimer
References: <1222864261-22570-1-git-send-email-apw@shadowen.org> <1222864261-22570-5-git-send-email-apw@shadowen.org> <48E390DA.9060109@linux-foundation.org> <20081002143508.GE11089@brain>
In-Reply-To: <20081002143508.GE11089@brain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:

>> At the beginning of reclaim just flush all pcp pages and then do not allow pcp
>> refills again until reclaim is finished?
> 
> Not entirely, some pages could get trapped there for sure.  But it is
> parallel allocations we are trying to guard against.  Plus we already flush
> the pcp during reclaim for higher orders.

So we just would need to forbid refilling the pcp.

Parallel allocations are less a problem if the freed order 0 pages get merged
immediately into the order 1 freelist. Of course that will only work 50% of
the time but it will have a similar effect to this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
