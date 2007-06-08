Date: Thu, 7 Jun 2007 22:52:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: memory unplug v4  [2/6] lru isolation race fix
In-Reply-To: <20070608143953.93719b3e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706072248310.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
 <20070608143953.93719b3e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, KAMEZAWA Hiroyuki wrote:

> release_pages() in mm/swap.c changes page_count() to be 0
> without clearing PageLRU flag...
> This means isolate_lru_page() can see a page, PageLRU() && page_count(page)==0..
> This is BUG. (get_page() will be called against count=0 page.)

Use get_page_unless_zero?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
