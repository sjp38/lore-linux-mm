Message-ID: <46E02CF5.3020301@redhat.com>
Date: Thu, 06 Sep 2007 12:38:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] prevent kswapd from freeing excessive amounts of lowmem
References: <46DF3545.4050604@redhat.com> <20070905182305.e5d08acf.akpm@linux-foundation.org>
In-Reply-To: <20070905182305.e5d08acf.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, safari-kernel@safari.iki.fi
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> I guess for a very small upper zone and a very large lower zone this could
> still put the scan balancing out of whack, fixable by a smarter version of
> "8*zone->pages_high" but it doesn't seem very likely that this will affect
> things much.
> 
> Why doesn't direct reclaim need similar treatment?

Because we only go into the direct reclaim path once
every zone is at or below zone->pages_low, and the
direct reclaim path will exit once we have freed more
than swap_cluster_max pages.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
