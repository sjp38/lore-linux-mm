Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDE36B025E
	for <linux-mm@kvack.org>; Mon,  9 May 2016 09:34:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d62so414922798iof.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 06:34:11 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0103.outbound.protection.outlook.com. [157.56.112.103])
        by mx.google.com with ESMTPS id 38si12191323otf.111.2016.05.09.06.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 May 2016 06:34:10 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <573065BD.2020708@virtuozzo.com>
 <20E775CA4D599049A25800DE5799F6DD1F627919@G4W3225.americas.hpqcorp.net>
 <57308A20.2050501@virtuozzo.com>
 <CACT4Y+apwYi6FHo9d_ZQe109Q-A0OfF7dSTopE0FZwO07j6-Xw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <573091CD.4080503@virtuozzo.com>
Date: Mon, 9 May 2016 16:34:05 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+apwYi6FHo9d_ZQe109Q-A0OfF7dSTopE0FZwO07j6-Xw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>, "glider@google.com" <glider@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 05/09/2016 04:20 PM, Dmitry Vyukov wrote:
> On Mon, May 9, 2016 at 3:01 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 05/09/2016 02:35 PM, Luruo, Kuthonuzo wrote:
>>>
>>> This patch with atomic bit op is similar in spirit to v1 except that it increases metadata size.
>>>
>>
>> I don't think that this is a big deal. That will slightly increase size of objects <= (128 - 32) bytes.
>> And if someone think otherwise, we can completely remove 'alloc_size'
>> (we use it only to print size in report - not very useful).
> 
> 
> Where did 128 come from?
> We now should allocate only 32 bytes for 16-byte user object. If not,
> there is something to fix.
> 

I just said this wrong. I mean that the patch increases size of objects that have object_size <= (128 - 32).
For bigger objects, the new 'struct kasan_[alloc,free]_meta' still fits into optimal redzone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
