Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3540E6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 07:54:59 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so2722738ier.13
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 04:54:59 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ou3si26636906icb.76.2014.08.20.04.54.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 04:54:58 -0700 (PDT)
Message-ID: <53F48C8B.4020707@codeaurora.org>
Date: Wed, 20 Aug 2014 17:24:51 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] ksm: provide support to use deferrable timers
 for scanner thread
References: <1406793591-26793-2-git-send-email-cpandya@codeaurora.org> <1406793591-26793-3-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408110332350.1500@eggly.anvils> <53EA3FF5.1050709@codeaurora.org>
In-Reply-To: <53EA3FF5.1050709@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-arm-msm@vger.kernel.org

Hi Hugh,

>>> + unsigned long enable;
>>> + int err;
>>> +
>>> + err = kstrtoul(buf, 10,&enable);
>>> + if (err< 0)
>>> + return err;
>>> + if (enable>= 1)
>>> + return -EINVAL;
>>
>> I haven't studied the patch itself, I'm still worrying about the concept.
>> But this caught my eye just before hitting Send: I don't think we need
>> a tunable which only accepts the value 0 ;)
>
> Okay. I can correct this to accept any non-zero value. Is that okay ?

I missed that to reply earlier. This was suggested by Andrew. And I 
think that is okay as displaying any non-zero value to user via this 
knob may not be completely right.

>
>>
>>> + use_deferrable_timer = enable;
>


-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
