Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 04A426B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 02:12:44 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so35459288wid.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 23:12:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si7970434wiz.8.2015.08.25.23.12.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 23:12:42 -0700 (PDT)
Subject: Re: [PATCH] Memory hot added,The memory can not been added to movable
 zone
References: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
 <20150819165029.665b89d7ab3228185460172c@linux-foundation.org>
 <55D57071.1080901@inspur.com> <55db6d6d.82d1370a.dd0ff.6055@mx.google.com>
 <55DC4294.2020407@inspur.com> <55DC4DC3.30509@suse.cz>
 <55DD0A1B.4090700@inspur.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DD58D8.1090508@suse.cz>
Date: Wed, 26 Aug 2015 08:12:40 +0200
MIME-Version: 1.0
In-Reply-To: <55DD0A1B.4090700@inspur.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On 26.8.2015 2:36, Changsheng Liu wrote:
> 
> 
> a?? 2015/8/25 19:13, Vlastimil Babka a??e??:
>> On 08/25/2015 12:25 PM, Changsheng Liu wrote:
>>> Thanks very much for your review, I can move the memory from normal zone
>>> to movable zone succesfully.
>>> And thank you for let me understand the memory mechanism better.
>>> a?? 2015/8/25 3:15, Yasuaki Ishimatsu a??e??:
>>
>> So you agree to drop the patch from -mm?
>      The system add memory to normal zone defaultly so that it can be 
> used by kernel and then we can not move the memory to movable zone.
>      The patch can add the memory to movable zone directlly.

I thought that you confirmed that the following works?
echo online_movable > /sys/devices/system/memory/memoryXXX/state

If you want it to be the default, there's the node_movable kernel boot option.
Does it work for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
