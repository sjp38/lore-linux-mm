Date: Tue, 17 May 2005 14:43:23 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] consistency of zone->zone_start_pfn, spanned_pages
In-Reply-To: <42893D7C.6070907@jp.fujitsu.com>
References: <1116000019.32433.10.camel@localhost> <42893D7C.6070907@jp.fujitsu.com>
Message-Id: <20050517134334.2391.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> Hi,
> Dave Hansen wrote:
> > The zone struct has a few important members which explicitly define the
> > range of pages that it manages: zone_start_pfn and spanned_pages.
> > 
> > The current memory hotplug coded has concentrated on appending memory to
> > existing zones, which means just increasing spanned_pages.  There is
> > currently no code that breaks at runtime if this value is simply
> > incremented.
> > 
> 
> How about removing zone_start_pfn and spanned_pages ?
> 
> I found they are used in
>     bad_range() in page_alloc.c
>     mark_free_page() in CONFIG_PM.
> 
> And I think we can remove them with section-range-ops when CONFIG_SPARSEMEM=y.
> They are used in some another places ?

Hmm, spanned_pages is used at build_zonelists_node() 
in page_alloc.c.
It looks like still useful for me to initialize and update zonelists
which is hot-added.


Bye.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
