Date: Tue, 19 Jun 2007 12:22:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/7] Memory Compaction v2
In-Reply-To: <20070619165841.GG17109@skynet.ie>
Message-ID: <Pine.LNX.4.64.0706191221130.7008@schroedinger.engr.sgi.com>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0706181022530.4751@schroedinger.engr.sgi.com>
 <20070619165841.GG17109@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jun 2007, Mel Gorman wrote:

> Agreed. When I put this together first, I felt I would be able to isolate
> pages of different types on migratelist but that is not the case as migration
> would not be able to tell the difference between a LRU page and a pagetable
> page. I'll rename cc->migratelist to cc->migratelist_lru with the view to
> potentially adding cc->migratelist_pagetable or cc->migratelist_slab later.

Right. The particular issue with moving page table pages or slab pages is 
that you do not have a LRU. The page state needs to be established in a 
different way and there needs to be mechanism to ensure that the page is 
not currently being setup or torn down. For the slab pages I have relied 
on page->inuse > 0 to signify a page in use. I am not sure how one would 
realize that for page table pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
