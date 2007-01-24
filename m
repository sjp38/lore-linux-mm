Date: Wed, 24 Jan 2007 11:53:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Limit the size of the pagecache
Message-Id: <20070124115310.48cda374.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: aubreylee@gmail.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jan 2007 16:49:55 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> If we enter reclaim and the number of page cache pages
> is too high then we switch off swapping during reclaim
> to avoid touching anonymous pages.

In general, I like this (kind of) feature.

> +	/*
> +	 * If the page cache is too big then focus on page cache
> +	 * and ignore anonymous pages
> +	 */
> +	if (sc->may_swap && zone_page_state(zone, NR_FILE_PAGES)
> +			> zone->max_pagecache_pages)
> +		sc->may_swap = 0;
> +


How about adding this (kind of) check ?

if (sc->may_swap &&
    zone_page_state(zone, NR_FILE_PAGES) &&
    !(curreht->flags & PF_MEMALLOC))
	sc->may_swap = 0;

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
