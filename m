Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBA06B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:28:39 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f5so12332566oic.10
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 23:28:39 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id k70si5829631oib.414.2017.08.30.23.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 23:28:37 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: stacktrace: avoid listing stacktrace functions
 in stacktrace
References: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
 <20170830132828.0bf9b9bc64f51362a64a6694@linux-foundation.org>
From: Prakash Gupta <guptap@codeaurora.org>
Message-ID: <9ce9206f-cffa-99c5-2a34-e5988bd0b603@codeaurora.org>
Date: Thu, 31 Aug 2017 11:58:31 +0530
MIME-Version: 1.0
In-Reply-To: <20170830132828.0bf9b9bc64f51362a64a6694@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com, iamjoonsoo.kim@lge.com, rmk+kernel@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 8/31/2017 1:58 AM, Andrew Morton wrote:
> On Wed, 30 Aug 2017 13:02:22 +0530 Prakash Gupta <guptap@codeaurora.org> wrote:
> 
>> The stacktraces always begin as follows:
>>
>>   [<c00117b4>] save_stack_trace_tsk+0x0/0x98
>>   [<c0011870>] save_stack_trace+0x24/0x28
>>   ...
>>
>> This is because the stack trace code includes the stack frames for itself.
>> This is incorrect behaviour, and also leads to "skip" doing the wrong thing
>> (which is the number of stack frames to avoid recording.)
>>
>> Perversely, it does the right thing when passed a non-current thread.  Fix
>> this by ensuring that we have a known constant number of frames above the
>> main stack trace function, and always skip these.
>>
>> This was fixed for arch arm by Commit 3683f44c42e9 ("ARM: stacktrace: avoid
>> listing stacktrace functions in stacktrace")
> 
> I can take this (with acks, please?)
> 
> 3683f44c42e9 has a cc:stable but your patch does not.  Should it?
> 

My bad, it should be copied to stable as well.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a 
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
