Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5CAC46B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 22:35:00 -0400 (EDT)
Message-ID: <51AD5251.9020202@codeaurora.org>
Date: Mon, 03 Jun 2013 19:34:57 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page_alloc: fix watermark check in __zone_watermark_ok()
References: <518B5556.4010005@samsung.com> <519FCC46.2000703@codeaurora.org> <CAH9JG2U7787jzqdnr1Z7kZbyEUvHZJG_XZiPENGJQVENsqVDTA@mail.gmail.com> <20130529150811.3d4d9a55f704e95be64c7b52@linux-foundation.org>
In-Reply-To: <20130529150811.3d4d9a55f704e95be64c7b52@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Tomasz Stanislawski <t.stanislaws@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, minchan@kernel.org, mgorman@suse.de, 'Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On 5/29/2013 3:08 PM, Andrew Morton wrote:
> On Sat, 25 May 2013 13:32:02 +0900 Kyungmin Park <kmpark@infradead.org> wrote:
>
>>> I haven't seen any response to this patch but it has been of some benefit
>>> to some of our use cases. You're welcome to add
>>>
>>> Tested-by: Laura Abbott <lauraa@codeaurora.org>
>>>
>>
>> Thanks Laura,
>> We already got mail from Andrew, it's merged mm tree.
>
> Yes, but I have it scheduled for 3.11 with no -stable backport.
>
> This is because the patch changelog didn't tell me about the
> userspace-visible impact of the bug.  Judging from Laura's comments, this
> was a mistake.
>
> So please: details.  What problems were observable to Laura and do we
> think this bug should be fixed in 3.10 and earlier?
>

We were observing allocation failures of higher order pages (order 5 = 
128K typically) under tight memory conditions resulting in driver 
failure. The output from the page allocation failure showed plenty of 
free pages of the appropriate order/type/zone and mostly CMA pages in 
the lower orders.

For full disclosure, we still observed some page allocation failures 
even after applying the patch but the number was drastically reduced and 
those failures were attributed to fragmentation/other system issues.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
