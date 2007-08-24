Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7OGkj49029484
	for <linux-mm@kvack.org>; Sat, 25 Aug 2007 02:46:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7OGkkqu4706446
	for <linux-mm@kvack.org>; Sat, 25 Aug 2007 02:46:46 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7OHkjFr006015
	for <linux-mm@kvack.org>; Sat, 25 Aug 2007 03:46:45 +1000
Message-ID: <46CF0B70.1050302@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2007 22:16:40 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1 Kernel
 panic - not syncing: DMA: Memory would be corrupted)
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com> <20070823142133.9359a1ce.akpm@linux-foundation.org> <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:
> I found find_next_best_node() was wrong.
> I confirmed boot up by the following patch.
> Mel-san, Kamalesh-san, could you try this?
>
> Bye.
> ---
>
> Fix decision of memoryless node in find_next_best_node().
> This can be cause of SW-IOMMU's allocation failure.
>
> This patch is for 2.6.23-rc3-mm1.
>
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: current/mm/page_alloc.c
> ===================================================================
> --- current.orig/mm/page_alloc.c	2007-08-24 16:03:17.000000000 +0900
> +++ current/mm/page_alloc.c	2007-08-24 16:04:06.000000000 +0900
> @@ -2136,7 +2136,7 @@ static int find_next_best_node(int node,
>  		 * Note:  N_HIGH_MEMORY state not guaranteed to be
>  		 *        populated yet.
>  		 */
> -		if (pgdat->node_present_pages)
> +		if (!pgdat->node_present_pages)
>  			continue;
>
>  		/* Don't want a node to appear more than once */
>
>   
This patch resolves the kernel panic problem.

-
Kamalesh Babulal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
