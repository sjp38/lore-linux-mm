Date: Fri, 18 Apr 2008 12:32:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcgroup: check and initialize page->cgroup in
 memmap_init_zone
Message-Id: <20080418123256.da4d1db0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080417201432.36b1c326.akpm@linux-foundation.org>
References: <48080706.50305@cn.fujitsu.com>
	<48080930.5090905@cn.fujitsu.com>
	<48080B86.7040200@cn.fujitsu.com>
	<20080417201432.36b1c326.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shi Weihua <shiwh@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 17 Apr 2008 20:14:32 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> >  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> >  		/*
> > @@ -2535,6 +2536,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> >  		set_page_links(page, zone, nid, pfn);
> >  		init_page_count(page);
> >  		reset_page_mapcount(page);
> > +		pc = page_get_page_cgroup(page);
> > +		if (pc) 
> > +			page_reset_bad_cgroup(page);
> >  		SetPageReserved(page);
> >  
> 
> hm, fishy.  Perhaps the architecture isn't zeroing the memmap arrays?
> 
AFAIK, No. memmap is allocated by alloc_bootmem() and returned memory is
cleared by memset().

> Or perhaps that page was used and then later freed before we got to
> memmap_init_zone() and was freed with a non-zero ->page_cgroup.  Which is
> unlikely given that page.page_cgroup was only just added and is only
> present if CONFIG_CGROUP_MEM_RES_CTLR.
> 
Hmm, I'll try his .config and see what happens.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
