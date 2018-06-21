Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6AC6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 18:24:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i12-v6so1768826pgt.13
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 15:24:29 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id w2-v6si4778942pgq.581.2018.06.21.15.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 15:24:27 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: register mm for khugepaged when merging vma for
 shmem
References: <1529617247-126312-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180621221008.r33hpd223kx2gv3a@kshutemo-mobl1>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <be046d3f-06e0-09fd-c1d0-3e374dedcf16@linux.alibaba.com>
Date: Thu, 21 Jun 2018 15:24:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180621221008.r33hpd223kx2gv3a@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 6/21/18 3:10 PM, Kirill A. Shutemov wrote:
> On Fri, Jun 22, 2018 at 05:40:47AM +0800, Yang Shi wrote:
>> When merging anonymous page vma, if the size of vam can fit in at least
> s/vam/vma/
>
>> one hugepage, the mm will be registered for khugepaged for collapsing
>> THP in the future.
>>
>> But, it skips shmem vma. Doing so for shmem too when merging vma in
>> order to increase the odd to collapse hugepage by khugepaged.
> Good catch. Thanks.
>
> I think the fix incomplete. We shouldn't require vma->anon_vma for shmem,
> only for anonymous mappings. We don't support file-private THPs.

So you mean, shmem_file(vma->vm_file) && PageAnon(page)?

>
>> Also increase the count of shmem THP collapse. It looks missed before.
> Separate patch, please.

Sure.

Thanks,
Yang

>
