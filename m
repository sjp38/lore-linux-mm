Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 46CE36B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:21:10 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so23569574wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:21:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f197si16297311wmd.85.2016.03.29.05.21.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 05:21:09 -0700 (PDT)
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
References: <56F4E104.9090505@huawei.com>
 <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
 <56F61EC8.7080508@huawei.com> <56FA5062.2020103@suse.cz>
 <56FA5AF5.30006@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FA732E.9020906@suse.cz>
Date: Tue, 29 Mar 2016 14:21:02 +0200
MIME-Version: 1.0
In-Reply-To: <56FA5AF5.30006@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On 03/29/2016 12:37 PM, Xishi Qiu wrote:
> On 2016/3/29 17:52, Vlastimil Babka wrote:
>> The code in this functions seems to come from 099730d67417d ("mm, hugetlb: use memory policy when available") by Dave Hansen (adding to CC), which was indeed merged in 4.4-rc1.
>>
>> However, alloc_pages_node() is only called in the block guarded by:
>>
>> if (!IS_ENABLED(CONFIG_NUMA) || !vma) {
>>
>> The rather weird "!IS_ENABLED(CONFIG_NUMA)" part comes from immediate followup commit e0ec90ee7e6f ("mm, hugetlbfs: optimize when NUMA=n")
>>
>> So I doubt the code path here can actually happen. But it's fragile and confusing nevertheless.
>>
>
> Hi Vlastimil
>
> __alloc_buddy_huge_page(h, NULL, addr, nid); // so the vma is NULL

Hm that's true, I got lost in the logic, thanks.
But the problem with dequeue_huge_page_node() is also IMHO true, and 
older, so we should fix 3.12+.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
