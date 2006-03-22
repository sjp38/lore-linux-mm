Message-ID: <44209A26.3040102@yahoo.com.au>
Date: Wed, 22 Mar 2006 11:28:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: PATCH][1/8] 2.6.15 mlock: make_pages_wired/unwired
References: <bc56f2f0603200536scb87a8ck@mail.gmail.com>	 <441FEFB4.6050700@yahoo.com.au> <bc56f2f0603210803l28145c7dj@mail.gmail.com>
In-Reply-To: <bc56f2f0603210803l28145c7dj@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
> We dont account HugeTLB pages for:
> 
> 1. HugeTLB pages themselves are not reclaimable.
> 
> 2. If we count HugeTLB pages in "Wired",then we would have no mind
>    how many of the "Wired" are HugeTLB pages, and how many are
> normal-size pages.
>    Thus, hard to get a clear map of physical memory use,for example:
>      how many pages are reclaimable?
>    If we must count HugeTLB pages,more fields should be added to
> "/proc/meminfo",
>    for exmaple: "Wired HugeTLB:", "Wired Normal:".
> 

Then why do you wire them at all? Your unwire function does not appear
to be able to unwire them.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
