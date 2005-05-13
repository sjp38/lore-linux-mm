Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4DIVOfL007093
	for <linux-mm@kvack.org>; Fri, 13 May 2005 14:31:24 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4DIVOaE156562
	for <linux-mm@kvack.org>; Fri, 13 May 2005 14:31:24 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4DIVO16004221
	for <linux-mm@kvack.org>; Fri, 13 May 2005 14:31:24 -0400
Subject: Re: [RFC] consistency of zone->zone_start_pfn, spanned_pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050513182446.GA23416@lnx-holt.americas.sgi.com>
References: <1116000019.32433.10.camel@localhost>
	 <20050513182446.GA23416@lnx-holt.americas.sgi.com>
Content-Type: text/plain
Date: Fri, 13 May 2005 11:31:13 -0700
Message-Id: <1116009073.32433.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-05-13 at 13:24 -0500, Robin Holt wrote:
> On Fri, May 13, 2005 at 09:00:19AM -0700, Dave Hansen wrote:
> > Any other ideas?
> 
> Not necessarily a good idea but how about...
> 
> static int bad_range(struct zone *zone, struct page *page)
> {
> 	unsigned long start_pfn;
> 	unsigned long spanned_pages;
> 
> 	do {
> 		start_pfn = zone->zone_start_pfn;
> 		spanned_pages = zone->spanned_pages;
> 	while (unlikely(start_pfn != zone->zone_start_pfn));
> 
> 	if (page_to_pfn(page) >= start_pfn + spanned_pages;
> 		return 1;
> }

I think that's a similar idea to using a seq_lock, right?

I have the feeling that also open-coding this for shrinking zones would
make it a bit more complex.  It's a good idea, though.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
