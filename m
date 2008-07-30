Received: by yw-out-1718.google.com with SMTP id 5so122228ywm.26
        for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:48:26 -0700 (PDT)
Message-ID: <2f11576a0807301348y235dad46s2478d59181d3b9e8@mail.gmail.com>
Date: Thu, 31 Jul 2008 05:48:25 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH/DESCRIPTION 7/7] unevictable lru: replace patch description
In-Reply-To: <20080730200702.24272.12495.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200702.24272.12495.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

> Christoph Lameter pointed out that ram disk pages also clutter the LRU
> lists.  When vmscan finds them dirty and tries to clean them, the ram disk
> writeback function just redirties the page so that it goes back onto the
> active list.  Round and round she goes...
>
> With the ram disk driver [rd.c] replaced by the newer 'brd.c', this is
> no longer the case, as ram disk pages are no longer maintained on the
> lru.  [This makes them unmigratable for defrag or memory hot remove,
> but that can be addressed by a separate patch series.]  However, the
> ramfs pages behave like ram disk pages used to, so:
>
> Define new address_space flag [shares address_space flags member with
> mapping's gfp mask] to indicate that the address space contains all
> unevictable pages.  This will provide for efficient testing of ramfs
> pages in page_evictable().
>
> Also provide wrapper functions to set/test the unevictable state to
> minimize #ifdefs in ramfs driver and any other users of this facility.
>
> Set the unevictable state on address_space structures for new ramfs
> inodes.  Test the unevictable state in page_evictable() to cull
> unevictable pages.
>
> These changes depend on [CONFIG_]UNEVICTABLE_LRU.

looks good to me.
but I can't believe my english skill.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
