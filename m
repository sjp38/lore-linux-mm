Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j36FdU5j462224
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 11:39:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j36FdUj6164916
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 09:39:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j36FdTbm012399
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 09:39:29 -0600
Subject: Re: [PATCH_FOR_REVIEW 2.6.12-rc1 2/3] mm: manual page
	migration-rc1 -- add node_map arg to try_to_migrate_pages()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050406041701.25060.91114.75958@jackhammer.engr.sgi.com>
References: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>
	 <20050406041701.25060.91114.75958@jackhammer.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 06 Apr 2005 08:39:23 -0700
Message-Id: <1112801963.19430.151.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-05 at 21:17 -0700, Ray Bryant wrote:
> +#ifdef CONFIG_NUMA
> +static inline struct page *node_migrate_onepage(struct page *page, short *node_map) 
> +{
> +	if (node_map)
> +		return migrate_onepage(page, node_map[page_to_nid(page)]);
> +	else
> +		return migrate_onepage(page, MIGRATE_NODE_ANY); 
> +		
> +}
> +#else
> +static inline struct page *node_migrate_onepage(struct page *page, short *node_map) 
> +{
> +	return migrate_onepage(page, MIGRATE_NODE_ANY); 
> +}
> +#endif

I don't think that #ifdef is needed.  A user is always welcome to call
node_migrate_onepage() with a non-existent node in node_map[] because
they'll just get an error when the allocation attempt occurs.  The same
is true when there's only one node.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
