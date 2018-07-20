Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6366B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 19:51:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z21-v6so8540407plo.13
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:51:49 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id f12-v6si2695470pgg.653.2018.07.20.16.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 16:51:48 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180720210626.5bnyddmn4avp2l3x@kshutemo-mobl1>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3118b646-681e-a2aa-dc7b-71d4821fa50f@linux.alibaba.com>
Date: Fri, 20 Jul 2018 16:51:31 -0700
MIME-Version: 1.0
In-Reply-To: <20180720210626.5bnyddmn4avp2l3x@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: hughd@google.com, rientjes@google.com, aaron.lu@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/20/18 2:06 PM, Kirill A. Shutemov wrote:
> On Sat, Jul 21, 2018 at 02:13:50AM +0800, Yang Shi wrote:
>> By digging into the original review, it looks use_zero_page sysfs knob
>> was added to help ease-of-testing and give user a way to mitigate
>> refcounting overhead.
>>
>> It has been a few years since the knob was added at the first place, I
>> think we are confident that it is stable enough. And, since commit
>> 6fcb52a56ff60 ("thp: reduce usage of huge zero page's atomic counter"),
>> it looks refcounting overhead has been reduced significantly.
>>
>> Other than the above, the value of the knob is always 1 (enabled by
>> default), I'm supposed very few people turn it off by default.
>>
>> So, it sounds not worth to still keep this knob around.
> I don't think that having the knob around is huge maintenance burden.
> And since it helped to workaround a security bug relative recently I would
> rather keep it.

I agree to keep it for a while to let that security bug cool down, 
however, if there is no user anymore, it sounds pointless to still keep 
a dead knob.

>
