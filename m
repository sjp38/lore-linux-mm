Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 258E16B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 05:39:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y128so1831685pfg.5
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 02:39:23 -0700 (PDT)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTP id t191si309332pgc.187.2017.11.01.02.39.21
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 02:39:21 -0700 (PDT)
Subject: Re: [PATCH RFC v2 1/4] mm/mempolicy: Fix get_nodes() mask
 miscalculation
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-2-git-send-email-xieyisheng1@huawei.com>
 <922a4767-9eed-40aa-c437-6f6fcdcab150@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <c9b57bde-7834-45c4-2c22-3220e3680c93@huawei.com>
Date: Wed, 1 Nov 2017 17:37:36 +0800
MIME-Version: 1.0
In-Reply-To: <922a4767-9eed-40aa-c437-6f6fcdcab150@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

Hi Vlastimil,

Thanks for comment!
On 2017/10/31 16:34, Vlastimil Babka wrote:
> On 10/27/2017 12:14 PM, Yisheng Xie wrote:
>> It appears there is a nodemask miscalculation in the get_nodes()
>> function in mm/mempolicy.c.  This bug has two effects:
>>
>> 1. It is impossible to specify a length 1 nodemask.
>> 2. It is impossible to specify a nodemask containing the last node.
> 
> This should be more specific, which syscalls are you talking about?
> I assume it's set_mempolicy() and mbind() and it's the same issue that
> was discussed at https://marc.info/?l=linux-mm&m=150732591909576&w=2 ?

I just missed this thread, sorry about that. Not only set_mempolicy() and
mbind(), but migrate_pages() also suffers this problem. Maybe related
manpage should documented this as your mentioned below.

Thanks
Yisheng Xie

> 
>> Brent have submmit a patch before v2.6.12, however, Andi revert his
>> changed for ABI problem. I just resent this patch as RFC, for do not
>> clear about what's the problem Andi have met.
> 
> You should have CC'd Andi. As was discussed in the other thread, this
> would make existing programs potentially unsafe, so we can't change it.
> Instead it should be documented.
> 
>> As manpage of set_mempolicy, If the value of maxnode is zero, the
>> nodemask argument is ignored. but we should not ignore the nodemask
>> when maxnode is 1.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
