Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 136FA6B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 17:49:29 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hl10so1240080igb.5
        for <linux-mm@kvack.org>; Fri, 23 May 2014 14:49:28 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id gh14si7742621icb.1.2014.05.23.14.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 14:49:28 -0700 (PDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so1240552igd.8
        for <linux-mm@kvack.org>; Fri, 23 May 2014 14:49:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1405231353080.13205@chino.kir.corp.google.com>
References: <1400847135-22291-1-git-send-email-dh.herrmann@gmail.com>
	<alpine.DEB.2.02.1405231353080.13205@chino.kir.corp.google.com>
Date: Fri, 23 May 2014 23:49:28 +0200
Message-ID: <CANq1E4SfL=c_ZgGwRkQWoEHEWF4q8-DVB+RsQfo6CqGQc9MoZA@mail.gmail.com>
Subject: Re: [PATCH] mm/madvise: fix WILLNEED on SHM/ANON to actually do something
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vladimir Cernov <gg.kaspersky@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>

Hi

On Fri, May 23, 2014 at 10:55 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 23 May 2014, David Herrmann wrote:
>
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 539eeb9..a402f8f 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -195,7 +195,7 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
>>       for (; start < end; start += PAGE_SIZE) {
>>               index = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
>>
>> -             page = find_get_page(mapping, index);
>> +             page = find_get_entry(mapping, index);
>>               if (!radix_tree_exceptional_entry(page)) {
>>                       if (page)
>>                               page_cache_release(page);
>
> This is already in -mm from Johannes, see
> http://marc.info/?l=linux-kernel&m=139998616712729.  Check out
> http://www.ozlabs.org/~akpm/mmotm/ for this kernel.

Didn't check -mm, sorry. Thanks for the links!
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
