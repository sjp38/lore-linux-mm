Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id E9B3A6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:54:50 -0400 (EDT)
Received: by qkda128 with SMTP id a128so65189133qkd.3
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 00:54:50 -0700 (PDT)
Received: from bgp253.corp-email.cn (bgp253.corp-email.cn. [112.65.243.253])
        by mx.google.com with ESMTPS id l62si37436780qge.55.2015.08.26.00.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 00:54:50 -0700 (PDT)
Subject: Re: [PATCH] Memory hot added,The memory can not been added to movable
 zone
References: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
 <20150819165029.665b89d7ab3228185460172c@linux-foundation.org>
 <55D57071.1080901@inspur.com> <55db6d6d.82d1370a.dd0ff.6055@mx.google.com>
 <55DC4294.2020407@inspur.com> <55DC4DC3.30509@suse.cz>
 <55DD0A1B.4090700@inspur.com> <55DD58D8.1090508@suse.cz>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <55DD705F.7000308@inspur.com>
Date: Wed, 26 Aug 2015 15:53:03 +0800
MIME-Version: 1.0
In-Reply-To: <55DD58D8.1090508@suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>



a?? 2015/8/26 14:12, Vlastimil Babka a??e??:
> On 26.8.2015 2:36, Changsheng Liu wrote:
>>
>> a?? 2015/8/25 19:13, Vlastimil Babka a??e??:
>>> On 08/25/2015 12:25 PM, Changsheng Liu wrote:
>>>> Thanks very much for your review, I can move the memory from normal zone
>>>> to movable zone succesfully.
>>>> And thank you for let me understand the memory mechanism better.
>>>> a?? 2015/8/25 3:15, Yasuaki Ishimatsu a??e??:
>>> So you agree to drop the patch from -mm?
>>       The system add memory to normal zone defaultly so that it can be
>> used by kernel and then we can not move the memory to movable zone.
>>       The patch can add the memory to movable zone directlly.
> I thought that you confirmed that the following works?
> echo online_movable > /sys/devices/system/memory/memoryXXX/state
>
> If you want it to be the default, there's the node_movable kernel boot option.
> Does it work for you?
> .
     It does not work when memory is hot added.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
