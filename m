Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18D026B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 21:24:53 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v4so55213611pgc.20
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 18:24:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id r81si3290814pfk.112.2017.04.06.18.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 18:24:52 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2] mm, swap: Use kvzalloc to allocate some swap data structure
References: <20170405071058.25223-1-ying.huang@intel.com>
	<20170406134024.GD31725@bombadil.infradead.org>
Date: Fri, 07 Apr 2017 09:24:49 +0800
In-Reply-To: <20170406134024.GD31725@bombadil.infradead.org> (Matthew Wilcox's
	message of "Thu, 6 Apr 2017 06:40:24 -0700")
Message-ID: <87a87tau1q.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Hi, Matthew,

Matthew Wilcox <willy@infradead.org> writes:

> On Wed, Apr 05, 2017 at 03:10:58PM +0800, Huang, Ying wrote:
>> In general, kmalloc() will have less memory fragmentation than
>> vmalloc().  From Dave Hansen: For example, we have a two-page data
>> structure.  vmalloc() takes two effectively random order-0 pages,
>> probably from two different 2M pages and pins them.  That "kills" two
>> 2M pages.  kmalloc(), allocating two *contiguous* pages, is very
>> unlikely to cross a 2M boundary (it theoretically could).  That means
>> it will only "kill" the possibility of a single 2M page.  More 2M
>> pages == less fragmentation.
>
> Wait, what?  How does kmalloc() manage to allocate two pages that cross
> a 2MB boundary?  AFAIK if you ask kmalloc to allocate N pages, it asks
> the page allocator for an order-log(N) page allocation.  Being a buddy
> allocator, that comes back with an aligned set of pages.  There's no
> way it can get the last page from a 2MB region and the first page from
> the next 2MB region.

OK.  I will change the comments in the next version.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
