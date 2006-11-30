Date: Wed, 29 Nov 2006 20:10:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to
 userspace
In-Reply-To: <20061129033826.268090000@menage.corp.google.com>
Message-ID: <Pine.LNX.4.64.0611292008020.19628@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <20061129033826.268090000@menage.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, menage@google.com wrote:

> +	for (i = 0; i < pgdat->node_spanned_pages; ++i) {
> +		struct page *page = pgdat_page_nr(pgdat, i);
> +		if (!isolate_lru_page(page, &pagelist)) {
> +			pagecount++;
> +		} else {
> +			failcount++;
> +		}
> +	}

Go along the active / inactive LRU lists? isolate_lru_page will not 
allow you isolate other pages.

If you go along the lru lists then you also avoid having to deal with 
holes in the memory map. You cannot simply assume that all struct pages in 
the area are accessible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
