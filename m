Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 832E36B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 22:24:23 -0400 (EDT)
Date: Fri, 7 Sep 2012 11:26:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120907022601.GH16231@bbox>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
 <CAH9JG2VS62qU1FozAAhTmL0cgcsVBoXCg4X7kLVwciQps7iURg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9JG2VS62qU1FozAAhTmL0cgcsVBoXCg4X7kLVwciQps7iURg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Fri, Sep 07, 2012 at 09:57:12AM +0900, Kyungmin Park wrote:
> Hi Mel,
> 
> After apply your patch, It got the below message.
> Please note that it's not the latest kernel. it's kernel v3.0.31 + CMA
> + your patch.
> It seems it should not be active but it contains active field.

Yeb. At the moment, shrink_page_list shouldn't handle active pages
so we should clear PG_active bit in reclaim_clean_pages_from_list.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
