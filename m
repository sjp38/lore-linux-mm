From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when high-order
 watermarks are being hit
Date: Tue, 27 Oct 2009 14:18:34 -0400
Message-ID: <4AE7397A.4010907__21908.9468861513$1256669237$gmane$org@redhat.com>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B3BD6B005A
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:19:47 -0400 (EDT)
In-Reply-To: <1256650833-15516-4-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, " <rjw@sisk.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>"@redhat.com
List-Id: linux-mm.kvack.org

On 10/27/2009 09:40 AM, Mel Gorman wrote:
> When a high-order allocation fails, kswapd is kicked so that it reclaims
> at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> allocations. Something has changed in recent kernels that affect the timing
> where high-order GFP_ATOMIC allocations are now failing with more frequency,
> particularly under pressure. This patch forces kswapd to notice sooner that
> high-order allocations are occuring.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
