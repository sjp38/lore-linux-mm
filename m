Date: Wed, 24 Jan 2007 12:13:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Limit the size of the pagecache
Message-Id: <20070124121318.6874f003.kamezawa.hiroyu@jp.fujitsu.com>
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

one more thing...

On Tue, 23 Jan 2007 16:49:55 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> @@ -1168,6 +1170,11 @@ zonelist_scan:
>  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  				goto try_next_zone;
>  
> +		if ((gfp_mask & __GFP_PAGECACHE) &&
> +				zone_page_state(zone, NR_FILE_PAGES) >
> +					zone->max_pagecache_pages)
> +				goto try_next_zone;
> +

I don't prefer to cause zone fallback by this.
This may use ZONE_DMA before exhausing ZONE_NORMAL (ia64),
ZONE_NORMAL before ZONE_HIGHMEM (x86).
Very rapid page allocation can eats some amount of lower zone.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
