Date: Tue, 01 Apr 2008 08:28:12 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] hugetlb: vmstat events for huge page allocations
In-Reply-To: <1206978548.8042.7.camel@grover.beaverton.ibm.com>
References: <1206978548.8042.7.camel@grover.beaverton.ibm.com>
Message-Id: <20080401082435.3A47.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebmunson@us.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi

> Allocating huge pages directly from the buddy allocator is not guaranteed
> to succeed.  Success depends on several factors (such as the amount of
> physical memory available and the level of fragmentation).  With the
> addition of dynamic hugetlb pool resizing, allocations can occur much more
> frequently.  For these reasons it is desirable to keep track of huge page
> allocation successes and failures.
> 
> Add two new vmstat entries to track huge page allocations that succeed and
> fail.  The presence of the two entries is contingent upon
> CONFIG_HUGETLB_PAGE being enabled.

In generaly, I like this patch.

Have you seen Andi Kleen's "GB pages hugetlb support" series?
it contain multiple size hugepage support.
if it is merged, Is your patch caused any effect?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
