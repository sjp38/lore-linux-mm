Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE4EC6B0005
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 14:03:08 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m2-v6so10338001plt.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:03:08 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id d33-v6si17720440pla.57.2018.07.02.11.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 11:03:07 -0700 (PDT)
Subject: Re: [RFC v3 PATCH 3/5] mm: refactor do_munmap() to extract the common
 part
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-4-git-send-email-yang.shi@linux.alibaba.com>
 <20180702134226.GX19043@dhcp22.suse.cz>
 <5aa8953d-3781-8b22-89f6-994a52ea0172@linux.alibaba.com>
 <20180702175835.GH19043@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <20e2cd1a-7969-fa5e-4298-3bb1e6563acf@linux.alibaba.com>
Date: Mon, 2 Jul 2018 11:02:28 -0700
MIME-Version: 1.0
In-Reply-To: <20180702175835.GH19043@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org



On 7/2/18 10:58 AM, Michal Hocko wrote:
> On Mon 02-07-18 09:59:06, Yang Shi wrote:
>>
>> On 7/2/18 6:42 AM, Michal Hocko wrote:
>>> On Sat 30-06-18 06:39:43, Yang Shi wrote:
>>>> Introduces two new helper functions:
>>>>     * munmap_addr_sanity()
>>>>     * munmap_lookup_vma()
>>>>
>>>> They will be used by do_munmap() and the new do_munmap with zapping
>>>> large mapping early in the later patch.
>>>>
>>>> There is no functional change, just code refactor.
>>> There are whitespace changes which make the code much harder to review
>>> than necessary.
>>>> +static inline bool munmap_addr_sanity(unsigned long start, size_t len)
>>>>    {
>>>> -	unsigned long end;
>>>> -	struct vm_area_struct *vma, *prev, *last;
>>>> +	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE - start)
>>>> +		return false;
>>>> -	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
>>>> -		return -EINVAL;
>>> e.g. here.
>> Oh, yes. I did some coding style cleanup too.
> If you want to do some coding style cleanups make them a separate patch.
> The resulting diff would be much easier to review.

Sure, thanks

>
