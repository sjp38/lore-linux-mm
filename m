Date: Tue, 18 Sep 2007 11:59:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC 11/14] Reclaim Scalability: swap backed pages are
 nonreclaimable when no swap space available
Message-Id: <20070918115933.886238b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070914205512.6536.89432.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	<20070914205512.6536.89432.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007 16:55:12 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> +#ifdef CONFIG_NORECLAIM_NO_SWAP
> +	if (page_anon(page) && !PageSwapCache(page) && !nr_swap_pages)
> +		return 0;
> +#endif

nr_swap_pages depends on CONFIG_SWAP. 

So I recommend you to use total_swap_pages. (if CONFIG_SWAP=n, total_swap_pages is
compield to be 0.)

==
if (!total_swap_pages && page_anon(page)) 
	return 0;
==
By the way, nr_swap_pages is "# of currently available swap pages".
Should this page will be put into NORECLAIM list ? This number can be
changed to be > 0 easily.

Cheers,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
