Date: Tue, 4 Mar 2008 09:46:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc 05/10] Sparsemem: Vmemmap does not need section bits
Message-Id: <20080304094638.ace3675d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0803031620001.6789@schroedinger.engr.sgi.com>
References: <20080301040755.268426038@sgi.com>
	<20080301040814.772847658@sgi.com>
	<20080301133312.9ab8d826.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0803031204170.16049@schroedinger.engr.sgi.com>
	<20080304091809.b02b1e16.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0803031614510.6741@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0803031620001.6789@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008 16:20:45 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Something like this?
> 
This is acceptable for me. (But should be CCed to Andy.)

Thanks,
-Kame

> ---
>  include/linux/mm.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h	2008-03-03 16:15:55.395071738 -0800
> +++ linux-2.6/include/linux/mm.h	2008-03-03 16:16:49.047411228 -0800
> @@ -500,10 +500,12 @@ static inline struct zone *page_zone(str
>  	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
>  }
>  
> +#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  static inline unsigned long page_to_section(struct page *page)
>  {
>  	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
>  }
> +#endif
>  
>  static inline void set_page_zone(struct page *page, enum zone_type zone)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
