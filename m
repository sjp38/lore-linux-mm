Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 77BD86B002B
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 19:24:42 -0400 (EDT)
Date: Mon, 13 Aug 2012 08:26:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 3/4] mm: introduce putback_movable_pages()
Message-ID: <20120812232636.GI21033@bbox>
References: <cover.1344619987.git.aquini@redhat.com>
 <9147e5cccc4bb2d3f2e5f155e640148eb5365af5.1344619987.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9147e5cccc4bb2d3f2e5f155e640148eb5365af5.1344619987.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Fri, Aug 10, 2012 at 02:55:16PM -0300, Rafael Aquini wrote:
> The PATCH "mm: introduce compaction and migration for virtio ballooned pages"
> hacks around putback_lru_pages() in order to allow ballooned pages to be
> re-inserted on balloon page list as if a ballooned page was like a LRU page.
> 
> As ballooned pages are not legitimate LRU pages, this patch introduces
> putback_movable_pages() to properly cope with cases where the isolated
> pageset contains ballooned pages and LRU pages, thus fixing the mentioned
> inelegant hack around putback_lru_pages().
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks for your good work, Rafael.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
