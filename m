Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A93776B006A
	for <linux-mm@kvack.org>; Thu, 28 May 2009 03:02:08 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so2262574ywm.26
        for <linux-mm@kvack.org>; Thu, 28 May 2009 00:02:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090528143524.e8a2cde7.kamezawa.hiroyu@jp.fujitsu.com>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
	 <20090528143524.e8a2cde7.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 May 2009 19:02:09 +1200
Message-ID: <202cde0e0905280002o5614f279r9db7c8c52ad7df10@mail.gmail.com>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order allocations
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

Hi

>> Hi,
>> ...
>> What you could suggest to workaround the problem except hacks with page count?
>> May be it makes sence to introduce wm_insert_pages function?
>>
>
>
> Maybe followings are for drivers ?
>
> void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
> void free_pages_exact(void *virt, size_t size)
>
Hmm. This functions were developed for needs of video drivers to
prevent extra memory allocations, page splitting is the side effect of
using this function.
It should be Ok for UMA case.
The only problem that the driver I'm writing now should support NUMA
nodes selection also. In this case alloc_pages_exact won't help :(.
What could be the best solution to solve existing inconsistency? Any ideas?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
