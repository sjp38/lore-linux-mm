Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F21DC6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:55:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 11so16858327pge.4
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:55:45 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id 3si4112977plp.335.2017.09.25.08.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 08:55:44 -0700 (PDT)
Subject: Re: [PATCH 0/2 v4] oom: capture unreclaimable slab info in oom
 message when kernel panic
References: <1505947132-4363-1-git-send-email-yang.s@alibaba-inc.com>
 <20170925142352.havlx6ikheanqyhj@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <e773cd57-8df6-ee6e-d051-857b8f354a0a@alibaba-inc.com>
Date: Mon, 25 Sep 2017 23:55:19 +0800
MIME-Version: 1.0
In-Reply-To: <20170925142352.havlx6ikheanqyhj@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/25/17 7:23 AM, Michal Hocko wrote:
> On Thu 21-09-17 06:38:50, Yang Shi wrote:
>> Recently we ran into a oom issue, kernel panic due to no killable process.
>> The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump doesn't capture vmcore due to some reason.
>>
>> So, it may sound better to capture unreclaimable slab info in oom message when kernel panic to aid trouble shooting and cover the corner case.
>> Since kernel already panic, so capturing more information sounds worthy and doesn't bother normal oom killer.
>>
>> With the patchset, tools/vm/slabinfo has a new option, "-U", to show unreclaimable slab only.
>>
>> And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in oom killer message.
> 
> Well, I do undestand that this _might_ be useful but it also might
> generates a _lot_ of output. The oom report can be quite verbose already
> so is this something we want to have enabled by default?

The uneclaimable slub message will be just printed out when kernel panic 
(no killable process or panic_on_oom is set). So, it will not bother 
normal oom. Since kernel is already panic, so it might be preferred to 
have more information reported.

We definitely can add a proc knob to control it if we want to disable 
the message even if when kernel panic.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
