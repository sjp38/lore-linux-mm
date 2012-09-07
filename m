Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 7A6926B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 04:10:36 -0400 (EDT)
Date: Fri, 7 Sep 2012 09:10:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120907081029.GU11266@suse.de>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
 <CAH9JG2VS62qU1FozAAhTmL0cgcsVBoXCg4X7kLVwciQps7iURg@mail.gmail.com>
 <20120907022601.GH16231@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120907022601.GH16231@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Fri, Sep 07, 2012 at 11:26:01AM +0900, Minchan Kim wrote:
> On Fri, Sep 07, 2012 at 09:57:12AM +0900, Kyungmin Park wrote:
> > Hi Mel,
> > 
> > After apply your patch, It got the below message.
> > Please note that it's not the latest kernel. it's kernel v3.0.31 + CMA
> > + your patch.
> > It seems it should not be active but it contains active field.
> 
> Yeb. At the moment, shrink_page_list shouldn't handle active pages
> so we should clear PG_active bit in reclaim_clean_pages_from_list.
> 

Yep, that was an obvious thing I missed. It was a very fast prototype to
illustrate my point. It should be possible to fix.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
