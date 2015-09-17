Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id DBC116B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 09:00:57 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so8802030lbb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 06:00:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uu1si3921121wjc.126.2015.09.17.06.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Sep 2015 06:00:55 -0700 (PDT)
Subject: Re: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
 <20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55FAB985.9060705@suse.cz>
Date: Thu, 17 Sep 2015 15:00:53 +0200
MIME-Version: 1.0
In-Reply-To: <20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, ddstreet@ieee.org, akpm@linux-foundation.org, minchan@kernel.org, sergey.senozhatsky@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/16/2015 01:50 PM, Vitaly Wool wrote:
> For zram to be able to use zbud via the common zpool API,
> allocations of size PAGE_SIZE should be allowed by zpool.
> zbud uses the beginning of an allocated page for its internal
> structure but it is not a problem as long as we keep track of
> such special pages using a newly introduced page flag.
> To be able to keep track of zbud pages in any case, struct page's
> lru pointer will be used for zbud page lists instead of the one
> that used to be part of the aforementioned internal structure.

I don't know how zsmalloc handles uncompressible PAGE_SIZE allocations, 
but I wouldn't expect it to be any more clever than this? So why 
duplicate the functionality in zswap and zbud? This could be handled 
e.g. at the zpool level? Or maybe just in zram, as IIRC in zswap 
(frontswap) it's valid just to reject a page and it goes to physical swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
