Date: Fri, 10 Mar 2006 11:16:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/03] Unmapped: Implement two LRU:s
In-Reply-To: <20060310034417.8340.49483.sendpatchset@cherry.local>
Message-ID: <Pine.LNX.4.64.0603101113210.28805@schroedinger.engr.sgi.com>
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
 <20060310034417.8340.49483.sendpatchset@cherry.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2006, Magnus Damm wrote:

> Use separate LRU:s for mapped and unmapped pages.
> 
> This patch creates two instances of "struct lru" per zone, both protected by
> zone->lru_lock. A new bit in page->flags named PG_mapped is used to determine
> which LRU the page belongs to. The rmap code is changed to move pages to the 
> mapped LRU, while the vmscan code moves pages back to the unmapped LRU when 
> needed. Pages moved to the mapped LRU are added to the inactive list, while
> pages moved back to the unmapped LRU are added to the active list.

The swapper moves pages to the unmapped list? So the mapped LRU 
lists contains unmapped pages? That would get rid of the benefit that I 
saw from this scheme. Pretty inconsistent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
