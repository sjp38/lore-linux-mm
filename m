Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCA386B0266
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 12:44:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p2so21711782pfk.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 09:44:50 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id t8si7311447pfh.547.2017.10.09.09.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 09:44:49 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
 <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
 <20171006093702.3ca2p6ymyycwfgbk@dhcp22.suse.cz>
 <ff7e0d92-0f12-46fa-dbc7-79c556ffb7c2@alibaba-inc.com>
 <20171009063316.qjmunbabyr2nzh52@dhcp22.suse.cz>
 <20171009063642.nykrjazifntrj5zz@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <e5dea13b-0b20-d268-970c-c06dc9095503@alibaba-inc.com>
Date: Tue, 10 Oct 2017 00:44:21 +0800
MIME-Version: 1.0
In-Reply-To: <20171009063642.nykrjazifntrj5zz@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/8/17 11:36 PM, Michal Hocko wrote:
> On Mon 09-10-17 08:33:16, Michal Hocko wrote:
>> On Sat 07-10-17 00:37:55, Yang Shi wrote:
>>>
>>>
>>> On 10/6/17 2:37 AM, Michal Hocko wrote:
>>>> On Thu 05-10-17 05:29:10, Yang Shi wrote:
>> [...]
>>>>> +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>>>>> +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
>>>>> +			continue;
>>>>> +
>>>>> +		memset(&sinfo, 0, sizeof(sinfo));
>>>>
>>>> why do you zero out the structure. All the fields you are printing are
>>>> filled out in get_slabinfo.
>>>
>>> No special reason, just wipe out the potential stale data on the stack.
>>
>> Do not add code that has no meaning. The OOM killer is a slow path but
>> that doesn't mean we should throw spare cycles out of the window.
> 
> With this fixed and the compile fix [1] folded, feel free to add my
> Acked-by: Michal Hocko <mhocko@suse.com>

Sure, thanks. I think I'd better to send out a new version so that 
Andrew could replace them easily.

Yang

> 
> [1] http://lkml.kernel.org/r/1507492085-42264-1-git-send-email-yang.s@alibaba-inc.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
