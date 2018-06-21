Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 761C16B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 18:50:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s7-v6so2188216pfm.4
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 15:50:05 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id m11-v6si5869720plt.284.2018.06.21.15.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 15:50:04 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: register mm for khugepaged when merging vma for
 shmem
From: Yang Shi <yang.shi@linux.alibaba.com>
References: <1529617247-126312-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180621221008.r33hpd223kx2gv3a@kshutemo-mobl1>
 <be046d3f-06e0-09fd-c1d0-3e374dedcf16@linux.alibaba.com>
Message-ID: <8a411d2f-1765-beb2-0850-73feaa7ba79b@linux.alibaba.com>
Date: Thu, 21 Jun 2018 15:49:58 -0700
MIME-Version: 1.0
In-Reply-To: <be046d3f-06e0-09fd-c1d0-3e374dedcf16@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 6/21/18 3:24 PM, Yang Shi wrote:
>
>
> On 6/21/18 3:10 PM, Kirill A. Shutemov wrote:
>> On Fri, Jun 22, 2018 at 05:40:47AM +0800, Yang Shi wrote:
>>> When merging anonymous page vma, if the size of vam can fit in at least
>> s/vam/vma/
>>
>>> one hugepage, the mm will be registered for khugepaged for collapsing
>>> THP in the future.
>>>
>>> But, it skips shmem vma. Doing so for shmem too when merging vma in
>>> order to increase the odd to collapse hugepage by khugepaged.
>> Good catch. Thanks.
>>
>> I think the fix incomplete. We shouldn't require vma->anon_vma for 
>> shmem,
>> only for anonymous mappings. We don't support file-private THPs.
>
> So you mean, shmem_file(vma->vm_file) && PageAnon(page)?

I got your point. Please disregard the question.

>
>>
>>> Also increase the count of shmem THP collapse. It looks missed before.
>> Separate patch, please.
>
> Sure.
>
> Thanks,
> Yang
>
>>
>
