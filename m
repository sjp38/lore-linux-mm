Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4007F6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:26:53 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id i13so2901967veh.29
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:26:52 -0700 (PDT)
Received: from mail-ve0-x22c.google.com (mail-ve0-x22c.google.com [2607:f8b0:400c:c01::22c])
        by mx.google.com with ESMTPS id ya3si2981133vec.105.2014.06.19.14.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 14:26:52 -0700 (PDT)
Received: by mail-ve0-f172.google.com with SMTP id jz11so2915529veb.3
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:26:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140619140651.c3c49cf70a7f349db595239e@linux-foundation.org>
References: <1403193138-7677-1-git-send-email-a.ryabinin@samsung.com>
	<alpine.DEB.2.11.1406191555110.4002@gentwo.org>
	<20140619140651.c3c49cf70a7f349db595239e@linux-foundation.org>
Date: Fri, 20 Jun 2014 01:26:52 +0400
Message-ID: <CAPAsAGyYW13VnSKMDZRWXMA3BRefP+wsnqGVbHHJ2Qfk9kFy9A@mail.gmail.com>
Subject: Re: [PATCH] mm: slub: SLUB_DEBUG=n: use the same alloc/free hooks as
 for SLUB_DEBUG=y
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@gentwo.org>, Andrey Ryabinin <a.ryabinin@samsung.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>

2014-06-20 1:06 GMT+04:00 Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 19 Jun 2014 15:56:56 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:
>
>> On Thu, 19 Jun 2014, Andrey Ryabinin wrote:
>>
>> > I see no reason why calls to other debugging subsystems (LOCKDEP,
>> > DEBUG_ATOMIC_SLEEP, KMEMCHECK and FAILSLAB) are hidden under SLUB_DEBUG.
>> > All this features should work regardless of SLUB_DEBUG config, as all of
>> > them already have own Kconfig options.
>>
>> The reason for hiding this under SLUB_DEBUG was to have some way to
>> guarantee that no instrumentations is added if one does not want it.
>>
>> SLUB_DEBUG is on by default and builds in a general
>> debugging framework that can be enabled at runtime in
>> production kernels.
>>
>> If someone disabled SLUB_DEBUG then that has been done with the intend to
>> get a minimal configuration.
>>
>
> (Is that a nack?)
>
> The intent seems to have been implemented strangely.  Perhaps it would
> be clearer and more conventional to express all this using Kconfig
> logic.
>

Seems I forgot to mention in commit message that the main intent of
this patch is not to fix some weird configurations, which nobody uses,
but a simple cleanup. Just look at diffstat (36 insertions vs 61
deletions). And someone who is going to add more debug hooks in future
will have to do it only in one place.

> Anyway, if we plan to leave the code as-is then can we please get a
> comment in there so the next person is not similarly confused?
>



-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
