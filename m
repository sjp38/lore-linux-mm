Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 281346B0177
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 10:12:10 -0400 (EDT)
Message-ID: <4FE47D0E.3000804@redhat.com>
Date: Fri, 22 Jun 2012 10:11:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
References: <1340315835-28571-1-git-send-email-riel@surriel.com>  <1340315835-28571-2-git-send-email-riel@surriel.com> <1340359115.18025.57.camel@twins>
In-Reply-To: <1340359115.18025.57.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On 06/22/2012 05:58 AM, Peter Zijlstra wrote:
> On Thu, 2012-06-21 at 17:57 -0400, Rik van Riel wrote:
>> @@ -1941,6 +2017,8 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>>          *insertion_point = vma;
>>          if (vma)
>>                  vma->vm_prev = prev;
>> +       if (vma)
>> +               rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
>
> Shouldn't that be adjust_free_gap()? There is after all no actual erase
> happening.

You are right. I will fix this and also adjust the comment
above adjust_free_gap().

I am still trying to wrap my brain around your alternative
search algorithm, not sure if/how it can be combined with
arbitrary address limits and alignment...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
