Received: by wx-out-0506.google.com with SMTP id s8so528521wxc
        for <linux-mm@kvack.org>; Fri, 19 Jan 2007 08:05:02 -0800 (PST)
Message-ID: <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>
Date: Sat, 20 Jan 2007 00:05:01 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
In-Reply-To: <45B0DB45.4070004@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
	 <45B0DB45.4070004@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>
List-ID: <linux-mm.kvack.org>

On 1/19/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>
>
> Hi Aubrey,
>
> The idea of creating separate flag for pagecache in page_alloc is
> interesting.  The good part is that you flag watermark low and the
> zone reclaimer will do the rest of the job.
>
> However when the zone reclaimer starts to reclaim pages, it will
> remove all cold pages and not specifically pagecache pages.  This
> may affect performance of applications.
>
> One possible solution to this reclaim is to use scan control fields
> and ask the shrink_page_list() and shrink_active_list() routines to
> target only pagecache pages.  Pagecache pages are not mapped and
> they are easy to find on the LRU list.
>
> Please review my patch at http://lkml.org/lkml/2007/01/17/96
>

So you mean the existing reclaimer has the same issue, doesn't it?
In your and Roy's patch, balance_pagecache() routine is called on file
backed access.
So you still want to add this checking? or change the current
reclaimer completely?

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
