Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 751806B0032
	for <linux-mm@kvack.org>; Sat, 21 Sep 2013 20:55:09 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so2177716pad.28
        for <linux-mm@kvack.org>; Sat, 21 Sep 2013 17:55:09 -0700 (PDT)
Message-ID: <523E3FC6.7020009@huawei.com>
Date: Sun, 22 Sep 2013 08:54:30 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/ksm: return NULL when doesn't get mergeable page
References: <5236FC88.6050409@huawei.com> <20130919083329.GA1620@thinkpad-work.brq.redhat.com>
In-Reply-To: <20130919083329.GA1620@thinkpad-work.brq.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/9/19 16:33, Petr Holasek wrote:

> On Mon, 16 Sep 2013, Jianguo Wu wrote:
>> In get_mergeable_page() local variable page is not initialized,
>> it may hold a garbage value, when find_mergeable_vma() return NULL,
>> get_mergeable_page() may return a garbage value to the caller.
>>
>> So initialize page as NULL.
>>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>>  mm/ksm.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index b6afe0c..87efbae 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -460,7 +460,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
>>  	struct mm_struct *mm = rmap_item->mm;
>>  	unsigned long addr = rmap_item->address;
>>  	struct vm_area_struct *vma;
>> -	struct page *page;
>> +	struct page *page = NULL;
>>  
>>  	down_read(&mm->mmap_sem);
>>  	vma = find_mergeable_vma(mm, addr);
>> -- 
>> 1.7.1
>>
> 
> When find_mergeable_vma returned NULL, NULL is assigned to page in "out"
> statement.
> 

Oh, yes, thanks, Petr.

> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
