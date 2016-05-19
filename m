Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 665AF6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 19:26:12 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so134693073pac.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 16:26:12 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 8si23168716pad.28.2016.05.19.16.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 16:26:11 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id tb2so16134829pac.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 16:26:11 -0700 (PDT)
Subject: Re: [PATCH] mm: move page_ext_init after all struct pages are
 initialized
References: <1463693345-30842-1-git-send-email-yang.shi@linaro.org>
 <20160519153007.322150e4253656a3ac963656@linux-foundation.org>
 <6dd46bac-a0e4-d3c0-ded3-cbacc7f4a4ff@linaro.org>
 <20160519162107.372d19eac129d590ea160203@linux-foundation.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <bf7c4532-40bb-69bb-41b0-ed08a424011e@linaro.org>
Date: Thu, 19 May 2016 16:26:09 -0700
MIME-Version: 1.0
In-Reply-To: <20160519162107.372d19eac129d590ea160203@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/19/2016 4:21 PM, Andrew Morton wrote:
> On Thu, 19 May 2016 15:35:15 -0700 "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>> On 5/19/2016 3:30 PM, Andrew Morton wrote:
>>> On Thu, 19 May 2016 14:29:05 -0700 Yang Shi <yang.shi@linaro.org> wrote:
>>>
>>>> When DEFERRED_STRUCT_PAGE_INIT is enabled, just a subset of memmap at boot
>>>> are initialized, then the rest are initialized in parallel by starting one-off
>>>> "pgdatinitX" kernel thread for each node X.
>>>>
>>>> If page_ext_init is called before it, some pages will not have valid extension,
>>>> so move page_ext_init() after it.
>>>>
>>>
>>> <stdreply>When fixing a bug, please fully describe the end-user impact
>>> of that bug</>
>>
>> The kernel ran into the below oops which is same with the oops reported
>> in
>> http://ozlabs.org/~akpm/mmots/broken-out/mm-page_is_guard-return-false-when-page_ext-arrays-are-not-allocated-yet.patch.
>
> So this patch makes
> mm-page_is_guard-return-false-when-page_ext-arrays-are-not-allocated-yet.patch
> obsolete?

Actually, no. Checking the return value for lookup_page_ext() is still 
needed. But, the commit log need to be amended since that bootup oops 
won't happen anymore with this patch applied.

Thanks,
Yang

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
