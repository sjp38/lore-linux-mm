Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0D28D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 17:59:06 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p37LuJsd010716
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 15:56:19 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p37LwxaW094964
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 15:59:02 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p37LwxtO029644
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 15:58:59 -0600
Subject: Re: [PATCH 1/2] rename alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104071437130.14967@chino.kir.corp.google.com>
References: <20110407172104.1F8B7329@kernel>
	 <alpine.DEB.2.00.1104071437130.14967@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 07 Apr 2011 14:58:57 -0700
Message-ID: <1302213537.8184.4105.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-04-07 at 14:40 -0700, David Rientjes wrote:
> > alloc_pages_exact() returns a virtual address.  But, alloc_pages() returns
> > a 'struct page *'.  That makes for very confused kernel hackers.
> > 
> > __get_free_pages(), on the other hand, returns virtual addresses.  That
> > makes alloc_pages_exact() a much closer match to __get_free_pages(), so
> > rename it to get_free_pages_exact().
> > 
> 
> The patch also reverses the arguments of the function in 
> include/linux/gfp.h, undoubtedly to resemble the (mask, order) appearance 
> of __get_free_pages():
> 
> 	-void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
> 	+void *get_free_pages_exact(gfp_t gfp_mask, size_t size);

Thanks.  I dumped the fixes for that in the second patch.  Whoops.  Will
repost.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
