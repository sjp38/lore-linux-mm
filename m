Date: Wed, 19 Oct 2005 08:29:37 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
In-Reply-To: <aec7e5c30510190304y3a1935e5k57ddd8912b4e411a@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0510190826210.12887@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
  <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
 <aec7e5c30510180134of0b129au3f1a1b61cf822b53@mail.gmail.com>
 <Pine.LNX.4.62.0510180938430.7911@schroedinger.engr.sgi.com>
 <aec7e5c30510190304y3a1935e5k57ddd8912b4e411a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 19 Oct 2005, Magnus Damm wrote:

> I'm trying to figure out if this code works in all cases:
> 
> +               spin_lock_irq(&zone->lru_lock);
> +               list_del(&page->lru);
> +               if (!TestSetPageLRU(page)) {
> +                       if (PageActive(page))
> +                               add_page_to_active_list(zone, page);
> +                       else
> +                               add_page_to_inactive_list(zone, page);
> +                       count++;
> +               }
> +               spin_unlock_irq(&zone->lru_lock);
> 
> Why not use if (TestSetPageLRU(page)) BUG()?

That is probably right.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
