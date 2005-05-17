Message-ID: <42893D7C.6070907@jp.fujitsu.com>
Date: Tue, 17 May 2005 09:40:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [RFC] consistency of zone->zone_start_pfn, spanned_pages
References: <1116000019.32433.10.camel@localhost>
In-Reply-To: <1116000019.32433.10.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,
Dave Hansen wrote:
> The zone struct has a few important members which explicitly define the
> range of pages that it manages: zone_start_pfn and spanned_pages.
> 
> The current memory hotplug coded has concentrated on appending memory to
> existing zones, which means just increasing spanned_pages.  There is
> currently no code that breaks at runtime if this value is simply
> incremented.
> 

How about removing zone_start_pfn and spanned_pages ?

I found they are used in
    bad_range() in page_alloc.c
    mark_free_page() in CONFIG_PM.

And I think we can remove them with section-range-ops when CONFIG_SPARSEMEM=y.
They are used in some another places ?

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
