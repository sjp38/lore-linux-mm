Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42D496B0260
	for <linux-mm@kvack.org>; Mon,  9 May 2016 09:20:35 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so86137588lfc.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 06:20:35 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id o92si18365357lfg.131.2016.05.09.06.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 06:20:33 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id j8so199109458lfd.2
        for <linux-mm@kvack.org>; Mon, 09 May 2016 06:20:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57308A20.2050501@virtuozzo.com>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <573065BD.2020708@virtuozzo.com> <20E775CA4D599049A25800DE5799F6DD1F627919@G4W3225.americas.hpqcorp.net>
 <57308A20.2050501@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 May 2016 15:20:13 +0200
Message-ID: <CACT4Y+apwYi6FHo9d_ZQe109Q-A0OfF7dSTopE0FZwO07j6-Xw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>, "glider@google.com" <glider@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 9, 2016 at 3:01 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 05/09/2016 02:35 PM, Luruo, Kuthonuzo wrote:
>>
>> This patch with atomic bit op is similar in spirit to v1 except that it increases metadata size.
>>
>
> I don't think that this is a big deal. That will slightly increase size of objects <= (128 - 32) bytes.
> And if someone think otherwise, we can completely remove 'alloc_size'
> (we use it only to print size in report - not very useful).


Where did 128 come from?
We now should allocate only 32 bytes for 16-byte user object. If not,
there is something to fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
