Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9Q7GQhU001372
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 03:16:26 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9Q7GQod480766
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 01:16:26 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9Q7GPDV006591
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 01:16:26 -0600
Subject: Re: [PATCH 3/5] Swap Migration V4: migrate_pages() function
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051025193039.6828.74991.sendpatchset@schroedinger.engr.sgi.com>
References: <20051025193023.6828.89649.sendpatchset@schroedinger.engr.sgi.com>
	 <20051025193039.6828.74991.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 26 Oct 2005 09:15:34 +0200
Message-Id: <1130310934.1226.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Mike Kravetz <kravetz@us.ibm.com>, Ray Bryant <raybry@mpdtxmail.amd.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Magnus Damm <magnus.damm@gmail.com>, Paul Jackson <pj@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-10-25 at 12:30 -0700, Christoph Lameter wrote:
> 
> +#ifdef CONFIG_SWAP
> +       if (PageSwapCache(page)) {
> +               swp_entry_t swap = { .val = page_private(page) };
> +               add_to_swapped_list(swap.val);
> +               __delete_from_swap_cache(page);
> +               write_unlock_irq(&mapping->tree_lock);
> +               swap_free(swap);
> +               __put_page(page);       /* The pagecache ref */
> +               return 1;
> +       }
> +#endif /* CONFIG_SWAP */

Why is this #ifdef needed?  PageSwapCache() is #defined to 0 when !
CONFIG_SWAP.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
