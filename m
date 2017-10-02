Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57C846B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 11:46:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id c137so9401911pga.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 08:46:32 -0700 (PDT)
Received: from out0-195.mail.aliyun.com (out0-195.mail.aliyun.com. [140.205.0.195])
        by mx.google.com with ESMTPS id i9si4924957pgq.152.2017.10.02.08.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 08:46:31 -0700 (PDT)
Subject: Re: [PATCH 0/2 v8] oom: capture unreclaimable slab info in oom
 message
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com>
 <fccbce9c-a40e-621f-e9a4-17c327ed84e8@I-love.SAKURA.ne.jp>
 <20171002112051.uk4gyrtygfgtvp5g@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <030a906a-c845-9639-8df3-2a48d11a1207@alibaba-inc.com>
Date: Mon, 02 Oct 2017 23:46:14 +0800
MIME-Version: 1.0
In-Reply-To: <20171002112051.uk4gyrtygfgtvp5g@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/2/17 4:20 AM, Michal Hocko wrote:
> On Thu 28-09-17 13:36:57, Tetsuo Handa wrote:
>> On 2017/09/28 6:46, Yang Shi wrote:
>>> Changelog v7 a??> v8:
>>> * Adopted Michala??s suggestion to dump unreclaim slab info when unreclaimable slabs amount > total user memory. Not only in oom panic path.
>>
>> Holding slab_mutex inside dump_unreclaimable_slab() was refrained since V2
>> because there are
>>
>> 	mutex_lock(&slab_mutex);
>> 	kmalloc(GFP_KERNEL);
>> 	mutex_unlock(&slab_mutex);
>>
>> users. If we call dump_unreclaimable_slab() for non OOM panic path, aren't we
>> introducing a risk of crash (i.e. kernel panic) for regular OOM path?
> 
> yes we are
>   
>> We can try mutex_trylock() from dump_unreclaimable_slab() at best.
>> But it is still remaining unsafe, isn't it?
> 
> using the trylock sounds like a reasonable compromise.

OK, it sounds we reach agreement on trylock. Will solve those comments 
in v9.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
