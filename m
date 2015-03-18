Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 59E036B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 01:07:18 -0400 (EDT)
Received: by oier21 with SMTP id r21so27410295oie.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 22:07:18 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id r4si8673952oej.1.2015.03.17.22.07.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 22:07:17 -0700 (PDT)
Received: by oigv203 with SMTP id v203so27323722oig.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 22:07:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150317145823.3213cba4dc629c716df0fdd9@linux-foundation.org>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
	<1426248777-19768-2-git-send-email-r.peniaev@gmail.com>
	<20150317045608.GA22902@js1304-P5Q-DELUXE>
	<CACZ9PQWbZ7m1LQLs+bOjtHNsKDmSZmkjAH8vmnc2VBgCLDdhDg@mail.gmail.com>
	<20150317072952.GA23143@js1304-P5Q-DELUXE>
	<CACZ9PQUO4cBsTdO37n4UWeHk=26g_WqWo-cVsDCf8E1gkq2Zkg@mail.gmail.com>
	<20150317145823.3213cba4dc629c716df0fdd9@linux-foundation.org>
Date: Wed, 18 Mar 2015 14:07:17 +0900
Message-ID: <CAAmzW4M2EDFX7XsK7kgwEaGgZBBnVb97rGHwinaNLt8Q==TP1w@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space
 caused by vm_map_ram allocator
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Peniaev <r.peniaev@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

2015-03-18 6:58 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> On Tue, 17 Mar 2015 17:22:46 +0900 Roman Peniaev <r.peniaev@gmail.com> wrote:
>
>> >> My second patch fixes this problem.
>> >> I occupy the block on allocation and avoid jumping to the search loop.
>> >
>> > I'm not sure that this fixes above case.
>> > 'vm_map_ram (3) * 85' means 85 times vm_map_ram() calls.
>> >
>> > First vm_map_ram(3) caller could get benefit from your second patch.
>> > But, second caller and the other callers in each iteration could not
>> > get benefit and should iterate whole list to find suitable free block,
>> > because this free block is put to the tail of the list. Am I missing
>> > something?
>>
>> You are missing the fact that we occupy blocks in 2^n.
>> So in your example 4 page slots will be occupied (order is 2), not 3.
>
> Could you please
>
> - update the changelogs so they answer the questions which Joonsoo
>   Kim and Gioh Kim asked
>
> - write a little in-kernel benchmark to test the scenario which
>   Joonsoo described and include the before and after timing results in
>   the changelogs

I misunderstand before and my scenario isn't possible. So, I'm fine with
current patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
