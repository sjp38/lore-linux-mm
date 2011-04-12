Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4EED4900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:04:31 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3CEgQdQ024998
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:42:34 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 73FAA38C803D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:04:19 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3CF4Sfn158734
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:04:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3CF4RoE018287
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:04:28 -0400
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vttl1ho83l0zgt@mnazarewicz-glaptop>
References: <20110411220345.9B95067C@kernel>
	 <20110411220346.2FED5787@kernel>
	 <20110411152223.3fb91a62.akpm@linux-foundation.org>
	 <op.vttl1ho83l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 12 Apr 2011 08:04:13 -0700
Message-ID: <1302620653.8321.1725.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>

On Tue, 2011-04-12 at 12:28 +0200, Michal Nazarewicz wrote:
> > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> >> +void __free_pages_exact(struct page *page, size_t nr_pages)
> >> +{
> >> +	struct page *end = page + nr_pages;
> >> +
> >> +	while (page < end) {
> >> +		__free_page(page);
> >> +		page++;
> >> +	}
> >> +}
> >> +EXPORT_SYMBOL(__free_pages_exact);
> 
> On Tue, 12 Apr 2011 00:22:23 +0200, Andrew Morton wrote:
> > Really, this function duplicates release_pages().
> 
> It requires an array of pointers to pages which is not great though if one
> just wants to free a contiguous sequence of pages.

Actually, the various mem_map[]s _are_ arrays, at least up to
MAX_ORDER_NR_PAGES at a time.  We can use that property here.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
