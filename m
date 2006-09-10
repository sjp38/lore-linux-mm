Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8AGPfQa003522
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 12:25:41 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8AGPY6Y203088
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 10:25:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8AGPYLk021490
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 10:25:34 -0600
Subject: Re: [patch 2/2] convert s390 page handling macros to functions v3
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060910130832.GB12084@osiris.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com>
	 <Pine.LNX.4.64.0609092248400.6762@scrub.home>
	 <20060910130832.GB12084@osiris.ibm.com>
Content-Type: text/plain
Date: Sun, 10 Sep 2006 09:25:18 -0700
Message-Id: <1157905518.26324.83.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Roman Zippel <zippel@linux-m68k.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2006-09-10 at 15:08 +0200, Heiko Carstens wrote:
> 
> +static inline int page_test_and_clear_dirty(struct page *page)
> +{
> +       unsigned long physpage = __pa((page - mem_map) << PAGE_SHIFT);
> +       int skey = page_get_storage_key(physpage); 

This has nothing to do with your patch at all, but why is 'page -
mem_map' being open-coded here?

I see at least a couple of page_to_phys() definitions on some
architectures.  This operation is done enough times that s390 could
probably use the same treatment.

It could at least use a page_to_pfn() instead of the 'page - mem_map'
operation, right?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
