Message-ID: <48E390DA.9060109@linux-foundation.org>
Date: Wed, 01 Oct 2008 10:01:46 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation
 by the reclaimer
References: <1222864261-22570-1-git-send-email-apw@shadowen.org> <1222864261-22570-5-git-send-email-apw@shadowen.org>
In-Reply-To: <1222864261-22570-5-git-send-email-apw@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> When a process enters direct reclaim it will expend effort identifying
> and releasing pages in the hope of obtaining a page.  However as these
> pages are released asynchronously there is every possibility that the
> pages will have been consumed by other allocators before the reclaimer
> gets a look in.  This is particularly problematic where the reclaimer is
> attempting to allocate a higher order page.  It is highly likely that
> a parallel allocation will consume lower order constituent pages as we
> release them preventing them coelescing into the higher order page the
> reclaimer desires.

The reclaim problem is due to the pcp queueing right? Could we disable pcp
queueing during reclaim? pcp processing is not necessarily a gain, so
temporarily disabling it should not be a problem.

At the beginning of reclaim just flush all pcp pages and then do not allow pcp
refills again until reclaim is finished?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
