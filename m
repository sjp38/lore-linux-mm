Date: Fri, 25 May 2007 07:03:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/6] Compound Page Enhancements
In-Reply-To: <20070524230032.554be39e.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705250701400.5490@schroedinger.engr.sgi.com>
References: <20070525051716.030494061@sgi.com> <20070524230032.554be39e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Andrew Morton wrote:

> And looking back on it, I don't see the point in that PG_head_tail_mask
> hack either.  We could have done
> 
> static inline int page_tail(struct page *page)
> {
> 	return PageCompound(page) && (page->first_page != page);
> }

But then PageHead(page) wont work anymore. pagehead->first_page is in use 
for some other purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
