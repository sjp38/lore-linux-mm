Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id A9BF26B026A
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 10:14:28 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so68070166lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:14:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si18929466wju.16.2015.09.14.07.14.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 07:14:27 -0700 (PDT)
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <55F6D356.5000106@suse.cz>
 <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F6D641.6010209@suse.cz>
Date: Mon, 14 Sep 2015 16:14:25 +0200
MIME-Version: 1.0
In-Reply-To: <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 09/14/2015 04:12 PM, Vitaly Wool wrote:
> On Mon, Sep 14, 2015 at 4:01 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 09/14/2015 03:49 PM, Vitaly Wool wrote:
>>>
>>> While using ZRAM on a small RAM footprint devices, together with
>>> KSM,
>>> I ran into several occasions when moving pages from compressed swap back
>>> into the "normal" part of RAM caused significant latencies in system
>>
>>
>> I'm sure Minchan will want to hear the details of that :)
>>
>>> operation. By using zbud I lose in compression ratio but gain in
>>> determinism, lower latencies and lower fragmentation, so in the coming
>>
>>
>> I doubt the "lower fragmentation" part given what I've read about the design of zbud and zsmalloc?
>
> As it turns out, I see more cases of compaction kicking in and
> significantly more compact_stalls with zsmalloc.

Interesting, I thought that zsmalloc doesn't need contiguous high-order 
pages.

> ~vitaly
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
