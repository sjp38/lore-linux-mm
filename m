Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7T58dSM009471
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 01:08:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7T58dXr366980
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 23:08:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7T58ctW031632
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 23:08:38 -0600
Subject: Re: [PATCH] call mm/page-writeback.c:set_ratelimit() when new
	pages are hot-added
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1156803805.1196.74.camel@linuxchandra>
References: <1156803805.1196.74.camel@linuxchandra>
Content-Type: text/plain
Date: Mon, 28 Aug 2006 22:08:34 -0700
Message-Id: <1156828115.5408.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: akpm@osdl.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-28 at 15:23 -0700, Chandra Seetharaman wrote:
> --- linux-2.6.17.orig/mm/memory_hotplug.c
> +++ linux-2.6.17/mm/memory_hotplug.c
> @@ -141,6 +141,7 @@ int online_pages(unsigned long pfn, unsi
>         unsigned long start_pfn;
>         struct zone *zone;
>         int need_zonelists_rebuild = 0;
> +       extern void set_ratelimit(void);
>  
>         /*
>          * This doesn't need a lock to do pfn_to_page().
> @@ -191,6 +192,7 @@ int online_pages(unsigned long pfn, unsi
>         if (need_zonelists_rebuild)
>                 build_all_zonelists();
>         vm_total_pages = nr_free_pagecache_pages();
> +       set_ratelimit();
>         return 0;
>  } 

Hi Chandra,

It would be great if you could put set_ratelimit() into a proper header
like the rest of the functions needed by memory hotplug.  These kinds of
externs are ugly because they can too easily get out of sync with their
definitions and cause problems.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
