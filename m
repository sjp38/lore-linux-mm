Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED656B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 05:29:05 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3299255pad.13
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 02:29:04 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id wg3si5267426pac.4.2014.07.31.02.29.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 02:29:04 -0700 (PDT)
Message-ID: <53DA0C5A.3010409@codeaurora.org>
Date: Thu, 31 Jul 2014 14:58:58 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: BUG when __kmap_atomic_idx equals KM_TYPE_NR
References: <1406787871-2951-1-git-send-email-cpandya@codeaurora.org> <alpine.DEB.2.02.1407310001360.18238@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407310001360.18238@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/31/2014 12:32 PM, David Rientjes wrote:
> On Thu, 31 Jul 2014, Chintan Pandya wrote:
>
>> __kmap_atomic_idx is per_cpu variable. Each CPU can
>> use KM_TYPE_NR entries from FIXMAP i.e. from 0 to
>> KM_TYPE_NR - 1. Allowing __kmap_atomic_idx to over-
>> shoot to KM_TYPE_NR can mess up with next CPU's 0th
>> entry which is a bug. Hence BUG_ON if
>> __kmap_atomic_idx>= KM_TYPE_NR.
>>
>
> This appears to be a completely different patch, not a v2.  Why is this
> check only done for CONFIG_DEBUG_HIGHMEM?

I agree that this check could have been there even without 
CONFIG_DEBUG_HIGHMEM for stability reasons.

>
> I think Andrew's comment earlier was referring to the changelog only and
> not the patch, which looked correct.

I think Andrew asked for a BUG case details also to justify the 
overhead. But we have never encountered that BUG case. Present patch is 
only logical fix to the code. However, in the fast path, if such 
overhead is allowed, I can move BUG_ON out of any debug configs. 
Otherwise, as per Andrew's suggestion, I will convert DEBUG_HIGHMEM into 
DEBUG_VM which is used more frequently.

>
>> Signed-off-by: Chintan Pandya<cpandya@codeaurora.org>
>> ---
>> Changes:
>>



-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
