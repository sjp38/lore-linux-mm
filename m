Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 629116B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 13:29:47 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z20so3061445igj.10
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 10:29:47 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ii1si3955862igb.19.2014.11.26.10.29.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Nov 2014 10:29:46 -0800 (PST)
Message-ID: <54761C18.6090003@codeaurora.org>
Date: Wed, 26 Nov 2014 10:29:44 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Improving CMA
References: <5473E146.7000503@codeaurora.org> <20141125113225.GH2725@suse.de> <54755621.6050700@lge.com>
In-Reply-To: <54755621.6050700@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Mel Gorman <mgorman@suse.de>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>, minchan@kernel.org, zhuhui@xiaomi.com, iamjoonsoo.kim@lge.com

On 11/25/2014 8:25 PM, Gioh Kim wrote:
>
>
> 2014-11-25 i??i?? 8:32i?? Mel Gorman i?'(e??) i?' e,?:
>> On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
>>> There have been a number of patch series posted designed to improve various
>>> aspects of CMA. A sampling:
>>>
>>> https://lkml.org/lkml/2014/10/15/623
>>> http://marc.info/?l=linux-mm&m=141571797202006&w=2
>>> https://lkml.org/lkml/2014/6/26/549
>>>
>>> As far as I can tell, these are all trying to fix real problems with CMA but
>>> none of them have moved forward very much from what I can tell. The goal of
>>> this session would be to come out with an agreement on what are the biggest
>>> problems with CMA and the best ways to solve them.
>>>
>>
>> I think this is a good topic. Some of the issues have been brought up before
>> at LSF/MM but they never made that much traction so it's worth revisiting. I
>> haven't been paying close attention to the mailing list discussions but
>> I've been a little worried that the page allocator paths are turning into
>> a bigger and bigger mess. I'm also a bit worried that options such as
>> migrating pages out of CMA areas that are about to be pinned for having
>> callback options to forcibly free pages never went anywhere.
>>
>
>
> I have two question.
>
> First, is GCMA able to replace CMA? It's news to me.
> I need some time to check GCMA.
>
> Second, is CMA popular enough to change allocator path?
> Yes, I need it.
> But I don't know any company uses it, and nobody seems to have interest in it.

We use it very heavily in our devices and I don't think it's a stretch to
say we depend on it to actually ship a product. I suspect this may be the case
with other companies as well. It may not be as obvious if CMA is being used
because much of the work is still out of tree. I think if CMA performance
metrics were improved it would see more obvious traction as well.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
