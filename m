Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4A36B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 23:00:25 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id rd18so21132432iec.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 20:00:25 -0800 (PST)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id t5si11297540igm.14.2015.02.03.20.00.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 20:00:23 -0800 (PST)
Received: by mail-ie0-f169.google.com with SMTP id rl12so30379167iec.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 20:00:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150203150408.1913cf209c4552683cca8b35@linux-foundation.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-3-git-send-email-a.ryabinin@samsung.com>
	<20150203150408.1913cf209c4552683cca8b35@linux-foundation.org>
Date: Wed, 4 Feb 2015 08:00:18 +0400
Message-ID: <CADmp3APLy0qg+qubdpPTFKSot6xyfAoEVNP4zXhZnGAfEAWniw@mail.gmail.com>
Subject: Re: [PATCH v11 02/19] Add kernel address sanitizer infrastructure.
From: Andrey Konovalov <adech.fo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

Sorry I didn't reply earlier.

Signed-off-by: Andrey Konovalov <adech.fo@gmail.com>

(Repeating in plain text.)

On Wed, Feb 4, 2015 at 2:04 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 03 Feb 2015 20:42:55 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>
>>
>> ...
>>
>> Based on work by Andrey Konovalov <adech.fo@gmail.com>
>>
>
> We still don't have Andrey Konovalov's signoff?  As it stands we're
> taking some of his work and putting it into Linux without his
> permission.
>
>> ...
>>
>> --- /dev/null
>> +++ b/mm/kasan/kasan.c
>> @@ -0,0 +1,302 @@
>> +/*
>> + * This file contains shadow memory manipulation code.
>> + *
>> + * Copyright (c) 2014 Samsung Electronics Co., Ltd.
>> + * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
>> + *
>> + * Some of code borrowed from https://github.com/xairy/linux by
>> + *        Andrey Konovalov <adech.fo@gmail.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + *
>> + */
>
> https://code.google.com/p/thread-sanitizer/ is BSD licensed and we're
> changing it to GPL.
>
> I don't do the lawyer stuff, but this is all a bit worrisome.  I'd be a
> lot more comfortable with that signed-off-by, please.
>
>



-- 
Sincerely,
Andrey Konovalov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
