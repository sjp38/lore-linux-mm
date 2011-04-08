Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 664438D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 18:07:18 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p38LuokI004723
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 17:56:50 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6B9BC6E8036
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 18:07:09 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p38M6K0W065082
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 18:06:37 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p38M6JRn015459
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 16:06:20 -0600
Subject: Re: [PATCH 2/2] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vtmcx9kd3l0zgt@mnazarewicz-glaptop>
References: <20110407172104.1F8B7329@kernel>
	 <20110407172105.831B9A0A@kernel>  <op.vtmcx9kd3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 08 Apr 2011 15:06:16 -0700
Message-ID: <1302300376.7286.1392.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-08 at 14:28 +0200, Michal Nazarewicz wrote:
> On Thu, 07 Apr 2011 19:21:05 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
> > +		struct page *alloc_end = page + (1 << order);
> > +		struct page *used = page + PAGE_ALIGN(size)/PAGE_SIZE;
> > -		split_page(virt_to_page((void *)addr), order);
> > +		split_page(page, order);
> >  		while (used < alloc_end) {
> > -			free_page(used);
> > -			used += PAGE_SIZE;
> > +			__free_page(used);
> > +			used++;
> >  		}
> 
> Have you thought about moving this loop to a separate function, ie.
> _free_page_range(start, end)?  I'm asking because this loop appears
> in two places and my CMA would also benefit from such a function.

It's actually perilously close to free_pages_exact().  I'll try to make
it usable for this case as well.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
