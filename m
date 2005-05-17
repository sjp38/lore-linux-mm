Message-ID: <4289E473.1090404@shadowen.org>
Date: Tue, 17 May 2005 13:32:51 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [RFC] consistency of zone->zone_start_pfn, spanned_pages
References: <1116000019.32433.10.camel@localhost> <42893D7C.6070907@jp.fujitsu.com>
In-Reply-To: <42893D7C.6070907@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> How about removing zone_start_pfn and spanned_pages ?
> 
> I found they are used in
>    bad_range() in page_alloc.c
>    mark_free_page() in CONFIG_PM.
> 
> And I think we can remove them with section-range-ops when
> CONFIG_SPARSEMEM=y.
> They are used in some another places ?

This needs careful thought as we use bad_range in __free_pages_bulk() in
a non-debug form to work out whether a free'd page is a member of a zone
when trying to pair it with its buddy.  Take for instance ZONE_DMA on
typical x86 hardware which has 0 complete MAX_ORDER buddies within.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
