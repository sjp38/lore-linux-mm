Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8C8526B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 02:59:38 -0400 (EDT)
Message-ID: <5237FDCC.5010109@oracle.com>
Date: Tue, 17 Sep 2013 14:59:24 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] mm: migrate zbud pages
References: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
In-Reply-To: <1378889944-23192-1-git-send-email-k.kozlowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

Hi Krzysztof,

On 09/11/2013 04:58 PM, Krzysztof Kozlowski wrote:
> Hi,
> 
> Currently zbud pages are not movable and they cannot be allocated from CMA
> (Contiguous Memory Allocator) region. These patches add migration of zbud pages.
> 

I agree that the migration of zbud pages is important so that system
will not enter order-0 page fragmentation and can be helpful for page
compaction/huge pages etc..

But after I looked at the [patch 4/5], I found it will make zbud very
complicated.
I'd prefer to add this migration feature later until current version
zswap/zbud becomes better enough and more stable.

Mel mentioned several problems about zswap/zbud in thread "[PATCH v6
0/5] zram/zsmalloc promotion".

Like "it's clunky as hell and the layering between zswap and zbud is
twisty" and "I think I brought up its stalling behaviour during review
when it was being merged. It would have been preferable if writeback
could be initiated in batches and then waited on at the very least..
 It's worse that it uses _swap_writepage directly instead of going
through a writepage ops.  It would have been better if zbud pages
existed on the LRU and written back with an address space ops and
properly handled asynchonous writeback."

So I think it would be better if we can address those issues at first
and it would be easier to address these issues before adding more new
features. Welcome any ideas.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
