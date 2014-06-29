Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DD49B6B0039
	for <linux-mm@kvack.org>; Sun, 29 Jun 2014 15:49:39 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so7051594pde.12
        for <linux-mm@kvack.org>; Sun, 29 Jun 2014 12:49:39 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id rw8si20664321pab.167.2014.06.29.12.49.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jun 2014 12:49:38 -0700 (PDT)
Message-ID: <53B06DD0.8030106@codeaurora.org>
Date: Sun, 29 Jun 2014 12:49:36 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC] CMA page migration failure due to buffers on bh_lru
References: <53A8D092.4040801@lge.com> <xa1td2dvmznq.fsf@mina86.com> <53ACAB82.6020201@lge.com>
In-Reply-To: <53ACAB82.6020201@lge.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, Hugh Dickins <hughd@google.com>

(cc-ing Hugh since he had comments on the patch before)

On 6/26/2014 4:23 PM, Gioh Kim wrote:
> 
> 
> 2014-06-27 i??i ? 12:57, Michal Nazarewicz i?' e,?:
>> On Tue, Jun 24 2014, Gioh Kim <gioh.kim@lge.com> wrote:
>>> Hello,
>>>
>>> I am trying to apply CMA feature for my platform.
>>> My kernel version, 3.10.x, is not allocating memory from CMA area so that I applied
>>> a Joonsoo Kim's patch (https://lkml.org/lkml/2014/5/28/64).
>>> Now my platform can use CMA area effectively.
>>>
>>> But I have many failures to allocate memory from CMA area.
>>> I found the same situation to Laura Abbott's patch descrbing,
>>> https://lkml.org/lkml/2012/8/31/313,
>>> that releases buffer-heads attached at CPU's LRU list.
>>>
>>> If Joonsoo's patch is applied and/or CMA feature is applied more and more,
>>> buffer-heads problem is going to be serious definitely.
>>>
>>> Please look into the Laura's patch again.
>>> I think it must be applied with Joonsoo's patch.
>>
>> Just to make sure I understood you correctly, you're saying Laura's
>> patch at <https://lkml.org/lkml/2012/8/31/313> fixes your issue?
>>
> 
> Yes, it is.

I submitted this before and it was suggested that this was more
related to filesystems

http://marc.info/?l=linaro-mm-sig&m=137645770708817&w=2

I never saw more discussion and pushed this into the 'CMA hacks' pile. 
So far we've been keeping the patch out of tree and it's useful to know
that others have found the same problem. I'm willing to resubmit the
patch for further discussion.

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
