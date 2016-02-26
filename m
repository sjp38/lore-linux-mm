Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id D66C56B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:08:35 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id dm2so82800230obb.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:08:35 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id w133si11956562oif.121.2016.02.26.09.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 09:08:35 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id m82so65961826oif.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:08:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGytHfMaX8VzgWX-PBXcH8aO0G82L3ZX5dSNa=trBFVsyg@mail.gmail.com>
References: <1456461361-4345-1-git-send-email-iamjoonsoo.kim@lge.com>
	<CAPAsAGytHfMaX8VzgWX-PBXcH8aO0G82L3ZX5dSNa=trBFVsyg@mail.gmail.com>
Date: Sat, 27 Feb 2016 02:08:35 +0900
Message-ID: <CAAmzW4MH3EmnXCmz-n=qYGPXZhrajVYOCkNw_0XvhnOK=T9-Ng@mail.gmail.com>
Subject: Re: [PATCH v2] mm/slub: support left redzone
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-27 1:47 GMT+09:00 Andrey Ryabinin <ryabinin.a.a@gmail.com>:
> 2016-02-26 7:36 GMT+03:00  <js1304@gmail.com>:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> SLUB already has a redzone debugging feature.  But it is only positioned
>> at the end of object (aka right redzone) so it cannot catch left oob.
>> Although current object's right redzone acts as left redzone of next
>> object, first object in a slab cannot take advantage of this effect.  This
>> patch explicitly adds a left red zone to each object to detect left oob
>> more precisely.
>>
>
> So why for each object? Can't we have left redzone only for the first object?

It's easier to implement and less code churn than allowing left redzone
only for the first object.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
