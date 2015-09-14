Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7326F6B0266
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 10:12:23 -0400 (EDT)
Received: by qgx61 with SMTP id 61so115691253qgx.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:12:23 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id c61si12149733qga.112.2015.09.14.07.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 07:12:22 -0700 (PDT)
Received: by qkcf65 with SMTP id f65so58458547qkc.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:12:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F6D356.5000106@suse.cz>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<55F6D356.5000106@suse.cz>
Date: Mon, 14 Sep 2015 16:12:22 +0200
Message-ID: <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Sep 14, 2015 at 4:01 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 09/14/2015 03:49 PM, Vitaly Wool wrote:
>>
>> While using ZRAM on a small RAM footprint devices, together with
>> KSM,
>> I ran into several occasions when moving pages from compressed swap back
>> into the "normal" part of RAM caused significant latencies in system
>
>
> I'm sure Minchan will want to hear the details of that :)
>
>> operation. By using zbud I lose in compression ratio but gain in
>> determinism, lower latencies and lower fragmentation, so in the coming
>
>
> I doubt the "lower fragmentation" part given what I've read about the design of zbud and zsmalloc?

As it turns out, I see more cases of compaction kicking in and
significantly more compact_stalls with zsmalloc.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
