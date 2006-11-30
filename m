Date: Thu, 30 Nov 2006 09:18:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to
 userspace
Message-Id: <20061130091815.018f52fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061129033826.268090000@menage.corp.google.com>
References: <20061129030655.941148000@menage.corp.google.com>
	<20061129033826.268090000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006 19:06:56 -0800
menage@google.com wrote:

>
> +	for (i = 0; i < pgdat->node_spanned_pages; ++i) {
> +		struct page *page = pgdat_page_nr(pgdat, i);
you need pfn_valid() check before accessing page struct.


> +		if (!isolate_lru_page(page, &pagelist)) {
you'll see panic if !PageLRU(page).

looks scanning zone's lru list is more suitable for your purpose.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
