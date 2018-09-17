Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 150BD8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 15:50:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x19-v6so8937321pfh.15
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 12:50:36 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id y8-v6si17248007pfk.75.2018.09.17.12.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 12:50:34 -0700 (PDT)
Subject: Re: [RFC v10 PATCH 1/3] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536957299-43536-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180915092101.GA31572@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <578efe1c-0de0-d71d-ac14-cf5b74e2a713@linux.alibaba.com>
Date: Mon, 17 Sep 2018 12:49:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180915092101.GA31572@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/15/18 2:21 AM, Matthew Wilcox wrote:
> On Sat, Sep 15, 2018 at 04:34:57AM +0800, Yang Shi wrote:
>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
>> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
>
> Looks good!  Thanks for sticking with this patch series.

Thanks for reviewing this patch series. I'm going to wait for one or two 
days to see whether anyone else has more comments before I have the 
spelling error fixed.

Yang

>
> Minor spelling fixes:
>
>> -	/*
>> -	 * Remove the vma's, and unmap the actual pages
>> -	 */
>> +	/* Detatch vmas from rbtree */
> "Detach"
>
>> +	/*
>> +	 * mpx unmap need to be handled with write mmap_sem. It is safe to
>> +	 * deal with it before unmap_region().
>> +	 */
> 	 * mpx unmap needs to be called with mmap_sem held for write.
> 	 * It is safe to call it before unmap_region()
>
>> +	ret = __do_munmap(mm, start, len, &uf, downgrade);
>> +	/*
>> +	 * Returning 1 indicates mmap_sem is down graded.
>> +	 * But 1 is not legal return value of vm_munmap() and munmap(), reset
>> +	 * it to 0 before return.
>> +	 */
> "downgraded" is one word.
