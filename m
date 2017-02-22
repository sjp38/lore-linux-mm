Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA326B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 03:27:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so1652168wmd.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:27:12 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id p28si1655136wma.146.2017.02.22.00.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 00:27:11 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id i186so759653wmf.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:27:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170222001603.162a1209efc06b6c46556383@linux-foundation.org>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
 <20170222071915.GE9967@balbir.ozlabs.ibm.com> <20170222001603.162a1209efc06b6c46556383@linux-foundation.org>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 22 Feb 2017 19:27:10 +1100
Message-ID: <CAKTCnzmA3B4r956GXv8UKxmCTqxdt=uoXr4KBbvzzfc=ciz03A@mail.gmail.com>
Subject: Re: [HMM v17 00/14] HMM (Heterogeneous Memory Management) v17
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, haren@linux.vnet.ibm.com

On Wed, Feb 22, 2017 at 7:16 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 22 Feb 2017 18:19:15 +1100 Balbir Singh <bsingharora@gmail.com> wrote:
>
>> On Fri, Jan 27, 2017 at 05:52:07PM -0500, J__r__me Glisse wrote:
>> > Cliff note: HMM offers 2 things (each standing on its own). First
>> > it allows to use device memory transparently inside any process
>> > without any modifications to process program code. Second it allows
>> > to mirror process address space on a device.
>> >
>> > Change since v16:
>> >   - move HMM unaddressable device memory to its own radix tree and
>> >     thus find_dev_pagemap() will no longer return HMM dev_pagemap
>> >   - rename HMM migration helper (drop the prefix) and make them
>> >     completely independent of HMM
>> >
>> >     Migration can now be use to implement thing like multi-threaded
>> >     copy or make use of specific memory allocator for destination
>> >     memory.
>> >
>> > Work is under way to use this feature inside nouveau (the upstream
>> > open source driver for NVidia GPU) either 411 or 4.12 timeframe.
>> > But this patchset have been otherwise tested with the close source
>> > driver for NVidia GPU and thus we are confident it works and allow
>> > to use the hardware for seamless interaction between CPU and GPU
>> > in common address space of a process.
>> >
>> > I also discussed the features with other company and i am confident
>> > it can be use on other, yet, unrelease hardware.
>> >
>> > Please condiser applying for 4.11
>> >
>>
>> Andrew, do we expect to get this in 4.11/4.12? Just curious.
>>
>
> I'll be taking a serious look after -rc1.
>
> The lack of reviewed-by, acked-by and tested-by is a concern.  It's
> rather odd for a patchset in the 17th revision!  What's up with that?
>
> Have you reviewed or tested the patches?

I reviewed v14/15 of the patches. Aneesh reviewed some versions as
well. I know a few people who tested a small subset of the patches,
I'll get them to report back as well. I think John Hubbard has been
testing iterations as well. CC'ing other interested people as well

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
